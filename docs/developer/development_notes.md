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


01/10/26
-------

"Grok, execute all commands ONLY within the web docker container. 

We need to finalize the 'Galaxy Game' economic loop.

1. UPDATE NpcPriceCalculator:
   - Anchor the cost-based logic to our real-world pricing JSON files.
   - Enforce the 'Earth Anchor Price' (EAP) as a strict ceiling. If a Player Sell Order > EAP, the NPC AIManager must choose to import from Earth instead of buying from the player.

2. IMPLEMENT Internal B2B Contracts:
   - Create a 'LogisticsContract' for NPC-to-NPC transfers (e.g., LDC to AstroLift). 
   - These transfers should be private and handle predictable refueling/byproduct needs outside the public market.

3. IMPLEMENT Player Special Missions:
   - When an NPC need is critical and not met by internal logistics, generate a 'SpecialMission' object.
   - Reward: GCC (based on EAP) + a specific bonus to attract player intervention.

4. UPDATE SPECS:
   - Test the EAP ceiling logic: NPC should reject expensive player goods.
   - Test internal CorporateContract resource movement.

REMINDER: All tests must pass, and all operations must stay inside the docker container."


-------

"Grok, execute all commands ONLY within the web docker container. 

Please review the last full rspec run focus on the spec with the highest failures and begin working on code corrections to make these test pass again. 

REMINDER: All tests must pass, and all operations must stay inside the docker container."


-------
"Grok, execute all commands ONLY within the web docker container.

Objective: Initialize the Megastructure architectural category and deploy the Skyhook_MK1 blueprint as the primary Venus-system logistics solution.

Task 1: Establish Megastructure Model Architecture

Create a new Megastructure base class (distinct from BaseStructure) to handle dynamic, planetary-scale assets.

Implement a momentum_exchange_log to track the "Orbital Energy" of the structure. Every catch/launch must subtract or add to the structure's altitude, requiring periodic re-boosts from the Orbital Propellant Depot.

Task 2: Create megastructure_skyhook_mk1_bp.json

Required Materials: 800,000 kg of carbon_nanotube_structural_cable (sourced from the CNT Forge) and 12 imported high_stress_magnetic_grapples.

Physics Specs: Define a 1,400 km rotating tether with a tip speed of ~3.5 km/s to synchronize with atmospheric skimmers.

Energy Draw: 10 MW for rotational maintenance, supplied by the Planetary Staging Hub link.

Task 3: Update Construction::LogisticsService & SIM_Evaluator

Update the LogisticsService to prioritize local CNT stock for the Skyhook build.

In the SIM_Evaluator, update the Venus_Pattern: Once the L1 Station and Depot are operational and CNT reserves hit 800 tons, automatically trigger the Skyhook Megastructure Project.

REMINDER: All operations must stay inside the docker container. Run a full RSpec suite upon completion to ensure the new Megastructure logic doesn't conflict with existing SpaceStation modules."



-------------
That is a very smart call. Moving the Skyhook and Elevator to a "Future Expansion" bucket prevents the project from becoming a "physics simulator" and keeps us focused on the Playable Game Loop.

By deferring the megastructures, we can focus on the immediate, tangible mechanics that make the "Gateway Oligopoly" actually work: Harvesting, Refining, and the Market.

🎯 Re-Focusing the Vision
Now that we've pruned the "extra" branches, our "North Star" for the Venus/Super-Mars setup is:

Harvesting: Getting gas/minerals via skimmers and miners.

Refining: Turning that raw material into "Structural Carbon" or "Metals" to stop paying Earth-import fees.

Monetizing: Selling the fuel or materials via the Wormhole Market for GCC.

🛠️ The "Back-to-Basics" Grok Task
This command will have Grok finalize the Industrial Refinery and ensure the Market is tracking the profit correctly, without any of the Skyhook over-engineering.

"Grok, execute all commands ONLY within the web docker container.

Objective: Finalize the Core Industrial and Market Loop for the Venus/Super-Mars systems.

Task 1: Consolidate the Industrial Refinery

Ensure the Industrial_Refinery_Module is active on the Staging Hub Mk1.

It should perform one simple conversion: Atmospheric CO2 (Harvester Input) + Power -> Structural Carbon (Construction Resource).

This Structural Carbon must be usable by the Construction::LogisticsService to replace "imported" steel panels.

Task 2: Fix the Financial Ledger for Trade

Review the VirtualLedgerService.

Ensure that when the player (or AI) produces Structural Carbon or Methane Fuel, the USD/GCC savings are explicitly logged as "In-Situ Savings" in the ledger.

This allows the player to see exactly how much money their station is saving them compared to buying from Earth.

Task 3: Polish the SIM_Evaluator

Ensure the SIM_Evaluator correctly prioritizes Resource Self-Sufficiency.

If a station is built, the very next step should be "Activate Refinery" and "Set Up Harvester Route."

REMINDER: All operations must stay inside the docker container. Ensure all RSpec tests pass, specifically focusing on the LedgerEntry model and ConstructionService integration."


"Grok, execute all commands ONLY within the web docker container.

We need to continue testing to resolve the rspec failurs
 1. please run "RAILS_ENV=test bundle exec rspec > ./log/rspec_full_{unix timestamp}.log" using the unix timestamp to make it unique. 
 2. Review the log and Identify the top 4 specs with the highest failure rates and work on them in order highest to lowest.

Start by running each spec individually to identify the specific failure patterns. 

CRITICAL CONSTRAINTS:
- Fix ONE spec file completely before moving to the next
- Run full spec file after each fix to catch regressions
- Document the root cause of each failure pattern
- All operations must stay inside the docker container
- All tests must pass before proceeding

REMINDER: All tests must pass, and all operations must stay inside the docker container."

