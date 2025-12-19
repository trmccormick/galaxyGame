require 'rails_helper'

RSpec.describe CelestialBodies::Satellites::Moon, type: :model do
  let(:star) { create(:star) }
  let(:solar_system) { create(:solar_system, current_star: star) }
  let(:planet) { create(:terrestrial_planet, solar_system: solar_system) }
  let(:moon) { create(:moon, solar_system: solar_system, parent_celestial_body: planet) }

  describe "STI configuration" do
    it "sets the correct type before validation" do
      expect(moon.type).to eq('CelestialBodies::Satellites::Moon')
    end
  end

  describe "#orbits_planet?" do
    it "returns true when parent celestial body is a planet" do
      expect(moon.orbits_planet?).to be true
    end
    
    it "returns false when parent celestial body is not set" do
      moon.parent_celestial_body = nil
      expect(moon.orbits_planet?).to be false
    end
    
    it "works with parent_body alias" do
      expect(moon.parent_body).to eq(planet)
      expect(moon.orbits_planet?).to be true
    end
  end
  
  describe "#calculate_tidal_forces" do
    it "returns 0 when parent celestial body is not set" do
      moon.parent_celestial_body = nil
      expect(moon.calculate_tidal_forces).to eq(0)
    end
    
    it "returns 0 when required attributes are missing" do
      moon.mass = nil
      expect(moon.calculate_tidal_forces).to eq(0)
    end
    
    it "calculates tidal forces based on parent mass and orbital period" do
      moon.mass = "7.3e22"
      moon.radius = 1.7e6
      moon.orbital_period = 27.3
      
      allow(planet).to receive(:mass).and_return("5.97e24")
      
      expect(moon.calculate_tidal_forces).to be > 0
    end
  end
end