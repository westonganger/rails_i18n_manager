$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "rails_i18n_manager/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "rails_i18n_manager"
  spec.version     = RailsI18nManager::VERSION
  spec.authors     = ["Weston Ganger"]
  spec.email       = ["weston@westonganger.com"]
  spec.homepage    = "https://github.com/westonganger/rails_i18n_manager"
  spec.summary     = "Web interface to manage i18n translations for your apps to facilitate the editors of your translations. Provides a low-tech and complete workflow for importing, translating, and exporting your I18n translation files. Design to allows you to keep the translation files inside your projects git repository where they should be."
  spec.description = spec.summary
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib,public}/**/*", "LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "slim"
  spec.add_dependency "kaminari"
  spec.add_dependency "active_sort_order"
  spec.add_dependency "easy_translate" ### no grpc dependency
  spec.add_dependency "rubyzip"
  spec.add_dependency "activerecord-import"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "rails-controller-testing"
  spec.add_development_dependency "faker"
  spec.add_development_dependency "minitest_change_assertions"
end
