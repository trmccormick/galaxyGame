require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.allow_remote_database_url = true
    DatabaseCleaner.clean_with(:deletion)
    
    # Ensure currencies exist after cleaning
    Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
      c.name = 'Galactic Crypto Currency'
      c.is_system_currency = true
      c.precision = 8
    end
    Financial::Currency.find_or_create_by!(symbol: 'USD') do |c|
      c.name = 'US Dollar'
      c.is_system_currency = true
      c.precision = 2
    end
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
