#!/usr/bin/env ruby
# frozen_string_literal: true

# Run from Rails root: ruby lib/tasks/migrate_geological_data.rb

require 'json'
require 'fileutils'
require 'pathname'

class GeologicalDataMigration
  BASE_PATH = Pathname.new(__dir__).join('../../app/data/star_systems/sol/celestial_bodies')
  
  def run
    puts "🌍 Starting Geological Features Data Migration..."
    puts "=" * 60
    
    create_directory_structure
    migrate_earth_data
    migrate_luna_data
    migrate_mars_data
    create_strategic_templates
    
    puts "=" * 60
    puts "✅ Migration complete!"
    puts "\nNext steps:"
    puts "1. Review the new files in geological_features/ directories"
    puts "2. Fill in strategic entries for key features"
    puts "3. Update PlanetaryGeologicalFeatureLookupService to use new paths"
    puts "4. Update models to reference new structure"
  end
  
  private
  
  def create_directory_structure
    puts "\n📁 Creating directory structure..."
    
    dirs = [
      'earth/geological_features',
      'earth/luna/geological_features',
      'mars/geological_features'
    ]
    
    dirs.each do |dir|
      path = BASE_PATH.join(dir)
      FileUtils.mkdir_p(path)
      puts "  ✓ Created #{dir}"
    end
  end
  
  def migrate_earth_data
    puts "\n🌍 Migrating Earth data..."
    
    old_path = BASE_PATH.join('earth/lava_tubes.json')
    new_path = BASE_PATH.join('earth/geological_features/lava_tubes.json')
    
    if File.exist?(old_path)
      # Read and wrap in proper structure
      data = JSON.parse(File.read(old_path))
      
      wrapped_data = {
        "celestial_body" => "earth",
        "feature_type" => "lava_tube",
        "tier" => "strategic",
        "last_updated" => Time.now.strftime("%Y-%m-%d"),
        "features" => wrap_lava_tubes(data, "earth")
      }
      
      File.write(new_path, JSON.pretty_generate(wrapped_data))
      puts "  ✓ Migrated earth/lava_tubes.json → earth/geological_features/lava_tubes.json"
      
      # Optionally move old file to backup
      FileUtils.mv(old_path, "#{old_path}.backup")
      puts "  ✓ Backed up original to earth/lava_tubes.json.backup"
    else
      puts "  ⚠ earth/lava_tubes.json not found, skipping"
    end
  end
  
  def migrate_luna_data
    puts "\n🌙 Migrating Luna data..."
    
    # Migrate Luna lava tubes (strategic)
    migrate_luna_lava_tubes
    
    # Migrate Luna craters (catalog)
    migrate_luna_craters_catalog
    
    # Create strategic craters file
    create_luna_strategic_craters
  end
  
  def migrate_luna_lava_tubes
    old_path = BASE_PATH.join('earth/luna/lava_tubes.json')
    new_path = BASE_PATH.join('earth/luna/geological_features/lava_tubes.json')
    
    if File.exist?(old_path)
      data = JSON.parse(File.read(old_path))
      
      wrapped_data = {
        "celestial_body" => "luna",
        "feature_type" => "lava_tube",
        "tier" => "strategic",
        "last_updated" => Time.now.strftime("%Y-%m-%d"),
        "features" => wrap_lava_tubes(data["lava_tubes"], "luna")
      }
      
      File.write(new_path, JSON.pretty_generate(wrapped_data))
      puts "  ✓ Migrated luna/lava_tubes.json → luna/geological_features/lava_tubes.json"
      
      FileUtils.mv(old_path, "#{old_path}.backup")
      puts "  ✓ Backed up original"
    else
      puts "  ⚠ luna/lava_tubes.json not found"
    end
  end
  
  def migrate_luna_craters_catalog
    old_path = BASE_PATH.join('earth/luna/lunar_craters.json')
    new_path = BASE_PATH.join('earth/luna/geological_features/craters_catalog.json')
    
    if File.exist?(old_path)
      raw_data = JSON.parse(File.read(old_path))
      
      catalog_data = {
        "celestial_body" => "luna",
        "feature_type" => "crater",
        "tier" => "catalog",
        "source" => "wikipedia_scrape",
        "last_updated" => Time.now.strftime("%Y-%m-%d"),
        "total_features" => raw_data.length,
        "features" => convert_lunar_craters_to_catalog(raw_data)
      }
      
      File.write(new_path, JSON.pretty_generate(catalog_data))
      puts "  ✓ Migrated #{raw_data.length} lunar craters to catalog"
      
      FileUtils.mv(old_path, "#{old_path}.backup")
      puts "  ✓ Backed up original"
    else
      puts "  ⚠ lunar_craters.json not found"
    end
  end
  
  def create_luna_strategic_craters
    new_path = BASE_PATH.join('earth/luna/geological_features/craters.json')
    
    strategic_craters = {
      "celestial_body" => "luna",
      "feature_type" => "crater",
      "tier" => "strategic",
      "last_updated" => Time.now.strftime("%Y-%m-%d"),
      "features" => [
        {
          "id" => "luna_cr_001",
          "name" => "Shackleton Crater",
          "feature_type" => "crater",
          "tier" => "strategic",
          "discovered" => true,
          "coordinates" => {
            "latitude" => -89.9,
            "longitude" => 0.0,
            "system" => "selenographic"
          },
          "dimensions" => {
            "diameter_m" => 21000,
            "depth_m" => 4200,
            "rim_height_m" => 200,
            "floor_area_m2" => 346360000
          },
          "crater_type" => "impact",
          "composition" => {
            "rim" => "anorthosite",
            "floor" => "mixed_regolith",
            "ice_present" => true,
            "ice_concentration" => "high"
          },
          "attributes" => {
            "permanently_shadowed" => true,
            "sunlight_on_rim" => "near_continuous",
            "solar_exposure_percent" => 89,
            "temperature_floor_k" => 40,
            "temperature_rim_k" => 220
          },
          "conversion_suitability" => {
            "crater_dome" => "excellent",
            "estimated_cost_multiplier" => 1.2,
            "advantages" => ["permanent ice deposits", "near-continuous solar on rim", "naturally defensible"],
            "challenges" => ["extremely large dome required", "polar location harsh", "cold floor temperature"]
          },
          "resources" => {
            "water_ice_tons" => 600000000,
            "accessible_ice_tons" => 150000000,
            "other_volatiles" => ["CO2", "NH3", "H2S"]
          },
          "priority" => "critical",
          "strategic_value" => ["water_ice", "solar_power", "outpost_location"]
        }
      ]
    }
    
    File.write(new_path, JSON.pretty_generate(strategic_craters))
    puts "  ✓ Created strategic craters file (template with Shackleton)"
  end
  
  def migrate_mars_data
    puts "\n🔴 Migrating Mars data..."
    
    # Migrate Mars craters (catalog)
    migrate_mars_craters_catalog
    
    # Create strategic files
    create_mars_strategic_craters
    create_mars_strategic_lava_tubes
    create_mars_strategic_valles
  end
  
  def migrate_mars_craters_catalog
    old_path = BASE_PATH.join('mars/martian_craters.json')
    new_path = BASE_PATH.join('mars/geological_features/craters_catalog.json')
    
    if File.exist?(old_path)
      raw_data = JSON.parse(File.read(old_path))
      
      catalog_data = {
        "celestial_body" => "mars",
        "feature_type" => "crater",
        "tier" => "catalog",
        "source" => "wikipedia_scrape",
        "last_updated" => Time.now.strftime("%Y-%m-%d"),
        "total_features" => raw_data.length,
        "features" => convert_martian_craters_to_catalog(raw_data)
      }
      
      File.write(new_path, JSON.pretty_generate(catalog_data))
      puts "  ✓ Migrated #{raw_data.length} martian craters to catalog"
      
      FileUtils.mv(old_path, "#{old_path}.backup")
      puts "  ✓ Backed up original"
    else
      puts "  ⚠ martian_craters.json not found"
    end
  end
  
  def create_mars_strategic_craters
    new_path = BASE_PATH.join('mars/geological_features/craters.json')
    
    strategic_craters = {
      "celestial_body" => "mars",
      "feature_type" => "crater",
      "tier" => "strategic",
      "last_updated" => Time.now.strftime("%Y-%m-%d"),
      "features" => [
        {
          "id" => "mars_cr_001",
          "name" => "Gale Crater",
          "feature_type" => "crater",
          "discovered" => true,
          "coordinates" => {
            "latitude" => -5.4,
            "longitude" => 137.8,
            "system" => "areographic"
          },
          "dimensions" => {
            "diameter_m" => 154000,
            "depth_m" => 4500,
            "rim_height_m" => 1200
          },
          "crater_type" => "impact",
          "composition" => {
            "layered_sediments" => true,
            "clays" => true,
            "sulfates" => true,
            "water_history" => "ancient_lake"
          },
          "attributes" => {
            "central_peak" => "Mount Sharp (5.5km high)",
            "explored_by" => "Curiosity Rover",
            "geological_significance" => "very_high"
          },
          "conversion_suitability" => {
            "crater_dome" => "poor",
            "surface_base" => "good",
            "estimated_cost_multiplier" => 1.5,
            "advantages" => ["extensively studied", "water history", "mineral resources"],
            "challenges" => ["very large", "central peak complicates doming"]
          },
          "resources" => {
            "minerals" => ["phyllosilicates", "sulfates", "hematite"],
            "water_history" => "confirmed_ancient_lake"
          },
          "priority" => "high",
          "strategic_value" => ["geological_study", "resource_potential", "known_composition"]
        },
        {
          "id" => "mars_cr_002",
          "name" => "Jezero Crater",
          "feature_type" => "crater",
          "discovered" => true,
          "coordinates" => {
            "latitude" => 18.38,
            "longitude" => 77.58,
            "system" => "areographic"
          },
          "dimensions" => {
            "diameter_m" => 45000,
            "depth_m" => 500,
            "rim_height_m" => 300
          },
          "crater_type" => "impact",
          "composition" => {
            "ancient_river_delta" => true,
            "carbonates" => true,
            "water_history" => "ancient_lake_with_delta"
          },
          "attributes" => {
            "explored_by" => "Perseverance Rover",
            "sample_collection" => "active",
            "geological_significance" => "very_high"
          },
          "conversion_suitability" => {
            "crater_dome" => "good",
            "surface_base" => "excellent",
            "estimated_cost_multiplier" => 1.3,
            "advantages" => ["flat floor", "extensively studied", "ancient water evidence"],
            "challenges" => ["large size", "ongoing exploration priority"]
          },
          "resources" => {
            "minerals" => ["carbonates", "olivine", "clays"],
            "water_history" => "confirmed_ancient_lake_and_delta"
          },
          "priority" => "high",
          "strategic_value" => ["geological_study", "resource_potential", "astrobiology"]
        }
      ]
    }
    
    File.write(new_path, JSON.pretty_generate(strategic_craters))
    puts "  ✓ Created strategic craters file (Gale, Jezero)"
  end
  
  def create_mars_strategic_lava_tubes
    new_path = BASE_PATH.join('mars/geological_features/lava_tubes.json')
    
    strategic_tubes = {
      "celestial_body" => "mars",
      "feature_type" => "lava_tube",
      "tier" => "strategic",
      "last_updated" => Time.now.strftime("%Y-%m-%d"),
      "features" => [
        {
          "id" => "mars_lt_001",
          "name" => "Arsia Mons Tube Network",
          "feature_type" => "lava_tube",
          "discovered" => false,
          "coordinates" => {
            "latitude" => -8.4,
            "longitude" => -120.0,
            "system" => "areographic"
          },
          "dimensions" => {
            "length_m" => 15000,
            "width_m" => 250,
            "height_m" => 200,
            "estimated_volume_m3" => 750000000
          },
          "formation" => "shield_volcano",
          "composition" => {
            "primary" => "basaltic_lava",
            "stability" => "excellent",
            "ceiling_thickness_m" => 50
          },
          "natural_openings" => [
            {
              "opening_type" => "skylight",
              "diameter_m" => 180,
              "depth_m" => 190
            }
          ],
          "attributes" => {
            "natural_shielding" => "excellent",
            "thermal_stability" => "extremely_high",
            "potential_ice" => "possible_in_deep_sections"
          },
          "conversion_suitability" => {
            "habitat" => "outstanding",
            "estimated_cost_multiplier" => 0.4,
            "advantages" => ["massive volume", "excellent natural shielding", "stable temperature"],
            "challenges" => ["large opening to seal", "remote location"]
          },
          "priority" => "critical",
          "strategic_value" => ["mega_habitat", "radiation_protection", "resource_access"]
        }
      ]
    }
    
    File.write(new_path, JSON.pretty_generate(strategic_tubes))
    puts "  ✓ Created strategic lava tubes file (Arsia Mons)"
  end
  
  def create_mars_strategic_valles
    new_path = BASE_PATH.join('mars/geological_features/valles.json')
    
    strategic_valles = {
      "celestial_body" => "mars",
      "feature_type" => "valley",
      "tier" => "strategic",
      "last_updated" => Time.now.strftime("%Y-%m-%d"),
      "features" => [
        {
          "id" => "mars_vl_001",
          "name" => "Valles Marineris",
          "feature_type" => "rift_valley",
          "discovered" => true,
          "coordinates" => {
            "latitude" => -14.0,
            "longitude" => -59.2,
            "system" => "areographic"
          },
          "dimensions" => {
            "length_m" => 4000000,
            "width_m" => 200000,
            "depth_m" => 7000,
            "volume_m3" => 5600000000000
          },
          "formation" => "tectonic_rifting",
          "composition" => {
            "walls" => "layered_sedimentary",
            "floor" => "landslide_deposits",
            "minerals" => ["gypsum", "sulfates", "clays"]
          },
          "attributes" => {
            "natural_shielding" => "excellent",
            "thermal_mass" => "very_high",
            "water_history" => "ancient_water_evidence"
          },
          "conversion_suitability" => {
            "pressurized_valley_section" => "excellent",
            "estimated_cost_multiplier" => 0.3,
            "advantages" => ["natural walls", "massive volume", "mineral resources"],
            "challenges" => ["sealing massive openings", "landslide risk"]
          },
          "segments" => [
            {
              "name" => "Coprates Chasma",
              "length_m" => 966000,
              "width_m" => 60000,
              "depth_m" => 8000,
              "suitability" => "excellent"
            }
          ],
          "priority" => "critical",
          "strategic_value" => ["mega_habitat_potential", "mineral_resources", "geological_study"]
        }
      ]
    }
    
    File.write(new_path, JSON.pretty_generate(strategic_valles))
    puts "  ✓ Created strategic valles file (Valles Marineris)"
  end
  
  def create_strategic_templates
    puts "\n📝 Creating template files..."
    
    # Earth canyons
    earth_canyons = BASE_PATH.join('earth/geological_features/canyons.json')
    unless File.exist?(earth_canyons)
      template = {
        "celestial_body" => "earth",
        "feature_type" => "canyon",
        "tier" => "strategic",
        "last_updated" => Time.now.strftime("%Y-%m-%d"),
        "features" => []
      }
      File.write(earth_canyons, JSON.pretty_generate(template))
      puts "  ✓ Created earth/geological_features/canyons.json template"
    end
  end
  
  # Conversion helpers
  
  def wrap_lava_tubes(data, celestial_body)
    return [] unless data.is_a?(Array)
    
    data.each_with_index.map do |tube, idx|
      {
        "id" => "#{celestial_body}_lt_#{format('%03d', idx + 1)}",
        "name" => tube["name"],
        "feature_type" => "lava_tube",
        "tier" => "strategic",
        "discovered" => false,
        "coordinates" => parse_coordinates(tube["coordinates"]),
        "dimensions" => {
          "length_m" => (tube["length_km"].to_f * 1000).to_i,
          "width_m" => tube["width_m"],
          "height_m" => tube["height_m"],
          "estimated_volume_m3" => calculate_tube_volume(tube)
        },
        "attributes" => {
          "features" => tube["features"] || [],
          "natural_shielding" => determine_shielding(tube),
          "thermal_stability" => "moderate"
        },
        "conversion_suitability" => {
          "habitat" => assess_suitability(tube),
          "estimated_cost_multiplier" => 0.7,
          "advantages" => tube["features"] || [],
          "challenges" => []
        },
        "priority" => tube["priority"] || "medium",
        "strategic_value" => tube["goals"] || []
      }
    end
  end
  
  def convert_lunar_craters_to_catalog(raw_data)
    raw_data.each_with_index.map do |crater, idx|
      {
        "id" => "luna_cr_cat_#{format('%04d', idx + 1)}",
        "name" => crater["name"],
        "feature_type" => "crater",
        "discovered" => true,
        "tier" => "catalog",
        "coordinates" => parse_coordinates(crater["coordinates"]),
        "dimensions" => {
          "diameter_m" => (crater["diameter"].to_f * 1000).to_i,
          "depth_m" => parse_depth(crater["depth"]),
          "depth_quality" => determine_depth_quality(crater["depth"])
        },
        "surveyed" => false,
        "conversion_suitability" => {
          "needs_survey" => true,
          "size_category" => categorize_size(crater["diameter"].to_f),
          "initial_assessment" => "potential"
        },
        "priority" => "unassessed",
        "strategic_value" => ["needs_survey"]
      }
    end
  end
  
  def convert_martian_craters_to_catalog(raw_data)
    raw_data.each_with_index.map do |crater, idx|
      {
        "id" => "mars_cr_cat_#{format('%04d', idx + 1)}",
        "name" => crater["name"],
        "feature_type" => "crater",
        "discovered" => true,
        "tier" => "catalog",
        "coordinates" => parse_coordinates(crater["coordinates"]),
        "dimensions" => {
          "diameter_m" => (crater["diameter"].to_f * 1000).to_i,
          "depth_m" => parse_depth(crater["depth"]),
          "depth_quality" => determine_depth_quality(crater["depth"])
        },
        "surveyed" => false,
        "conversion_suitability" => {
          "needs_survey" => true,
          "size_category" => categorize_size(crater["diameter"].to_f),
          "initial_assessment" => "unknown"
        },
        "priority" => "unassessed",
        "strategic_value" => ["needs_survey"]
      }
    end
  end
  
  # Parsing helpers
  
  def parse_coordinates(coord_string)
    # Parse "14.7°N 338.43°E" format
    return {} unless coord_string
    
    lat_match = coord_string.match(/([-\d.]+)°([NS])/)
    lon_match = coord_string.match(/([-\d.]+)°([EW])/)
    
    return {} unless lat_match && lon_match
    
    lat = lat_match[1].to_f
    lat = -lat if lat_match[2] == 'S'
    
    lon = lon_match[1].to_f
    lon = -lon if lon_match[2] == 'W'
    
    {
      "latitude" => lat,
      "longitude" => lon,
      "system" => "geographic"
    }
  end
  
  def parse_depth(depth_string)
    return nil if depth_string.nil? || depth_string.downcase.include?("unknown")
    
    # Parse "12.8 km (estimated)" or "1.19 km"
    match = depth_string.match(/([\d.]+)\s*km/)
    match ? (match[1].to_f * 1000).to_i : nil
  end
  
  def determine_depth_quality(depth_string)
    return "unknown" if depth_string.nil? || depth_string.downcase.include?("unknown")
    depth_string.downcase.include?("estimated") ? "estimated" : "measured"
  end
  
  def categorize_size(diameter_km)
    case diameter_km
    when 0..10 then "small"
    when 10..50 then "medium"
    when 50..100 then "large"
    else "very_large"
    end
  end
  
  def calculate_tube_volume(tube)
    length = tube["length_km"].to_f * 1000
    width = tube["width_m"].to_f
    height = tube["height_m"].to_f
    # Approximate as cylinder
    (Math::PI * (width / 2) ** 2 * length).to_i
  end
  
  def determine_shielding(tube)
    features = tube["features"] || []
    features.any? { |f| f.downcase.include?("shield") } ? "excellent" : "good"
  end
  
  def assess_suitability(tube)
    priority = tube["priority"]
    case priority
    when "high", "critical" then "excellent"
    when "medium" then "good"
    else "fair"
    end
  end
end

# Run the migration
if __FILE__ == $0
  GeologicalDataMigration.new.run
end