module RailsI18nManager
  class TranslationValue < ApplicationRecord

    belongs_to :translation_key, class_name: "RailsI18nManager::TranslationKey"

    validates :translation_key, presence: true
    validates :locale, presence: true, uniqueness: {scope: :translation_key_id}
    validates :translation, presence: {if: ->(){ locale == translation_key.translation_app.default_locale.to_s } }

  end
end
