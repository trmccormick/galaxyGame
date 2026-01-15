# app/services/lookup/planetary_geological_feature_lookup_service.rb

require 'json'
require 'pathname'

module Lookup
  class PlanetaryGeologicalFeatureLookupService < BaseLookupService
    def initialize(celestial_body, tier: :all)
      @celestial_body = celestial_body
      @tier = tier # :all, :strategic, :catalog
      @features = load_features
    end

    def all_features
      @features
    end

    def find_by_name(name)
      @features.find { |f| f['name']&.downcase == name.to_s.downcase }
    end

    def find_by_id(id)
      @features.find { |f| f['id'] == id.to_s || f['feature_id'] == id.to_s }
    end

    def features_by_type(type)
      @features.select { |f| f['feature_type']&.downcase == type.to_s.downcase }
    end

    def feature_summary
      @features.group_by { |f| f['feature_type'] || 'unknown' }
    end

    # Get catalog features (for discovery gameplay)
    def catalog_features(type = nil)
      catalog = @features.select { |f| f['tier'] == 'catalog' }
      type ? catalog.select { |f| f['feature_type'] == type.to_s } : catalog
    end

    # Get strategic features (curated, gameplay-ready)
    def strategic_features(type = nil)
      strategic = @features.select { |f| f['tier'] == 'strategic' }
      type ? strategic.select { |f| f['feature_type'] == type.to_s } : strategic
    end

    private

    def body_feature_path
      system_name = @celestial_body&.solar_system&.name || 'sol'
      path_parts = [
        'star_systems',
        system_name.downcase,
        'celestial_bodies'
      ]

      # Handle moons (parent_celestial_body relationship)
      if @celestial_body.respond_to?(:parent_celestial_body) && @celestial_body.parent_celestial_body.present?
        path_parts << @celestial_body.parent_celestial_body.name.downcase
      end

      path_parts << @celestial_body.name.downcase
      path_parts << 'geological_features'  # New subdirectory
      
      # Convert to Pathname if it's a String (e.g., in tests)
      base_path = GalaxyGame::Paths::JSON_DATA
      base_path = Pathname.new(base_path) if base_path.is_a?(String)
      base_path.join(*path_parts)
    end

    def load_features
      features = []
      feature_path = body_feature_path
      
      return [] unless feature_path.exist?

      Rails.logger.debug "Loading geological features from: #{feature_path}"
      
      # Load all JSON files in the geological_features directory
      Dir.glob(File.join(feature_path, "*.json")).each do |file_path|
        begin
          content = File.read(file_path)
          data = JSON.parse(content)
          
          # Handle new wrapped structure: { "features": [...] }
          if data.is_a?(Hash)
            if data['features'].is_a?(Array)
              # New structure: extract features array
              features.concat(data['features'])
            else
              # Single feature wrapped in hash
              features << data
            end
          elsif data.is_a?(Array)
            # Legacy array structure (for test compatibility)
            features.concat(data)
          else
            # Single unwrapped feature
            features << data
          end
        rescue JSON::ParserError => e
          Rails.logger.warn "Failed to parse JSON file #{file_path}: #{e.message}"
        end
      end

      # Filter by tier if specified
      features = filter_by_tier(features) unless @tier == :all

      Rails.logger.debug "Found #{features.count} features for #{@celestial_body.name}"
      features
    end

    def filter_by_tier(features)
      return features if @tier == :all
      
      features.select { |f| f['tier'] == @tier.to_s }
    end
  end
end