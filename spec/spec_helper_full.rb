require_relative 'spec_helper_lite'
#require_relative '../config/environment.rb'

module SpecHelpers
  def setup_database
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.start
  end

  def teardown_database
    DatabaseCleaner.clean
  end
end
