# spec/support/lookup_services.rb
RSpec.configure do |config|
  # Clear lookup service caches between tests
  config.before(:each, type: :service) do
    if defined?(Lookup::UnitLookupService)
      # Clear any instance variables that might cache data
      Lookup::UnitLookupService.class_eval do
        @instance = nil if instance_variable_defined?(:@instance)
      end
    end
  end
  
  # Suppress debug logging for cleaner test output
  config.before(:each, type: :service) do
    allow(Rails.logger).to receive(:debug) unless ENV['DEBUG_TESTS']
  end
end