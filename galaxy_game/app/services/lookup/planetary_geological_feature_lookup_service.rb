# app/services/lookup/planetary_geological_feature_lookup_service.rb

require 'json'
require 'pathname'

module Lookup
  class PlanetaryGeologicalFeatureLookupService < BaseLookupService
    def initialize(celestial_body)
      @celestial_body = celestial_body
      @features = load_features
    end

    def all_features
      @features
    end

    def find_by_name(name)
      @features.find { |f| f['name']&.downcase == name.to_s.downcase }
    end

    def features_by_type(type)
      @features.select { |f| f['type']&.downcase == type.to_s.downcase }
    end

    def feature_summary
      @features.group_by { |f| f['type'] || 'unknown' }
    end

    private

    def body_feature_path
      system_name = @celestial_body&.solar_system&.name || 'sol'
      path_parts = [
        Rails.root,
        GalaxyGame::Paths::JSON_DATA,
        'star_systems',
        system_name.downcase,
        'celestial_bodies'
      ]

      # Use parent_celestial_body instead of parent_body
      if @celestial_body.respond_to?(:parent_celestial_body) && @celestial_body.parent_celestial_body.present?
        path_parts << @celestial_body.parent_celestial_body.name.downcase
      end

      path_parts << @celestial_body.name.downcase
      Pathname.new(File.join(*path_parts))
    end

    def load_features
      features = []
      feature_path = body_feature_path
      
      return [] unless feature_path.exist?

      Rails.logger.debug "Loading features from: #{feature_path}"
      
      Dir.glob(File.join(feature_path, "*.json")).each do |file_path|
        begin
          content = File.read(file_path)
          data = JSON.parse(content)
          
          if data.is_a?(Array)
            features.concat(data)
          else
            features << data
          end
        rescue JSON::ParserError => e
          Rails.logger.warn "Failed to parse JSON file #{file_path}: #{e.message}"
        end
      end

      Rails.logger.debug "Found #{features.count} features for #{@celestial_body.name}"
      features
    end
  end
end
