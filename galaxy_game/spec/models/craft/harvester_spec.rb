require 'rails_helper'

RSpec.describe Craft::Harvester, type: :model do
  let(:player) { create(:player) }
  let(:harvester) { create(:craft_harvester, player: player) }
  let(:target_body) { 'asteroid' }

  before do
    allow(harvester).to receive(:craft_info).and_return({
      'deployment' => { 'deployment_locations' => ['asteroid', 'moon'] },
      'extraction_efficiency' => 0.9,
      'processable_materials' => ['raw_material'],
      'processing_conversion_rate' => 0.8
    })
  end

  describe 'validations' do
    it 'is valid with a positive extraction_rate' do
      harvester.extraction_rate = 10
      expect(harvester).to be_valid
    end

    it 'is invalid with a negative extraction_rate' do
      harvester.extraction_rate = -5
      expect(harvester).to_not be_valid
    end
  end

  describe '#extract_resources' do
    context 'when extracting from a valid target' do
      it 'increases inventory with extracted resources' do
        harvester.extract_resources(target_body, 100)
        raw_material = harvester.inventory.items.find_by(name: 'raw_material')

        expect(raw_material.amount).to eq(90) # 100 * 0.9 efficiency
      end
    end

    context 'when extracting from an invalid target' do
      it 'raises an error' do
        expect { harvester.extract_resources('gas_giant', 50) }
          .to raise_error("Invalid target")
      end
    end

    context 'when storage is full' do
      before do
        allow(harvester).to receive(:can_store?).and_return(false)
      end

      it 'raises an error' do
        expect { harvester.extract_resources(target_body, 50) }
          .to raise_error("Storage full")
      end
    end
  end

  describe '#process_resources' do
    before do
      harvester.inventory.items.create!(name: 'raw_material', amount: 100, owner: harvester.player)
    end

    it 'converts raw material into refined material' do
      harvester.process_resources

      raw_material = harvester.inventory.items.find_by(name: 'raw_material')
      refined_material = harvester.inventory.items.find_by(name: 'refined_material')

      expect(raw_material.amount).to eq(20) # 100 - 80 processed
      expect(refined_material.amount).to eq(80) # 100 * 0.8 conversion
    end

    it 'does nothing if no processable materials are present' do
      harvester.inventory.items.destroy_all
      expect { harvester.process_resources }.not_to change { harvester.inventory.items.count }
    end
  end
end
