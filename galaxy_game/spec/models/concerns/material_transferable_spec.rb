require 'rails_helper'

RSpec.describe MaterialTransferable, type: :concern do
  let(:celestial_body) { create(:celestial_body) }
  let(:hydrosphere) { create(:hydrosphere, celestial_body: celestial_body) }
  let(:geosphere) { create(:geosphere, celestial_body: celestial_body) }

  before do
    hydrosphere.materials.create!(name: 'Water', amount: 100, state: 'liquid', celestial_body: celestial_body)
  end

  describe '#transfer_material' do
    it 'transfers material between spheres' do
      expect {
        hydrosphere.transfer_material('Water', 50, geosphere)
      }.to change { hydrosphere.materials.find_by(name: 'Water').amount }.by(-50)
        .and change { geosphere.materials.where(name: 'Water').sum(:amount) }.by(50)
    end

    it 'prevents transfer if insufficient amount' do
      expect(hydrosphere.transfer_material('Water', 150, geosphere)).to be false
    end

    it 'prevents transfer of non-existent material' do
      expect(hydrosphere.transfer_material('Unobtainium', 50, geosphere)).to be false
    end

    it 'updates existing material in target' do
      geosphere.materials.create!(name: 'Water', amount: 25, state: 'liquid', celestial_body: celestial_body)
      hydrosphere.transfer_material('Water', 50, geosphere)
      expect(geosphere.materials.find_by(name: 'Water').amount).to eq(75)
    end
  end
end