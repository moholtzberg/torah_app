require 'test_helper'
require 'capybara/rails'

class IngrationSupport < ActiveSupport::TestCase

  DatabaseCleaner.strategy = :truncation

  def teardown
    DatabaseCleaner.clean
  end
end
