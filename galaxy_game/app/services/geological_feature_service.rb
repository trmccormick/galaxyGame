# Service for loading and managing geological features from JSON files
class GeologicalFeatureService
  attr_reader :celestial_body
  
  def initialize(celestial_body)
    @celestial_body = celestial_body
  end
  
  # Load all geological features for the celestial body
  def load_features
    {
      celestial_body: {
        id: celestial_body.id,
        name: celestial_body.name,
        identifier: celestial_body.identifier
      },
      lava_tubes: load_lava_tubes,
      craters: load_craters,
      strategic_sites: combine_strategic_sites
    }
  end
  
  private
  
  def load_lava_tubes
    return [] unless celestial_body.name.downcase == 'luna'
    
    file_path = geological_data_path('lava_tubes.json')
    return [] unless File.exist?(file_path)
    
    data = JSON.parse(File.read(file_path))
    format_features(data['features'] || [], 'lava_tube')
  end
  
  def load_craters
    return [] unless celestial_body.name.downcase == 'luna'
    
    file_path = geological_data_path('craters.json')
    return [] unless File.exist?(file_path)
    
    data = JSON.parse(File.read(file_path))
    format_features(data['features'] || [], 'crater')
  end
  
  def combine_strategic_sites
    (load_lava_tubes + load_craters).select { |f| f[:priority] == 'high' || f[:priority] == 'critical' }
  end
  
  def format_features(features, type)
    features.map do |feature|
      {
        id: feature['id'],
        name: feature['name'],
        type: type,
        lat: feature.dig('coordinates', 'latitude'),
        lon: feature.dig('coordinates', 'longitude'),
        priority: feature['priority'],
        strategic_value: feature['strategic_value'],
        dimensions: feature['dimensions'],
        resources: feature['resources'],
        attributes: feature['attributes'],
        discovered: feature['discovered']
      }
    end
  end
  
  def geological_data_path(filename)
    # Path relative to Rails root: data/json-data/star_systems/sol/celestial_bodies/earth/luna/geological_features/
    body_name = celestial_body.name.downcase
    
    # For Luna
    if body_name == 'luna'
      Rails.root.join('app', 'data', 'json-data', 'star_systems', 'sol', 'celestial_bodies', 'earth', 'luna', 'geological_features', filename)
    else
      # Future: Add paths for Mars, Venus, etc.
      Rails.root.join('app', 'data', 'json-data', 'geological_features', body_name, filename)
    end
  end
end
