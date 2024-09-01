require "spec_helper"

ENV["RAILS_ENV"] ||= "test"

require_relative "dummy/config/environment"

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end

if Rails::VERSION::STRING.to_f <= 6.0
  def assert_no_difference(expression, message = nil, &block)
    assert_difference expression, 0, message, &block
  end

  def assert_difference(expression, *args, &block)
    expressions =
      if expression.is_a?(Hash)
        message = args[0]
        expression
      else
        difference = args[0] || 1
        message = args[1]
        Array(expression).index_with(difference)
      end

    exps = expressions.keys.map { |e|
      e.respond_to?(:call) ? e : lambda { eval(e, block.binding) }
    }
    before = exps.map(&:call)

    retval = assert_nothing_raised(&block)

    expressions.zip(exps, before) do |(code, diff), exp, before_value|
      actual = exp.call
      error  = "#{code.inspect} didn't change by #{diff}, but by #{actual - before_value}"
      error  = "#{message}.\n#{error}" if message
      assert_equal(before_value + diff, actual, error)
    end

    retval
  end

  def assert_nothing_raised
    yield.tap { assert(true) }
  rescue => error
    raise Minitest::UnexpectedError.new(error)
  end
end
