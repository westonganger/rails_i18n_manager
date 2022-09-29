require "spec_helper"

module RailsI18nManager
  RSpec.describe "TranslationsController", type: :request do
    let(:translation_app){ FactoryBot.create(:translation_app, default_locale: :en, additional_locales: [:fr]) }
    let(:translation_key){ FactoryBot.create(:translation_key, translation_app: translation_app) }
    let!(:default_translation_value){ FactoryBot.create(:translation_value, translation_key: translation_key, locale: translation_app.default_locale) }

    context "index" do
      it "renders" do
        get rails_i18n_manager.translations_path
        expect(response).to have_http_status(200)

        get rails_i18n_manager.translations_path, params: {search: "foobarfoobar"}
        expect(response).to have_http_status(200)

        get rails_i18n_manager.translations_path, params: {status: "Missing"}
        expect(response).to have_http_status(200)

        get rails_i18n_manager.translations_path, params: {translation_app_id: translation_app.id}
        expect(response).to have_http_status(200)

        ["", 'asc','desc'].each do |direction|
          ['app_name','key','updated_at'].each do |col|
            get rails_i18n_manager.translations_path, params: {sort: col, direction: direction}
            expect(response).to have_http_status(200), "Error: #{direction} #{col}"
          end
        end
      end

      it "exports" do
        get rails_i18n_manager.translations_path, params: {format: :zip, export_format: :yaml}
        expect(response).to have_http_status(200)

        get rails_i18n_manager.translations_path, params: {format: :zip, export_format: :json}
        expect(response).to have_http_status(200)

        get rails_i18n_manager.translations_path, params: {format: :csv}
        expect(response).to have_http_status(200)

        get rails_i18n_manager.translations_path, params: {translation_app_id: translation_app.id, format: :zip, export_format: :yaml}
        expect(response).to have_http_status(200)

        get rails_i18n_manager.translations_path, params: {translation_app_id: translation_app.id, format: :zip, export_format: :json}
        expect(response).to have_http_status(200)

        get rails_i18n_manager.translations_path, params: {translation_app_id: translation_app.id, format: :csv}
        expect(response).to have_http_status(200)
      end
    end

    context "show" do
      it "renders" do
        get rails_i18n_manager.translation_path(translation_key)
        expect(response).to have_http_status(200)
      end
    end

    context "edit" do
      it "renders" do
        get rails_i18n_manager.edit_translation_path(translation_key)
        expect(response).to have_http_status(200)
      end
    end

    context "update" do
      it "succeeds" do
        translation_value = FactoryBot.create(:translation_value, translation_key: translation_key, locale: :fr)

        assert_changed ->(){ translation_value.translation } do
          patch rails_i18n_manager.translation_path(translation_key), params: {
            translation_key: {
              translation_values_attributes: {
                "0" => {
                  id: translation_value.id,
                  translation: SecureRandom.hex(6),
                }
              }
            }
          }
          expect(response).to redirect_to(rails_i18n_manager.edit_translation_path(translation_key))
          translation_value.reload
        end
      end
    end

    context "translate_missing" do
      it "succeeds" do
        post rails_i18n_manager.translate_missing_translations_path
        expect(response).to redirect_to(rails_i18n_manager.translations_path)

        post rails_i18n_manager.translate_missing_translations_path(app_name: translation_app.name)
        expect(response).to redirect_to(rails_i18n_manager.translations_path(app_name: translation_app.name))

        post rails_i18n_manager.translate_missing_translations_path(translation_key_id: translation_key.id)
        expect(response).to redirect_to(rails_i18n_manager.translation_path(translation_key))
      end
    end

    context "import" do
      it "succeeds" do
        get rails_i18n_manager.import_translations_path
        expect(response).to have_http_status(200)

        post rails_i18n_manager.import_translations_path, params: {}
        expect(response).to have_http_status(200)

        post rails_i18n_manager.import_translations_url, params: {translation_app_id: translation_app.id}
        expect(response).to have_http_status(200)

        yaml = <<~YAML
          en:
            foo:
            bar:
            baz:
        YAML
        filename = Rails.root.join("tmp/#{SecureRandom.hex(6)}.yaml")
        File.write(filename, yaml, mode: "wb")
        file_upload = Rack::Test::UploadedFile.new(filename)
        post rails_i18n_manager.import_translations_path, params: {translation_app_id: translation_app.id, file: file_upload}
        expect(response).to have_http_status(200)
      end
    end

    context "destroy" do
      it "works" do
        expect(translation_key.active).to eq(true)
        assert_no_difference ->(){ TranslationKey.count } do
          delete rails_i18n_manager.translation_path(translation_key)
        end

        translation_key.update_columns(active: false)

        assert_difference ->(){ TranslationKey.count }, -1 do
          delete rails_i18n_manager.translation_path(translation_key)
          expect(response).to redirect_to(rails_i18n_manager.translations_path)
        end
      end
    end

  end
end
