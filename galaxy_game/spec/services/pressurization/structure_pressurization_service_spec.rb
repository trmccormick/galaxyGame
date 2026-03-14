require 'rails_helper'

RSpec.describe Pressurization::StructurePressurizationService, type: :service do
  let(:player) { create(:player) }
  let(:settlement) { create(:base_settlement, :station, owner: player) }
  let(:structure) { create(:base_structure, settlement: settlement) }

  describe '.pressurize_structure' do
    context 'when gases are available in inventory' do
      before do
        create(:item, name: 'O2', material_type: :gas, amount: 800,
               inventory: settlement.inventory, owner: player)
        create(:item, name: 'N2', material_type: :gas, amount: 1800,
               inventory: settlement.inventory, owner: player)
      end

      it 'sources gases from settlement inventory' do
        expect(described_class).to receive(:source_gases_from_depot_tanks)
          .with(settlement).and_call_original
        described_class.pressurize_structure(structure)
      end

      it 'uses inventory gases for pressurization' do
        result = described_class.pressurize_structure(structure)
        expect(result[:available_gases]).to include(:oxygen, :nitrogen)
        expect(result[:available_gases][:oxygen]).to eq(800)
        expect(result[:available_gases][:nitrogen]).to eq(1800)
      end
    end

    context 'when no gases are available' do
      it 'falls back to standard pressurization logic' do
        expect(described_class).to receive(:source_gases_from_depot_tanks)
          .with(settlement).and_return({})
        described_class.pressurize_structure(structure)
      end
    end
  end

  describe '.source_gases_from_depot_tanks' do
    context 'when settlement has gas items in inventory' do
      before do
        create(:item, name: 'O2', material_type: :gas, amount: 500,
               inventory: settlement.inventory, owner: player)
        create(:item, name: 'N2', material_type: :gas, amount: 1000,
               inventory: settlement.inventory, owner: player)
        create(:item, name: 'O2', material_type: :gas, amount: 300,
               inventory: settlement.inventory, owner: player)
        create(:item, name: 'N2', material_type: :gas, amount: 800,
               inventory: settlement.inventory, owner: player)
      end

      it 'aggregates gases from inventory' do
        result = described_class.send(:source_gases_from_depot_tanks, settlement)
        expect(result[:oxygen]).to eq(800)  # 500 + 300
        expect(result[:nitrogen]).to eq(1800) # 1000 + 800
      end
    end

    context 'when settlement has no gas items' do
      it 'returns empty hash' do
        result = described_class.send(:source_gases_from_depot_tanks, settlement)
        expect(result).to eq({})
      end
    end

    context 'when inventory has only non-gas items' do
      before do
        create(:item, name: '3d_printed_ibeam', material_type: :component, amount: 500,
               inventory: settlement.inventory, owner: player)
      end

      it 'returns empty hash' do
        result = described_class.send(:source_gases_from_depot_tanks, settlement)
        expect(result).to eq({})
      end
    end
  end

  describe 'mining byproduct integration' do
    before do
      create(:item, name: 'O2', material_type: :gas, amount: 100,
             inventory: settlement.inventory, owner: player)
      create(:item, name: 'N2', material_type: :gas, amount: 200,
             inventory: settlement.inventory, owner: player)
    end

    context 'when mining Si produces O2 byproduct' do
      it 'increases available gases from inventory for pressurization' do
        initial_gases = described_class.send(:source_gases_from_depot_tanks, settlement)
        initial_o2 = initial_gases[:oxygen]

        Manufacturing::ByproductManufacturingService.process_mining_byproducts(
          settlement, 'Si', 1000
        )

        updated_gases = described_class.send(:source_gases_from_depot_tanks, settlement)
        updated_o2 = updated_gases[:oxygen]

        expect(updated_o2).to eq(initial_o2 + 500)
      end
    end
  end
end