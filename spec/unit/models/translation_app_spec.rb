require 'spec_helper'

module RailsI18nManager
  RSpec.describe TranslationApp, type: :model do

    let(:translation_app) { FactoryBot.create(:translation_app, default_locale: :en, additional_locales: [:fr]) }

    context "validations" do
      it "requires a default locale" do
        translation_app.default_locale = nil
        translation_app.valid?
        expect(translation_app.errors[:default_locale]).to be_present
      end

      it "allows empty (additional) locales" do
        translation_app.additional_locales = []
        expect(translation_app.valid?).to eq(true)
      end
    end

    context "additional_locales" do
      it "removes default locale if included" do
        expect(translation_app.default_locale).not_to eq("fr")
        expect(translation_app.additional_locales_array).to eq(["fr"])
        translation_app.additional_locales = translation_app.additional_locales_array + [translation_app.default_locale]
        expect(translation_app.additional_locales_array).to eq(["fr"])
      end
    end

    context "handle_added_locales" do
      it "doesnt create the new blank records" do
        translation_app.translation_keys.create!(key: :foo)
        translation_app.translation_keys.create!(key: :bar)

        num_keys = translation_app.translation_keys.count
        expect(TranslationValue.where(translation_key_id: translation_app.translation_key_ids).count).to eq(0)

        translation_app.update!(additional_locales: [:en, :fr, :es])
        expect(TranslationValue.where(translation_key_id: translation_app.translation_key_ids).count).to eq(0)
      end
    end

    context "handle_removed_locales" do
      it "deletes all translations values for the removed locale" do
        translation_app.update!(additional_locales: ["fr", "es"])

        FactoryBot.create(:translation_key, :with_translation_values, translation_app: translation_app)
        FactoryBot.create(:translation_key, :with_translation_values, translation_app: translation_app)

        num_keys = translation_app.translation_keys.count
        expect(TranslationValue.where(translation_key_id: translation_app.translation_key_ids).count).to eq(6)

        translation_app.update!(additional_locales: ["fr"])
        expect(TranslationValue.where(translation_key_id: translation_app.translation_key_ids).count).to eq(4)
      end
    end

  end
end
