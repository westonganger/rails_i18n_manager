require 'spec_helper'

module RailsI18nManager
  RSpec.describe TranslationValue, type: :model do

    let(:translation_app) { FactoryBot.create(:translation_app, default_locale: :en, additional_locales: [:fr]) }
    let(:translation_key) { FactoryBot.create(:translation_key) }
    let(:default_translation_value) { translation_key.translation_values.create!(locale: translation_app.default_locale, translation: "foo") }
    let(:additional_translation_value) { translation_key.translation_values.create!(locale: translation_app.additional_locales_array.first, translation: "bar") }

    context "validations" do
      it "requires translation for default locale only" do
        default_translation_value.translation = nil
        default_translation_value.valid?
        expect(default_translation_value.errors[:translation]).not_to be_empty

        additional_translation_value.translation = nil
        additional_translation_value.valid?
        expect(additional_translation_value.errors[:translation]).to be_empty
      end
    end

  end
end
