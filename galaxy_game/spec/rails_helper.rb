# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'

require File.expand_path('../../config/environment', __FILE__)
ENV["RAILS_ENV"] ||= 'test'

# RUN RAILS
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!

# require shoulda-matchers
require 'shoulda/matchers'

# require support files 
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }
Dir[Rails.root.join('spec', 'shared', '*.rb')].each { |f| require f }
# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # configure rspec
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include ActiveJob::TestHelper

  # Shoulda Matchers
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
