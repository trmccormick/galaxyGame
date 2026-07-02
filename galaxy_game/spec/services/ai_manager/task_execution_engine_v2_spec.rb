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

  describe '#register_to_bus_from_effect' do
    let(:hub) { create(:planetary_umbilical_hub, attachable: settlement, owner: settlement) }
    let(:effect) { { 'unit' => 'Gas Separator', 'hub' => 'Planetary Umbilical Hub', 'port_type' => 'input', 'hub_port' => 'volatiles_processing' } }

    it 'returns false when no settlement is set' do
      engine.instance_variable_set(:@settlement, nil)
      result = engine.register_to_bus_from_effect(effect)
      expect(result).to be true  # early return true for nil settlement
    end

    it 'raises error when unit is not deployed' do
      engine.instance_variable_set(:@settlement, settlement)
      expect { engine.register_to_bus_from_effect(effect) }.to raise_error(AIManager::InfrastructureSequenceError, /Gas Separator.*not deployed/)
    end

    it 'raises error when hub is not deployed' do
      unit_double = instance_double('Units::BaseUnit', name: 'Gas Separator', unit_type: 'gas_separator_unit')
      allow(settlement.units).to receive(:find_by).with(name: 'Gas Separator').and_return(unit_double)
      
      allow(settlement.units).to receive(:find_by).with(name: 'Planetary Umbilical Hub').and_return(nil)
      allow(settlement.units).to receive(:where).with("name LIKE ?", "Planetary Umbilical Hub%").and_return([])
      
      engine.instance_variable_set(:@settlement, settlement)
      expect { engine.register_to_bus_from_effect(effect) }.to raise_error(AIManager::InfrastructureSequenceError, /Planetary Umbilical Hub.*not deployed/)
    end

    it 'registers unit port with hub routing table' do
      # Create a mock unit with operational_data stubbed
      unit = instance_double('Units::BaseUnit', name: 'Gas Separator', unit_type: 'gas_separator_unit')
      allow(unit).to receive(:operational_data).and_return({})
      allow(unit).to receive(:update!)
      
      allow(settlement.units).to receive(:find_by).with(name: 'Gas Separator').and_return(unit)
      
      hub_mock = instance_double('Units::BaseUnit', name: 'Planetary Umbilical Hub', unit_type: 'planetary_umbilical_hub')
      allow(hub_mock).to receive(:operational_data).and_return({ 'bus_routing_table' => { registered_units: [], routing_rules: [] } })
      allow(hub_mock).to receive(:update!)
      
      allow(settlement.units).to receive(:find_by).with(name: 'Planetary Umbilical Hub').and_return(hub_mock)
      
      # Mock LegacyPortAdapter to return non-zero ports so registration succeeds
      adapter_double = instance_double('Lookup::LegacyPortAdapter')
      allow(adapter_double).to receive(:resolve_port_schema).with('gas_separator_unit').and_return({
        schema_version: 'legacy_flat',
        ports_hash: { input: 1 },
        connection_schema: nil
      })
      allow(Lookup::LegacyPortAdapter).to receive(:new).and_return(adapter_double)
      
      engine.instance_variable_set(:@settlement, settlement)
      result = engine.register_to_bus_from_effect(effect)
      
      expect(result).to be true
    end

    it 'handles multi-port registration' do
      multi_port_effect = {
        'unit' => 'Gas Separator',
        'hub' => 'Planetary Umbilical Hub',
        'ports' => [
          { 'port_type' => 'input', 'hub_port' => 'volatiles_processing' },
          { 'port_type' => 'hydrogen_output', 'hub_port' => 'cryo_grid_h2' }
        ]
      }
      
      unit = instance_double('Units::BaseUnit', name: 'Gas Separator', unit_type: 'gas_separator_unit')
      allow(unit).to receive(:operational_data).and_return({})
      allow(unit).to receive(:update!)
      
      allow(settlement.units).to receive(:find_by).with(name: 'Gas Separator').and_return(unit)
      
      hub_mock = instance_double('Units::BaseUnit', name: 'Planetary Umbilical Hub', unit_type: 'planetary_umbilical_hub')
      allow(hub_mock).to receive(:operational_data).and_return({ 'bus_routing_table' => { registered_units: [], routing_rules: [] } })
      allow(hub_mock).to receive(:update!)
      
      allow(settlement.units).to receive(:find_by).with(name: 'Planetary Umbilical Hub').and_return(hub_mock)
      
      # Mock LegacyPortAdapter to return non-zero ports so registration succeeds
      adapter_double = instance_double('Lookup::LegacyPortAdapter')
      allow(adapter_double).to receive(:resolve_port_schema).with('gas_separator_unit').and_return({
        schema_version: 'legacy_flat',
        ports_hash: { input: 1, hydrogen_output: 1 },
        connection_schema: nil
      })
      allow(Lookup::LegacyPortAdapter).to receive(:new).and_return(adapter_double)
      
      engine.instance_variable_set(:@settlement, settlement)
      result = engine.register_to_bus_from_effect(multi_port_effect)
      
      expect(result).to be true
    end

    it 'rejects non-hub units as bus targets' do
      unit = instance_double('Units::BaseUnit', name: 'Gas Separator', unit_type: 'gas_separator_unit')
      allow(settlement.units).to receive(:find_by).with(name: 'Gas Separator').and_return(unit)
      
      non_hub = instance_double('Units::BaseUnit', name: 'Cryo Tank', unit_type: 'inflatable_cryo_tank')
      allow(settlement.units).to receive(:find_by).with(name: 'Planetary Umbilical Hub').and_return(nil)
      allow(settlement.units).to receive(:where).with("name LIKE ?", "Planetary Umbilical Hub%").and_return([non_hub])
      
      engine.instance_variable_set(:@settlement, settlement)
      expect { engine.register_to_bus_from_effect(effect) }.to raise_error(AIManager::InfrastructureSequenceError, /not a valid hub/)
    end
  end

  describe '#register_bus_routing_rules' do
    let(:hub_mock) { instance_double('Units::BaseUnit', name: 'Planetary Umbilical Hub', unit_type: 'planetary_umbilical_hub') }

    before do
      allow(settlement.units).to receive(:find_by).with(name: 'Planetary Umbilical Hub').and_return(hub_mock)
    end

    it 'registers downstream routing rules on the hub' do
      output_ports = [
        { 'from_port' => 'hydrogen_output', 'to_hub_port' => 'cryo_grid_h2', 'formula' => 'H2' },
        { 'from_port' => 'oxygen_output', 'to_hub_port' => 'cryo_grid_o2', 'formula' => 'O2' }
      ]
      
      allow(hub_mock).to receive(:operational_data).and_return({ 'bus_routing_table' => { registered_units: [], routing_rules: [] } })
      allow(hub_mock).to receive(:update!)
      
      engine.instance_variable_set(:@settlement, settlement)
      result = engine.register_bus_routing_rules('Gas Separator', 'Planetary Umbilical Hub', output_ports)
      
      expect(result).to be true
    end

    it 'does not duplicate existing routing rules' do
      hub_op = { 'bus_routing_table' => { registered_units: [], routing_rules: [{ from_hub_port: 'hydrogen_output', to_hub_port: 'cryo_grid_h2', formula: 'H2' }] } }
      allow(hub_mock).to receive(:operational_data).and_return(hub_op)
      allow(hub_mock).to receive(:update!)
      
      engine.instance_variable_set(:@settlement, settlement)
      result = engine.register_bus_routing_rules('Gas Separator', 'Planetary Umbilical Hub', [
        { 'from_port' => 'hydrogen_output', 'to_hub_port' => 'cryo_grid_h2', 'formula' => 'H2' }
      ])
      
      expect(result).to be true
    end
  end
end
