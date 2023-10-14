require 'spec_helper'

module RailsI18nManager
  RSpec.describe TranslationKey, type: :model do

    let!(:translation_app) { FactoryBot.create(:translation_app, default_locale: :en, additional_locales: [:fr]) }
    let!(:translation_key) { FactoryBot.create(:translation_key) }
    let!(:default_translation_value) { FactoryBot.create(:translation_value, translation_key: translation_key, locale: translation_app.default_locale) }
    let!(:additional_translation_value) { FactoryBot.create(:translation_value, translation_key: translation_key, locale: translation_app.additional_locales_array.first) }

    context "default_translation" do
      it "returns translation value of default locale" do
        expect(default_translation_value.translation).to be_present
        expect(additional_translation_value.translation).not_to eq(default_translation_value.translation)
        expect(translation_key.default_translation).to eq(default_translation_value.translation)
      end
    end

    context "any_missing_translations?" do
      it "check for any missing translations" do
        translation_key.any_missing_translations?
      end
    end

    context "to_csv" do
      it "returns a csv string with correct headers" do
        csv_str = TranslationKey.to_csv
        expect(csv_str).to be_kind_of(String)

        rows = CSV.parse(csv_str)

        expect(rows.first).to match_array(["App Name", "Key", "Locale", "Translation", "Updated At"])
      end

      it "create a csv for all apps" do
        csv_str = TranslationKey.to_csv
        rows = CSV.parse(csv_str)

        expect(rows.size).to eq(1+TranslationApp.all.sum{|x| x.all_locales.size*x.translation_keys.size })
      end

      it "creates a csv for a single app" do
        csv_str = TranslationKey.where(translation_app_id: translation_app.id).to_csv
        rows = CSV.parse(csv_str)

        expect(rows.size).to eq(1+(translation_app.all_locales.size*translation_app.translation_keys.size))
      end

      it "includes rows for locales without an associated translation key record" do
        2.times do
          key = FactoryBot.create(:translation_key, translation_app: translation_app)
          FactoryBot.create(:translation_value, translation_key: key, locale: key.translation_app.default_locale)
        end
        expect(translation_app.all_locales.size).to eq(2)
        expect(translation_app.translation_keys.size).to eq(2)
        expect(translation_app.translation_keys.flat_map(&:translation_values).size).to eq(2)

        csv_str = TranslationKey.where(translation_app_id: translation_app.id).to_csv
        rows = CSV.parse(csv_str)

        expect(rows.size).to eq(5)
      end
    end

    context "export_to" do
      context "invalid format" do
        it "raises error" do
          expect do
            TranslationKey.export_to(app_name: nil, zip: false, format: :foo)
          end.to raise_error(ArgumentError, "Invalid format provided")
        end
      end

      it "works for all apps" do
        dirname = TranslationKey.export_to(app_name: nil, zip: false, format: "yaml")
        expect(File.directory?(dirname)).to eq(true)
        app_dirs = Dir.glob("#{dirname}/*")
        expect(app_dirs.size > 1)
        expect(app_dirs.any?{|x| File.directory?(x) && x.end_with?("/#{TranslationApp.first.name}")}).to eq(true)
        expect(app_dirs.any?{|x| File.directory?(x) && x.end_with?("/#{TranslationApp.last.name}")}).to eq(true)
      end

      it "works for a single app" do
        expect(TranslationApp.all.size).to be >= 2

        dirname = TranslationKey.export_to(app_name: translation_app.name, zip: false, format: "yaml")
        expect(File.directory?(dirname)).to eq(true)
        files = Dir.glob("#{dirname}/*")
        expect(files.size).to eq(2)
        expect(files[0].end_with?("/en.yml")).to eq(true)
        expect(files[1].end_with?("/fr.yml")).to eq(true)
      end

      it "zips the content if zip: true" do
        filename = TranslationKey.export_to(app_name: translation_app.name, zip: true, format: "yaml")
        expect(File.directory?(filename)).to eq(false)
        expect(filename.split(".").last).to eq("zip")
      end

      it "doesnt zip the content if zip: false" do
        dirname = TranslationKey.export_to(app_name: translation_app.name, zip: false, format: "yaml")
        expect(File.directory?(dirname)).to eq(true)
        files = Dir.glob("#{dirname}/**/*")
        expect(files.size).to eq(2)
        expect(files[0].end_with?("/en.yml")).to eq(true)
        expect(files[1].end_with?("/fr.yml")).to eq(true)
      end

      it "deletes old tmp files" do
        allow(FileUtils).to receive(:rm_r).and_call_original

        TranslationKey.export_to(app_name: nil, zip: false, format: "yaml")
        TranslationKey.export_to(app_name: nil, zip: false, format: "yaml")
        expect(FileUtils).not_to have_received(:rm_r)

        allow(File).to receive(:ctime).and_return(2.minutes.ago)
        TranslationKey.export_to(app_name: nil, zip: false, format: "yaml")
        expect(FileUtils).to have_received(:rm_r).once
      end

      context "yaml" do
        it "outputs content in yaml" do
          dirname = TranslationKey.export_to(app_name: nil, zip: false, format: "yaml")

          files = Dir.glob("#{dirname}/**/*").reject{|f| File.directory?(f) }
          expect(files.all?{|x| x.end_with?(".yml") }).to eq(true)

          YAML.safe_load(File.read(files.first))
        end
      end

      context "json" do
        it "outputs content in json" do
          dirname = TranslationKey.export_to(app_name: nil, zip: false, format: :json)

          files = Dir.glob("#{dirname}/**/*").reject{|f| File.directory?(f) }
          expect(files.all?{|x| x.end_with?(".json") }).to eq(true)

          JSON.parse(File.read(files.first))
        end
      end
    end

  end
end
