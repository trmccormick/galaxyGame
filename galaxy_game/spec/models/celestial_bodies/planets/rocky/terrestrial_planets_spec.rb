require 'rails_helper'

RSpec.describe CelestialBodies::Planets::Rocky::TerrestrialPlanet, type: :model do
  let(:star) { create(:star) }
  let(:solar_system) { create(:solar_system, current_star: star) }
  let(:planet) { create(:terrestrial_planet, :mars, solar_system: solar_system) }

  describe '#atmosphere_composition' do
    it 'returns a hash of gas names and percentages' do
      expect(planet.atmosphere_composition).to be_a(Hash)
    end
  end

  describe '#habitable_zone?' do
    it 'returns a boolean indicating if the planet is in the habitable zone' do
      expect([true, false]).to include(planet.habitable_zone?)
    end
  end

  describe '#habitability_score' do
    it 'returns a numeric score for habitability' do
      expect(planet.habitability_score).to be_a(Numeric)
    end
  end

  describe '#classification' do
    it 'returns a string classification for the planet' do
      expect(planet.classification).to be_a(String)
    end
  end

  describe '#day_night_cycle' do
    it 'returns nil or a numeric value for the day-night cycle' do
      result = planet.day_night_cycle
      expect(result).to(be_nil.or be_a(Numeric))
    end
  end

  describe '#earth_masses' do
    it 'returns the mass of the planet in Earth masses' do
      expect(planet.earth_masses).to be_a(Float)
    end
  end

  describe '#earth_radii' do
    it 'returns the radius of the planet in Earth radii' do
      expect(planet.earth_radii).to be_a(Float)
    end
  end

  describe '#temperature_score' do
    it 'returns a numeric score for temperature habitability' do
      expect(planet.send(:temperature_score)).to be_a(Numeric)
    end
  end

  describe '#pressure_score' do
    it 'returns a numeric score for pressure habitability' do
      expect(planet.send(:pressure_score)).to be_a(Numeric)
    end
  end

  describe '#atmosphere_score' do
    it 'returns a numeric score for atmosphere habitability' do
      expect(planet.send(:atmosphere_score)).to be_a(Numeric)
    end
  end

  describe '#gravity_score' do
    it 'returns a numeric score for gravity habitability' do
      expect(planet.send(:gravity_score)).to be_a(Numeric)
    end
  end

  describe '#calculated_atmospheric_pressure' do
    it 'returns a numeric value for calculated atmospheric pressure' do
      expect(planet.send(:calculated_atmospheric_pressure)).to be_a(Numeric)
    end
  end
end
