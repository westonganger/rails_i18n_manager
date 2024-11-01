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

        file_extname = File.extname(file)

        if [".yml", ".yaml", ".json"].exclude?(file_extname)
          errors.add(:file, "Invalid file format. Must be yaml or json file.")
          return
        end

        file_contents = File.read(file)

        if file_contents.blank?
          errors.add(:file, "Empty file provided.")
          return
        end

        case file_extname
        when ".yml", ".yaml"
          if !YAML.safe_load(file_contents).is_a?(Hash)
            errors.add(:file, "Invalid #{file_extname.sub(".","")} file.")
            return
          end

        when ".json"
          begin
            JSON.parse(file_contents)
          rescue JSON::ParserError
            errors.add(:file, "Invalid json file.")
            return
          end
        end
      end

    end
  end
end
