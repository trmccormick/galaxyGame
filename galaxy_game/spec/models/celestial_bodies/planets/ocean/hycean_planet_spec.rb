require 'rails_helper'

RSpec.describe CelestialBodies::Planets::Ocean::HyceanPlanet, type: :model do
  subject(:hycean_planet) { create(:hycean_planet) }
  
  describe "validations" do
    it "requires an atmosphere to be present" do
      hycean_planet.atmosphere.destroy
      hycean_planet.reload
      
      expect(hycean_planet).not_to be_valid
      expect(hycean_planet.errors[:atmosphere]).to include("can't be blank")
    end
    
    it "requires at least 10% hydrogen in atmosphere" do
      # Update H2 percentage to be too low
      h2_gas = hycean_planet.atmosphere.gases.find_by(name: 'H2')
      h2_gas.update(percentage: 5)
      
      expect(hycean_planet).not_to be_valid
      expect(hycean_planet.errors[:atmosphere]).to include("must contain at least 10% hydrogen for a Hycean planet")
    end
    
    it "requires significant atmospheric pressure (>1 atm)" do
      hycean_planet.atmosphere.update(pressure: 0.5)
      
      expect(hycean_planet).not_to be_valid
      expect(hycean_planet.errors[:atmosphere]).to include("must have significant pressure (>1 atm) for a Hycean planet")
    end
    
    it "is valid with proper hydrogen content and pressure" do
      # Factory creates with 60% H2 and 15 atm by default
      expect(hycean_planet).to be_valid
    end
    
    it "inherits ocean planet water coverage validation" do
      # Set water coverage below 30% (violates parent class requirement)
      total_water_area = hycean_planet.surface_area * 0.25
      hycean_planet.hydrosphere.update(
        liquid_bodies: {
          'oceans' => total_water_area * 0.7,
          'lakes' => total_water_area * 0.2,
          'rivers' => total_water_area * 0.1,
          'ice_caps' => 0,
          'groundwater' => 0
        }
      )
      hycean_planet.reload
      
      expect(hycean_planet).not_to be_valid
      expect(hycean_planet.errors[:hydrosphere]).to include("water coverage must be at least 30% for an ocean planet")
    end
  end
  
  describe "#habitability_factors" do
    it "includes base ocean planet factors" do
      factors = hycean_planet.habitability_factors
      
      expect(factors[:aquatic_environment]).to be_present
    end
    
    it "includes hydrogen blanket greenhouse effect" do
      factors = hycean_planet.habitability_factors
      
      expect(factors[:greenhouse_effect]).to eq("strong_hydrogen_blanket")
    end
    
    it "calculates pressure habitability zones" do
      factors = hycean_planet.habitability_factors
      
      expect(factors[:pressure_zones]).to be_present
      expect(factors[:pressure_zones]).to be_a(Integer)
    end
    
    it "indicates expanded habitable temperature range" do
      factors = hycean_planet.habitability_factors
      
      expect(factors[:habitable_temperature_range]).to eq("expanded")
    end
    
    it "rates optimal pressure range (10-100 atm) as level 3" do
      hycean_planet.atmosphere.update(pressure: 50)
      hycean_planet.save!
      
      factors = hycean_planet.habitability_factors
      
      expect(factors[:pressure_zones]).to eq(3)
    end
    
    it "rates moderate pressure range (1-10 or 100-1000 atm) as level 2" do
      hycean_planet.atmosphere.update(pressure: 5)
      hycean_planet.save!
      
      factors = hycean_planet.habitability_factors
      
      expect(factors[:pressure_zones]).to eq(2)
    end
    
    it "rates extreme pressure as level 1" do
      hycean_planet.atmosphere.update(pressure: 2000)
      hycean_planet.save!
      
      factors = hycean_planet.habitability_factors
      
      expect(factors[:pressure_zones]).to eq(1)
    end
  end
  
  describe "#surface_features" do
    it "includes base ocean planet features" do
      features = hycean_planet.surface_features
      
      expect(features).to include("significant_bodies_of_water")
    end
    
    it "includes hydrogen atmosphere features" do
      features = hycean_planet.surface_features
      
      expect(features).to include("thick_atmospheric_layer")
      expect(features).to include("hydrogen_dominated_atmosphere")
      expect(features).to include("strong_greenhouse_effect")
      expect(features).to include("exotic_cloud_formations")
    end
    
    it "includes extreme storm systems for high pressure atmospheres" do
      hycean_planet.atmosphere.update(pressure: 25)
      hycean_planet.save!
      
      features = hycean_planet.surface_features
      
      expect(features).to include("extreme_storm_systems")
    end
    
    it "does not include storm systems for lower pressure" do
      hycean_planet.atmosphere.update(pressure: 3)
      hycean_planet.save!
      
      features = hycean_planet.surface_features
      
      expect(features).not_to include("extreme_storm_systems")
    end
  end
  
  describe "#ocean_chemistry" do
    it "identifies hydrogen saturated oceans for high H2 content" do
      # Factory creates with 60% H2 by default
      chemistry = hycean_planet.ocean_chemistry
      
      expect(chemistry).to eq("hydrogen_saturated")
    end
    
    it "identifies methane rich oceans when CH4 is present" do
      # Change H2 to be lower
      h2_gas = hycean_planet.atmosphere.gases.find_by(name: 'H2')
      h2_gas.update(percentage: 15)
      
      chemistry = hycean_planet.ocean_chemistry
      
      expect(chemistry).to eq("methane_rich")
    end
    
    it "returns unknown when hydrosphere composition is missing" do
      hycean_planet.hydrosphere.update(composition: nil)
      hycean_planet.reload
      
      chemistry = hycean_planet.ocean_chemistry
      
      expect(chemistry).to eq("unknown")
    end
  end
  
  describe "#habitable_layer_depth" do
    it "calculates habitable depth range based on pressure" do
      depths = hycean_planet.habitable_layer_depth
      
      expect(depths).to be_a(Hash)
      expect(depths).to have_key(:minimum_depth)
      expect(depths).to have_key(:maximum_depth)
    end
    
    it "sets deeper minimum depth for higher pressure" do
      hycean_planet.atmosphere.update(pressure: 50)
      hycean_planet.save!
      
      depths = hycean_planet.habitable_layer_depth
      
      # 50 atm * 100 = 5000m minimum
      expect(depths[:minimum_depth]).to eq(5000)
    end
    
    it "ensures maximum depth is greater than minimum" do
      depths = hycean_planet.habitable_layer_depth
      
      expect(depths[:maximum_depth]).to be > depths[:minimum_depth]
    end
    
    it "returns nil when atmosphere is missing" do
      hycean_planet.atmosphere.destroy
      hycean_planet.reload
      
      expect(hycean_planet.habitable_layer_depth).to be_nil
    end
    
    it "returns nil when hydrosphere is missing" do
      hycean_planet.hydrosphere.destroy
      hycean_planet.reload
      
      expect(hycean_planet.habitable_layer_depth).to be_nil
    end
  end
  
  describe "#hydrogen_percentage (private method)" do
    it "calculates hydrogen percentage from atmosphere" do
      # Access through ocean_chemistry which uses it
      chemistry = hycean_planet.ocean_chemistry
      
      # Factory creates with 60% H2
      expect(chemistry).to eq("hydrogen_saturated")
    end
    
    it "returns 0 when H2 gas is not present" do
      # Remove all H2
      hycean_planet.atmosphere.gases.where(name: 'H2').destroy_all
      hycean_planet.reload
      
      # This should now fail validation, but we can test the behavior
      expect(hycean_planet).not_to be_valid
    end
  end
  
  describe "STI type" do
    it "sets the correct STI type" do
      expect(hycean_planet.type).to eq('CelestialBodies::Planets::Ocean::HyceanPlanet')
    end
  end
  
  describe "with :extreme trait" do
    subject(:extreme_hycean) { create(:hycean_planet, :extreme) }
    
    it "has very high surface temperature" do
      expect(extreme_hycean.surface_temperature).to eq(400)
    end
    
    it "has very high atmospheric pressure" do
      expect(extreme_hycean.atmosphere.pressure).to eq(50.0)
    end
  end
  
  describe "with :cold trait" do
    subject(:cold_hycean) { create(:hycean_planet, :cold) }
    
    it "has below-freezing surface temperature" do
      expect(cold_hycean.surface_temperature).to eq(260)
    end
    
    it "has significant ice coverage" do
      liquid_bodies = cold_hycean.hydrosphere.liquid_bodies
      
      expect(liquid_bodies['ice_caps'].to_f).to be > 0
    end
    
    it "has higher ammonia content as antifreeze" do
      composition = cold_hycean.hydrosphere.composition
      
      expect(composition['ammonia']).to eq(12)
    end
    
    it "has mixed liquid-solid state distribution" do
      state_dist = cold_hycean.hydrosphere.state_distribution
      
      expect(state_dist['liquid']).to eq(60)
      expect(state_dist['solid']).to eq(40)
    end
  end
  
  describe "inheritance from OceanPlanet" do
    it "inherits water_volume calculation" do
      volume = hycean_planet.water_volume
      
      expect(volume).to be > 0
    end
    
    it "can analyze water chemistry" do
      hycean_planet.hydrosphere.update(
        composition: { 'water' => 85, 'salts' => 15 }
      )
      hycean_planet.reload
      
      factors = hycean_planet.habitability_factors
      
      # Should have water_chemistry from parent or ocean_chemistry override
      expect(factors[:water_chemistry]).to be_present
    end
  end
end