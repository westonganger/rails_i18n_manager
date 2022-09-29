module RailsI18nManager
  class TranslationApp < ApplicationRecord
    NAME = "Translated App".freeze

    has_many :translation_keys, class_name: "RailsI18nManager::TranslationKey", dependent: :destroy

    before_validation :clean_additional_locales
    after_update :handle_removed_locales
    after_update :handle_added_locales

    validates :name, presence: true, uniqueness: {case_sensitive: false}
    validates :default_locale, presence: true
    validate :validate_additional_locales

    scope :search, ->(str){
      fields = [
        "#{table_name}.name",
      ]

      like = connection.adapter_name.downcase.to_s == "postgres" ? "ILIKE" : "LIKE"

      sql_conditions = []

      fields.each do |col|
        sql_conditions << "(#{col} #{like} :search)"
      end

      self.where(sql_conditions.join(" OR "), search: "%#{str}%")
    }

    def additional_locales=(val)
      if val.is_a?(Array)
        val = val.map{|x| x.to_s.downcase.strip.presence }.compact.uniq.sort
        val.delete(self.default_locale)

        self[:additional_locales] = val.join(",")
      else
        self[:additional_locales] = val
      end
    end

    def additional_locales_array
      additional_locales.to_s.split(",")
    end

    def all_locales
      [self.default_locale] + additional_locales_array
    end

    private

    def validate_additional_locales
      if additional_locales_changed?
        invalid_locales = []

        additional_locales_array.each do |locale|
          if !RailsI18nManager.config.valid_locales.include?(locale)
            invalid_locales << locale
          end
        end

        if invalid_locales.any?
          self.errors.add(:additional_locales, "Invalid locales: #{invalid_locales.join(", ")}")
        end
      end
    end

    def clean_additional_locales
      if additional_locales_changed?
        cleaned_array = additional_locales_array.map{|x| x.to_s.downcase.strip.presence }.compact.uniq.sort
        cleaned_array.delete(self.default_locale)

        self.additional_locales = cleaned_array.join(",")
      end
    end

    def handle_removed_locales
      if previous_changes.has_key?("default_locale") || previous_changes.has_key?("additional_locales")
        TranslationValue
          .joins(:translation_key).where(TranslationKey.table_name => {translation_app_id: self.id})
          .where.not(locale: all_locales)
          .delete_all ### instead of destroy_all, use delete_all for speedup
      end
    end

    def handle_added_locales
      ### ATTEMPTING TO JUST SKIP THIS

      # ### For new locales, create TranslationValue records
      # value_records_for_import = []

      # translation_keys.includes(:translation_values).each do |key_record|
      #   additional_locales_array.each do |locale|
      #     val_record = key_record.translation_values.detect{|x| x.locale == locale }

      #     if val_record.nil?
      #       value_records_for_import << key_record.translation_values.new(locale: locale)
      #     end
      #   end
      # end

      # ### We use active_record-import for big speedup also using validate: false for more speed
      # TranslationValue.import(value_records_for_import, validate: false)
      # end
    end

  end
end
