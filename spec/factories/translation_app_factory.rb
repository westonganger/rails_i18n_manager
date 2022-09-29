FactoryBot.define do
  factory :translation_app, class: RailsI18nManager::TranslationApp do
    name { Faker::App.unique.name }
    default_locale { "en" }
    additional_locales { ["fr", "es"] }
  end
end
