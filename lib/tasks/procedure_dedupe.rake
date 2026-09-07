require 'fileutils'
require 'yaml'

namespace :procedure do
  desc "Deduplicate procedure rows. Use DIRECTION=up to apply and DIRECTION=down to restore from the backup."
  task :dedupe => :environment do
    direction = (ENV['DIRECTION'] || 'up').to_s
    backup_path = Pathname.new(ENV['BACKUP_PATH'] || Rails.root.join('tmp', 'procedure_dedupe_backup.yml'))

    mappings = {
      174 => 61,   # hysterectomy whitespace duplicate
      175 => 77,   # glansplasty whitespace duplicate
      250 => 96,   # vaginectomy whitespace duplicate
      311 => 170,  # scrotoplasty whitespace duplicate
      249 => 306   # lapascopic hysterectomy typo -> laparoscopic hysterectomy
    }

    case direction
    when 'up'
      if backup_path.exist?
        abort "Backup already exists at #{backup_path}; move it aside or pass BACKUP_PATH to a new file before running again."
      end

      source_ids = mappings.keys
      backup = {
        'created_at' => Time.now.utc.iso8601,
        'mappings' => mappings,
        'procedures' => Procedure.where(id: source_ids).order(:id).map(&:attributes),
        'pins' => Pin.where(procedure_id: source_ids).pluck(:id, :procedure_id),
        'skills' => Skill.where(procedure_id: source_ids).pluck(:id, :procedure_id),
        'comments' => Comment.where(commentable_type: 'Procedure', commentable_id: source_ids).pluck(:id, :commentable_id, :commentable_type)
      }

      backup_path.dirname.mkpath
      File.write(backup_path, YAML.dump(backup))

      ActiveRecord::Base.transaction do
        mappings.each do |from_id, to_id|
          Pin.where(procedure_id: from_id).update_all(procedure_id: to_id)
          Skill.where(procedure_id: from_id).update_all(procedure_id: to_id)
          Comment.where(commentable_type: 'Procedure', commentable_id: from_id).update_all(commentable_id: to_id)
          Procedure.where(id: from_id).delete_all
        end
      end

      Pin.where(id: backup['pins'].map(&:first)).find_each do |pin|
        pin.__elasticsearch__.index_document
      end

      puts "Applied procedure dedupe mappings: #{mappings.inspect}"
      puts "Backup written to #{backup_path}"
    when 'down'
      abort "Backup file not found at #{backup_path}" unless backup_path.exist?

      backup = YAML.load_file(backup_path)
      mappings = (backup['mappings'] || {}).transform_keys(&:to_i).transform_values(&:to_i)
      procedures = backup['procedures'] || []
      pins = backup['pins'] || []
      skills = backup['skills'] || []
      comments = backup['comments'] || []

      ActiveRecord::Base.transaction do
        procedures.sort_by { |attrs| attrs['id'].to_i }.each do |attrs|
          attrs = attrs.stringify_keys
          attrs['id'] = attrs['id'].to_i
          existing = Procedure.where(id: attrs['id']).first
          next if existing.present?

          procedure = Procedure.new(
            id: attrs['id'],
            name: attrs['name'],
            body_type: attrs['body_type'],
            gender: attrs['gender']
          )
          procedure.created_at = attrs['created_at']
          procedure.updated_at = attrs['updated_at']
          procedure.save!(validate: false)
        end

        pins.each do |pin_id, procedure_id|
          Pin.where(id: pin_id).update_all(procedure_id: procedure_id)
        end

        skills.each do |skill_id, procedure_id|
          Skill.where(id: skill_id).update_all(procedure_id: procedure_id)
        end

        comments.each do |comment_id, commentable_id, commentable_type|
          Comment.where(id: comment_id).update_all(commentable_id: commentable_id, commentable_type: commentable_type)
        end
      end

      puts "Restored procedure dedupe backup from #{backup_path}"
    else
      abort "Unknown DIRECTION=#{direction.inspect}. Use up or down."
    end
  end
end
