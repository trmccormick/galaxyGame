# spec/services/ai_manager/testing/bootstrap_controller_spec.rb
require 'rails_helper'
require_relative '../../../../app/services/ai_manager/testing/bootstrap_controller'

RSpec.describe AIManager::Testing::BootstrapController, type: :service do
  let(:bootstrap_controller) { described_class.new }

  describe '#initialize' do
    it 'initializes with default scenario' do
      expect(bootstrap_controller.test_scenario).to eq(:default)
      expect(bootstrap_controller.settlement).to be_nil
      expect(bootstrap_controller.initialized?).to be false
    end

    it 'accepts custom scenario' do
      controller = described_class.new(:resource_crisis)
      expect(controller.test_scenario).to eq(:resource_crisis)
    end
  end

  describe '#bootstrap_test_environment' do
    before do
      allow_any_instance_of(Settlement::BaseSettlement).to receive(:save).and_return(true)
      allow_any_instance_of(Settlement::BaseSettlement).to receive(:persisted?).and_return(true)
      allow_any_instance_of(Settlement::BaseSettlement).to receive(:id).and_return(rand(10000..99999))
      allow_any_instance_of(Settlement::BaseSettlement).to receive(:inventory).and_return(double('inventory'))
    end

    it 'bootstraps test environment successfully' do
      result = bootstrap_controller.bootstrap_test_environment

      expect(result).to be_a(Hash)
      expect(result[:scenario]).to eq(:default)
      expect(bootstrap_controller.initialized?).to be true
    end

    it 'creates isolated settlement' do
      bootstrap_controller.bootstrap_test_environment

      settlement = bootstrap_controller.settlement
      expect(settlement).to be_a(Settlement::BaseSettlement)
      expect(settlement.name).to include('[TEST]')
    end

    it 'generates system data' do
      bootstrap_controller.bootstrap_test_environment

      system_data = bootstrap_controller.system_data
      expect(system_data).to have_key(:celestial_bodies)
      expect(system_data[:celestial_bodies]).to be_an(Array)
    end

    it 'initializes test resources' do
      bootstrap_controller.bootstrap_test_environment

      resources = bootstrap_controller.resources
      expect(resources).to have_key('Iron')
      expect(resources['Iron'][:available]).to be > 0
    end
  end

  describe '#reset_environment' do
    before do
      bootstrap_controller.bootstrap_test_environment
    end

    it 'resets environment to clean state' do
      expect(bootstrap_controller.initialized?).to be true

      bootstrap_controller.reset_environment

      expect(bootstrap_controller.initialized?).to be false
      expect(bootstrap_controller.settlement).to be_nil
      expect(bootstrap_controller.system_data).to be_empty
    end
  end

  describe '#environment_status' do
    it 'returns environment status' do
      status = bootstrap_controller.environment_status

      expect(status).to have_key(:initialized)
      expect(status).to have_key(:scenario)
      expect(status).to have_key(:settlement_id)
    end

    it 'shows initialized status after bootstrap' do
      bootstrap_controller.bootstrap_test_environment

      status = bootstrap_controller.environment_status
      expect(status[:initialized]).to be true
      expect([Integer, NilClass]).to include(status[:settlement_id].class)
    end
  end

  describe 'scenario configurations' do
    it 'applies resource_crisis scenario' do
      controller = described_class.new(:resource_crisis)
      controller.bootstrap_test_environment

      resources = controller.resources
      expect(resources['Iron'][:available]).to be < 1000 # Low resources
    end

    it 'applies expansion_ready scenario' do
      controller = described_class.new(:expansion_ready)
      controller.bootstrap_test_environment

      settlement = controller.settlement
      expect(settlement.current_population).to be > 400 # High population
    end
  end
end