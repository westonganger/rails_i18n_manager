module RailsI18nManager
  class TranslationAppsController < ApplicationController
    before_action :set_translation_app, only: [:show, :edit, :update, :destroy]

    def index
      @translation_apps = TranslationApp
        .sort_order(params[:sort], params[:direction], base_sort_order: "#{TranslationApp.table_name}.name ASC")
        .multi_search(params[:search])
        .page(params[:page])
    end

    def new
      @translation_app = TranslationApp.new
      render "form"
    end

    def create
      @translation_app = TranslationApp.new(permitted_params)

      if @translation_app.save
        flash[:notice] = "Successfully created."
        redirect_to action: :edit, id: @translation_app.id
      else
        flash.now[:error] = "Create failed."
        render "rails_i18n_manager/translation_apps/form"
      end
    end

    def show
      redirect_to action: :edit
    end

    def edit
      render "form"
    end

    def update
      if @translation_app.update(permitted_params)
        flash[:notice] = "Update success."
        redirect_to action: :index
      else
        flash.now[:error] = "Update failed."
        render "rails_i18n_manager/translation_apps/form"
      end
    end

    def destroy
      if @translation_app.destroy
        flash[:notice] = "Deleted '#{@translation_app.name}'"
      else
        flash[:alert] = "Delete failed"
      end
      redirect_to action: :index
    end

    private

    def set_translation_app
      @translation_app = TranslationApp.find_by!(id: params[:id])
    end

    def set_browser_title
      @browser_title = TranslationApp::NAME.pluralize
    end

    def permitted_params
      params.require(:translation_app).permit(:name, :default_locale, additional_locales: [])
    end

  end
end
