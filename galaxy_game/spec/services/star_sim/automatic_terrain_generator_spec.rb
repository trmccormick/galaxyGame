# spec/services/star_sim/automatic_terrain_generator_spec.rb
require 'rails_helper'

RSpec.describe StarSim::AutomaticTerrainGenerator do
  let(:generator) { described_class.new }
  let(:mock_planet) do
    double('CelestialBody',
      name: 'TestPlanet',
      radius: 6371000,
      mass: 5.972e24,
      surface_temperature: 288,
      hydrosphere: double('hydrosphere', water_coverage: 71.0),
      atmosphere: double('atmosphere', pressure: 1.0),
      properties: { 'volcanic_activity' => 'moderate' },
      class: double('class', name: 'CelestialBodies::Planets::Rocky::TerrestrialPlanet'),
      geosphere: nil,
      magnetic_field: 50.0,  # Gauss
      density: 5.5,  # g/cm³
      type: 'terrestrial'
    ).tap do |planet|
      allow(planet).to receive(:create_geosphere!).and_return(double('geosphere').tap do |geosphere|
        allow(geosphere).to receive(:update!)
      end)
    end
  end

  describe '#generate_terrain_for_body' do
    before(:each) do
      # Allow the real method to be called for this test
      allow(generator).to receive(:generate_terrain_for_body).and_call_original
    end

    context 'when planet has no existing terrain' do
      it 'generates terrain data' do
        result = generator.generate_terrain_for_body(mock_planet)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:grid)
        expect(result).to have_key(:elevation)
        expect(result).to have_key(:biomes)
        expect(result).to have_key(:resource_grid)
        expect(result).to have_key(:strategic_markers)
      end

      it 'includes resource placements' do
        result = generator.generate_terrain_for_body(mock_planet)

        expect(result[:resource_grid]).to be_an(Array)
        expect(result[:resource_counts]).to be_a(Hash)
      end

      it 'includes strategic markers' do
        result = generator.generate_terrain_for_body(mock_planet)

        expect(result[:strategic_markers]).to be_an(Array)
      end
    end

    context 'when planet already has terrain' do
      let(:planet_with_terrain) do
        double('CelestialBody',
          name: 'TestPlanet',
          geosphere: double('geosphere', terrain_map: [[1, 2], [3, 4]])
        )
      end

      it 'skips terrain generation' do
        result = generator.generate_terrain_for_body(planet_with_terrain)
        expect(result).to be_nil
      end
    end
  end

  describe '#should_generate_terrain?' do
    context 'for terrestrial planets' do
      let(:terrestrial_planet) do
        double('CelestialBody',
          geosphere: nil,
          class: double('class', name: 'CelestialBodies::Planets::Rocky::TerrestrialPlanet')
        )
      end

      it 'returns true' do
        expect(generator.send(:should_generate_terrain?, terrestrial_planet)).to be true
      end
    end

    context 'for major moons' do
      let(:major_moon) do
        double('CelestialBody',
          name: 'Luna',
          mass: 7.34e22,
          geosphere: nil,
          class: double('class', name: 'CelestialBodies::Satellites::Moon')
        )
      end

      it 'returns true for major moons' do
        expect(generator.send(:should_generate_terrain?, major_moon)).to be true
      end
    end

    context 'for gas giants' do
      let(:gas_giant) do
        double('CelestialBody',
          name: 'Jupiter',
          geosphere: nil,
          class: double('class', name: 'CelestialBodies::Planets::Gaseous::GasGiant')
        )
      end

      it 'returns false' do
        expect(generator.send(:should_generate_terrain?, gas_giant)).to be false
      end
    end
  end

  describe '#analyze_planet_properties' do
    it 'calculates terrain complexity based on planet size' do
      params = generator.send(:analyze_planet_properties, mock_planet)

      expect(params[:terrain_complexity]).to be_between(0.1, 1.0)
      expect(params[:biome_density]).to be_between(0.0, 0.8)
      expect(params[:elevation_scale]).to be > 0
    end

    it 'adjusts for Earth-like planets' do
      earth_planet = double('CelestialBody',
        name: 'Earth',
        radius: 6371000,
        mass: 5.972e24,
        surface_temperature: 288,
        hydrosphere: double('hydrosphere', water_coverage: 71.0),
        atmosphere: double('atmosphere', pressure: 1.0),
        properties: {},
        density: 5.5  # g/cm³
      )

      params = generator.send(:analyze_planet_properties, earth_planet)
      expect(params[:biome_density]).to eq(1.0)
    end
  end

  describe '#earth_like_planet?' do
    it 'returns true for Earth' do
      earth = double('CelestialBody', name: 'Earth')
      expect(generator.send(:earth_like_planet?, earth)).to be true
    end

    it 'returns true for habitable planets' do
      habitable_planet = double('CelestialBody',
        name: 'TestPlanet',
        surface_temperature: 300,
        hydrosphere: double('hydrosphere', water_coverage: 80.0),
        atmosphere: double('atmosphere', pressure: 1.5)
      )
      expect(generator.send(:earth_like_planet?, habitable_planet)).to be true
    end

    it 'returns false for inhospitable planets' do
      inhospitable_planet = double('CelestialBody',
        name: 'TestPlanet',
        surface_temperature: 100,
        hydrosphere: double('hydrosphere', water_coverage: 10.0),
        atmosphere: double('atmosphere', pressure: 0.1)
      )
      expect(generator.send(:earth_like_planet?, inhospitable_planet)).to be false
    end
  end
end