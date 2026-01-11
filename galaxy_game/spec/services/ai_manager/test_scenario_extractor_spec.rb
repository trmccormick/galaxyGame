require 'rails_helper'
require_relative '../../../app/services/ai_manager'


RSpec.describe AIManager::TestScenarioExtractor do
  describe '.extract_training_scenarios' do
    it 'extracts realistic settlement scenarios from test mocks' do
      scenarios = described_class.extract_training_scenarios

      expect(scenarios).to be_an(Array)
      expect(scenarios.count).to be >= 3

      # Check critical scenario structure
      critical_scenario = scenarios.find { |s| s[:scenario_id] == 'critical_life_support_failure' }
      expect(critical_scenario).to be_present
      expect(critical_scenario[:settlement_state][:oxygen_level]).to eq(15)
      expect(critical_scenario[:expected_decision][:action]).to eq(:emergency_procurement)
    end

    it 'includes operational and expansion scenarios' do
      scenarios = described_class.extract_training_scenarios

      operational = scenarios.find { |s| s[:scenario_id] == 'resource_procurement_needed' }
      expansion = scenarios.find { |s| s[:scenario_id] == 'stable_expansion_opportunity' }

      expect(operational[:expected_decision][:action]).to eq(:resource_procurement)
      expect(expansion[:expected_decision][:action]).to eq(:expansion)
    end
  end

  describe '.convert_to_training_format' do
    it 'converts scenarios to AI training format' do
      scenarios = described_class.extract_training_scenarios
      training_data = described_class.convert_to_training_format(scenarios)

      expect(training_data.first).to have_key(:input_state)
      expect(training_data.first).to have_key(:output_decision)
      expect(training_data.first).to have_key(:reward_function)
      expect(training_data.first[:confidence_score]).to eq(0.9)
    end
  end
end