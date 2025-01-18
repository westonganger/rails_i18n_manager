require 'slim'
require 'active_sort_order'
require 'kaminari'
require "zip"
require "activerecord-import"
require "csv"
require "easy_translate"

module RailsI18nManager
  class Engine < ::Rails::Engine
    isolate_namespace RailsI18nManager

    paths["app/models"] << "app/lib"

    initializer "rails_i18n_manager.load_static_assets" do |app|
      ### Expose static assets
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
  end
end
