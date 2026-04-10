# spec/models/settlement/orbital_settlement_spec.rb
require 'rails_helper'

RSpec.describe Settlement::OrbitalSettlement, type: :model do
  let(:orbital_settlement) { build(:orbital_settlement) }

  describe '#location' do
    it 'returns the celestial_location of the first structure if present' do
      structure = double('Structure', celestial_location: :location_a)
      allow(orbital_settlement).to receive(:structures).and_return([structure])
      expect(orbital_settlement.location).to eq(:location_a)
    end

    it 'returns nil if there are no structures' do
      allow(orbital_settlement).to receive(:structures).and_return([])
      expect(orbital_settlement.location).to be_nil
    end
  end

  describe '#celestial_body' do
    it 'returns the celestial_body of the location if present' do
      location = double('CelestialLocation', celestial_body: :mars)
      allow(orbital_settlement).to receive(:location).and_return(location)
      expect(orbital_settlement.celestial_body).to eq(:mars)
    end

    it 'returns nil if location is nil' do
      allow(orbital_settlement).to receive(:location).and_return(nil)
      expect(orbital_settlement.celestial_body).to be_nil
    end
  end

  describe '#total_storage_capacity' do
    it 'sums total_storage_capacity across all structures' do
      s1 = double('Structure', total_storage_capacity: 100)
      s2 = double('Structure', total_storage_capacity: 200)
      allow(orbital_settlement).to receive(:structures).and_return([s1, s2])
      expect(orbital_settlement.total_storage_capacity).to eq(300)
    end
  end

  describe '#population_capacity' do
    it 'sums habitat_capacity across all structures' do
      s1 = double('Structure', habitat_capacity: 10)
      s2 = double('Structure', habitat_capacity: 20)
      allow(orbital_settlement).to receive(:structures).and_return([s1, s2])
      expect(orbital_settlement.population_capacity).to eq(30)
    end
  end

  describe '#add_specialized_structure!' do
    it 'creates a new structure with the given blueprint_id and planned shell_status' do
      expect(orbital_settlement).to receive_message_chain(:structures, :create!).with(identifier: 'bp42', shell_status: 'planned')
      orbital_settlement.add_specialized_structure!('bp42')
    end
  end
end
