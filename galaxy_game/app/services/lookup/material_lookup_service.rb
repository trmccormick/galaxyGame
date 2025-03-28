require 'yaml'

module Lookup
  class MaterialLookupService < BaseLookupService
    MATERIAL_PATHS = {
      raw: {
        path: Rails.root.join("app", "data", "materials", "raw"),
        subfolders: ["gases", "geological_materials", "meteorites", "ores", "other"]
      },
      processed: Rails.root.join("app", "data", "materials", "processed"),
      solids: Rails.root.join("app", "data", "materials", "solids"),
      synthetic: Rails.root.join("app", "data", "materials", "synthetic_material")
    }

    def initialize
      super
      Rails.logger.debug "Material paths: #{MATERIAL_PATHS.inspect}"
      @materials = load_materials
    end

    def find_material(query)
      query = query.to_s.downcase
      found = @materials.find { |material| match_material?(material, query) }
      Rails.logger.debug "Material lookup for '#{query}': #{found ? 'found' : 'not found'}"
      found
    end

    private

    def load_materials
      materials = []
      
      MATERIAL_PATHS.each do |type, config|
        if config.is_a?(Hash)
          base_path = config[:path]
          Rails.logger.debug "Checking base path: #{base_path}"
          config[:subfolders].each do |subfolder|
            path = base_path.join(subfolder)
            Rails.logger.debug "Checking subfolder path: #{path}"
            materials.concat(load_json_files(path))
          end
        else
          Rails.logger.debug "Checking direct path: #{config}"
          materials.concat(load_json_files(config))
        end
      end

      materials
    rescue => e
      Rails.logger.error "Error loading materials: #{e.message}"
      []
    end

    def load_json_files(path)
      return [] unless File.directory?(path)

      Dir.glob(File.join(path, "*.json")).map do |file|
        begin
          data = JSON.parse(File.read(file))
          Rails.logger.debug "Loaded material from #{file}"
          data
        rescue JSON::ParserError => e
          Rails.logger.error "Error parsing #{file}: #{e.message}"
          nil
        rescue StandardError => e
          Rails.logger.error "Error loading #{file}: #{e.message}"
          nil
        end
      end.compact
    end

    def match_material?(material, query)
      return false unless material && query
      query = query.downcase.gsub('_', ' ')
    
      searchable_terms = [
        material['id']&.downcase,
        material['name']&.downcase,
        material['chemical_formula']&.downcase,
        material['chemical_formula']&.gsub(/[^a-zA-Z0-9]/, '')&.downcase, # Add simplified chemical formula
        *(material['aliases']&.map(&:downcase) || [])
      ].compact
    
      searchable_terms.any? { |term| term == query || term.gsub('_', ' ') == query }
    end
  end
end