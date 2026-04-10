# spec/models/structures/orbital_structure_spec.rb
require 'rails_helper'

RSpec.describe Structures::OrbitalStructure, type: :model do
  let(:orbital_structure) { build(:orbital_structure) }

  describe 'associations' do
    it { should have_one(:celestial_location).class_name('Location::CelestialLocation').dependent(:destroy) }
    it { should have_one(:atmosphere).dependent(:destroy) }
  end

  describe 'included modules' do
    it 'includes Shell, HasUnits, Housing, EnergyManagement, AtmosphericProcessing, Docking, SpinGravity' do
      expect(described_class.included_modules).to include(
        Structures::Shell,
        HasUnits,
        Housing,
        EnergyManagement,
        AtmosphericProcessing,
        Docking,
        SpinGravity
      )
    end
  end

  describe '#total_storage_capacity' do
    it 'sums storage unit capacities' do
      allow(orbital_structure).to receive_message_chain(:base_units, :where).with(unit_type: 'storage').and_return([
        double(operational_data: { 'storage' => { 'capacity' => 100 } }),
        double(operational_data: { 'storage' => { 'capacity' => 200 } })
      ])
      expect(orbital_structure.total_storage_capacity).to eq(300)
    end
  end

  describe '#habitat_capacity' do
    it 'returns 0 with no units' do
      expect(orbital_structure.habitat_capacity).to eq(0)
    end

    it 'sums capacity from habitat units' do
      unit = instance_double('Units::BaseUnit',
        operational_data: { 'capacity' => { 'passenger_capacity' => 10 } }
      )
      allow(orbital_structure).to receive_message_chain(:base_units, :sum).and_return(10)
      expect(orbital_structure.habitat_capacity).to eq(10)
    end
  end

  describe '#total_mass' do
    it 'calculates total mass from blueprint, inventory, and atmosphere' do
      allow(orbital_structure).to receive(:blueprint).and_return({ 'physical_properties' => { 'empty_mass' => 1000 } })
      allow(orbital_structure).to receive_message_chain(:inventory, :total_weight).and_return(200)
      allow(orbital_structure).to receive_message_chain(:atmosphere, :total_atmospheric_mass).and_return(50)
      expect(orbital_structure.total_mass).to eq(1250)
    end
    it 'handles nil blueprint and atmosphere' do
      allow(orbital_structure).to receive(:blueprint).and_return(nil)
      allow(orbital_structure).to receive_message_chain(:inventory, :total_weight).and_return(0)
      allow(orbital_structure).to receive(:atmosphere).and_return(nil)
      expect(orbital_structure.total_mass).to eq(0)
    end
  end

  describe 'callbacks' do
    it 'initializes atmosphere if needed after create' do
      allow(orbital_structure).to receive(:needs_atmosphere?).and_return(true)
      allow(orbital_structure).to receive(:atmosphere).and_return(nil)
      allow(orbital_structure).to receive(:get_construction_atmosphere_data).and_return({ temperature: 293, pressure: 1.0, composition: { 'O2' => 0.21, 'N2' => 0.78 } })
      expect(orbital_structure).to receive(:create_atmosphere!).with(environment_type: 'artificial', temperature: 293, pressure: 1.0, composition: { 'O2' => 0.21, 'N2' => 0.78 }, sealing_status: true)
      orbital_structure.send(:initialize_atmosphere_if_needed)
    end
  end
end
