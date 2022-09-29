FactoryBot.define do
  factory :translation_value, class: RailsI18nManager::TranslationValue do
    translation_key { FactoryBot.create(:translation_key) }
    locale { translation_key.translation_app.default_locale }
    translation do
      if locale == translation_key.translation_app.default_locale
        translation_key.key.split(".").last.titleize
      else
        Faker::Lorem.word
      end
    end
  end
end
