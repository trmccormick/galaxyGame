require 'rails_helper'

RSpec.describe Storage::SurfaceStorage, type: :model do
  let(:celestial_body) { create(:celestial_body, :luna) }
  let(:location) { 
    create(:celestial_location, 
      name: "Shackleton Crater Base", 
      coordinates: "89.90°S 0.00°E",
      celestial_body: celestial_body
    ) 
  }
  let(:player) { create(:player, active_location: "Shackleton Crater Base") }
  let(:settlement) { create(:base_settlement, owner: player, location: location) }
  let(:inventory) { settlement.inventory }
  
  let(:surface_storage) { create(:surface_storage, inventory: inventory, item_type: 'Solid') }

  describe 'validations' do
    it 'validates presence of required attributes' do
      expect(surface_storage).to validate_presence_of(:inventory)
      expect(surface_storage).to validate_presence_of(:item_type)
    end
  end

  describe '#add_pile' do
    let(:material_name) { 'processed_lunar_regolith' }

    it 'creates a new material pile' do
      expect {
        surface_storage.add_pile(
          material_name: material_name,
          amount: 100
        )
      }.to change(Storage::MaterialPile, :count).by(1)
    end

    it 'updates existing pile amount' do
      pile = create(:material_pile, 
        surface_storage: surface_storage,
        material_type: material_name,
        amount: 100
      )
      
      surface_storage.add_pile(
        material_name: material_name,
        amount: 50
      )
      
      expect(pile.reload.amount).to eq(150)
    end

    it 'returns false when material_name is invalid' do
      expect(surface_storage.add_pile(material_name: nil, amount: 100)).to be false
    end
  end

  describe '#check_item_conditions' do
    let(:item) { create(:item, metadata: {}) } # Initialize metadata

    context 'when atmosphere contains corrosive gases' do
      before do
        allow(celestial_body).to receive(:atmosphere)
          .and_return(double('Atmosphere', composition: ['O2', 'CO2']))
      end

      it 'applies surface conditions to the item' do
        surface_storage.check_item_conditions(item)
        expect(item.metadata['corroded']).to be true #check metadata
      end
    end

    context 'when atmosphere does not contain corrosive gases' do
      before do
        allow(celestial_body).to receive(:atmosphere)
          .and_return(double('Atmosphere', composition: ['N2']))
      end

      it 'does not corrode the item' do
        surface_storage.check_item_conditions(item)
        expect(item.metadata['corroded']).to be_nil #check metadata
      end
    end
  end
end