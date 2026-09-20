require 'yaml'
require 'csv'

namespace :complications do
  SENTINEL_TAGS = %w[0 n/a na no none nothing no\ complications none\ so\ far none\ to\ date too. too\ early].freeze
  PLACEHOLDER_TAG_PATTERNS = [
    /\A(?:absolutely\s+)?none(?:\s+(?:so\s+far|as\s+of\s+yet|at\s+this\s+time|from\s+stage\s+\d+|in\s+this\s+stage|to\s+date|to\s+complain\s+about|yet|what[-\s]?so[-\s]?ever))?[.!\s:-]*\z/i,
    /\Anone[^a-z0-9]*\z/i,
    /\A(?:\d+\s+months?\s+postop|very\s+early\s+on)\s*[-:;]\s*none(?:\s+(?:so\s+far|yet))?[.!\s:-]*\z/i,
    /\Aso\s+far\s+none[.!\s:-]*\z/i,
    /\A(?:aucune\s*\/\s*none|nulla\s*\/\s*nothing)\z/i,
    /\Ano\s+(?:issues?(?:\s+after\s+surgery)?|complications)[.!\s]*\z/i
  ].freeze
  CANONICAL_TAGS = {
    'hematoma on left side' => 'hematoma',
    'hematoma' => 'hematoma',
    'haematoma' => 'hematoma',
    'small hematoma' => 'hematoma',
    'fistula' => 'fistula',
    'fistulas' => 'fistula',
    'minor fistula' => 'fistula',
    'small fistulas' => 'fistula',
    'infection' => 'infection',
    'minor infection' => 'infection',
    'infection on right side' => 'infection',
    'seroma' => 'seroma',
    'serroma' => 'seroma',
    'small seroma' => 'seroma',
    'dogears' => 'dog ears',
    'keloid' => 'keloid',
    'keloids' => 'keloid',
    'keloid scarring' => 'keloid',
    'wound separation' => 'wound separation',
    'minor wound separation' => 'wound separation',
    'delayed wound healing on right nipple graft' => 'delayed wound healing',
    'hypertrophic scars' => 'hypertrophic scarring',
    'hypertrophic scarring' => 'hypertrophic scarring',
    'hyperpigmentation' => 'hyperpigmentation',
    'stricture' => 'stricture'
  }.freeze
  REMOVE_TAGS = [
    'rod placement adjustment and 2 pinhole fistulas corrected in same procedure',
    'none. only normal wound healing.'
  ].freeze

  desc 'Remove placeholder complication tags and normalize reviewed aliases; use DIRECTION=down to restore the backup.'
  task cleanup: :environment do
    direction = (ENV['DIRECTION'] || 'up').to_s
    backup_path = Pathname.new(ENV['BACKUP_PATH'] || Rails.root.join('tmp', 'complication_cleanup_backup.yml'))
    dry_run = ENV['DRY_RUN'].to_s == '1'
    placeholder_only = ENV['PLACEHOLDER_ONLY'].to_s == '1'
    mapping_path = ENV['MAPPING_PATH']

    reviewed_mapping = {}
    if mapping_path
      abort "Mapping file not found at #{mapping_path}" unless File.file?(mapping_path)

      CSV.foreach(mapping_path, headers: true, encoding: 'UTF-8') do |row|
        label = row['label'].to_s.strip.downcase
        suggestion = row['our_suggested_tags'].to_s.strip
        abort "Mapping file row has no label" if label.empty?
        abort "Mapping file still contains REVIEW for #{row['label'].inspect}" if suggestion.casecmp('REVIEW').zero?
        abort "Mapping file row has no decision for #{row['label'].inspect}" if suggestion.empty?

        reviewed_mapping[label] = if suggestion.casecmp('REMOVE').zero?
          nil
        else
          suggestion.split(';').map(&:strip).reject(&:empty?)
        end
      end
    end

    normalize = lambda do |tag|
      key = tag.to_s.strip.downcase
      next reviewed_mapping[key] if mapping_path && reviewed_mapping.key?(key)
      next nil if SENTINEL_TAGS.include?(key) || REMOVE_TAGS.include?(key) || PLACEHOLDER_TAG_PATTERNS.any? { |pattern| pattern.match?(key) }

      placeholder_only ? tag.to_s.strip : CANONICAL_TAGS.fetch(key, tag.to_s.strip)
    end

    replace_complications = lambda do |pin, names|
      pin.taggings.where(context: 'complications').delete_all
      pin.reload
      previous_strict_case_match = ActsAsTaggableOn.strict_case_match
      ActsAsTaggableOn.strict_case_match = true
      pin.complication_list = names.join(', ')
      pin.save!(validate: false)
    ensure
      ActsAsTaggableOn.strict_case_match = previous_strict_case_match
    end

    case direction
    when 'up'
      changes = []
      Pin.find_each do |pin|
        before = pin.complications.pluck(:name)
        after = before.flat_map { |tag| Array(normalize.call(tag)) }.compact.uniq
        next if before == after

        changes << {
          'pin_id' => pin.id,
          'user_id' => pin.user_id,
          'before' => before,
          'after' => after
        }
      end

      puts "Planned complication cleanup changes: #{changes.length}"
      if dry_run
        changes.first(20).each { |change| puts change.inspect }
        next
      end

      abort "Backup already exists at #{backup_path}; pass a new BACKUP_PATH before running again." if backup_path.exist?
      backup_path.dirname.mkpath
      File.write(backup_path, YAML.dump({ 'created_at' => Time.now.utc.iso8601, 'changes' => changes }))

      ActiveRecord::Base.transaction do
        changes.each do |change|
          pin = Pin.find(change['pin_id'])
          replace_complications.call(pin, change['after'])
        end
      end

      changes.each do |change|
        Pin.find(change['pin_id']).__elasticsearch__.index_document
      end
      puts "Applied #{changes.length} complication cleanups. Backup written to #{backup_path}."
    when 'down'
      abort "Backup file not found at #{backup_path}" unless backup_path.exist?

      backup = YAML.respond_to?(:unsafe_load_file) ? YAML.unsafe_load_file(backup_path) : YAML.load_file(backup_path)
      changes = backup['changes'] || []
      ActiveRecord::Base.transaction do
        changes.each do |change|
          pin = Pin.find(change['pin_id'])
          replace_complications.call(pin, Array(change['before']))
        end
      end

      changes.each do |change|
        Pin.find(change['pin_id']).__elasticsearch__.index_document
      end
      puts "Restored #{changes.length} complication changes from #{backup_path}."
    else
      abort "Unknown DIRECTION=#{direction.inspect}. Use up or down."
    end
  end
end
