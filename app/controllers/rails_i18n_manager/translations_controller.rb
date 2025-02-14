module RailsI18nManager
  class TranslationsController < ApplicationController
    before_action :get_translation_key, only: [:show, :edit, :update, :destroy]

    def index
      case params[:sort]
      when "app_name"
        sort = "#{TranslationApp.table_name}.name"
      when "updated_at"
        sort = "#{TranslationKey.table_name}.updated_at"
      else
        sort = params[:sort]
      end

      @translation_keys = TranslationKey
        .includes(:translation_app, :translation_values)
        .references(:translation_app)
        .sort_order(sort, params[:direction], base_sort_order: "#{TranslationApp.table_name}.name ASC, #{TranslationKey.table_name}.key ASC")

      apply_filters

      if request.format.to_sym != :html && TranslationApp.first.nil?
        request.format = :html
        flash[:alert] = "No Translation apps exists"
        redirect_to action: :index
        return false
      end

      respond_to do |format|
        format.html do
          @translation_keys = @translation_keys.page(params[:page])
        end

        format.any do
          @translations_keys = @translation_keys.where(active: true) ### Ensure exported keys are active for any exports

          case request.format.to_sym
          when :csv
            if params.dig(:filters, :app_name).present?
              @translation_keys = @translation_keys.joins(:translation_app).where(TranslationApp.table_name => {name: params.dig(:filters, :app_name)})
            end

            send_data @translation_keys.to_csv, filename: "translations.csv"
          when :zip
            file = @translation_keys.export_to(format: params[:export_format], zip: true, app_name: params.dig(:filters, :app_name).presence)

            if file
              send_file file, filename: "translations-#{params[:export_format]}-#{params.dig(:filters, :app_name).presence || "all-apps"}.zip"
            else
              flash[:alert] = "Sorry, Nothing to export"
              redirect_to action: :index
            end
          else
            raise ActionController::UnknownFormat
          end
        end
      end
    end

    def show
      render "edit"
    end

    def edit
    end

    def update
      @translation_key.assign_attributes(allowed_params)

      if @translation_key.save
        flash[:notice] = "Update success."
        redirect_to edit_translation_path(@translation_key)
      else
        flash[:notice] = "Update failed."
        render "translations/edit"
      end
    end

    def destroy
      if @translation_key.active
        redirect_to translations_path, alert: "Cannot delete active translations"
      else
        @translation_key.destroy!
        redirect_to translations_path, notice: "Delete Successful"
      end
    end

    def delete_inactive_keys
      @translation_keys = TranslationKey
        .where(active: false)
        .includes(:translation_app, :translation_values)
        .references(:translation_app)

      apply_filters

      @translation_keys.destroy_all

      flash[:notice] = "Delete Inactive was successful."
      redirect_to translations_path(filters: params[:filters].to_unsafe_h)
    end

    def import
      if request.get?
        @form = Forms::TranslationFileForm.new
        render
      else
        @form = Forms::TranslationFileForm.new(params[:import_form])

        if @form.valid?
          begin
            TranslationsImporter.import(
              translation_app_id: @form.translation_app_id,
              parsed_file_contents: @form.parsed_file_contents,
              overwrite_existing: @form.overwrite_existing,
              mark_inactive_translations: @form.mark_inactive_translations,
            )
          rescue TranslationsImporter::ImportAbortedError => e
            flash.now.alert = e.message
            render
            return
          end

          redirect_to translations_path, notice: "Import Successful"
        else
          flash.now.alert = "Please see form errors below"
          render
        end
      end
    end

    def translate_missing
      @translation_keys = TranslationKey.includes(:translation_values)

      apply_filters

      translated_count = 0
      total_missing = 0

      if params.dig(:filters, :app_name)
        app_locales = TranslationApp.find_by(name: params.dig(:filters, :app_name)).additional_locales_array
      else
        @translation_keys = @translation_keys.includes(:translation_app)
      end

      ### Check & Translate for Every i18n key
      @translation_keys.each do |key_record|
        locales = (app_locales || key_record.translation_app.additional_locales_array)

        ### Filter to just google translate supported languages
        locales = (locales & GoogleTranslate::SUPPORTED_LOCALES) # intersection

        default_translation_text = key_record.default_translation

        next if default_translation_text.blank?

        locales.each do |locale|
          if locale == key_record.translation_app.default_locale
            next ### skip, we dont translate the default locale
          end

          val_record = key_record.translation_values.detect{|x| x.locale == locale.to_s }

          ### Translate Missing
          if val_record.nil? || val_record.translation.blank?
            total_missing += 1

            translated_text = GoogleTranslate.translate(
              default_translation_text,
              from: key_record.translation_app.default_locale,
              to: locale
            )

            if translated_text.present?
              if val_record.nil?
                val_record = key_record.translation_values.new(locale: locale)
              end

              val_record.assign_attributes(translation: translated_text)

              val_record.save!

              translated_count += 1
            end
          end
        end
      end

      if params[:translation_key_id]
        url = request.referrer || translation_path(params[:translation_key_id])
      else
        url = translations_path(filters: params[:filters].to_unsafe_h)
      end

      redirect_to url, notice: "Translated #{translated_count} of #{total_missing} total missing translations"
    end

    private

    def get_translation_key
      @translation_key = TranslationKey.includes(:translation_values).find_by!(id: params[:id])
    end

    def allowed_params
      params.require(:translation_key).permit(translation_values_attributes: [:id, :locale, :translation])
    end

    def apply_filters
      if params.dig(:filters, :app_name).present?
        @translation_keys = @translation_keys.joins(:translation_app).where(TranslationApp.table_name => {name: params.dig(:filters, :app_name)})
      end

      if params[:translation_key_id].present?
        @translation_keys = @translation_keys.where(id: params[:translation_key_id])
      end

      if request.format.html?
        ### ONLY FOR HTML - SO THAT WE DONT DOWNLOAD INCOMPLETE TRANSLATION EXPORT PACKAGES

        if params.dig(:filters, :search).present?
          @translation_keys = @translation_keys.search(params.dig(:filters, :search))
        end

        if params.dig(:filters, :status).blank?
          params[:filters] ||= {}
          params[:filters][:status] = "All Active Translations"
        end

        if params.dig(:filters, :status) == "Inactive Translations"
          @translation_keys = @translation_keys.where(active: false)
        elsif params.dig(:filters, :status) == "All Translations"
          # Do nothing
        elsif params.dig(:filters, :status) == "All Active Translations"
          @translation_keys = @translation_keys.where(active: true)
        elsif params.dig(:filters, :status).start_with?("Missing")
          missing_key_ids = []

          if params.dig(:filters, :app_name).present?
            translation_apps = TranslationApp.where(name: params.dig(:filters, :app_name))
          else
            translation_apps = TranslationApp.all
          end

          translation_apps.includes(translation_keys: [:translation_values]).each do |app_record|
            app_record.translation_keys.each do |key_record|
              if params.dig(:filters, :status) == "Missing Default Translation"
                if key_record.translation_values.detect{|x| x.locale == app_record.default_locale}&.translation.blank?
                  missing_key_ids << key_record.id
                end
              else
                if key_record.any_missing_translations?
                  missing_key_ids << key_record.id
                end
              end
            end
          end

          @translation_keys = @translation_keys
            .references(:translation_values)
            .where("#{TranslationValue.table_name}.translation IS NULL OR #{TranslationKey.table_name}.id IN (:ids)", ids: missing_key_ids)
        end
      end
    end

    def set_browser_title
      @browser_title = "Translations"
    end

  end
end
