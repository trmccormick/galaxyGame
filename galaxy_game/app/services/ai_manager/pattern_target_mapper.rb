module AIManager
  # Maps mission pattern names to target celestial bodies for location-based pricing
  class PatternTargetMapper
    PATTERN_TARGETS = {
      'mars-terraforming' => 'mars',
      'venus-industrial' => 'venus',
      'titan-fuel' => 'titan',
      'asteroid-mining' => 'ceres', # Use Ceres as representative asteroid
      'europa-water' => 'europa'
    }.freeze
    
    class << self
      # Get the target location for a mission pattern
      # @param pattern_name [String] The mission pattern identifier
      # @return [CelestialBodies::CelestialBody, nil] The target celestial body
      def target_location(pattern_name)
        identifier = PATTERN_TARGETS[pattern_name]
        Rails.logger.info "[PatternTargetMapper] Pattern: #{pattern_name} → identifier: #{identifier}"
        return nil unless identifier
        
        body = CelestialBodies::CelestialBody.find_by(identifier: identifier)
        Rails.logger.info "[PatternTargetMapper] Found celestial body: #{body&.name || 'NONE'}"
        body
      end
      
      # Get the target location identifier (for cases where DB isn't available)
      # @param pattern_name [String] The mission pattern identifier
      # @return [String, nil] The target identifier
      def target_identifier(pattern_name)
        PATTERN_TARGETS[pattern_name]
      end
      
      # Check if a pattern has a defined target location
      # @param pattern_name [String] The mission pattern identifier
      # @return [Boolean]
      def has_target?(pattern_name)
        PATTERN_TARGETS.key?(pattern_name)
      end
      
      # Get all supported patterns
      # @return [Array<String>] List of pattern names
      def supported_patterns
        PATTERN_TARGETS.keys
      end
    end
  end
end
