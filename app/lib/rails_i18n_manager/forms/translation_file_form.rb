module RailsI18nManager
  module Forms
    class TranslationFileForm < Base

      attr_accessor :translation_app_id, :file, :overwrite_existing
      attr_reader :overwrite_existing, :mark_inactive_translations

      validates :translation_app_id, presence: {message: "Must select an App"}
      validates :file, presence: true
      validate :validate_file

      def overwrite_existing=(val)
        @overwrite_existing = ["1", "true", "t"].include?(val.to_s.downcase)
      end

      def mark_inactive_translations=(val)
        @mark_inactive_translations = ["1", "true", "t"].include?(val.to_s.downcase)
      end

      def validate_file
        if file.blank?
          errors.add(:file, "Must upload a valid translation file.")
          return
        end

        if [".yml", ".json"].exclude?(File.extname(file))
          errors.add(:file, "Invalid file format. Must be yml or json file.")
          return
        end

        if File.read(file).blank?
          errors.add(:file, "Empty file provided.")
          return
        end

        case File.extname(file)
        when ".yml"
          if !YAML.safe_load(File.read(file)).is_a?(Hash)
            errors.add(:file, "Invalid yml file.")
            return
          end

        when ".json"
          begin
            JSON.parse(File.read(file))
          rescue JSON::ParserError
            errors.add(:file, "Invalid json file.")
            return
          end
        end
      end

    end
  end
end
