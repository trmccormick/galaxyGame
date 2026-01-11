require 'rails_helper'

RSpec.describe Pressurization::StructurePressurizationService, type: :service do
  let(:player) { create(:player) }
  let(:settlement) { create(:base_settlement, :station, owner: player) }
  let(:structure) { create(:base_structure, settlement: settlement) }

  describe '.pressurize_structure' do
    context 'when depot tanks are available' do
      let!(:depot_tank1) { create(:depot_tank, settlement: settlement) }
      let!(:depot_tank2) { create(:depot_tank, settlement: settlement) }

      before do
        depot_tank1.save
        depot_tank1.update_columns(operational_data: depot_tank1.operational_data.merge('gas_storage' => { 'oxygen' => 500, 'nitrogen' => 1000 }))

        depot_tank2.save
        depot_tank2.update_columns(operational_data: depot_tank2.operational_data.merge('gas_storage' => { 'oxygen' => 300, 'nitrogen' => 800 }))
      end

      it 'sources gases from depot tanks' do
        expect(described_class).to receive(:source_gases_from_depot_tanks).with(settlement).and_call_original

        described_class.pressurize_structure(structure)
      end

      it 'uses depot tank gases for pressurization' do
        result = described_class.pressurize_structure(structure)

        # Should return available gases from depot tanks
        expect(result[:available_gases]).to include(:oxygen, :nitrogen)
        expect(result[:available_gases][:oxygen]).to eq(800)
        expect(result[:available_gases][:nitrogen]).to eq(1800)
      end
    end

    context 'when no depot tanks are available' do
      it 'falls back to standard pressurization logic' do
        expect(described_class).to receive(:source_gases_from_depot_tanks).with(settlement).and_return({})

        described_class.pressurize_structure(structure)
      end
    end
  end

  describe '.source_gases_from_depot_tanks' do
    context 'when settlement has depot tanks' do
      let!(:depot_tank1) { create(:depot_tank, settlement: settlement) }
      let!(:depot_tank2) { create(:depot_tank, settlement: settlement) }

      before do
        depot_tank1.save
        depot_tank1.update_columns(operational_data: depot_tank1.operational_data.merge('gas_storage' => { 'oxygen' => 500, 'nitrogen' => 1000 }))

        depot_tank2.save
        depot_tank2.update_columns(operational_data: depot_tank2.operational_data.merge('gas_storage' => { 'oxygen' => 300, 'nitrogen' => 800 }))
      end

      it 'aggregates gases from all depot tanks' do
        result = described_class.send(:source_gases_from_depot_tanks, settlement)

        expect(result[:oxygen]).to eq(800) # 500 + 300
        expect(result[:nitrogen]).to eq(1800) # 1000 + 800
      end

      it 'returns empty hash when no gases are stored' do
        depot_tank1.update!(operational_data: {"structure_type" => "depot_tank"})
        depot_tank2.update!(operational_data: {"structure_type" => "depot_tank"})

        result = described_class.send(:source_gases_from_depot_tanks, settlement)
        expect(result).to eq({})
      end
    end

    context 'when settlement has no depot tanks' do
      it 'returns empty hash' do
        result = described_class.send(:source_gases_from_depot_tanks, settlement)
        expect(result).to eq({})
      end
    end

    context 'when depot tanks have no gas_storage data' do
      let!(:depot_tank) { create(:depot_tank, settlement: settlement) }

      before do
        depot_tank.operational_data = {
          'structure_type' => 'depot_tank'
        }
        depot_tank.save
      end

      it 'returns empty hash' do
        result = described_class.send(:source_gases_from_depot_tanks, settlement)
        expect(result).to eq({})
      end
    end
  end

  describe 'mining byproduct integration' do
    let!(:depot_tank) { create(:depot_tank, settlement: settlement) }

    before do
      depot_tank.save
      depot_tank.update_columns(operational_data: depot_tank.operational_data.merge('gas_storage' => { 'oxygen' => 100, 'nitrogen' => 200 }))
    end

    context 'when mining Si produces O2 byproduct' do
      it 'increases available gases from depot tanks for pressurization' do
        # Initial available gases
        initial_gases = described_class.send(:source_gases_from_depot_tanks, settlement)
        initial_o2 = initial_gases[:oxygen]

        # Simulate mining Si which produces O2 byproduct
        Manufacturing::ByproductManufacturingService.process_mining_byproducts(settlement, 'Si', 1000) # 1000 kg Si mined

        # Check available gases after byproduct addition
        updated_gases = described_class.send(:source_gases_from_depot_tanks, settlement)
        updated_o2 = updated_gases[:oxygen]

        # Should have increased O2 by 500 kg (0.5 * 1000)
        expect(updated_o2).to eq(initial_o2 + 500)
      end
    end
  end
end