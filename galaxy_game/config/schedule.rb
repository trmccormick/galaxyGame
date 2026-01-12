# set environmentals
ENV.each { |k, v| env(k, v) }

# set logs and environment
set :output, {:standard => "#{path}/log/cron.log", :error => "#{path}/log/cron_error.log"}
set :environment, ENV['RAILS_ENV']

# Wormhole system jobs
# every 24.hours do
#   runner "WormholeGenerationJob.perform_later"
# end

# every 1.hour do
#   runner "WormholeMaintenanceJob.perform_later"
# end

# every 15.minutes do
#   runner "WormholeShiftJob.perform_later"
# end

# every 1.day, at: '00:00' do
#   runner "MineGccJob.perform_later"
# end

# System maintenance
every 1.day do
  command "cd #{path} && bundle exec rake log:clear"
  command "cd #{path} && bin/rails tmp:clear"
  command "cd #{path} && bin/rails tmp:create"  
  command "cd #{path} && bin/rails restart" # restart the server
end
