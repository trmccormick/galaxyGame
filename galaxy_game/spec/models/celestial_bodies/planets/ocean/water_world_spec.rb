require 'rails_helper'

RSpec.describe CelestialBodies::Planets::Ocean::WaterWorld, type: :model do
  subject(:water_world) { build(:water_world) }
  
  describe "validations" do
    it "requires high water coverage" do
      # Build the water world first to get surface_area
      water_world.save! # Need to persist to create associations
      
      # Calculate liquid_bodies for 60% coverage (below minimum)
      total_water_area = water_world.surface_area * 0.60
      
      # Update the hydrosphere to have 60% coverage
      water_world.hydrosphere.update(
        liquid_bodies: {
          'oceans' => total_water_area * 0.7,
          'lakes' => total_water_area * 0.2,
          'rivers' => total_water_area * 0.1,
          'ice_caps' => 0,
          'groundwater' => 0
        }
      )
      
      # Reload and validate
      water_world.reload
      expect(water_world).not_to be_valid
      expect(water_world.errors[:hydrosphere]).to include("water coverage must be at least 65% for a water world")
    end
    
    it "is valid with appropriate water coverage" do
      # The factory creates a water_world with 90% coverage by default
      water_world.save!
      
      expect(water_world).to be_valid
      expect(water_world.hydrosphere.water_coverage).to be >= 65.0
    end
  end
  
  describe "#surface_features" do
    it "includes oceanic features" do
      water_world.save! # Persist to create hydrosphere
      
      features = water_world.surface_features
      
      expect(features).to include("global_ocean")
      expect(features).to include("seafloor_terrain")
    end
    
    it "includes pelagic_world for extreme coverage" do
      water_world.save!
      
      # Update to 99% coverage
      total_water_area = water_world.surface_area * 0.99
      water_world.hydrosphere.update(
        liquid_bodies: {
          'oceans' => total_water_area * 0.99,
          'lakes' => 0,
          'rivers' => 0,
          'ice_caps' => 0,
          'groundwater' => 0
        }
      )
      water_world.reload
      
      features = water_world.surface_features
      
      expect(features).to include("pelagic_world")
      expect(features).not_to include("coastal_zones")
    end
  end
  
  describe "#average_ocean_depth" do
    it "calculates depth based on planet size and water coverage" do
      water_world.radius = 6371000 # Earth-sized
      water_world.save! # Creates hydrosphere with 90% coverage
      
      depth = water_world.average_ocean_depth
      
      # The calculation should return a reasonable depth
      # For 90% coverage, should be greater than base depth (3800m)
      expect(depth).to be > 3800
      expect(depth).to be_within(1000).of(6000)
    end
    
    it "returns 0 when radius is missing" do
      water_world.radius = nil
      
      expect(water_world.average_ocean_depth).to eq(0)
    end
    
    it "returns 0 when hydrosphere is missing" do
      water_world.radius = 6371000
      water_world.save!
      water_world.hydrosphere.destroy
      water_world.reload
      
      expect(water_world.average_ocean_depth).to eq(0)
    end
  end
end