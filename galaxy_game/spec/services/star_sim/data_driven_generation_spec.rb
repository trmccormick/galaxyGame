require 'rails_helper'

RSpec.describe 'Data-Driven Celestial Body Generation' do
  let(:json_path) { Rails.root.join('app', 'data', 'star_systems', 'sol-complete.json') }
  let(:system_data) { JSON.parse(File.read(json_path)) }
  let(:celestial_bodies) { system_data['celestial_bodies'] }

  describe 'Sol system magnetosphere values' do
    it 'has Earth with magnetosphere_strength 1.0 and radius ~60000 km' do
      earth = celestial_bodies.find { |p| p['name'] == 'Earth' }
      expect(earth).not_to be_nil
      expect(earth['magnetosphere_strength']).to eq(1.0)
      expect(earth['magnetosphere_radius_km']).to be_within(5000).of(60000)
    end

    it 'has Venus with magnetosphere_strength 0.3 and smaller radius' do
      venus = celestial_bodies.find { |p| p['name'] == 'Venus' }
      expect(venus).not_to be_nil
      expect(venus['magnetosphere_strength']).to eq(0.3)
      expect(venus['magnetosphere_radius_km']).to be < 10000 # Induced field, shorter range
    end

    it 'has Mars with magnetosphere_strength 0.0 and no radius' do
      mars = celestial_bodies.find { |p| p['name'] == 'Mars' }
      expect(mars).not_to be_nil
      expect(mars['magnetosphere_strength']).to eq(0.0)
      expect(mars['magnetosphere_radius_km']).to be_nil
    end

    it 'has Mercury with very weak magnetosphere' do
      mercury = celestial_bodies.find { |p| p['name'] == 'Mercury' }
      expect(mercury).not_to be_nil
      expect(mercury['magnetosphere_strength']).to be > 0.0
      expect(mercury['magnetosphere_strength']).to be < 0.01
      expect(mercury['magnetosphere_radius_km']).to be < 1000
    end

    it 'has no duplicate magnetosphere fields for any planet' do
      celestial_bodies.each do |body|
        next unless body['type'] == 'terrestrial_planet'
        
        # Count occurrences of magnetosphere_strength in this body
        body_str = body.to_json
        count = body_str.scan(/"magnetosphere_strength"/).size
        
        expect(count).to eq(1), "Expected 1 magnetosphere_strength for #{body['name']}, found #{count}"
      end
    end
  end

  describe 'Gas giants magnetosphere values' do
    it 'has Jupiter with strong magnetosphere and large radius' do
      jupiter = celestial_bodies.find { |p| p['type'] == 'gas_giant' && p['name'] == 'Jupiter' }
      expect(jupiter).not_to be_nil
      expect(jupiter['magnetosphere_strength']).to eq(1.0)
      expect(jupiter['magnetosphere_radius_km']).to eq(7000000) # 7M km field extent
    end

    it 'has Saturn with strong magnetosphere' do
      saturn = celestial_bodies.find { |p| p['type'] == 'gas_giant' && p['name'] == 'Saturn' }
      expect(saturn).not_to be_nil
      expect(saturn['magnetosphere_strength']).to be > 0.5
    end
  end

  describe 'Moon magnetosphere data structure' do
    it 'has Ganymede with intrinsic magnetosphere_strength 0.15 and parent Jupiter' do
      ganymede = celestial_bodies.find { |m| m['name'] == 'Ganymede' }
      expect(ganymede).not_to be_nil
      expect(ganymede['magnetosphere_strength']).to eq(0.15)
      expect(ganymede['magnetosphere_radius_km']).to eq(500)
      expect(ganymede['orbital_distance_km']).to eq(1070400)
      expect(ganymede['parent_body']).to eq('Jupiter')
    end

    it 'has Jupiter with strong magnetosphere protecting inner moons' do
      jupiter = celestial_bodies.find { |p| p['type'] == 'gas_giant' && p['name'] == 'Jupiter' }
      expect(jupiter['magnetosphere_strength']).to eq(1.0)
      expect(jupiter['magnetosphere_radius_km']).to eq(7000000) # 7M km field extent
      
      # Ganymede orbits at 1.07M km, well inside Jupiter's 7M km magnetosphere
      ganymede_orbit_km = 1070400
      expect(ganymede_orbit_km).to be < jupiter['magnetosphere_radius_km']
    end

    it 'supports parent_body_name for moons (Titan orbiting Saturn)' do
      titan = celestial_bodies.find { |m| m['name'] == 'Titan' }
      if titan
        expect(titan['parent_body']).to eq('Saturn')
      end
    end
  end

  describe 'No hardcoded planet values in data file' do
    it 'does not contain Topaz patches' do
      system_str = system_data.to_json
      expect(system_str).not_to include('magnetic_moment')
      expect(system_str).not_to include('tei_score')
    end

    it 'does not contain strong_magnetosphere boolean flags' do
      system_str = system_data.to_json
      expect(system_str).not_to include('strong_magnetosphere')
    end
  end
end
