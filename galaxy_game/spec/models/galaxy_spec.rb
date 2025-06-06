require 'rails_helper'

RSpec.describe Galaxy, type: :model do
  describe 'validations' do
    it 'validates presence of identifier' do
      galaxy = Galaxy.new(name: "Test")
      expect(galaxy).not_to be_valid
      
      galaxy.identifier = "TEST-123"
      expect(galaxy).to be_valid
    end
    
    it 'validates uniqueness of identifier' do
      Galaxy.create!(name: "Original", identifier: "UNIQUE-ID")
      
      galaxy = Galaxy.new(name: "Copy", identifier: "UNIQUE-ID")
      expect(galaxy).not_to be_valid
      expect(galaxy.errors[:identifier]).to include("has already been taken")
    end
  end
  
  describe 'associations' do
    it 'has many solar systems' do
      galaxy = Galaxy.create!(name: "Milky Way", identifier: "MW-001")
      solar_system = SolarSystem.create!(name: "Solar System", identifier: "SS-001", galaxy: galaxy)
      
      galaxy.reload
      expect(galaxy.solar_systems).to include(solar_system)
    end
    
    it 'has one spatial location' do
      galaxy = Galaxy.create!(name: "Andromeda", identifier: "AND-001")
      
      # Use your spatial_location factory with the correct attributes
      spatial_location = create(:spatial_location)
      
      # Associate the spatial location with the galaxy
      galaxy.spatial_location = spatial_location
      galaxy.save
      
      galaxy.reload
      expect(galaxy.spatial_location).to eq(spatial_location)
    end
  end
  
  describe 'callbacks' do
    it 'generates a unique name before create if name is not present' do
      galaxy = Galaxy.new(identifier: "GLX")
      expect(galaxy.read_attribute(:name)).to be_nil
      galaxy.save
      expect(galaxy.name).not_to be_nil
      expect(galaxy.name).to match(/^[A-Z0-9]{6}$/) # Should be a 6-char alphanumeric
    end
    
    # This test has incorrect expectations - need to modify it
    it 'generates a random alphanumeric name if none provided' do
      galaxy = Galaxy.new(identifier: "AUTO-NAME-TEST")
      expect(galaxy.read_attribute(:name)).to be_nil
      galaxy.save
      expect(galaxy.name).to match(/^[A-Z0-9]{6}$/) # Match pattern: 6 alphanumeric chars
    end
  end
  
  describe 'galaxy type' do
    it 'accepts different galaxy types' do
      galaxy = create(:galaxy, galaxy_type: 'elliptical')
      expect(galaxy.galaxy_type).to eq('elliptical')
      
      galaxy.update(galaxy_type: 'spiral')
      expect(galaxy.galaxy_type).to eq('spiral')
    end
  end
  
  describe '#name' do
    it 'returns the name if present' do
      galaxy = create(:galaxy, name: 'Milky Way')
      expect(galaxy.name).to eq('Milky Way')
    end
    
    it 'returns the identifier if name is not present' do
      galaxy = create(:galaxy, name: nil)
      galaxy.name = nil
      galaxy.save(validate: false)
      expect(galaxy.name).to eq(galaxy.identifier)
    end
  end
  
  describe '#total_mass' do
    it 'calculates total mass properly', skip: "Implement this when total_mass method exists" do
      galaxy = create(:galaxy, mass: 2.0e12)
      expect(galaxy.total_mass).to be > galaxy.mass
    end
  end
  
  describe 'galaxy properties' do
    it 'can store galaxy attributes' do
      galaxy = Galaxy.create!(
        name: "Andromeda",
        identifier: "AND-001",
        galaxy_type: "spiral",
        age_in_billions: 10,
        star_count: 1_000_000_000_000,
        mass: 1.5e12,
        diameter: 220_000
      )
      
      expect(galaxy.galaxy_type).to eq("spiral")
      expect(galaxy.age_in_billions).to eq(10)
      expect(galaxy.star_count).to eq(1_000_000_000_000)
      expect(galaxy.mass).to eq(1.5e12)
      expect(galaxy.diameter).to eq(220_000)
    end
    
    let(:galaxy) { create(:galaxy) }
    
    it 'has expected attributes' do
      expect(galaxy.identifier).not_to be_nil
      expect(galaxy.galaxy_type).to eq('spiral')
      expect(galaxy.age_in_billions).to eq(13)
      expect(galaxy.star_count).to eq(200000)
      expect(galaxy.mass).to eq(1.5e12)
      expect(galaxy.diameter).to eq(100000)
    end
  end
  
  describe 'spatial context' do
    it 'can be assigned a spatial location' do
      galaxy = create(:galaxy)
      spatial_location = create(:spatial_location)
      
      # Associate the spatial location with the galaxy
      spatial_location.update(spatial_context: galaxy)
      
      galaxy.reload
      expect(galaxy.spatial_location).to eq(spatial_location)
    end
  end

  describe '.create_with_random_properties' do
    it 'creates a galaxy with the given identifier' do
      identifier = 'TEST-GALAXY-123'
      galaxy = Galaxy.create_with_random_properties(identifier)
      
      expect(galaxy).to be_persisted
      expect(galaxy.identifier).to eq(identifier)
    end
    
    it 'uses provided options when given' do
      galaxy = Galaxy.create_with_random_properties(
        'CUSTOM-GALAXY', 
        name: 'My Custom Galaxy',
        type: 'elliptical',
        mass: 3.5e12
      )
      
      expect(galaxy.name).to eq('My Custom Galaxy')
      expect(galaxy.galaxy_type).to eq('elliptical')
      expect(galaxy.mass).to eq(3.5e12)
    end
    
    it 'generates random properties when not specified' do
      galaxy1 = Galaxy.create_with_random_properties('RANDOM-1')
      galaxy2 = Galaxy.create_with_random_properties('RANDOM-2')
      
      # Both should have valid values
      expect(galaxy1.mass).to be_between(1.0e11, 5.0e12)
      expect(galaxy2.mass).to be_between(1.0e11, 5.0e12)
      
      # They should likely be different (not guaranteed but highly probable)
      all_same = galaxy1.mass == galaxy2.mass && 
                galaxy1.galaxy_type == galaxy2.galaxy_type
                
      expect(all_same).to be_falsey, "Expected randomly generated galaxies to have different properties"
    end
    
    it 'handles a mix of specified and random properties' do
      galaxy = Galaxy.create_with_random_properties(
        'MIXED-PROPS',
        name: 'Partially Random',
        # type not specified - should be random
      )
      
      expect(galaxy.name).to eq('Partially Random')
      expect(galaxy.galaxy_type).to be_present # Should have a random type
      expect(galaxy.mass).to be_between(1.0e11, 5.0e12) # Should have a random mass
    end
  end
end