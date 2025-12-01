# spec/models/celestial_bodies/planets/gaseous/gas_giant_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Planets::Gaseous::GasGiant, type: :model do
  # Inherit all tests from GaseousPlanet spec
  it_behaves_like "a gaseous planet"
  
  # Setup for gas giant-specific tests
  let(:star) { create(:star, mass: 1.989e30, temperature: 5778, radius: 696_340_000) } # Sun-like
  let(:solar_system) { create(:solar_system, current_star: star) }
  let(:gas_giant) {
    FactoryBot.create(:gas_giant,
      name: "Test Gas Giant",
      identifier: "GG-TEST-1",
      mass: 1.898e27, # Jupiter mass
      radius: 7.1492e7, # Jupiter radius
      size: 1.0e8, # DB-safe value for size
      density: 1.33, # Jupiter density
      orbital_period: 374371200, # Jupiter orbital period in seconds
      solar_system: solar_system
    )
  }
  
  describe "gas giant specific methods" do
    describe "#estimate_moon_count" do
      context "with Jupiter mass" do
        it "estimates a realistic moon count" do
          # Jupiter has 79 known moons, so our estimate should be reasonable
          moon_count = gas_giant.estimate_moon_count
          expect(moon_count).to be_between(10, 100).inclusive
        end
      end
      
      context "with different masses" do
        it "scales moon count with mass" do
          original_count = gas_giant.estimate_moon_count
          
          # Double the mass
          gas_giant.mass *= 2
          new_count = gas_giant.estimate_moon_count
          
          expect(new_count).to be > original_count
        end
      end
    end
    
    describe "#ring_system_probability" do
      it "returns a high probability for gas giants" do
        probability = gas_giant.ring_system_probability
        expect(probability).to be_between(0.7, 0.8).inclusive
      end
    end
  end
end