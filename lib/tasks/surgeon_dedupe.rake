require 'yaml'

namespace :surgeon do
  desc "Deduplicate surgeon rows. Use DIRECTION=up to apply and DIRECTION=down to restore from the backup."
  task :dedupe => :environment do
    direction = (ENV['DIRECTION'] || 'up').to_s
    backup_path = Pathname.new(ENV['BACKUP_PATH'] || Rails.root.join('tmp', 'surgeon_dedupe_backup.yml'))

    mappings = {
      1296 => 162,  # liedl, bernhard -> Bernhard Liedl
      1331 => 95,   # rumer whitespace duplicate
      1361 => 1211, # N/A placeholder duplicate
      1386 => 1369, # watt whitespace duplicate
      1583 => 1505, # hubalek whitespace duplicate
      1586 => 1577, # delucia whitespace duplicate
      1748 => 1747, # calder whitespace duplicate
      1804 => 1803, # kingsbury lowercase duplicate
      1808 => 196,   # Sterne whitespace duplicate
      1927 => 1745,  # Moscatiello whitespace duplicate
      2295 => 2293,  # Melikoglu whitespace duplicate
      2296 => 2293,  # Melikoglu whitespace duplicate
      1215 => 1214,  # Tarricone whitespace duplicate
      1130 => 1129,  # Picazo whitespace duplicate
      1138 => 1137,  # Kaweski whitespace duplicate
      1374 => 1373,  # Lemker whitespace duplicate
      1301 => 1302,  # Mcevenue spelling correction -> McEvenue
      1292 => 1068,  # Schenning -> Schennings (verified public spelling)
      2173 => 1074,   # Maude Belanger -> Maud Bélanger (verified public spelling)
      1257 => 1214,   # Tarrigone/Vicent -> Tarricone/Vicente (verified public spelling)
      1248 => 1247,   # Ethrington -> Etherington
      1317 => 1318,   # Johnathan -> Jonathan
      1630 => 1631,   # Jaqueline -> Jacqueline
      1734 => 1736,   # J Brian -> J. Brian
      1336 => 1258,   # Keyllo -> Kyllo (verified surgeon website)
      1353 => 1647,   # Philip Ruben -> Philip Rubin (verified surgeon websites)
      1379 => 1380    # Reesch -> Resch (verified surviving profile URL)
    }.reject { |from_id, to_id| from_id == to_id }

    canonical_updates = {
      1068 => { 'first_name' => 'Torgny', 'last_name' => 'Schennings' },
      1074 => { 'first_name' => 'Maud', 'last_name' => "B\u00e9langer" },
      1214 => { 'first_name' => 'Vicente', 'last_name' => 'Tarricone' },
      1247 => { 'first_name' => 'Linsey', 'last_name' => 'Etherington' },
      1318 => { 'first_name' => 'Jonathan', 'last_name' => 'Keith' },
      1631 => { 'first_name' => 'Jacqueline', 'last_name' => 'Wegge' },
      1736 => { 'first_name' => 'J. Brian', 'last_name' => 'Boyd' },
      1258 => { 'first_name' => 'Jeffrey', 'last_name' => 'Kyllo' },
      1647 => { 'first_name' => 'Philip', 'last_name' => 'Rubin' },
      1380 => { 'first_name' => 'Charlotte', 'last_name' => 'Resch' }
    }

    normalize = lambda do |value|
      value.to_s.strip.gsub(/\s+/, ' ').downcase
    end
    normalize_without_accents = lambda do |value|
      I18n.transliterate(normalize.call(value))
    end
    edit_distance = lambda do |left, right|
      distances = (0..right.length).to_a
      left.each_char.with_index(1) do |left_char, row|
        previous = distances[0]
        distances[0] = row
        right.each_char.with_index(1) do |right_char, column|
          current = distances[column]
          distances[column] = [
            distances[column] + 1,
            distances[column - 1] + 1,
            previous + (left_char == right_char ? 0 : 1)
          ].min
          previous = current
        end
      end
      distances[right.length]
    end

    case direction
    when 'report'
      groups = Surgeon.all.group_by do |surgeon|
        [normalize.call(surgeon.last_name), normalize.call(surgeon.first_name)]
      end
      duplicate_groups = groups.select { |_key, surgeons| surgeons.length > 1 }
      needs_normalization = Surgeon.all.select do |surgeon|
        [surgeon.first_name, surgeon.last_name].any? do |value|
          value.present? && value != value.strip.gsub(/\s+/, ' ')
        end
      end

      puts "Exact normalized duplicate groups: #{duplicate_groups.length}"
      duplicate_groups.each do |key, surgeons|
        names = surgeons.map { |surgeon| "#{surgeon.id}: #{surgeon}" }.join(' | ')
        puts "#{key.join(', ')} -> #{names}"
      end
      accent_insensitive_groups = Surgeon.all.group_by do |surgeon|
        [normalize_without_accents.call(surgeon.last_name), normalize_without_accents.call(surgeon.first_name)]
      end.select { |_key, surgeons| surgeons.length > 1 }
      puts "Accent-insensitive duplicate candidates: #{accent_insensitive_groups.length}"
      accent_insensitive_groups.each do |key, surgeons|
        names = surgeons.map { |surgeon| "#{surgeon.id}: #{surgeon}" }.join(' | ')
        puts "#{key.join(', ')} -> #{names}"
      end
      fuzzy_candidates = []
      all_surgeons = Surgeon.all.to_a
      all_surgeons.each_with_index do |left, index|
        all_surgeons[(index + 1)..-1].to_a.each do |right|
          left_first = normalize_without_accents.call(left.first_name)
          right_first = normalize_without_accents.call(right.first_name)
          left_last = normalize_without_accents.call(left.last_name)
          right_last = normalize_without_accents.call(right.last_name)
          next if [left_first, right_first, left_last, right_last].any?(&:blank?)
          last_distance = edit_distance.call(left_last, right_last)
          first_distance = edit_distance.call(left_first, right_first)
          next unless last_distance <= 1 && first_distance <= 1
          next if left_first == right_first && left_last == right_last

          fuzzy_candidates << [left, right, first_distance, last_distance]
        end
      end
      puts "Likely typo/name-variant candidates: #{fuzzy_candidates.length}"
      fuzzy_candidates.each do |left, right, first_distance, last_distance|
        puts "#{left.id}: #{left} | #{right.id}: #{right} [first #{first_distance}, last #{last_distance}]"
      end
      puts "Names needing whitespace normalization: #{needs_normalization.length}"
      needs_normalization.each do |surgeon|
        puts "#{surgeon.id}: #{surgeon.last_name.inspect}, #{surgeon.first_name.inspect}"
      end
    when 'up'
      if backup_path.exist?
        abort "Backup already exists at #{backup_path}; move it aside or pass BACKUP_PATH to a new file before running again."
      end

      source_ids = mappings.keys
      backup = {
        'created_at' => Time.now.utc.iso8601,
        'mappings' => mappings,
        'surgeons' => Surgeon.where(id: source_ids).order(:id).map(&:attributes),
        'target_surgeons' => Surgeon.where(id: mappings.values.uniq).order(:id).map(&:attributes),
        'pins' => Pin.where(surgeon_id: source_ids).pluck(:id, :surgeon_id),
        'skills' => Skill.where(surgeon_id: source_ids).pluck(:id, :surgeon_id)
      }

      backup_path.dirname.mkpath
      File.write(backup_path, YAML.dump(backup))

      ActiveRecord::Base.transaction do
        mappings.each do |from_id, to_id|
          Pin.where(surgeon_id: from_id).update_all(surgeon_id: to_id)
          Skill.where(surgeon_id: from_id).update_all(surgeon_id: to_id)
          Surgeon.where(id: from_id).delete_all
        end
        canonical_updates.each do |surgeon_id, attributes|
          Surgeon.where(id: surgeon_id).update_all(attributes)
        end
      end

      if ENV.fetch('INDEX', '1') != '0'
        Pin.where(id: backup['pins'].map(&:first)).find_each do |pin|
          pin.__elasticsearch__.index_document
        end
      end

      puts "Applied surgeon dedupe mappings: #{mappings.inspect}"
      puts "Backup written to #{backup_path}"
    when 'reindex'
      abort "Backup file not found at #{backup_path}" unless backup_path.exist?
      backup = YAML.respond_to?(:unsafe_load_file) ? YAML.unsafe_load_file(backup_path) : YAML.load_file(backup_path)
      pin_ids = (backup['pins'] || []).map(&:first)
      Pin.where(id: pin_ids).find_each do |pin|
        pin.__elasticsearch__.index_document
      end
      puts "Reindexed #{pin_ids.length} affected pins from #{backup_path}"
    when 'down'
      abort "Backup file not found at #{backup_path}" unless backup_path.exist?

      backup = YAML.respond_to?(:unsafe_load_file) ? YAML.unsafe_load_file(backup_path) : YAML.load_file(backup_path)
      surgeons = backup['surgeons'] || []
      target_surgeons = backup['target_surgeons'] || []
      pins = backup['pins'] || []
      skills = backup['skills'] || []

      ActiveRecord::Base.transaction do
        surgeons.sort_by { |attrs| attrs['id'].to_i }.each do |attrs|
          attrs = attrs.stringify_keys
          attrs['id'] = attrs['id'].to_i
          existing = Surgeon.where(id: attrs['id']).first
          next if existing.present?

          surgeon = Surgeon.new(attrs)
          surgeon.created_at = attrs['created_at']
          surgeon.updated_at = attrs['updated_at']
          surgeon.save!(validate: false)
        end

        target_surgeons.each do |attrs|
          Surgeon.where(id: attrs['id']).update_all(attrs.stringify_keys.except('id'))
        end

        pins.each do |pin_id, surgeon_id|
          Pin.where(id: pin_id).update_all(surgeon_id: surgeon_id)
        end

        skills.each do |skill_id, surgeon_id|
          Skill.where(id: skill_id).update_all(surgeon_id: surgeon_id)
        end
      end

      puts "Restored surgeon dedupe backup from #{backup_path}"
    else
      abort "Unknown DIRECTION=#{direction.inspect}. Use report, up, reindex, or down."
    end
  end
