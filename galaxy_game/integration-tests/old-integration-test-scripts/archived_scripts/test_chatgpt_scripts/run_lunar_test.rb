# app/sample_test_scripts/run_lunar_test.rb

require_relative 'scenario_validator'

file_path = File.join(__dir__, 'lunar_lava_tube_test_build.json')
scenario = TestScripts::ScenarioValidator.new(file_path)
scenario.run