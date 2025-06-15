require 'rails_helper'

RSpec.describe CelestialBodies::Satellites::Satellite, type: :model do
  # Use your existing factory pattern - these should all work now
  let(:star) { create(:star, mass: 1.989e30) }
  let(:solar_system) { create(:solar_system) }
  let(:planet) { create(:terrestrial_planet, 
                       mass: "5.972e24", 
                       radius: 6.371e6, 
                       rotational_period: 1.0,
                       solar_system: solar_system) }
  let(:satellite) { create(:satellite, 
                          parent_celestial_body: planet,
                          orbital_period: 27.3,
                          rotational_period: 27.3,
                          solar_system: solar_system) }

  describe "inheritance and concerns" do
    it "inherits from CelestialBody" do
      expect(satellite).to be_a(CelestialBodies::CelestialBody)
    end

    it "includes OrbitalMechanics concern" do
      expect(CelestialBodies::Satellites::Satellite.included_modules).to include(OrbitalMechanics)
    end
  end

  describe "associations" do
    it "belongs to parent_celestial_body" do
      expect(satellite.parent_celestial_body).to eq(planet)
    end

    it "has parent_body alias" do
      expect(satellite.parent_body).to eq(planet)
      expect(satellite.parent_body).to eq(satellite.parent_celestial_body)
    end
  end

  describe "validations" do
    it "validates orbital_period is positive" do
      satellite.orbital_period = -1
      expect(satellite).not_to be_valid
      expect(satellite.errors[:orbital_period]).to include("must be greater than 0")
    end

    it "validates rotational_period is positive" do
      satellite.rotational_period = -1
      expect(satellite).not_to be_valid
      expect(satellite.errors[:rotational_period]).to include("must be greater than 0")
    end

    it "allows nil values for orbital and rotational periods" do
      satellite.orbital_period = nil
      satellite.rotational_period = nil
      expect(satellite).to be_valid
    end
  end

  describe "rotational mechanics" do
    describe "#tidally_locked?" do
      it "returns true when rotational and orbital periods are equal" do
        satellite.rotational_period = 27.3
        satellite.orbital_period = 27.3
        expect(satellite.tidally_locked?).to be true
      end

      it "returns true when periods are within 5% tolerance" do
        satellite.rotational_period = 27.0
        satellite.orbital_period = 27.3
        expect(satellite.tidally_locked?).to be true
      end

      it "returns false when periods differ significantly" do
        satellite.rotational_period = 1.0  # 24 hours
        satellite.orbital_period = 27.3
        expect(satellite.tidally_locked?).to be false
      end

      it "returns false when either period is missing" do
        satellite.rotational_period = nil
        expect(satellite.tidally_locked?).to be false
      end
    end

    describe "#day_length_hours" do
      it "converts rotational period from days to hours" do
        satellite.rotational_period = 2.0
        expect(satellite.day_length_hours).to eq(48.0)
      end

      it "returns nil when rotational_period is not set" do
        satellite.rotational_period = nil
        expect(satellite.day_length_hours).to be_nil
      end
    end

    describe "#temperature_variation" do
      it "returns :extreme for very long rotational periods" do
        satellite.rotational_period = 150.0
        expect(satellite.temperature_variation).to eq(:extreme)
      end

      it "returns :none for tidally locked satellites" do
        satellite.rotational_period = 27.3
        satellite.orbital_period = 27.3
        expect(satellite.temperature_variation).to eq(:none)
      end

      it "returns :normal for Earth-like rotation" do
        satellite.rotational_period = 1.0
        expect(satellite.temperature_variation).to eq(:normal)
      end

      it "returns :extreme when rotational_period is nil" do
        satellite.rotational_period = nil
        expect(satellite.temperature_variation).to eq(:extreme)
      end
    end
  end

  describe "orbital relationship methods" do
    describe "#orbits_planet?" do
      it "returns true when parent is a terrestrial planet" do
        expect(satellite.orbits_planet?).to be true
      end

      it "returns false when parent celestial body is not set" do
        satellite.parent_celestial_body = nil
        expect(satellite.orbits_planet?).to be false
      end
    end

    describe "#calculate_tidal_forces" do
      it "returns 0 when parent celestial body is not set" do
        satellite.parent_celestial_body = nil
        expect(satellite.calculate_tidal_forces).to eq(0)
      end

      it "returns 0 when mass is not set" do
        satellite.mass = nil
        expect(satellite.calculate_tidal_forces).to eq(0)
      end

      it "calculates tidal forces when all data is present" do
        allow(planet).to receive(:mass).and_return("5.97e24")
        
        tidal_force = satellite.calculate_tidal_forces
        expect(tidal_force).to be > 0
      end
    end
  end
end