end

namespace :surgeon do
  desc "Normalize surgeon whitespace and reviewed lowercase names. Use DIRECTION=up to apply and DIRECTION=down to restore."
  task :normalize_names => :environment do
    direction = (ENV['DIRECTION'] || 'report').to_s
    backup_path = Pathname.new(ENV['BACKUP_PATH'] || Rails.root.join('tmp', 'surgeon_name_normalization_backup.yml'))
    lowercase_corrections = {
      1205 => { 'first_name' => 'Patricia', 'last_name' => 'Sandholm' },
      1232 => { 'first_name' => 'Debra', 'last_name' => 'Johnson' },
      1237 => { 'first_name' => 'Lisa', 'last_name' => 'DeFrancisco' },
      1274 => { 'first_name' => 'Philip', 'last_name' => 'Iorianni' },
      1505 => { 'first_name' => 'Michael', 'last_name' => 'Hubalek' },
      1509 => { 'first_name' => 'Edward', 'last_name' => 'Lee' },
      1737 => { 'first_name' => 'Rajiv', 'last_name' => 'Chandawarkar' },
      1760 => { 'first_name' => 'Kyle', 'last_name' => 'Belek' },
      1826 => { 'first_name' => 'Isıl', 'last_name' => 'Demir' },
      2171 => { 'first_name' => 'Dany', 'last_name' => 'Hanna' }
    }
    normalize = lambda { |value| value.to_s.strip.gsub(/\s+/, ' ') }
    changes = Surgeon.all.each_with_object({}) do |surgeon, result|
      proposed = {
        'first_name' => normalize.call(surgeon.first_name),
        'last_name' => normalize.call(surgeon.last_name)
      }
      proposed.merge!(lowercase_corrections[surgeon.id]) if lowercase_corrections[surgeon.id]
      result[surgeon.id] = proposed if proposed['first_name'] != surgeon.first_name || proposed['last_name'] != surgeon.last_name
    end

    case direction
    when 'report'
      puts "Surgeon names needing normalization: #{changes.length}"
      changes.each do |surgeon_id, proposed|
        surgeon = Surgeon.find(surgeon_id)
        puts "#{surgeon_id}: #{surgeon.first_name.inspect}, #{surgeon.last_name.inspect} -> #{proposed['first_name'].inspect}, #{proposed['last_name'].inspect}"
      end
    when 'up'
      abort "Backup already exists at #{backup_path}; pass a new BACKUP_PATH before running again." if backup_path.exist?
      backup = {
        'created_at' => Time.now.utc.iso8601,
        'surgeons' => Surgeon.where(id: changes.keys).order(:id).map(&:attributes)
      }
      backup_path.dirname.mkpath
      File.write(backup_path, YAML.dump(backup))
      ActiveRecord::Base.transaction do
        changes.each do |surgeon_id, attributes|
          Surgeon.where(id: surgeon_id).update_all(attributes.merge('updated_at' => Time.current))
        end
      end
      puts "Normalized #{changes.length} surgeon names"
      puts "Backup written to #{backup_path}"
    when 'down'
      abort "Backup file not found at #{backup_path}" unless backup_path.exist?
      backup = YAML.respond_to?(:unsafe_load_file) ? YAML.unsafe_load_file(backup_path) : YAML.load_file(backup_path)
      ActiveRecord::Base.transaction do
        (backup['surgeons'] || []).each do |attributes|
          attributes = attributes.stringify_keys
          Surgeon.where(id: attributes['id']).update_all(attributes.except('id'))
        end
      end
      puts "Restored surgeon names from #{backup_path}"
    else
      abort "Unknown DIRECTION=#{direction.inspect}. Use report, up, or down."
    end
  end
end
