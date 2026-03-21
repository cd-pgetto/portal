ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/spec"
require "minitest/mock"
require "simplecov"

SimpleCov.start "rails" do
  enable_coverage :branch
end

Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |f| require f }

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
    include FactoryBot::Syntax::Methods
    extend Minitest::Spec::DSL

    unless ENV["NOCOVERAGE"]
      parallelize_setup { |worker| SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}" }
      parallelize_teardown { |worker| SimpleCov.result }
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include SignInHelper
  end
end
