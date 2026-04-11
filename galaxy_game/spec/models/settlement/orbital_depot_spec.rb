# spec/models/settlement/orbital_depot_spec.rb
require 'rails_helper'

RSpec.describe Settlement::OrbitalSettlement, type: :model do
  let(:mars) { CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_or_create_by!(name: 'Mars') }
  let(:location) do
    Location::CelestialLocation.create!(
      celestial_body: mars,
      latitude: 0.0,
      longitude: 0.0,
      altitude: 20_000_000.0, # 20,000 km orbit
      locationable: depot
    )
  end
  
  let(:depot) do
    described_class.create!(
      name: 'Mars Orbital Depot',
      settlement_type: 'outpost',
      current_population: 10
    )
  end
  
  before do
    # Ensure depot has inventory
    depot.create_account_and_inventory unless depot.inventory

    # Create gas storage unit with required fields
    Units::BaseUnit.create!(
      attachable: depot,
      owner: depot,
      unit_type: 'storage',
      name: 'Gas Storage Tank Alpha',
      identifier: SecureRandom.uuid,
      operational_data: {
        'storage' => {
          'type' => 'gas',
          'capacity' => 1_000_000_000.0 # 1 billion kg capacity
        }
      }
    )
  end
  
  describe 'inheritance' do
    it 'is not a subclass of SpaceStation' do
      expect(depot).not_to be_a(Settlement::SpaceStation)
    end
    
    it 'inherits from BaseSettlement' do
      expect(depot).to be_a(Settlement::BaseSettlement)
    end
  end
  
  describe '#add_gas' do
    it 'adds gas to inventory' do
      expect {
        depot.add_gas('H2', 1_000_000.0)
      }.to change { depot.inventory.items.count }.by(1)
    end
    
    it 'stores gas amount correctly' do
      depot.add_gas('H2', 1_000_000.0)
      expect(depot.get_gas('H2')).to eq(1_000_000.0)
    end
    
    it 'accumulates multiple additions' do
      depot.add_gas('H2', 500_000.0)
      # Sabatier: CO2 + 4H2 -> CH4 + 2H2O
      # For 1000 kg CH4: need 500 kg H2
      h2_for_ch4 = 500_000.0
      
      h2_consumed = depot.remove_gas('H2', h2_for_ch4)
      expect(h2_consumed).to eq(h2_for_ch4)
      expect(depot.get_gas('H2')).to eq(1_500_000.0)
    end
    
    it 'tracks multiple import batches' do
      # Year 1: Import batch A
      depot.add_gas('H2', 1_000_000.0, import_year: 1, cycler: 'Alpha')
      
      # Year 2: Import batch B
      depot.add_gas('H2', 1_500_000.0, import_year: 2, cycler: 'Beta')
      
      expect(depot.get_gas('H2')).to eq(2_500_000.0)
      expect(depot.get_gas('H2', import_year: 1)).to eq(1_000_000.0)
      expect(depot.get_gas('H2', import_year: 2)).to eq(1_500_000.0)
    end
  end
  
  describe 'integration with TerraformingManager' do
    it 'provides interface compatible with PORO OrbitalDepot' do
      # Verify method signatures match for easy migration
      expect(depot).to respond_to(:add_gas).with(2).arguments
      expect(depot).to respond_to(:remove_gas).with(2).arguments
      expect(depot).to respond_to(:get_gas).with(1).argument
      expect(depot).to respond_to(:has_gas?).with(2).arguments
    end
  end
end
