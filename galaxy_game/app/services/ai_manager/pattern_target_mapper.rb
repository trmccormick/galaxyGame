module AIManager
  class PatternTargetMapper
    # Maps mission pattern names to celestial body identifiers or names
    PATTERN_TARGETS = {
      'mars-terraforming' => 'Mars',
      'venus-industrial' => 'Venus',
      'titan-fuel' => 'Titan',
      'asteroid-mining' => 'Ceres',
      'europa-water' => 'Europa'
    }.freeze
    
    def self.target_identifier(pattern_name)
      PATTERN_TARGETS[pattern_name]
    end
    
    def self.target_location(pattern_name)
      target_name = PATTERN_TARGETS[pattern_name]
      Rails.logger.info "[PatternTargetMapper] Pattern: #{pattern_name} → target_name: #{target_name}"
      return nil unless target_name
      
      # Try to find by name first (case-insensitive)
      body = CelestialBodies::CelestialBody.where('LOWER(name) = ?', target_name.downcase).first
      
      # Fallback to identifier search if name search fails
      body ||= CelestialBodies::CelestialBody.find_by(identifier: target_name)
      
      Rails.logger.info "[PatternTargetMapper] Found celestial body: #{body&.name || 'NONE'}"
      body
    end
  end
end
