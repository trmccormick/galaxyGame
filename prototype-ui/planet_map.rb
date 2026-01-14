# app/models/planet_map.rb
class PlanetMap < ApplicationRecord
  belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
  
  # Dimensions based on planet size
  # For Earth-sized planet: 360x180 tiles (1 degree per tile)
  # Smaller planets scale down proportionally
  validates :width, :height, presence: true, numericality: { greater_than: 0 }
  
  # Store the actual tile data as JSON
  # Structure: { "0,0": { terrain: "ocean", elevation: -2000, biome: "deep_sea" }, ... }
  store :tile_data, accessors: [:tiles], coder: JSON
  
  # Generation parameters
  store :generation_params, accessors: [:seed, :noise_scale, :octaves], coder: JSON
  
  # Calculate dimensions from planet radius
  def self.calculate_dimensions(planet)
    # Earth radius: 6371 km, use as baseline for 360x180 map
    earth_radius = 6.371e6
    scale_factor = planet.radius / earth_radius
    
    # Minimum 50x50 for small bodies, max 720x360 for super-earths
    width = [[50, (360 * scale_factor).to_i].max, 720].min
    height = [[50, (180 * scale_factor).to_i].max, 360].min
    
    { width: width, height: height }
  end
  
  # Generate map from planet's geosphere/hydrosphere data
  def generate_from_planet_data!
    generator = PlanetMapGenerator.new(celestial_body)
    self.tiles = generator.generate(width, height, generation_params)
    save!
  end
  
  # Get tile at specific coordinates
  def tile_at(x, y)
    tiles&.dig("#{x},#{y}") || default_tile
  end
  
  # Set tile at specific coordinates
  def set_tile_at(x, y, tile_data)
    self.tiles ||= {}
    self.tiles["#{x},#{y}"] = tile_data
  end
  
  # Export to JSON for frontend
  def to_map_json
    {
      planet_id: celestial_body.id,
      planet_name: celestial_body.name,
      width: width,
      height: height,
      tiles: tiles,
      metadata: {
        gravity: celestial_body.gravity,
        temperature: celestial_body.surface_temperature,
        pressure: celestial_body.atmosphere&.pressure,
        water_coverage: celestial_body.try(:water_coverage_percentage)
      }
    }
  end
  
  private
  
  def default_tile
    { terrain: 'empty', elevation: 0, biome: 'barren' }
  end
end

# app/services/planet_map_generator.rb
class PlanetMapGenerator
  attr_reader :planet
  
  def initialize(planet)
    @planet = planet
  end
  
  def generate(width, height, params = {})
    seed = params[:seed] || rand(100000)
    tiles = {}
    
    # Use planet's actual composition to generate terrain
    water_coverage = planet.try(:water_coverage_percentage) || 0
    geosphere = planet.geosphere
    
    # Generate base elevation using Perlin noise (to be implemented in frontend)
    # Store metadata for frontend generator
    (0...height).each do |y|
      (0...width).each do |x|
        tiles["#{x},#{y}"] = generate_tile(x, y, width, height, water_coverage, geosphere)
      end
    end
    
    tiles
  end
  
  private
  
  def generate_tile(x, y, width, height, water_coverage, geosphere)
    # Simplified generation - real implementation would use noise
    # This is placeholder data that frontend can use
    
    # Convert to latitude/longitude
    lat = 90 - (y.to_f / height * 180)
    lon = (x.to_f / width * 360) - 180
    
    # Determine if water based on coverage percentage
    is_water = rand(100) < water_coverage
    
    if is_water
      {
        terrain: 'ocean',
        elevation: rand(-4000..-1000),
        biome: determine_ocean_biome(lat),
        composition: 'H2O',
        coordinates: { lat: lat, lon: lon }
      }
    else
      {
        terrain: determine_land_terrain(geosphere),
        elevation: rand(0..3000),
        biome: determine_land_biome(lat, planet.surface_temperature),
        composition: dominant_material(geosphere),
        coordinates: { lat: lat, lon: lon }
      }
    end
  end
  
  def determine_ocean_biome(lat)
    case lat.abs
    when 0..30 then 'tropical_ocean'
    when 30..60 then 'temperate_ocean'
    else 'polar_ocean'
    end
  end
  
  def determine_land_terrain(geosphere)
    return 'rocky' unless geosphere
    
    # Use actual crust composition
    composition = geosphere.crust_composition
    return 'rocky' unless composition
    
    if composition['SiO2'].to_f > 60
      'granitic'
    elsif composition['FeO'].to_f > 15
      'basaltic'
    else
      'mixed'
    end
  end
  
  def determine_land_biome(lat, temperature)
    temp_k = temperature || 288 # Default to Earth-like
    temp_c = temp_k - 273.15
    
    case
    when temp_c < -30 then 'ice'
    when temp_c < 0 then 'tundra'
    when temp_c < 15
      lat.abs > 50 ? 'taiga' : 'temperate_forest'
    when temp_c < 25
      'grassland'
    else
      lat.abs < 30 ? 'tropical' : 'desert'
    end
  end
  
  def dominant_material(geosphere)
    return 'regolith' unless geosphere&.crust_composition
    
    geosphere.crust_composition.max_by { |_, v| v }&.first || 'regolith'
  end
end

# Migration
# rails generate migration CreatePlanetMaps
class CreatePlanetMaps < ActiveRecord::Migration[7.0]
  def change
    create_table :planet_maps do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.integer :width, null: false
      t.integer :height, null: false
      t.text :tile_data # Store as JSON
      t.text :generation_params # Store as JSON
      
      t.timestamps
    end
    
    add_index :planet_maps, :celestial_body_id, unique: true
  end
end