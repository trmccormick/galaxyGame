require 'rails_helper'

RSpec.describe Generators::ValleyGenerator, type: :service do
  let(:mars) { create(:terrestrial_planet, name: 'Mars') }

  describe '#generate' do
    context 'with random generation' do
      it 'creates a valley with random features' do
        generator = Generators::ValleyGenerator.new(random: true, params: { celestial_body: mars })
        valley = generator.generate

        expect(valley).to be_persisted
        expect(valley).to be_a(CelestialBodies::Features::Valley)
        expect(valley.celestial_body).to eq(mars)
        expect(valley.feature_id).to start_with('vl_')
        expect(valley.status).to eq('natural')
        expect(valley.static_data).to be_present
      end

      it 'generates random dimensions' do
        generator = Generators::ValleyGenerator.new(random: true, params: { celestial_body: mars })
        valley = generator.generate

        expect(valley.length_m).to be_between(5000, 50000)
        expect(valley.width_m).to be_between(1000, 10000)
        expect(valley.depth_m).to be_between(100, 1000)
      end

      it 'generates segments' do
        generator = Generators::ValleyGenerator.new(random: true, params: { celestial_body: mars })
        valley = generator.generate

        segments = valley.segments
        expect(segments).to be_an(Array)
        expect(segments.length).to be_between(3, 8)

        segments.each do |segment|
          expect(segment).to have_key('name')
          expect(segment).to have_key('length_m')
          expect(segment).to have_key('width_m')
        end
      end

      it 'creates random access points' do
        generator = Generators::ValleyGenerator.new(random: true, params: { celestial_body: mars })
        valley = generator.generate

        # May have 0-2 access points
        expect(valley.access_points.count).to be_between(0, 2)

        valley.access_points.each do |access_point|
          expect(access_point.celestial_body).to eq(mars)
          expect(access_point.parent_feature).to eq(valley)
          expect(access_point.status).to eq('natural')
        end
      end
    end

    context 'with predefined parameters' do
      let(:params) do
        {
          celestial_body: mars,
          feature_id: 'test_valley_001',
          status: 'surveyed',
          length: 15000,
          width: 3000,
          depth: 500,
          formation: 'erosion',
          habitat_rating: 7,
          cost_multiplier: 1.2,
          advantages: ['Natural protection', 'Large volume'],
          challenges: ['Complex terrain'],
          priority: 3,
          strategic_value: ['Habitat potential'],
          access_points: [
            { width: 50, height: 20, position: 5000, access_type: :wide }
          ]
        }
      end

      it 'creates a valley with specified parameters' do
        generator = Generators::ValleyGenerator.new(random: false, params: params)
        valley = generator.generate

        expect(valley.celestial_body).to eq(mars)
        expect(valley.feature_id).to eq('test_valley_001')
        expect(valley.status).to eq('surveyed')
        expect(valley.length_m).to eq(15000)
        expect(valley.width_m).to eq(3000)
        expect(valley.depth_m).to eq(500)
        expect(valley.formation).to eq('erosion')
        expect(valley.suitability_rating).to eq(7)
      end

      it 'creates predefined access points' do
        generator = Generators::ValleyGenerator.new(random: false, params: params)
        valley = generator.generate

        expect(valley.access_points.count).to eq(1)

        access_point = valley.access_points.first
        expect(access_point.static_data['dimensions']['width_m']).to eq(50)
        expect(access_point.static_data['position']['distance_from_entrance_m']).to eq(5000)
        expect(access_point.static_data['attributes']['access_type']).to eq('wide')
      end
    end
  end
end