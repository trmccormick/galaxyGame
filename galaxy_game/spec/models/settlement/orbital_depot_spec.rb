# spec/models/settlement/orbital_depot_spec.rb
require 'rails_helper'

RSpec.describe Settlement::OrbitalDepot, type: :model do
  let(:mars) { CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_or_create_by!(name: 'Mars') }
  let(:location) do
    CelestialLocation.create!(
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
    it 'inherits from SpaceStation' do
      expect(depot).to be_a(Settlement::SpaceStation)
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
      depot.add_gas('H2', 300_000.0)
      expect(depot.get_gas('H2')).to eq(800_000.0)
    end
    
    it 'stores metadata with gas' do
      depot.add_gas('H2', 1_000_000.0, source: 'Saturn', purity: 99.9)
      
      item = depot.inventory.items.find_by(name: 'H2')
      expect(item.metadata['source']).to eq('Saturn')
      expect(item.metadata['purity']).to eq(99.9)
      expect(item.metadata['storage_type']).to eq('depot_gas')
    end
    
    it 'handles multiple gas types' do
      depot.add_gas('H2', 1_000_000.0)
      depot.add_gas('O2', 500_000.0)
      depot.add_gas('N2', 750_000.0)
      
      expect(depot.get_gas('H2')).to eq(1_000_000.0)
      expect(depot.get_gas('O2')).to eq(500_000.0)
      expect(depot.get_gas('N2')).to eq(750_000.0)
    end
    
    it 'raises error for negative amounts' do
      expect {
        depot.add_gas('H2', -100.0)
      }.to raise_error(ArgumentError, 'Amount must be positive')
    end
  end
  
  describe '#remove_gas' do
    before do
      depot.add_gas('H2', 1_000_000.0)
    end
    
    it 'removes gas from inventory' do
      removed = depot.remove_gas('H2', 300_000.0)
      expect(removed).to eq(300_000.0)
      expect(depot.get_gas('H2')).to eq(700_000.0)
    end
    
    it 'caps removal at available amount' do
      removed = depot.remove_gas('H2', 2_000_000.0)
      expect(removed).to eq(1_000_000.0)
      expect(depot.get_gas('H2')).to eq(0.0)
    end
    
    it 'returns 0 when gas not available' do
      removed = depot.remove_gas('O2', 100.0)
      expect(removed).to eq(0.0)
    end
    
    it 'filters by metadata when provided' do
      depot.add_gas('H2', 500_000.0, batch: 'A')
      depot.add_gas('H2', 300_000.0, batch: 'B')
      
      removed = depot.remove_gas('H2', 200_000.0, batch: 'A')
      expect(removed).to eq(200_000.0)
      
      # Batch A should have 300k left, Batch B still has 300k
      expect(depot.get_gas('H2', batch: 'A')).to eq(300_000.0)
      expect(depot.get_gas('H2', batch: 'B')).to eq(300_000.0)
    end
    
    it 'raises error for negative amounts' do
      expect {
        depot.remove_gas('H2', -100.0)
      }.to raise_error(ArgumentError, 'Amount must be positive')
    end
  end
  
  describe '#get_gas' do
    it 'returns 0 for non-existent gas' do
      expect(depot.get_gas('H2')).to eq(0.0)
    end
    
    it 'returns correct amount for existing gas' do
      depot.add_gas('H2', 1_000_000.0)
      expect(depot.get_gas('H2')).to eq(1_000_000.0)
    end
    
    it 'filters by metadata when provided' do
      depot.add_gas('H2', 500_000.0, source: 'Saturn')
      depot.add_gas('H2', 300_000.0, source: 'Jupiter')
      
      expect(depot.get_gas('H2', source: 'Saturn')).to eq(500_000.0)
      expect(depot.get_gas('H2', source: 'Jupiter')).to eq(300_000.0)
      expect(depot.get_gas('H2')).to eq(800_000.0) # Total
    end
  end
  
  describe '#has_gas?' do
    before do
      depot.add_gas('H2', 1_000_000.0)
    end
    
    it 'returns true when sufficient gas available' do
      expect(depot.has_gas?('H2', 500_000.0)).to be true
    end
    
    it 'returns false when insufficient gas' do
      expect(depot.has_gas?('H2', 2_000_000.0)).to be false
    end
    
    it 'returns false for non-existent gas' do
      expect(depot.has_gas?('O2', 100.0)).to be false
    end
  end
  
  describe '#total_gas_mass' do
    it 'returns 0 when empty' do
      expect(depot.total_gas_mass).to eq(0.0)
    end
    
    it 'sums all gas types' do
      depot.add_gas('H2', 1_000_000.0)
      depot.add_gas('O2', 500_000.0)
      depot.add_gas('N2', 750_000.0)
      
      expect(depot.total_gas_mass).to eq(2_250_000.0)
    end
    
    it 'excludes non-gas items if present' do
      depot.add_gas('H2', 1_000_000.0)
      # Simulate a non-gas item (shouldn't have depot_gas metadata)
      depot.inventory.add_item('iron_ore', 500.0, depot, {})
      
      expect(depot.total_gas_mass).to eq(1_000_000.0)
    end
  end
  
  describe '#gas_inventory_summary' do
    it 'returns empty hash when no gases' do
      expect(depot.gas_inventory_summary).to eq({})
    end
    
    it 'groups by gas name' do
      depot.add_gas('H2', 1_000_000.0)
      depot.add_gas('H2', 500_000.0)
      depot.add_gas('O2', 750_000.0)
      
      summary = depot.gas_inventory_summary
      expect(summary['H2']).to eq(1_500_000.0)
      expect(summary['O2']).to eq(750_000.0)
    end
  end
  
  describe '#depot_status' do
    before do
      depot.add_gas('H2', 1_000_000.0)
      depot.add_gas('O2', 500_000.0)
    end
    
    it 'returns comprehensive status hash' do
      status = depot.depot_status
      
      expect(status[:name]).to eq('Mars Orbital Depot')
      expect(status[:total_gas_mass]).to eq(1_500_000.0)
      expect(status[:gas_inventory]).to include('H2' => 1_000_000.0, 'O2' => 500_000.0)
      expect(status[:operational]).to be_in([true, false])
    end
  end
  
  describe 'realistic terraforming scenario' do
    it 'handles H2 import from Saturn for O2 management' do
      # Simulate importing H2 for O2 management
      h2_needed = 1_000_000.0 # kg
      
      depot.add_gas('H2', h2_needed, source: 'Saturn', purpose: 'O2_management')
      expect(depot.get_gas('H2')).to eq(h2_needed)
      
      # Use H2 for reaction
      h2_consumed = depot.remove_gas('H2', 500_000.0)
      expect(h2_consumed).to eq(500_000.0)
      expect(depot.get_gas('H2')).to eq(500_000.0)
    end
    
    it 'handles Sabatier reaction H2 consumption' do
      depot.add_gas('H2', 2_000_000.0, source: 'Saturn', purpose: 'Sabatier')
      
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
