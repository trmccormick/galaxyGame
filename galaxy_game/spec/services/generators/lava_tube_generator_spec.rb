require 'rails_helper'

RSpec.describe Generators::LavaTubeGenerator, type: :service do
  let(:moon) { create(:moon) }
  let(:mars) { create(:terrestrial_planet, name: 'Mars') }

  describe '#generate' do
    context 'with random generation' do
      it 'creates a lava tube with random features' do
        generator = Generators::LavaTubeGenerator.new(random: true, params: { celestial_body: moon })
        lava_tube = generator.generate

        expect(lava_tube).to be_persisted
        expect(lava_tube).to be_a(CelestialBodies::Features::LavaTube)
        expect(lava_tube.celestial_body).to eq(moon)
        expect(lava_tube.feature_id).to be_present
        expect(lava_tube.status).to eq('natural')
        expect(lava_tube.static_data).to be_present
      end

      it 'generates random dimensions' do
        generator = Generators::LavaTubeGenerator.new(random: true, params: { celestial_body: moon })
        lava_tube = generator.generate

        expect(lava_tube.length_m).to be_between(1000, 5000)
        expect(lava_tube.width_m).to be_between(10, 50)
        expect(lava_tube.height_m).to be_between(5, 25)
      end

      it 'generates random attributes' do
        generator = Generators::LavaTubeGenerator.new(random: true, params: { celestial_body: moon })
        lava_tube = generator.generate

        expect(lava_tube.natural_shielding).to be_between(0.1, 0.9)
        expect(lava_tube.thermal_stability).to be_in(['stable', 'moderate', 'unstable'])
        expect(lava_tube.suitability_rating).to be_between(1, 10)
      end

      it 'creates random skylights and access points' do
        generator = Generators::LavaTubeGenerator.new(random: true, params: { celestial_body: moon })
        lava_tube = generator.generate

        expect(lava_tube.skylights.count).to be_between(1, 5)
        expect(lava_tube.access_points.count).to be_between(2, 10)

        lava_tube.skylights.each do |skylight|
          expect(skylight.celestial_body).to eq(moon)
          expect(skylight.parent_feature).to eq(lava_tube)
          expect(skylight.status).to eq('natural')
        end

        lava_tube.access_points.each do |access_point|
          expect(access_point.celestial_body).to eq(moon)
          expect(access_point.parent_feature).to eq(lava_tube)
          expect(access_point.status).to eq('natural')
        end
      end
    end

    context 'with predefined parameters' do
      let(:params) do
        {
          celestial_body: mars,
          feature_id: 'test_lava_tube_001',
          status: 'surveyed',
          length: 2500,
          diameter: 30,
          height: 15,
          natural_shielding: 0.8,
          thermal_stability: 'stable',
          habitat_rating: 8,
          cost_multiplier: 1.2,
          advantages: ['Natural radiation shielding', 'Large volume'],
          challenges: ['Complex access'],
          priority: 4,
          strategic_value: ['Habitat potential', 'Resource site'],
          skylights: [
            { diameter: 12, position: 500 },
            { diameter: 8, position: 1200 }
          ],
          access_points: [
            { size: 5, position: 100, access_type: :large },
            { size: 3, position: 800, access_type: :medium }
          ]
        }
      end

      it 'creates a lava tube with specified parameters' do
        generator = Generators::LavaTubeGenerator.new(random: false, params: params)
        lava_tube = generator.generate

        expect(lava_tube.celestial_body).to eq(mars)
        expect(lava_tube.feature_id).to eq('test_lava_tube_001')
        expect(lava_tube.status).to eq('surveyed')
        expect(lava_tube.length_m).to eq(2500)
        expect(lava_tube.width_m).to eq(30)
        expect(lava_tube.height_m).to eq(15)
        expect(lava_tube.natural_shielding).to eq(0.8)
        expect(lava_tube.thermal_stability).to eq('stable')
        expect(lava_tube.suitability_rating).to eq(8)
        expect(lava_tube.estimated_cost_multiplier).to eq(1.2)
        expect(lava_tube.advantages).to eq(['Natural radiation shielding', 'Large volume'])
        expect(lava_tube.challenges).to eq(['Complex access'])
        expect(lava_tube.priority).to eq(4)
        expect(lava_tube.strategic_value).to eq(['Habitat potential', 'Resource site'])
      end

      it 'creates predefined skylights and access points' do
        generator = Generators::LavaTubeGenerator.new(random: false, params: params)
        lava_tube = generator.generate

        expect(lava_tube.skylights.count).to eq(2)
        expect(lava_tube.access_points.count).to eq(2)

        first_skylight = lava_tube.skylights.first
        expect(first_skylight.static_data['dimensions']['diameter_m']).to eq(12)
        expect(first_skylight.static_data['position']['distance_from_entrance_m']).to eq(500)

        first_access_point = lava_tube.access_points.first
        expect(first_access_point.static_data['dimensions']['width_m']).to eq(5)
        expect(first_access_point.static_data['position']['distance_from_entrance_m']).to eq(100)
        expect(first_access_point.static_data['attributes']['access_type']).to eq('large')
      end
    end

    context 'with minimal parameters' do
      it 'creates a lava tube with defaults' do
        generator = Generators::LavaTubeGenerator.new(random: false, params: { celestial_body: moon })
        lava_tube = generator.generate

        expect(lava_tube).to be_persisted
        expect(lava_tube.celestial_body).to eq(moon)
        expect(lava_tube.feature_id).to start_with('lt_')
        expect(lava_tube.status).to eq('natural')
        expect(lava_tube.static_data).to be_present
        expect(lava_tube.length_m).to be_present
        expect(lava_tube.width_m).to be_present
      end
    end
  end
end