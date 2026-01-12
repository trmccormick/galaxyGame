# Ensure Capybara uses localhost to avoid host authorization errors
RSpec.configure do |config|
  config.before(:each, type: :feature) do
    Capybara.app_host = 'http://localhost'
  end
end
