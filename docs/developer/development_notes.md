## Testing and Quality Control 
The test suite includes rspec, capybara, selnium, simplecov, CircleCI, and code climate. 
Javascript is difficult to test by iteself.  To run tests locally uncomment the selenium docker container and adjust capybara setups. 
`RAILS_ENV=test bundle exec rspec` this helps to ensure that all gems are loaded appropriately and you do not get the `shoulda error`.  

Notes: for testing
run the following to configure the test database
`RAILS_ENV=test bin/rails db:create db:migrate` add `db:seed` if you need seed data for your tests (shouldn't be needed if using factories correctly)

run use the following to run all rspec tests
`RAILS_ENV=test bundle exec rspec`

to reset the database use. Useful if adjusting migrations and resetting the test database
`RAILS_ENV=test bin/rails db:drop db:create db:migrate`

### Troubleshooting
Using Chatgpt to generate some of this code based on the original java version. 

### testing
set this first before running migrations
bin/rails db:environment:set RAILS_ENV=test
bin/rails db:environment:set RAILS_ENV=development

RAILS_ENV=test bin/rails db:create db:migrate db:seed
RAILS_ENV=test bin/rails db:drop db:create db:migrate db:seed
RAILS_ENV=test bin/rails db:drop:_unsafe db:create db:migrate db:seed

RAILS_ENV=test bin/rails runner app/sample_test_scripts/scenario_tester.rb
RAILS_ENV=test bundle exec rspec spec/services/lookup/unit_lookup_service_spec.rb

RAILS_ENV=test bundle exec rspec 

RAILS_ENV=test bundle exec rspec --format documentation spec/models/craft/base_craft_spec.rb
RAILS_ENV=test bundle exec rspec --format documentation spec/models/item_spec.rb

RAILS_ENV=test bundle exec rspec ./spec/services/unit_module_assembly_service_spec.rb

RAILS_ENV=test bundle exec rspec ./spec/models/concerns/has_units_spec.rb
RAILS_ENV=test bundle exec rspec ./spec/services/fitting_service_spec.rb
RAILS_ENV=test bundle exec rspec ./spec/models/celestial_bodies/planets/ocean/ocean_planet_spec.rb

## integration testing
bin/rails r integration-tests/gcc_mining_sat.rb
RAILS_ENV=test bin/rails r integration-tests/gcc_mining_sat_integration_simplified.rb
RAILS_ENV=test bin/rails r integration-tests/gcc_mining_sat_integration_production.rb

## currently testing 04/28/2025
# set the enviroment
bin/rails db:environment:set RAILS_ENV=test

# prepend this before running tests below
RAILS_ENV=test LOG_LEVEL=debug bundle exec 

# current tests we are looking at
rspec ./spec/services/terra_sim/biosphere_simulation_service_spec.rb:165

# failing tests to revisit
RAILS_ENV=test bundle exec rspec --format documentation spec/models/item_spec.rb
 - seems that regolith handeling is causing issues with the tests. 5/29/25

# using ollama to generate json data
insure you have a model installed
`curl http://ollama:11434/api/tags` - from your we container test. It it's empty install llama3 or another model.

docker -exec -it ollama bash

the run 
ollama pull llama3
ollama pull llama2
ollama pull mistral
ollama pull gemma:2b

12/08/25 -
 running the pipeline testing
 RAILS_ENV=test bundle exec rake venus_mars:pipeline_v2 > ./log/pipeline.log 2>&1

12/09/25
 run all rspec saving to log file
 RAILS_ENV=test bundle exec rspec > ./log/rspec_full.log

 RAILS_ENV=test bundle exec rspec ./spec/integration/terraforming_integration_spec.rb > ./log/integration.log

RAILS_ENV=test bundle exec rspec > ./log/rspec_full.log

RAILS_ENV=test bundle exec rspec ./spec/models/biology/biosphere_integration_spec.rb

--------
test passing locally but failing on full run
-------
RAILS_ENV=test bundle exec rspec ./spec/services/construction/skylight_service_spec.rb

