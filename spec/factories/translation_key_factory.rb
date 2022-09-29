FactoryBot.define do
  factory :translation_key, class: RailsI18nManager::TranslationKey do
    translation_app { FactoryBot.create(:translation_app) }
    key { [Faker::Verb.base, Faker::Verb.base, Faker::Verb.base][0..(rand(1..2))].join(".").downcase }

#     after :build do |record|
#       record.assign_attributes(
#         translation_values_attributes: [
#           {locale: record.translation_app.default_locale, translation: "some-default-translation"}
#         ]
#       )
#     end

    trait :with_translation_values do
      after :create do |record|
        record.translation_app.all_locales.each do |locale|
          FactoryBot.create(:translation_value, translation_key: record, locale: locale)
        end
      end
    end

  end
end
