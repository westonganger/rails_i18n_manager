require "spec_helper"

module RailsI18nManager
  RSpec.describe TranslationsImportJob, type: :model do

    let(:translation_app){ FactoryBot.create(:translation_app, default_locale: :en, additional_locales: [:fr]) }

    before do
      @filename = Rails.root.join("tmp/#{SecureRandom.hex(6)}.yml").to_s
    end

    after do
      `rm -rf #{@filename}`
    end

    it "raises exception when the locale included in file but is not listed in translation app" do
      yaml = <<~YAML
        fr:
          foo: foo
          bar:
        es:
          foo: foo
      YAML
      File.write(@filename, yaml, mode: "wb")

      expect do
        TranslationsImportJob.new.perform(translation_app_id: translation_app.id, import_file: @filename)
      end.to raise_error(TranslationsImportJob::ImportAbortedError)
    end

    it "creates the correct amount of TranslationKey and TranslationValue" do
      prev_key_count = translation_app.translation_keys.size
      prev_value_count = translation_app.translation_keys.sum{|x| x.translation_values.size }

      yaml = <<~YAML
        en:
          foo: foo
          baz:
          beef:
            steak: steak
            roast:

        fr:
          fr_only_key: fr_only
      YAML
      File.write(@filename, yaml, mode: "wb")

      TranslationsImportJob.new.perform(translation_app_id: translation_app.id, import_file: @filename)

      translation_app.reload

      expect(translation_app.translation_keys.size).to eq(prev_key_count + 5)
      expect(translation_app.translation_keys.sum{|x| x.translation_values.size }).to eq(prev_value_count + 3)
    end

    context "overwrite_existing" do
      it "when true it overwrites existing present values" do
        foo_value = FactoryBot.create(
          :translation_value,
          locale: :en,
          translation: "old",
          translation_key: FactoryBot.create(
            :translation_key,
            translation_app: translation_app,
            key: "foo",
          ),
        )

        yaml = <<~YAML
          en:
            foo: updated
        YAML
        File.write(@filename, yaml, mode: "wb")

        TranslationsImportJob.new.perform(translation_app_id: translation_app.id, import_file: @filename, overwrite_existing: true)

        foo_value.reload

        expect(foo_value.translation).to eq("updated")
      end

      it "when false it does not overwrite existing present values" do
        foo_value = FactoryBot.create(
          :translation_value,
          locale: :fr,
          translation: "old",
          translation_key: FactoryBot.create(
            :translation_key,
            translation_app: translation_app,
            key: "foo",
          ),
        )

        blank_value = FactoryBot.create(
          :translation_value,
          locale: :fr,
          translation: nil,
          translation_key: FactoryBot.create(
            :translation_key,
            translation_app: translation_app,
            key: "bar",
          ),
        )

        yaml = <<~YAML
          fr:
            foo: foo_updated
            bar: bar_updated
        YAML
        File.write(@filename, yaml, mode: "wb")

        TranslationsImportJob.new.perform(translation_app_id: translation_app.id, import_file: @filename, overwrite_existing: false)

        foo_value.reload
        blank_value.reload

        expect(foo_value.translation).to eq("old")
        expect(blank_value.translation).to eq("bar_updated")
      end
    end

    context "mark_inactive_translations" do
      it "when true it sets active attributes" do
        yaml = <<~YAML
          en:
            foo:
            bar:
            baz:
        YAML
        File.write(@filename, yaml, mode: "wb")

        TranslationsImportJob.new.perform(translation_app_id: translation_app.id, import_file: @filename, mark_inactive_translations: true)
        translation_app.translation_keys.reload
        expect(translation_app.translation_keys.select(&:active).size).to eq(3)
        expect(translation_app.translation_keys.reject(&:active).size).to eq(0)

        yaml = <<~YAML
          en:
            foo:
            #bar:
            baz:
        YAML
        File.write(@filename, yaml, mode: "wb")

        TranslationsImportJob.new.perform(translation_app_id: translation_app.id, import_file: @filename, mark_inactive_translations: true)
        translation_app.translation_keys.reload
        expect(translation_app.translation_keys.select(&:active).size).to eq(2)
        expect(translation_app.translation_keys.reject(&:active).size).to eq(1)

        yaml = <<~YAML
          en:
            foo:
            bar:
            baz:
        YAML
        File.write(@filename, yaml, mode: "wb")

        TranslationsImportJob.new.perform(translation_app_id: translation_app.id, import_file: @filename, mark_inactive_translations: true)
        translation_app.translation_keys.reload
        expect(translation_app.translation_keys.select(&:active).size).to eq(3)
        expect(translation_app.translation_keys.reject(&:active).size).to eq(0)
      end

      it "when false it does not change active attribute" do
        yaml = <<~YAML
          en:
            foo:
            bar:
            baz:
        YAML
        File.write(@filename, yaml, mode: "wb")

        TranslationsImportJob.new.perform(translation_app_id: translation_app.id, import_file: @filename, mark_inactive_translations: false)
        expect(translation_app.translation_keys.select(&:active).size).to eq(3)
        expect(translation_app.translation_keys.reject(&:active).size).to eq(0)

        yaml = <<~YAML
          en:
            foo:
            #bar:
            baz:
        YAML
        File.write(@filename, yaml, mode: "wb")

        TranslationsImportJob.new.perform(translation_app_id: translation_app.id, import_file: @filename, mark_inactive_translations: false)
        expect(translation_app.translation_keys.select(&:active).size).to eq(3)
        expect(translation_app.translation_keys.reject(&:active).size).to eq(0)
      end
    end

  end
end
