Dir.glob("#{__dir__}/../../factories/*").each do |x|
  puts x
  require_relative(x)
end

module RailsI18nManager
  if TranslationKey.first
    raise "Error already seeded"
  end

  puts "Seeding"

  app = FactoryBot.create(:translation_app, name: "Bluejay")

  100.times do
    FactoryBot.create(:translation_key, :with_translation_values, translation_app: app)
  end

  puts "Successfully seeded"
end
