module RailsI18nManager
  class TranslationsImporter

    class ImportAbortedError < StandardError; end

    def self.import(translation_app_id:, parsed_file_contents:, overwrite_existing: false, mark_inactive_translations: false)
      app_record = TranslationApp.find(translation_app_id)

      new_locales = parsed_file_contents.keys - app_record.all_locales

      if new_locales.any?
        raise ImportAbortedError.new("Import aborted. Locale not listed in translation app: #{new_locales.join(', ')}")
      end

      all_keys = RailsI18nManager.fetch_flattened_dot_notation_keys(parsed_file_contents)

      key_records_by_key = app_record.translation_keys.includes(:translation_values).index_by(&:key)

      all_keys.each do |key|
        if key_records_by_key[key].nil?
          key_records_by_key[key] = app_record.translation_keys.new(key: key)
          key_records_by_key[key].save!
        end
      end

      translation_values_to_import = []

      key_records_by_key.each do |key, key_record|
        app_record.all_locales.each do |locale|
          split_keys = [locale] + key.split(".").map{|x| x}

          val = parsed_file_contents.dig(*split_keys)

          if val.present?
            val_record = key_record.translation_values.detect{|x| x.locale == locale.to_s }

            if val_record.nil?
              translation_values_to_import << key_record.translation_values.new(locale: locale, translation: val)
            elsif val_record.translation.blank? || (overwrite_existing && val_record.translation != val)
              val_record.update!(translation: val)
              next
            end
          end
        end
      end

      ### We use active_record-import for big speedup, set validate false if more speed required
      TranslationValue.import(translation_values_to_import, validate: true)

      if mark_inactive_translations
        app_record.translation_keys
          .where.not(key: all_keys)
          .update_all(active: false)

        app_record.translation_keys
          .where(key: all_keys)
          .update_all(active: true)
      end

      return true
    end

  end
end
