# spec/services/manufacturing/production_service_spec.rb
require 'rails_helper'

RSpec.describe Manufacturing::ProductionService do
  let!(:celestial_body) { CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01') }
  let(:location) do
    create(:celestial_location,
      name: "Shackleton Crater Base",
      celestial_body: celestial_body
    )
  end
  let(:player) { create(:player, active_location: "Shackleton Crater Base") }
  let(:settlement) do
    create(:base_settlement,
      owner: player,
      location: location
    )
  end
  
  let(:service) { described_class.new(settlement) }
  
  let(:blueprint_data) do
    {
      id: '3d_printed_ibeam',
      name: '3D-Printed I-Beam',
      category: 'structural',
      input_quantity_kg: 100,
      production_time_hours: 2.0,
      composition: { 'SiO2' => 43.0, 'Al2O3' => 24.0 },
      additional_materials: [
        { name: 'binding_agent', quantity: 0.1, composition: {} }
      ]
    }
  end
  
  # Setup surface storage with piles
  before do
    unless settlement.inventory.surface_storage
      create(:surface_storage, inventory: settlement.inventory)
    end
  end

  describe '#manufacture_component' do
    context 'with sufficient materials' do
      before do
        # Add raw regolith to surface pile
        surface_pile = settlement.inventory.surface_storage.material_piles.create!(
          material_type: 'raw_regolith',
          amount: 1000,
          quality_factor: 1.0
        )
        
        # Add binding agent to inventory
        settlement.inventory.add_item('binding_agent', 50, player)
      end

      it 'calculates PVE cycles correctly' do
        result = service.manufacture_component(blueprint_data, 1)
        
        expected_cycles = (blueprint_data[:input_quantity_kg] / Manufacturing::ProductionService::PVE_DATA[:output_inert_waste_kg]).ceil
        expect(result[:pve_cycles]).to eq(expected_cycles)
      end

      it 'creates a component production job' do
        expect {
          service.manufacture_component(blueprint_data, 1)
        }.to change { Job.where(job_type: :component_production).count }.by(1)

        job = Job.where(job_type: :component_production).last
        expect(job.operational_data['component_blueprint_id']).to eq('3d_printed_ibeam')
        expect(job.status).to eq('ready_to_claim')
      end

      it 'consumes raw regolith from surface pile' do
        pile = settlement.inventory.surface_storage.material_piles.where(material_type: 'raw_regolith').first
        initial_amount = pile.amount
        
        service.manufacture_component(blueprint_data, 1)
        
        expect(pile.reload.amount).to be < initial_amount
      end

      it 'consumes binding agent from inventory' do
        binding_agent = settlement.inventory.items.find_by(name: 'binding_agent')
        initial_amount = binding_agent.amount
        
        service.manufacture_component(blueprint_data, 1)
        
        expect(binding_agent.reload.amount).to be < initial_amount
      end

      it 'produces water to inventory' do
        initial_water = settlement.inventory.items.find_by(name: 'water')&.amount || 0
        
        service.manufacture_component(blueprint_data, 1)
        
        final_water = settlement.inventory.items.find_by(name: 'water').amount
        expect(final_water).to eq(initial_water + (service.calculate_pve_cycles(blueprint_data[:input_quantity_kg]) * Manufacturing::ProductionService::PVE_DATA[:output_water_kg]))
      end

      it 'produces gases to inventory' do
        initial_gas = settlement.inventory.items.find_by(name: 'gases')&.amount || 0
        
        service.manufacture_component(blueprint_data, 1)
        
        final_gas = settlement.inventory.items.find_by(name: 'gases').amount
        expect(final_gas).to eq(initial_gas + (service.calculate_pve_cycles(blueprint_data[:input_quantity_kg]) * Manufacturing::ProductionService::PVE_DATA[:output_gases_kg]))
      end

      it 'produces inert waste to surface pile' do
        service.manufacture_component(blueprint_data, 1)
        
        pile = settlement.inventory.surface_storage.material_piles.where(material_type: 'depleted_regolith').first
        expect(pile.amount).to be > 0
      end

      it 'creates final component in inventory' do
        expect {
          service.manufacture_component(blueprint_data, 2)
        }.to change { settlement.inventory.items.where(name: '3D-Printed I-Beam').count }.by(1)

        component = settlement.inventory.items.find_by(name: '3D-Printed I-Beam')
        expect(component.amount).to eq(2)
      end

      it 'returns comprehensive production report' do
        result = service.manufacture_component(blueprint_data, 1)
        
        expect(result).to have_key(:pve_cycles)
        expect(result).to have_key(:total_water)
        expect(result).to have_key(:total_gas)
        expect(result).to have_key(:total_inert_waste)
        expect(result).to have_key(:component_produced)
        expect(result).to have_key(:component_amount)
        expect(result).to have_key(:job_id)
        expect(result).to have_key(:materials_consumed)
        expect(result).to have_key(:byproducts)
        
        expect(result[:component_produced]).to eq('3d_printed_ibeam')
        expect(result[:component_amount]).to eq(1)
      end

      it 'tracks byproducts in job operational data' do
        service.manufacture_component(blueprint_data, 1)
        
        job = Job.where(job_type: :component_production).last
        expect(job.operational_data['byproducts']).to be_present
        expect(job.operational_data['byproducts'].first).to have_key('cycle')
        expect(job.operational_data['byproducts'].first).to have_key('water_kg')
        expect(job.operational_data['byproducts'].first).to have_key('gases_kg')
        expect(job.operational_data['byproducts'].first).to have_key('inert_waste_kg')
      end
    end

    context 'with insufficient raw regolith' do
      before do
        # Add very little raw regolith
        settlement.inventory.surface_storage.material_piles.create!(
          material_type: 'raw_regolith',
          amount: 1,
          quality_factor: 1.0
        )
        
        settlement.inventory.add_item('binding_agent', 50, player)
      end

      it 'raises an error' do
        expect {
          service.manufacture_component(blueprint_data, 1)
        }.to raise_error(/Insufficient materials/)
      end

      it 'does not consume any materials on failure' do
        pile = settlement.inventory.surface_storage.material_piles.where(material_type: 'raw_regolith').first
        binding_agent = settlement.inventory.items.find_by(name: 'binding_agent')
        initial_pile_amount = pile.amount
        initial_binding_amount = binding_agent.amount
        
        expect {
          service.manufacture_component(blueprint_data, 1)
        }.to raise_error(/Insufficient materials/)
        
        expect(pile.reload.amount).to eq(initial_pile_amount)
        expect(binding_agent.reload.amount).to eq(initial_binding_amount)
      end
    end

    context 'with insufficient binding agent' do
      before do
        settlement.inventory.surface_storage.material_piles.create!(
          material_type: 'raw_regolith',
          amount: 1000,
          quality_factor: 1.0
        )
        
        # Add very little binding agent
        settlement.inventory.add_item('binding_agent', 0.01, player)
      end

      it 'raises an error' do
        expect {
          service.manufacture_component(blueprint_data, 1)
        }.to raise_error(/Insufficient materials/)
      end
    end

    context 'with no surface storage' do
      before do
        settlement.inventory.surface_storage&.destroy
        settlement.inventory.reload
      end

      it 'raises an error on initialization' do
        expect {
          described_class.new(settlement)
        }.to raise_error(/Surface Storage not initialized/)
      end
    end
  end

  describe '#run_unit_cycle' do
    context 'with PVE unit type' do
      let(:input_material) do
        { quantity: 5.0, composition: { 'SiO2' => 43.0 } }
      end

      it 'returns correct yield data' do
        result = service.run_unit_cycle(:pve, input_material)
        
        expect(result[:input_kg]).to eq(5.0)
        expect(result[:output_gases_kg]).to eq(0.05)
        expect(result[:output_water_kg]).to eq(0.10)
        expect(result[:output_inert_waste_kg]).to eq(4.85)
        expect(result[:unit_type]).to eq(:pve)
        expect(result[:composition]).to eq({ 'SiO2' => 43.0 })
      end

      it 'scales output based on input quantity' do
        input = { quantity: 10.0, composition: {} }
        result = service.run_unit_cycle(:pve, input)
        
        expect(result[:output_gases_kg]).to eq(0.10)  # Double the base rate
        expect(result[:output_water_kg]).to eq(0.20)   # Double the base rate
        expect(result[:output_inert_waste_kg]).to eq(9.70)  # Double the base rate
      end
    end

    context 'with TEU unit type' do
      let(:input_material) do
        { quantity: 5.0, composition: {} }
      end

      it 'returns correct yield data' do
        result = service.run_unit_cycle(:teu, input_material)
        
        expect(result[:unit_type]).to eq(:teu)
        expect(result[:output_inert_waste_kg]).to eq(4.85)
      end
    end

    context 'with unknown unit type' do
      it 'raises an error' do
        expect {
          service.run_unit_cycle(:unknown, {})
        }.to raise_error(/Unknown unit type: unknown/)
      end
    end
  end

  describe '#calculate_pve_cycles' do
    it 'calculates cycles needed for required inert waste' do
      # Need 10kg inert waste, each cycle produces 4.85kg
      cycles = service.calculate_pve_cycles(10.0)
      expect(cycles).to eq(3)  # ceil(10 / 4.85) = 3
    end

    it 'handles exact cycle requirements' do
      # Need exactly 4.85kg inert waste, each cycle produces 4.85kg
      cycles = service.calculate_pve_cycles(4.85)
      expect(cycles).to eq(1)
    end

    it 'handles very small requirements' do
      cycles = service.calculate_pve_cycles(0.1)
      expect(cycles).to eq(1)  # Always at least 1 cycle
    end
  end

  describe '#run_pve_cycles' do
    it 'aggregates results from multiple cycles' do
      result = service.run_pve_cycles(3, { composition: {} })
      
      expect(result[:total_water]).to be_within(0.0001).of(0.30)  # 3 * 0.10
      expect(result[:total_gas]).to be_within(0.0001).of(0.15)    # 3 * 0.05
      expect(result[:total_inert_waste]).to be_within(0.0001).of(14.55)  # 3 * 4.85
      expect(result[:byproducts].length).to eq(3)
    end

    it 'tracks byproducts per cycle' do
      result = service.run_pve_cycles(2, { composition: {} })
      
      expect(result[:byproducts][0][:cycle]).to eq(1)
      expect(result[:byproducts][1][:cycle]).to eq(2)
      expect(result[:byproducts][0][:water_kg]).to eq(0.10)
    end
  end

  describe '#validate_materials_available' do
    before do
      settlement.inventory.add_item('test_material', 100, player)
    end

    it 'passes when materials are sufficient' do
      materials = { 'test_material' => { amount: 50, composition: {} } }
      
      expect {
        service.validate_materials_available(materials)
      }.not_to raise_error
    end

    it 'raises error when materials are insufficient' do
      materials = { 'test_material' => { amount: 150, composition: {} } }
      
      expect {
        service.validate_materials_available(materials)
      }.to raise_error(/Insufficient materials/)
    end
  end

  describe '#consume_materials' do
    before do
      settlement.inventory.add_item('material_a', 60, player)
      settlement.inventory.add_item('material_b', 40, player)
    end

    it 'consumes from multiple items' do
      # Add a second item row for material_a to genuinely test multi-row consumption
      settlement.inventory.add_item('material_a', 50, player, { batch: 'b2' })
      
      materials = {
        'material_a' => { amount: 80, composition: {} },
        'material_b' => { amount: 20, composition: {} }
      }
      
      service.consume_materials(materials)
      
      expect(settlement.inventory.items.where(name: 'material_a').sum(:amount)).to eq(30)
      expect(settlement.inventory.items.find_by(name: 'material_b').amount).to eq(20)
    end

    it 'destroys items fully consumed' do
      materials = { 'material_a' => { amount: 60, composition: {} } }
      
      service.consume_materials(materials)
      
      expect(settlement.inventory.items.where(name: 'material_a').count).to eq(0)
    end

    it 'raises error if consumption fails mid-way' do
      materials = {
        'material_a' => { amount: 60, composition: {} },
        'material_b' => { amount: 50, composition: {} }  # Only 40 available
      }
      
      expect {
        service.consume_materials(materials)
      }.to raise_error(/Insufficient materials|Failed to consume/)
    end
  end

  describe '#consume_from_pile' do
    before do
      @pile = settlement.inventory.surface_storage.material_piles.create!(
        material_type: 'test_pile',
        amount: 100,
        quality_factor: 1.0
      )
    end

    it 'reduces pile amount' do
      service.consume_from_pile('test_pile', 30)
      expect(@pile.reload.amount).to eq(70)
    end

    it 'raises error if pile insufficient' do
      expect {
        service.consume_from_pile('test_pile', 150)
      }.to raise_error(/Insufficient material in pile/)
    end

    it 'raises error if pile does not exist' do
      expect {
        service.consume_from_pile('nonexistent_pile', 10)
      }.to raise_error(/Insufficient material in pile/)
    end
  end

  describe '#produce_to_pile' do
    it 'creates new pile if it does not exist' do
      service.produce_to_pile('new_pile', 50)
      
      pile = settlement.inventory.surface_storage.material_piles.where(material_type: 'new_pile').first
      expect(pile).to be_present
      expect(pile.amount).to eq(50)
    end

    it 'adds to existing pile' do
      pile = settlement.inventory.surface_storage.material_piles.create!(
        material_type: 'existing_pile',
        amount: 100,
        quality_factor: 1.0
      )
      
      service.produce_to_pile('existing_pile', 50)
      expect(pile.reload.amount).to eq(150)
    end
  end

  describe '#produce_to_inventory' do
    it 'adds item to inventory' do
      initial_count = settlement.inventory.items.where(name: 'test_product').count
      
      service.produce_to_inventory('test_product', 25)
      
      final_count = settlement.inventory.items.where(name: 'test_product').count
      expect(final_count).to eq(initial_count + 1)
      
      item = settlement.inventory.items.find_by(name: 'test_product')
      expect(item.amount).to eq(25)
    end
  end

  describe 'PVE metrics preservation' do
    it 'maintains correct PVE_DATA ratios' do
      input = { quantity: 5.0, composition: {} }
      result = service.run_unit_cycle(:pve, input)
      
      expect(result[:output_gases_kg] / result[:input_kg]).to eq(0.01)  # 0.05/5.0
      expect(result[:output_water_kg] / result[:input_kg]).to eq(0.02)  # 0.10/5.0
      expect(result[:output_inert_waste_kg] / result[:input_kg]).to eq(0.97)  # 4.85/5.0
    end

    it 'preserves total mass balance' do
      input = { quantity: 5.0, composition: {} }
      result = service.run_unit_cycle(:pve, input)
      
      total_output = result[:output_gases_kg] + result[:output_water_kg] + result[:output_inert_waste_kg]
      expect(total_output).to be_within(0.01).of(result[:input_kg])
    end
  end
end
