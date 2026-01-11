require 'rails_helper'

RSpec.describe OrbitalRelationship, type: :model do
  # Test data setup
  let(:star) { create(:star, mass: 1.989e30, luminosity: 3.828e26) }  # Sun-like star
  let(:planet) { create(:terrestrial_planet, mass: "5.97e24", radius: 6.371e6, albedo: 0.3) }  # Earth-like
  let(:moon) { create(:moon, mass: "7.342e22", radius: 1.737e6) }  # Moon-like
  let(:binary_star) { create(:star, mass: 1.5e30, luminosity: 2.0e26) }

  describe "associations" do
    it "belongs to primary_body polymorphically" do
      relationship = OrbitalRelationship.new(primary_body: star)
      expect(relationship.primary_body).to eq(star)
    end

    it "belongs to secondary_body polymorphically" do
      relationship = OrbitalRelationship.new(secondary_body: planet)
      expect(relationship.secondary_body).to eq(planet)
    end
  end

  describe "validations" do
    let(:valid_attributes) do
      {
        primary_body: star,
        secondary_body: planet,
        relationship_type: 'star_planet',
        distance: 1.496e11,  # 1 AU
        semi_major_axis: 1.496e11
      }
    end

    it "is valid with valid attributes" do
      relationship = OrbitalRelationship.new(valid_attributes)
      expect(relationship).to be_valid
    end

    describe "relationship_type validation" do
      it "requires relationship_type to be present" do
        relationship = OrbitalRelationship.new(valid_attributes.except(:relationship_type))
        expect(relationship).not_to be_valid
        expect(relationship.errors[:relationship_type]).to include("can't be blank")
      end

      it "validates relationship_type inclusion" do
        valid_types = %w[star_planet planet_moon binary_star moon_submoon asteroid_planet]
        
        valid_types.each do |type|
          relationship = OrbitalRelationship.new(valid_attributes.merge(relationship_type: type))
          expect(relationship).to be_valid
        end

        relationship = OrbitalRelationship.new(valid_attributes.merge(relationship_type: 'invalid_type'))
        expect(relationship).not_to be_valid
      end
    end

    describe "numerical validations" do
      it "validates distance is positive" do
        relationship = OrbitalRelationship.new(valid_attributes.merge(distance: -1))
        expect(relationship).not_to be_valid
        expect(relationship.errors[:distance]).to include("must be greater than 0")
      end

      it "validates semi_major_axis is positive" do
        relationship = OrbitalRelationship.new(valid_attributes.merge(semi_major_axis: -1))
        expect(relationship).not_to be_valid
      end

      it "validates eccentricity is between 0 and 1" do
        # Valid eccentricity
        relationship = OrbitalRelationship.new(valid_attributes.merge(eccentricity: 0.5))
        expect(relationship).to be_valid

        # Invalid eccentricity
        relationship = OrbitalRelationship.new(valid_attributes.merge(eccentricity: 1.5))
        expect(relationship).not_to be_valid
      end

      it "validates orbital_period is positive" do
        relationship = OrbitalRelationship.new(valid_attributes.merge(orbital_period: -1))
        expect(relationship).not_to be_valid
      end
    end

    describe "uniqueness validation" do
      it "prevents duplicate relationships between same bodies" do
        OrbitalRelationship.create!(valid_attributes)
        
        duplicate = OrbitalRelationship.new(valid_attributes)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:secondary_body_id]).to include("has already been taken")
      end
    end
  end

  describe "backward compatibility methods" do
    let(:star_planet_relationship) do
      create(:orbital_relationship, 
        primary_body: star, 
        secondary_body: planet, 
        relationship_type: 'star_planet'
      )
    end

    describe "#sun" do
      it "returns primary_body when it's a Star" do
        expect(star_planet_relationship.sun).to eq(star)
      end

      it "returns nil when primary_body is not a Star" do
        planet_moon_relationship = create(:orbital_relationship,
          primary_body: planet,
          secondary_body: moon,
          relationship_type: 'planet_moon'
        )
        expect(planet_moon_relationship.sun).to be_nil
      end
    end

    describe "#sun=" do
      it "sets primary_body and relationship_type" do
        relationship = OrbitalRelationship.new(secondary_body: planet)
        relationship.sun = star
        
        expect(relationship.primary_body).to eq(star)
        expect(relationship.relationship_type).to eq('star_planet')
      end
    end

    describe "#celestial_body" do
      it "returns secondary_body when it's a CelestialBody" do
        expect(star_planet_relationship.celestial_body).to eq(planet)
      end
    end

    describe "#celestial_body=" do
      it "sets secondary_body" do
        relationship = OrbitalRelationship.new
        relationship.celestial_body = planet
        
        expect(relationship.secondary_body).to eq(planet)
      end
    end
  end

  describe "relationship type helpers" do
    it "identifies star_planet relationships" do
      relationship = create(:orbital_relationship,
        primary_body: star,
        secondary_body: planet,
        relationship_type: 'star_planet'
      )
      expect(relationship.star_planet_relationship?).to be true
      expect(relationship.planet_moon_relationship?).to be false
    end

    it "identifies planet_moon relationships" do
      relationship = create(:orbital_relationship,
        primary_body: planet,
        secondary_body: moon,
        relationship_type: 'planet_moon'
      )
      expect(relationship.planet_moon_relationship?).to be true
      expect(relationship.star_planet_relationship?).to be false
    end

    it "identifies binary_star relationships" do
      relationship = create(:orbital_relationship,
        primary_body: star,
        secondary_body: binary_star,
        relationship_type: 'binary_star'
      )
      expect(relationship.binary_star_relationship?).to be true
      expect(relationship.star_planet_relationship?).to be false
    end
  end

  describe "energy calculations" do
    describe "#stellar_energy_input" do
      it "calculates stellar energy based on luminosity and distance" do
        relationship = create(:orbital_relationship,
          primary_body: star,
          secondary_body: planet,
          relationship_type: 'star_planet',
          distance: 1.496e11  # 1 AU
        )

        expected_energy = star.luminosity / (4 * Math::PI * (1.496e11)**2)
        expect(relationship.stellar_energy_input).to be_within(0.01).of(expected_energy)
      end

      it "returns 0 when primary_body doesn't have luminosity" do
        relationship = create(:orbital_relationship,
          primary_body: planet,
          secondary_body: moon,
          relationship_type: 'planet_moon',
          distance: 3.844e8
        )

        expect(relationship.stellar_energy_input).to eq(0)
      end
    end

    describe "#tidal_heating" do
      it "calculates tidal heating for planet-moon relationships" do
        relationship = create(:orbital_relationship,
          primary_body: planet,
          secondary_body: moon,
          relationship_type: 'planet_moon',
          distance: 3.844e8,  # Earth-Moon distance
          eccentricity: 0.0549  # Moon's eccentricity
        )

        heating = relationship.tidal_heating
        expect(heating).to be > 0
      end

      it "includes eccentricity factor in calculation" do
        low_ecc = create(:orbital_relationship,
          primary_body: planet,
          secondary_body: moon,
          relationship_type: 'planet_moon',
          distance: 3.844e8,
          eccentricity: 0.01
        )

        high_ecc = create(:orbital_relationship,
          primary_body: planet,
          secondary_body: create(:moon, mass: "7.342e22", radius: 1.737e6),
          relationship_type: 'planet_moon',
          distance: 3.844e8,
          eccentricity: 0.2
        )

        expect(high_ecc.tidal_heating).to be > low_ecc.tidal_heating
      end
    end

    describe "#energy_input" do
      it "returns stellar energy for star_planet relationships" do
        relationship = create(:orbital_relationship,
          primary_body: star,
          secondary_body: planet,
          relationship_type: 'star_planet',
          distance: 1.496e11
        )

        expect(relationship.energy_input).to eq(relationship.stellar_energy_input)
      end

      it "returns combined tidal and reflected energy for planet_moon relationships" do
        # Create star-planet relationship first
        star_planet = create(:orbital_relationship,
          primary_body: star,
          secondary_body: planet,
          relationship_type: 'star_planet',
          distance: 1.496e11
        )

        # Create planet-moon relationship
        planet_moon = create(:orbital_relationship,
          primary_body: planet,
          secondary_body: moon,
          relationship_type: 'planet_moon',
          distance: 3.844e8
        )

        energy = planet_moon.energy_input
        expect(energy).to be > 0
        expect(energy).to eq(planet_moon.tidal_heating + planet_moon.reflected_energy)
      end
    end
  end

  describe "terraforming reflected_energy and energy_input" do
    it "returns extra energy for star_planet with orbital mirrors and albedo adjustment" do
      relationship = create(:orbital_relationship,
        primary_body: star,
        secondary_body: planet,
        relationship_type: 'star_planet',
        distance: 1.496e11
      )
      # Baseline: no mirrors, no albedo adjustment
      base_energy = relationship.energy_input
      # Add orbital mirrors (1e12 m^2 area, 100% reflectivity)
      mirror_energy = relationship.energy_input(mirror_area: 1e12, mirror_reflectivity: 1.0)
      expect(mirror_energy).to be > base_energy
      # Darken surface (albedo adjustment -0.1)
      darkened_energy = relationship.energy_input(albedo_adjustment: -0.1)
      expect(darkened_energy).to be > base_energy
      # Both together
      both_energy = relationship.energy_input(mirror_area: 1e12, mirror_reflectivity: 1.0, albedo_adjustment: -0.1)
      expect(both_energy).to be > [base_energy, mirror_energy, darkened_energy].max
    end
  end

  describe "orbital mechanics" do
    describe "#orbital_distance" do
      it "returns semi_major_axis when available" do
        relationship = create(:orbital_relationship,
          distance: 1.0e11,
          semi_major_axis: 1.5e11
        )
        expect(relationship.orbital_distance).to eq(1.5e11)
      end

      it "falls back to distance when semi_major_axis is nil" do
        relationship = create(:orbital_relationship,
          distance: 1.0e11,
          semi_major_axis: nil
        )
        expect(relationship.orbital_distance).to eq(1.0e11)
      end

      it "returns 0 when both are nil" do
        relationship = create(:orbital_relationship,
          distance: nil,
          semi_major_axis: nil
        )
        expect(relationship.orbital_distance).to eq(0)
      end
    end

    describe "#calculated_orbital_period" do
      it "calculates orbital period using Kepler's Third Law" do
        relationship = create(:orbital_relationship,
          primary_body: star,
          secondary_body: planet,
          relationship_type: 'star_planet',
          semi_major_axis: 1.496e11  # 1 AU
        )

        period = relationship.calculated_orbital_period
        expect(period).to be_within(1.0).of(365.25)  # Should be close to Earth's year
      end

      it "returns nil when primary_body has no mass" do
        star_with_mass = create(:star)
        relationship = create(:orbital_relationship,
          primary_body: star_with_mass,
          secondary_body: planet,
          semi_major_axis: 1.496e11
        )

        allow(star_with_mass).to receive(:mass).and_return(nil)
        expect(relationship.calculated_orbital_period).to be_nil
      end
    end

    describe "#current_orbital_position" do
      it "calculates orbital position based on time" do
        epoch = 1.month.ago
        relationship = create(:orbital_relationship,
          orbital_period: 30.0,  # 30 day period
          epoch_time: epoch,
          mean_anomaly_at_epoch: 0
        )

        position = relationship.current_orbital_position
        expect(position).to include(:mean_anomaly, :distance)
        expect(position[:mean_anomaly]).to be_between(0, 2 * Math::PI)
      end

      it "returns nil when orbital_period or epoch_time is missing" do
        relationship = create(:orbital_relationship,
          orbital_period: nil,
          epoch_time: nil
        )

        expect(relationship.current_orbital_position).to be_nil
      end
    end
  end

  describe "private methods" do
    describe "#masses_present?" do
      let(:relationship) { create(:orbital_relationship, primary_body: star, secondary_body: planet) }

      it "returns true when both bodies have mass" do
        expect(relationship.send(:masses_present?)).to be true
      end

      it "returns false when primary_body has no mass" do
        allow(star).to receive(:mass).and_return(nil)
        expect(relationship.send(:masses_present?)).to be false
      end
    end

    describe "#extract_mass" do
      let(:relationship) { create(:orbital_relationship) }

      it "extracts mass from Star objects" do
        mass = relationship.send(:extract_mass, star)
        expect(mass).to eq(star.mass)
      end

      it "extracts and converts mass from CelestialBody objects" do
        mass = relationship.send(:extract_mass, planet)
        expect(mass).to eq(planet.mass.to_f)
      end

      it "returns nil for unsupported object types" do
        mass = relationship.send(:extract_mass, "invalid")
        expect(mass).to be_nil
      end
    end
  end
end