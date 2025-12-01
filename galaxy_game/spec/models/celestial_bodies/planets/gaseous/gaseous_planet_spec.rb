# spec/models/celestial_bodies/planets/gaseous/gaseous_planet_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Planets::Gaseous::GaseousPlanet, type: :model do
  # Setup a star and solar system for our tests
  let(:star) { create(:star, mass: 1.989e30, temperature: 5778, radius: 696_340_000) } # Sun-like
  let(:solar_system) { create(:solar_system, current_star: star) }
  let(:gaseous_planet) { described_class.new(
    name: "Test Gas Planet",
    identifier: "GAS-TEST-1",
    mass: 1.898e27, # Jupiter mass
    radius: 7.1492e7, # Jupiter radius
    size: 1.43e15, # Jupiter volume in m^3 (example value)
    density: 1.33, # Jupiter density
    rotational_period: 9.93 * 3600, # ~10 hour rotation (in seconds)
    orbital_period: 4333 * 24 * 3600, # Jupiter orbital period (in seconds)
    semi_major_axis: 5.2, # Jupiter semi-major axis (in AU)
    solar_system: solar_system
  )}

  describe "validations" do
    it "is valid with valid attributes" do
      expect(gaseous_planet).to be_valid
    end
    
    it "requires density to be less than 2.0" do
      gaseous_planet.density = 2.5
      expect(gaseous_planet).not_to be_valid
      expect(gaseous_planet.errors[:density]).to include("must be less than 2.0")
    end
  end
  
  describe "#has_solid_surface?" do
    it "returns false for gaseous planets" do
      expect(gaseous_planet.has_solid_surface?).to eq(false)
    end
  end
  
  describe "#calculate_bands" do
    context "with fast rotation" do
      it "calculates more cloud bands" do
        gaseous_planet.rotational_period = 10 * 3600 # 10 hours
        band_count = gaseous_planet.calculate_bands
        expect(band_count).to be_between(6, 12).inclusive
      end
    end
    
    context "with slower rotation" do
      it "calculates fewer cloud bands" do
        gaseous_planet.rotational_period = 20 * 3600 # 20 hours
        band_count = gaseous_planet.calculate_bands
        expect(band_count).to be_between(2, 5).inclusive
      end
    end
    
    context "with nil rotation period" do
      it "returns a default value" do
        gaseous_planet.rotational_period = nil
        expect(gaseous_planet.calculate_bands).to eq(2)
      end
    end
  end
  
  describe "#calculate_blackbody_temperature" do
    context "with valid star and semi-major axis" do
      it "calculates approximate blackbody temperature" do
        # For Jupiter-like planet, should be around 110-120K
        temperature = gaseous_planet.calculate_blackbody_temperature
        expect(temperature).to be_within(20).of(110)
      end
    end
    
    context "without valid star data" do
      it "returns a default temperature value" do
        allow(gaseous_planet).to receive(:solar_system).and_return(nil)
        expect(gaseous_planet.calculate_blackbody_temperature).to eq(100)
      end
    end
  end
end