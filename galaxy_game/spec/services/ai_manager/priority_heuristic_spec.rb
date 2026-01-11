require 'rails_helper'
require_relative '../../../app/services/ai_manager'


RSpec.describe AIManager::PriorityHeuristic, type: :service do
  let(:settlement) { create(:base_settlement, :station) }
  let(:priority_heuristic) { described_class.new(settlement) }

  describe '#oxygen_critical?' do
    context 'when O2 mass is above 15% of target' do
      before do
        # Set up structure with sufficient O2
        structure = create(:base_structure, settlement: settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'oxygen' => 200.0 }))
      end

      it 'returns false' do
        expect(priority_heuristic.oxygen_critical?).to be false
      end
    end

    context 'when O2 mass is below 15% of target' do
      before do
        # Set up structure with insufficient O2
        structure = create(:base_structure, settlement: settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'oxygen' => 100.0 }))
      end

      it 'returns true' do
        expect(priority_heuristic.oxygen_critical?).to be true
      end
    end
  end

  describe '#account_negative?' do
    context 'when account balance is positive' do
      before do
        settlement.account.update!(balance: 1000.0)
      end

      it 'returns false' do
        expect(priority_heuristic.account_negative?).to be false
      end
    end

    context 'when account balance is negative' do
      before do
        settlement.account.update!(balance: -500.0)
      end

      it 'returns true' do
        expect(priority_heuristic.account_negative?).to be true
      end
    end
  end

  describe '#get_priorities' do
    context 'when neither condition is met' do
      before do
        settlement.account.update!(balance: 1000.0)
        structure = create(:base_structure, settlement: settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'oxygen' => 200.0, 'nitrogen' => 100.0 }))
      end

      it 'returns empty array' do
        expect(priority_heuristic.get_priorities).to eq([])
      end
    end

    context 'when oxygen is critical' do
      before do
        settlement.account.update!(balance: 1000.0)
        structure = create(:base_structure, settlement: settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'oxygen' => 100.0 }))
      end

      it 'returns refill_oxygen priority' do
        expect(priority_heuristic.get_priorities).to include(:refill_oxygen)
      end
    end

    context 'when account is negative' do
      before do
        settlement.account.update!(balance: -500.0)
        structure = create(:base_structure, settlement: settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'oxygen' => 200.0 }))
      end

      it 'returns debt_repayment priority' do
        expect(priority_heuristic.get_priorities).to include(:debt_repayment)
      end
    end

    context 'when both conditions are met' do
      before do
        settlement.account.update!(balance: -500.0)
        structure = create(:base_structure, settlement: settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'oxygen' => 100.0 }))
      end

      it 'returns both priorities' do
        priorities = priority_heuristic.get_priorities
        expect(priorities).to include(:refill_oxygen)
        expect(priorities).to include(:debt_repayment)
      end
    end
  end

  describe '#get_priorities on Mars' do
    context 'when oxygen is critical on Mars' do
      let(:mars_body) { create(:celestial_body, name: 'Mars') }
      let(:mars_location) { create(:celestial_location, celestial_body: mars_body) }
      let(:mars_settlement) { create(:base_settlement, :station, location: mars_location) }
      let(:mars_priority_heuristic) { described_class.new(mars_settlement) }

      before do
        mars_settlement.account.update!(balance: 1000.0)
        structure = create(:base_structure, settlement: mars_settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'oxygen' => 100.0 }))
        
        # Set up Mars-like atmosphere with high CO2
        mars_body.atmosphere.update!(composition: { "CO2" => 95.97, "Ar" => 1.93, "N2" => 1.89 })
        co2_gas = mars_body.atmosphere.gases.find_or_create_by(name: 'CO2')
        co2_gas.update!(percentage: 95.97)
        ar_gas = mars_body.atmosphere.gases.find_or_create_by(name: 'Ar')
        ar_gas.update!(percentage: 1.93)
      end

      it 'returns local_oxygen_generation priority instead of refill_oxygen' do
        expect(mars_priority_heuristic.get_priorities).to include(:local_oxygen_generation)
        expect(mars_priority_heuristic.get_priorities).not_to include(:refill_oxygen)
      end
    end

    context 'when nitrogen is critical on Mars' do
      let(:mars_body) { create(:celestial_body, name: 'Mars') }
      let(:mars_location) { create(:celestial_location, celestial_body: mars_body) }
      let(:mars_settlement) { create(:base_settlement, :station, location: mars_location) }
      let(:mars_priority_heuristic) { described_class.new(mars_settlement) }

      before do
        mars_settlement.account.update!(balance: 1000.0)
        structure = create(:base_structure, settlement: mars_settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'nitrogen' => 50.0 }))
        
        # Set up Mars-like atmosphere with Ar
        mars_body.atmosphere.update!(composition: { "CO2" => 95.97, "Ar" => 1.93, "N2" => 1.89 })
        ar_gas = mars_body.atmosphere.gases.find_or_create_by(name: 'Ar')
        ar_gas.update!(percentage: 1.93)
      end

      it 'returns local_argon_extraction priority' do
        expect(mars_priority_heuristic.get_priorities).to include(:local_argon_extraction)
      end
    end
  end

  describe '#calculate_si_ask_price' do
    before do
      allow(Market::NpcPriceCalculator).to receive(:calculate_ask).with(settlement, 'Si').and_return(100.0)
    end

    it 'returns 95% of the calculated ask price' do
      expect(priority_heuristic.calculate_si_ask_price).to eq(95.0)
    end
  end

  describe 'Environmental System Integration' do
    context 'with procedurally generated planet having 95% CO2 and 0.0 Tesla magnetic field' do
      let(:high_co2_body) { create(:celestial_body, name: 'TestPlanet', properties: { 'magnetic_field_tesla' => 0.0 }) }
      let(:high_co2_location) { create(:celestial_location, celestial_body: high_co2_body) }
      let(:high_co2_settlement) { create(:base_settlement, :station, location: high_co2_location) }
      let(:high_co2_priority_heuristic) { described_class.new(high_co2_settlement) }

      before do
        high_co2_settlement.account.update!(balance: 1000.0)
        structure = create(:base_structure, settlement: high_co2_settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'oxygen' => 100.0 }))
        
        # Set up atmosphere with 95% CO2
        high_co2_body.atmosphere.update!(composition: { "CO2" => 95.0, "N2" => 5.0 })
        co2_gas = high_co2_body.atmosphere.gases.find_or_create_by(name: 'CO2')
        co2_gas.update!(percentage: 95.0)
      end

      it 'correctly chooses local O2 production' do
        expect(high_co2_priority_heuristic.get_priorities).to include(:local_oxygen_generation)
        expect(high_co2_priority_heuristic.get_priorities).not_to include(:refill_oxygen)
      end
    end

    context 'with planet having low CO2 and weak magnetic field' do
      let(:low_co2_body) { create(:celestial_body, name: 'LowCO2Planet', properties: { 'magnetic_field_tesla' => 0.1 }) }
      let(:low_co2_location) { create(:celestial_location, celestial_body: low_co2_body) }
      let(:low_co2_settlement) { create(:base_settlement, :station, location: low_co2_location) }
      let(:low_co2_priority_heuristic) { described_class.new(low_co2_settlement) }

      before do
        low_co2_settlement.account.update!(balance: 1000.0)
        structure = create(:base_structure, settlement: low_co2_settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'oxygen' => 100.0 }))
        
        # Set up atmosphere with low CO2
        low_co2_body.atmosphere.update!(composition: { "N2" => 78.0, "O2" => 21.0, "CO2" => 0.5 })
        co2_gas = low_co2_body.atmosphere.gases.find_or_create_by(name: 'CO2')
        co2_gas.update!(percentage: 0.5)
      end

      it 'chooses oxygen refill instead of local generation' do
        expect(low_co2_priority_heuristic.get_priorities).to include(:refill_oxygen)
        expect(low_co2_priority_heuristic.get_priorities).not_to include(:local_oxygen_generation)
      end
    end

    context 'with settlement having excess CO and H2' do
      let(:excess_gas_body) { create(:celestial_body, name: 'ExcessGasPlanet') }
      let(:excess_gas_location) { create(:celestial_location, celestial_body: excess_gas_body) }
      let(:excess_gas_settlement) { create(:base_settlement, :station, location: excess_gas_location) }
      let(:excess_gas_priority_heuristic) { described_class.new(excess_gas_settlement) }

      before do
        excess_gas_settlement.account.update!(balance: 1000.0)
        structure = create(:base_structure, settlement: excess_gas_settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge('gas_storage' => { 'oxygen' => 200.0, 'nitrogen' => 100.0 }))
        
        # Add CO and H2 to inventory
        co_item = excess_gas_settlement.inventory.items.find_or_create_by(name: 'CO', material_type: :gas, owner: excess_gas_settlement)
        co_item.update!(amount: 200.0)
        h2_item = excess_gas_settlement.inventory.items.find_or_create_by(name: 'H2', material_type: :gas, owner: excess_gas_settlement)
        h2_item.update!(amount: 150.0)
      end

      it 'prioritizes methane synthesis' do
        expect(excess_gas_priority_heuristic.get_priorities).to include(:methane_synthesis)
      end
    end

    context 'with settlement having critical storage capacity' do
      let(:full_tanks_body) { create(:celestial_body, name: 'FullTanksPlanet') }
      let(:full_tanks_location) { create(:celestial_location, celestial_body: full_tanks_body) }
      let(:full_tanks_settlement) { create(:base_settlement, :station, location: full_tanks_location) }
      let(:full_tanks_priority_heuristic) { described_class.new(full_tanks_settlement) }

      before do
        full_tanks_settlement.account.update!(balance: 1000.0)
        structure = create(:base_structure, settlement: full_tanks_settlement)
        structure.save
        structure.update_columns(operational_data: structure.operational_data.merge(
          'gas_storage' => { 'oxygen' => 200.0, 'nitrogen' => 100.0 }
        ))
        full_tanks_settlement.update_columns(operational_data: { 'tank_farm_capacity' => 5.0 })  # Below 10%
      end

      it 'prioritizes storage module construction' do
        expect(full_tanks_priority_heuristic.get_priorities).to include(:construct_storage_module)
      end
    end
  end
end