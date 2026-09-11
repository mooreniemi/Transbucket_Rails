require 'fileutils'
require 'yaml'

namespace :procedure do
  desc "Import reviewed procedure display translations from locale catalogs. Use DIRECTION=down to restore the backup."
  task translations: :environment do
    direction = (ENV['DIRECTION'] || 'up').to_s
    backup_path = Pathname.new(ENV['BACKUP_PATH'] || Rails.root.join('tmp', 'procedure_translations_backup.yml'))
    locales = ApplicationController::SUPPORTED_LOCALES

    # These are full procedure names whose first locale alias is a reviewed
    # display translation. Search-only abbreviations remain search aliases.
    approved_names = [
      'phalloplasty',
      'vaginoplasty',
      'orchiectomy',
      'hysterectomy',
      'mastectomy',
      'breast augmentation',
      'facial feminization surgery',
      'urethral lengthening',
      'double incision with grafts',
      'periareolar mastectomy (keyhole)',
      'bilateral mastectomy',
      'metoidioplasty',
      "metoidioplasty ('meta')"
    ]

    case direction
    when 'up'
      abort "Backup already exists at #{backup_path}; pass a new BACKUP_PATH before running again." if backup_path.exist?

      changes = []
      Procedure.where(name: approved_names).find_each do |procedure|
        locales.each do |locale|
          # config/locales/zz_procedure_names.yml is auto-loaded by Rails' normal
          # i18n load path (its "zz_" filename makes it win the merge), so its
          # entries are already present here -- no need to load/merge it again.
          aliases = I18n.t(:procedure_aliases, locale: locale, default: {})
          translated_name = aliases[procedure.name] || aliases[procedure.name.to_sym]
          translated_name = Array(translated_name).first
          next if translated_name.blank? || translated_name == procedure.name

          translation = procedure.translations.find_or_initialize_by(locale: locale)
          changes << {
            'procedure_id' => procedure.id,
            'locale' => locale,
            'previous' => translation.persisted? ? translation.attributes : nil
          }
          translation.name = translated_name
          translation.save!
        end
      end

      backup_path.dirname.mkpath
      File.write(backup_path, YAML.dump({ 'created_at' => Time.now.utc.iso8601, 'changes' => changes }))

      changes.map { |change| change['procedure_id'] }.uniq.each do |procedure_id|
        Pin.where(procedure_id: procedure_id).find_each do |pin|
          pin.__elasticsearch__.index_document
        end
      end

      puts "Imported #{changes.length} procedure translations. Backup written to #{backup_path}."
    when 'down'
      abort "Backup file not found at #{backup_path}" unless backup_path.exist?

      backup = YAML.load_file(backup_path)
      ActiveRecord::Base.transaction do
        (backup['changes'] || []).each do |change|
          translation = ProcedureTranslation.where(
            procedure_id: change['procedure_id'],
            locale: change['locale']
          ).first

          previous = change['previous']
          if previous
            translation ||= ProcedureTranslation.new
            translation.assign_attributes(previous.except('id', 'created_at', 'updated_at'))
            translation.save!
          else
            translation.try(:destroy)
          end
        end
      end

      puts "Restored procedure translations from #{backup_path}."
    else
      abort "Unknown DIRECTION=#{direction.inspect}. Use up or down."
    end
  end
end
