# spec/services/ai_manager/task_execution_engine_v2_spec.rb
require 'rails_helper'

RSpec.describe AIManager::TaskExecutionEngineV2, type: :service do
  let(:settlement) { create(:base_settlement) }
  let(:celestial_body) { settlement.location&.celestial_body || settlement }
  let(:engine) { described_class.new(celestial_body, {}) }

  describe '.execute_resource_task' do
    let(:action) { { resources: ['electronics'] } }

    it 'returns false when resources list is empty' do
      action = { resources: [] }
      result = described_class.execute_resource_task(engine, settlement, action)
      expect(result).to be false
    end

    it 'uses real pricing data via NpcPriceCalculator' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'electronics').and_return(850.0)
      allow(engine).to receive(:request_import).with(settlement, 'electronics').and_return(true)

      result = described_class.execute_resource_task(engine, settlement, action)
      
      expect(Market::NpcPriceCalculator).to have_received(:calculate_bid).with(settlement, 'electronics')
      expect(result).to be true
    end

    it 'skips resources with no valid price' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'unknown_resource').and_return(nil)
      allow(engine).to receive(:request_import).never

      result = described_class.execute_resource_task(engine, settlement, { resources: ['unknown_resource'] })
      
      expect(result).to be false
    end

    it 'logs import price when pricing succeeds' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'electronics').and_return(850.0)
      allow(engine).to receive(:request_import).with(settlement, 'electronics').and_return(true)
      expect(Rails.logger).to receive(:info).with(/Importing electronics at 850.0 GCC\/kg/)

      described_class.execute_resource_task(engine, settlement, action)
    end

    it 'handles multiple resources' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'electronics').and_return(850.0)
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'nitrogen').and_return(420.0)
      allow(engine).to receive(:request_import).with(settlement, 'electronics').and_return(true)
      allow(engine).to receive(:request_import).with(settlement, 'nitrogen').and_return(true)

      result = described_class.execute_resource_task(engine, settlement, { resources: ['electronics', 'nitrogen'] })
      
      expect(result).to be true
    end
  end

  describe '#request_import' do
    it 'returns false when NpcPriceCalculator returns nil price' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'electronics').and_return(nil)
      expect(Rails.logger).to receive(:warn).with(/No valid price for electronics/)

      result = engine.request_import(settlement, 'electronics')
      expect(result).to be false
    end

    it 'returns false when NpcPriceCalculator returns zero price' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'electronics').and_return(0.0)
      expect(Rails.logger).to receive(:warn).with(/No valid price for electronics/)

      result = engine.request_import(settlement, 'electronics')
      expect(result).to be false
    end

    it 'logs import price and delegates to ServiceCoordinator when price is valid' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'electronics').and_return(850.0)
      coordinator_double = instance_double(AIManager::ServiceCoordinator)
      allow(coordinator_double).to receive(:acquire_resource).with('electronics', 100, settlement).and_return(true)
      allow(AIManager::ServiceCoordinator).to receive(:new).and_return(coordinator_double)

      result = engine.request_import(settlement, 'electronics')
      expect(result).to be true
    end
  end

  describe '#request_import_from_effect' do
    let(:effect) { { 'resource' => 'nitrogen', 'quantity' => 100 } }

    it 'returns false when no settlement is set' do
      engine.instance_variable_set(:@settlement, nil)
      result = engine.request_import_from_effect(effect)
      expect(result).to be false
    end

    it 'returns false when price is invalid' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'nitrogen').and_return(nil)
      
      engine.instance_variable_set(:@settlement, settlement)
      result = engine.request_import_from_effect(effect)
      expect(result).to be false
    end

    it 'delegates to ServiceCoordinator when price is valid' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'nitrogen').and_return(420.0)
      coordinator_double = instance_double(AIManager::ServiceCoordinator)
      allow(coordinator_double).to receive(:acquire_resource).with('nitrogen', 100, settlement).and_return(true)
      allow(AIManager::ServiceCoordinator).to receive(:new).and_return(coordinator_double)

      engine.instance_variable_set(:@settlement, settlement)
      result = engine.request_import_from_effect(effect)
      expect(result).to be true
    end
  end
end
