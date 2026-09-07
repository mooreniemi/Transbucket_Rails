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
      1301 => 1302   # Mcevenue spelling correction -> McEvenue
    }.reject { |from_id, to_id| from_id == to_id }

    case direction
    when 'up'
      if backup_path.exist?
        abort "Backup already exists at #{backup_path}; move it aside or pass BACKUP_PATH to a new file before running again."
      end

      source_ids = mappings.keys
      backup = {
        'created_at' => Time.now.utc.iso8601,
        'mappings' => mappings,
        'surgeons' => Surgeon.where(id: source_ids).order(:id).map(&:attributes),
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
      end

      Pin.where(id: backup['pins'].map(&:first)).find_each do |pin|
        pin.__elasticsearch__.index_document
      end

      puts "Applied surgeon dedupe mappings: #{mappings.inspect}"
      puts "Backup written to #{backup_path}"
    when 'down'
      abort "Backup file not found at #{backup_path}" unless backup_path.exist?

      backup = YAML.load_file(backup_path)
      surgeons = backup['surgeons'] || []
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

        pins.each do |pin_id, surgeon_id|
          Pin.where(id: pin_id).update_all(surgeon_id: surgeon_id)
        end

        skills.each do |skill_id, surgeon_id|
          Skill.where(id: skill_id).update_all(surgeon_id: surgeon_id)
        end
      end

      puts "Restored surgeon dedupe backup from #{backup_path}"
    else
      abort "Unknown DIRECTION=#{direction.inspect}. Use up or down."
    end
  end
end
