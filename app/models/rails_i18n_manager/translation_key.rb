module RailsI18nManager
  class TranslationKey < ApplicationRecord

    belongs_to :translation_app, class_name: "RailsI18nManager::TranslationApp"
    has_many :translation_values, class_name: "RailsI18nManager::TranslationValue", dependent: :destroy
    accepts_nested_attributes_for :translation_values, reject_if: ->(x){ x["id"].nil? && x["translation"].blank? }

    validates :translation_app, presence: true
    validates :key, presence: true, uniqueness: {case_sensitive: false, scope: [:translation_app_id]}
    validate :validate_translation_values_includes_default_locale

    def validate_translation_values_includes_default_locale
      return if new_record?
      if translation_values.empty? || translation_values.none?{|x| x.locale == translation_app.default_locale }
        errors.add(:base, "Translation for default locale is required")
      end
    end

    scope :search, ->(str){
      fields = [
        "#{table_name}.key",
        "#{TranslationApp.table_name}.name",
        "#{TranslationValue.table_name}.locale",
        "#{TranslationValue.table_name}.translation",
      ]

      like = connection.adapter_name.downcase.to_s == "postgres" ? "ILIKE" : "LIKE"

      sql_conditions = []

      fields.each do |col|
        sql_conditions << "(#{col} #{like} :search)"
      end

      self.left_joins(:translation_values, :translation_app)
        .where(sql_conditions.join(" OR "), search: "%#{str}%")
    }

    def default_translation
      return @default_translation if defined?(@default_translation)
      @default_translation = self.translation_values.detect{|x| x.locale == translation_app.default_locale.to_s }&.translation
    end

    def any_missing_translations?
      self.translation_app.all_locales.any? do |locale|
        val_record = translation_values.detect{|x| x.locale == locale.to_s}

        next val_record.nil? || val_record.translation.blank?
      end
    end

    def self.to_csv
      CSV.generate do |csv|
        csv << ["App Name", "Key", "Locale", "Translation", "Updated At"]

        self.all.order(key: :asc).includes(:translation_app, :translation_values).each do |key_record|
          value_records = {}

          key_record.translation_values.each do |value_record|
            value_records[value_record.locale] = value_record
          end

          key_record.translation_app.all_locales.each do |locale|
            value_record = value_records[locale]
            csv << [key_record.translation_app.name, key_record.key, value_record&.locale, value_record&.translation, value_record&.updated_at&.to_s]
          end
        end
      end
    end

    def self.export_to(app_name: nil, zip: false, format: :yaml)
      format = format.to_sym

      if format == :yaml
        format = "yml"
      elsif [:yaml, :json].exclude?(format)
        raise ArgumentError.new("Invalid format provided")
      end

      base_export_path = Rails.root.join("tmp/export/translations/")

      files_to_delete = Dir.glob("#{base_export_path}/*").each do |f|
        if File.ctime(f) < 1.minutes.ago
          `rm -rf #{f}`
        end
      end

      base_folder_path = File.join(base_export_path, "#{Time.now.to_i}/")

      FileUtils.mkdir_p(base_folder_path)

      if app_name.nil?
        translation_apps = TranslationApp.order(name: :asc)
      else
        translation_apps = [TranslationApp.find_by!(name: app_name)]
      end

      if translation_apps.empty?
        return nil
      end

      translation_apps.each do |app_record|
        current_app_name = app_record.name

        key_records = app_record.translation_keys.order(key: :asc).includes(:translation_values)

        app_record.all_locales.each do |locale|
          tree = {}

          key_records.each do |key_record|
            val_record = key_record.translation_values.detect{|x| x.locale == locale.to_s}

            split_keys = [locale.to_s] + key_record.key.split(".")

            RailsI18nManager.hash_deep_set(tree, split_keys, val_record.try!(:translation))
          end

          filename = File.join(base_folder_path, current_app_name, "#{locale}.#{format}")

          FileUtils.mkdir_p(File.dirname(filename))

          File.open(filename, "wb") do |io|
            if format == :json
              str = tree.to_json
            else
              str = tree.to_yaml(line_width: -1).sub("---\n", "")
            end

            io.write(str)
          end
        end
      end

      if zip
        temp_file = Tempfile.new([Time.now.to_i.to_s, ".zip"], binmode: true)

        files_to_write = Dir.glob("#{base_folder_path}/**/**")

        if files_to_write.empty?
          return nil
        end

        zip_file = Zip::File.open(temp_file, create: !File.exist?(temp_file)) do |zipfile|
          files_to_write.each do |file|
            zipfile.add(file.sub(base_folder_path, "translations/"), file)
          end
        end

        output_path = temp_file.path
      elsif app_name
        output_path = File.join(base_folder_path, app_name)
      else
        output_path = base_folder_path
      end

      return output_path
    end

  end
end
