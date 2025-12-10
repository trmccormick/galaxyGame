require 'rails_helper'

RSpec.describe CelestialBodies::Planets::Ocean::OceanPlanet, type: :model do
  subject(:ocean_planet) { create(:ocean_planet) }
  
  describe "validations" do
    it "requires a hydrosphere to be present" do
      ocean_planet.hydrosphere.destroy
      ocean_planet.reload
      
      expect(ocean_planet).not_to be_valid
      expect(ocean_planet.errors[:hydrosphere]).to include("can't be blank")
    end
    
    it "requires at least 30% water coverage" do
      # Set water coverage to 25% (below minimum)
      total_water_area = ocean_planet.surface_area * 0.25
      ocean_planet.hydrosphere.update(
        liquid_bodies: {
          'oceans' => total_water_area * 0.7,
          'lakes' => total_water_area * 0.2,
          'rivers' => total_water_area * 0.1,
          'ice_caps' => 0,
          'groundwater' => 0
        }
      )
      ocean_planet.reload
      
      expect(ocean_planet).not_to be_valid
      expect(ocean_planet.errors[:hydrosphere]).to include("water coverage must be at least 30% for an ocean planet")
    end
    
    it "is valid with 30% or more water coverage" do
      # Factory creates with 45% coverage by default
      expect(ocean_planet).to be_valid
      expect(ocean_planet.hydrosphere.water_coverage).to be >= 30.0
    end
  end
  
  describe "#habitability_factors" do
    it "includes aquatic environment factors based on water coverage" do
      # Factory creates with 45% coverage
      factors = ocean_planet.habitability_factors
      
      expect(factors[:aquatic_environment]).to be_present
    end
    
    it "marks aquatic environment as 'significant' for coverage below 50%" do
      # Default is 45% coverage
      factors = ocean_planet.habitability_factors
      
      expect(factors[:aquatic_environment]).to eq("significant")
    end
    
    it "marks aquatic environment as 'dominant' for coverage above 50%" do
      # Update to 60% coverage
      total_water_area = ocean_planet.surface_area * 0.60
      ocean_planet.hydrosphere.update(
        liquid_bodies: {
          'oceans' => total_water_area * 0.7,
          'lakes' => total_water_area * 0.2,
          'rivers' => total_water_area * 0.1,
          'ice_caps' => 0,
          'groundwater' => 0
        }
      )
      ocean_planet.reload
      
      factors = ocean_planet.habitability_factors
      
      expect(factors[:aquatic_environment]).to eq("dominant")
    end
    
    it "analyzes water chemistry from hydrosphere composition" do
      ocean_planet.hydrosphere.update(
        composition: { 'water' => 85, 'salts' => 15 }
      )
      ocean_planet.reload
      
      factors = ocean_planet.habitability_factors
      
      expect(factors[:water_chemistry]).to eq("highly_saline")
    end
    
    it "includes temperature state for liquid water range" do
      ocean_planet.update_columns(surface_temperature: 300) # 27°C
      ocean_planet.reload
      
      factors = ocean_planet.habitability_factors
      
      expect(factors[:temperature_state]).to eq("liquid_water_possible")
    end
    
    it "identifies frozen surface for low temperatures" do
      ocean_planet.update_columns(surface_temperature: 250) # -23°C
      ocean_planet.reload
      
      factors = ocean_planet.habitability_factors
      
      expect(factors[:temperature_state]).to eq("frozen_surface")
    end
    
    it "identifies vapor dominated state for high temperatures" do
      ocean_planet.update_columns(surface_temperature: 400) # 127°C
      ocean_planet.reload
      
      factors = ocean_planet.habitability_factors
      
      expect(factors[:temperature_state]).to eq("vapor_dominated")
    end
  end
  
  describe "#surface_features" do
    it "includes basic water features" do
      features = ocean_planet.surface_features
      
      expect(features).to include("significant_bodies_of_water")
      expect(features).to include("coastal_zones")
    end
    
    it "includes ocean_dominated for high water coverage" do
      # Update to 75% coverage
      total_water_area = ocean_planet.surface_area * 0.75
      ocean_planet.hydrosphere.update(
        liquid_bodies: {
          'oceans' => total_water_area * 0.7,
          'lakes' => total_water_area * 0.2,
          'rivers' => total_water_area * 0.1,
          'ice_caps' => 0,
          'groundwater' => 0
        }
      )
      ocean_planet.reload
      
      features = ocean_planet.surface_features
      
      expect(features).to include("ocean_dominated")
    end
    
    it "includes ice formations for cold temperatures" do
      ocean_planet.update_columns(surface_temperature: 260) # -13°C
      ocean_planet.reload
      
      features = ocean_planet.surface_features
      
      expect(features).to include("ice_formations")
    end
    
    it "includes liquid oceans for moderate temperatures" do
      ocean_planet.update_columns(surface_temperature: 290) # 17°C
      ocean_planet.reload
      
      features = ocean_planet.surface_features
      
      expect(features).to include("liquid_oceans")
    end
    
    it "includes vapor clouds for high temperatures" do
      ocean_planet.update_columns(surface_temperature: 380) # 107°C
      ocean_planet.reload
      
      features = ocean_planet.surface_features
      
      expect(features).to include("vapor_clouds")
    end
  end
  
  describe "#water_volume" do
    it "calculates water volume based on planet size and coverage" do
      volume = ocean_planet.water_volume
      
      expect(volume).to be > 0
      expect(volume).to be_a(Float)
    end
    
    it "returns 0 when radius is missing" do
      ocean_planet.update(radius: nil)
      
      expect(ocean_planet.water_volume).to eq(0)
    end
    
    it "returns 0 when hydrosphere is missing" do
      ocean_planet.hydrosphere.destroy
      ocean_planet.reload
      
      expect(ocean_planet.water_volume).to eq(0)
    end
    
    it "increases with higher water coverage" do
      initial_volume = ocean_planet.water_volume
      
      # Increase coverage from 45% to 70%
      total_water_area = ocean_planet.surface_area * 0.70
      ocean_planet.hydrosphere.update(
        liquid_bodies: {
          'oceans' => total_water_area * 0.7,
          'lakes' => total_water_area * 0.2,
          'rivers' => total_water_area * 0.1,
          'ice_caps' => 0,
          'groundwater' => 0
        }
      )
      ocean_planet.reload
      
      new_volume = ocean_planet.water_volume
      
      expect(new_volume).to be > initial_volume
    end
  end
  
  describe "#analyze_water_chemistry (protected method)" do
    it "identifies highly saline water" do
      ocean_planet.hydrosphere.update(
        composition: { 'water' => 85, 'salts' => 15 }
      )
      ocean_planet.reload
      
      # Access through habitability_factors which calls it
      factors = ocean_planet.habitability_factors
      
      expect(factors[:water_chemistry]).to eq("highly_saline")
    end
    
    it "identifies moderately saline water" do
      ocean_planet.hydrosphere.update(
        composition: { 'water' => 95, 'salts' => 5 }
      )
      ocean_planet.reload
      
      factors = ocean_planet.habitability_factors
      
      expect(factors[:water_chemistry]).to eq("moderately_saline")
    end
    
    it "identifies low salinity water" do
      ocean_planet.hydrosphere.update(
        composition: { 'water' => 98, 'salts' => 2 }
      )
      ocean_planet.reload
      
      factors = ocean_planet.habitability_factors
      
      expect(factors[:water_chemistry]).to eq("low_salinity")
    end
  end
  
  describe "STI type" do
    it "sets the correct STI type" do
      expect(ocean_planet.type).to eq('CelestialBodies::Planets::Ocean::OceanPlanet')
    end
  end
end