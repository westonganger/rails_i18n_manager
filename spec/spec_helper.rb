require "rails_helper"
require "database_cleaner"
require "factory_bot_rails"
require "faker"
require "minitest_change_assertions"
require "rspec-html-matchers"

require "active_support/all"

RSpec.configure do |config|
  config.include RSpecHtmlMatchers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.example_status_persistence_file_path = "spec/examples.txt"

  config.disable_monkey_patching!

  config.order = :random

  Kernel.srand(config.seed)

  config.before(:suite) do
    ### PERFORMS CLEAN IMMEDIATELY
    DatabaseCleaner.clean_with(:truncation)

    #DatabaseCleaner.strategy = :truncation, { except: [], pre_count: true }
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before(:each) do
    RailsI18nManager.config.google_translate_api_key = "foobar"
  end

  require "rails-controller-testing"
  RSpec.configure do |config|
    [:controller, :view, :request].each do |type|
      config.include ::Rails::Controller::Testing::TestProcess, type: type
      config.include ::Rails::Controller::Testing::TemplateAssertions, :type => type
      config.include ::Rails::Controller::Testing::Integration, :type => type
    end
  end

end
