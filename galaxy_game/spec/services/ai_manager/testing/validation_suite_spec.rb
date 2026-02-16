# spec/services/ai_manager/testing/validation_suite_spec.rb
require 'rails_helper'

RSpec.describe AIManager::Testing::ValidationSuite, type: :service do
  let(:validation_suite) { described_class.new }

  describe '#run_validation_suite' do
    it 'runs complete validation suite' do
      results = validation_suite.run_validation_suite

      expect(results).to have_key(:timestamp)
      expect(results).to have_key(:validations)
      expect(results).to have_key(:safety_checks)
      expect(results).to have_key(:overall_status)
    end

    it 'includes validation results' do
      results = validation_suite.run_validation_suite

      expect(results[:validations]).to be_a(Hash)
      expect(results[:validations].keys).to include(:decision_structure)
    end

    it 'includes safety check results' do
      results = validation_suite.run_validation_suite

      expect(results[:safety_checks]).to be_a(Hash)
      expect(results[:safety_checks].keys).to include(:no_live_database_writes)
    end
  end

  describe '#validate_ai_behavior' do
    let(:decision_data) do
      {
        type: :resource_acquisition,
        score: 0.8,
        rationale: 'Critical resource shortage requires immediate acquisition'
      }
    end

    it 'validates decision structure' do
      results = validation_suite.validate_ai_behavior(decision_data)

      expect(results).to have_key(:passed)
      expect(results).to have_key(:validations)
      expect(results[:validations].size).to eq(4) # 4 validation checks
    end

    it 'validates expected patterns' do
      patterns = [/resource/]
      results = validation_suite.validate_ai_behavior(decision_data, patterns)

      expect(results[:passed]).to be >= 1
    end
  end

  describe '#validate_ai_safety' do
    let(:operation_data) do
      {
        operations: [
          { type: :database_write, test_mode: true },
          { type: :api_call, mocked: true }
        ]
      }
    end

    it 'validates safety constraints' do
      results = validation_suite.validate_ai_safety(operation_data)

      expect(results).to have_key(:safe)
      expect(results).to have_key(:results)
      expect(results[:results].size).to eq(4) # 4 safety checks
    end

    it 'detects safety violations' do
      unsafe_data = {
        operations: [
          { type: :database_write, test_mode: false } # Live database write
        ]
      }

      results = validation_suite.validate_ai_safety(unsafe_data)

      expect(results[:safe]).to be false
      expect(results[:critical_violations]).to be > 0
    end
  end

  describe '#validate_performance_metrics' do
    let(:metrics_data) do
      {
        average_response_time: 1.2,
        memory_usage: 100.megabytes,
        error_rate: 2.0,
        concurrent_users: 10,
        performance_degradation: 5.0
      }
    end

    it 'validates performance metrics' do
      results = validation_suite.validate_performance_metrics(metrics_data)

      expect(results).to have_key(:passed)
      expect(results).to have_key(:validations)
      expect(results[:validations].size).to eq(4) # 4 performance checks
    end

    it 'detects performance issues' do
      poor_metrics = metrics_data.merge(error_rate: 10.0) # High error rate

      results = validation_suite.validate_performance_metrics(poor_metrics)

      expect(results[:failed]).to be > 0
    end
  end

  describe '#validation_history' do
    before do
      3.times { validation_suite.run_validation_suite }
    end

    it 'returns validation history' do
      history = validation_suite.validation_history

      expect(history.size).to eq(3)
      expect(history.first).to have_key(:timestamp)
    end

    it 'limits history size' do
      history = validation_suite.validation_history(2)

      expect(history.size).to eq(2)
    end
  end

  describe '#validation_statistics' do
    before do
      # Run some validations
      validation_suite.run_validation_suite
    end

    it 'returns validation statistics' do
      stats = validation_suite.validation_statistics

      expect(stats).to have_key(:total_validation_runs)
      expect(stats).to have_key(:pass_rate)
      expect(stats).to have_key(:recent_trend)
    end
  end
end