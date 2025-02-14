require "spec_helper"

module RailsI18nManager
  RSpec.describe "TranslationAppsController", type: :request do

    let!(:translation_app){ FactoryBot.create(:translation_app) }
    let!(:translation_key){ FactoryBot.create(:translation_key, translation_app: translation_app) }

    context "index" do
      it "renders" do
        get rails_i18n_manager.translation_apps_path
        expect(response).to have_http_status(200)

        get rails_i18n_manager.translation_apps_path, params: {search: "foobarfoobar"}
        expect(response).to have_http_status(200)

        ["", 'asc','desc'].each do |direction|
          ['name'].each do |col|
            get rails_i18n_manager.translation_apps_path, params: {sort: col, direction: direction}
            expect(response).to have_http_status(200), "Error: #{direction} #{col}"
          end
        end

        get rails_i18n_manager.translation_app_path(translation_app)
        expect(response).to redirect_to(rails_i18n_manager.edit_translation_app_path(translation_app))
      end
    end

    context "new" do
      it "renders" do
        get rails_i18n_manager.new_translation_app_path
        expect(response).to have_http_status(200)
      end
    end

    context "create" do
      it "succeeds" do
        assert_changed ->(){ TranslationApp.count } do
          post rails_i18n_manager.translation_apps_path, params: {translation_app: {name: "some-new-app-name", default_locale: "en"}}
          expect(response).to redirect_to(rails_i18n_manager.edit_translation_app_path(TranslationApp.last))
        end
      end

      it "renders form when there are validation errors" do
        assert_not_changed ->(){ TranslationApp.count } do
          post rails_i18n_manager.translation_apps_path, params: {translation_app: {name: ""}}
          expect(response).to render_template("translation_apps/form")
        end
      end
    end

    context "edit" do
      it "renders" do
        get rails_i18n_manager.edit_translation_app_path(translation_app)
        expect(response).to have_http_status(200)
      end
    end

    context "update" do
      it "succeeds" do
        translation_app.update!(additional_locales: nil)

        assert_changed ->(){ translation_app.additional_locales_array } do
          patch rails_i18n_manager.translation_app_path(translation_app), params: {translation_app: {additional_locales: ['es','id']}}
          translation_app.reload
        end
        expect(response).to redirect_to(rails_i18n_manager.translation_apps_path)
      end

      it "renders form when there are validation errors" do
        assert_not_changed ->(){ translation_app.additional_locales_array } do
          patch rails_i18n_manager.translation_app_path(translation_app), params: {translation_app: {additional_locales: ['foobar']}}

          expect(response).to render_template("translation_apps/form")
          translation_app.reload
        end
      end
    end

  end
end
