require 'yaml'

namespace :complications do
  SENTINEL_TAGS = %w[0 n/a na no none nothing no\ complications none\ so\ far none\ to\ date too.].freeze
  PLACEHOLDER_TAG_PATTERNS = [
    /\A(?:absolutely\s+)?none(?:\s+(?:so\s+far|as\s+of\s+yet|at\s+this\s+time|from\s+stage\s+\d+|in\s+this\s+stage|to\s+date|to\s+complain\s+about|yet|what[-\s]?so[-\s]?ever))?[.!\s:-]*\z/i,
    /\Anone[^a-z0-9]*\z/i,
    /\A(?:\d+\s+months?\s+postop|very\s+early\s+on)\s*[-:;]\s*none(?:\s+(?:so\s+far|yet))?[.!\s:-]*\z/i,
    /\A(?:aucune\s*\/\s*none|nulla\s*\/\s*nothing)\z/i,
    /\Ano\s+(?:issues?(?:\s+after\s+surgery)?|complications)[.!\s]*\z/i
  ].freeze
  CANONICAL_TAGS = {
    'hematoma' => 'hematoma',
    'haematoma' => 'hematoma',
    'fistula' => 'fistula',
    'fistulas' => 'fistula',
    'infection' => 'infection',
    'seroma' => 'seroma',
    'serroma' => 'seroma',
    'dogears' => 'dog ears',
    'hypertrophic scars' => 'hypertrophic scarring',
    'hypertrophic scarring' => 'hypertrophic scarring',
    'stricture' => 'stricture'
  }.freeze

  desc 'Remove placeholder complication tags and normalize reviewed aliases; use DIRECTION=down to restore the backup.'
  task cleanup: :environment do
    direction = (ENV['DIRECTION'] || 'up').to_s
    backup_path = Pathname.new(ENV['BACKUP_PATH'] || Rails.root.join('tmp', 'complication_cleanup_backup.yml'))
    dry_run = ENV['DRY_RUN'].to_s == '1'
    placeholder_only = ENV['PLACEHOLDER_ONLY'].to_s == '1'

    normalize = lambda do |tag|
      key = tag.to_s.strip.downcase
      next nil if SENTINEL_TAGS.include?(key) || PLACEHOLDER_TAG_PATTERNS.any? { |pattern| pattern.match?(key) }

      placeholder_only ? tag.to_s.strip : CANONICAL_TAGS.fetch(key, tag.to_s.strip)
    end

    case direction
    when 'up'
      changes = []
      Pin.find_each do |pin|
        before = pin.complications.pluck(:name)
        after = before.map { |tag| normalize.call(tag) }.compact.uniq
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
          pin.complication_list = change['after'].join(', ')
          pin.save!(validate: false)
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
          pin.complication_list = Array(change['before']).join(', ')
          pin.save!(validate: false)
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
