# app/jobs/universe_registration_job.rb
class UniverseRegistrationJob
  include Sidekiq::Job
  queue_as :default

  class InvalidSystemBoundariesError < StandardError; end

  # Validate that all celestial bodies in a system seed fall within
  # the macro spatial envelope defined by GameConstants.
  #
  # Accepts two seed formats:
  #   Full (JSON-path): { "celestial_bodies" => { "terrestrial_planets" => [...], ... }, "wormholes" => [...] }
  #   Simplified:       { planets: [...], wormholes: [...] }
  def validate_system_envelope!(system_seed)
    validate_wormhole_count!(system_seed)
    validate_planet_boundaries!(system_seed)
  end

  private

  def validate_wormhole_count!(system_seed)
    count = extract_wormhole_count(system_seed)
    return unless count > 0

    if count > GameConstants::MAX_WORMHOLES_PER_SYSTEM
      raise InvalidSystemBoundariesError,
        "Wormhole count #{count} exceeds structural cap of #{GameConstants::MAX_WORMHOLES_PER_SYSTEM}"
    end
  end

  def validate_planet_boundaries!(system_seed)
    planets = extract_planets(system_seed)
    return unless planets

    planets.each do |planet|
      au = extract_semi_major_axis_au(planet)
      next if au.nil? || au.zero?

      distance_m = au * 1.496e11
      name = planet["name"] || planet[:name] || "Unknown"

      if distance_m < GameConstants::SAFE_DISTANCE_FROM_STAR
        raise InvalidSystemBoundariesError,
          "'#{name}' at #{au} AU is inside inner boundary (#{GameConstants::SAFE_DISTANCE_FROM_STAR} m)"
      end

      if distance_m > GameConstants::MAX_DISTANCE_FROM_STAR
        raise InvalidSystemBoundariesError,
          "'#{name}' at #{au} AU exceeds outer boundary (#{GameConstants::MAX_DISTANCE_FROM_STAR} m)"
      end
    end
  end

  def extract_wormhole_count(system_seed)
    # Full seed format: string keys
    if system_seed.is_a?(Hash) && system_seed.key?("wormholes")
      Array(system_seed["wormholes"]).count
    # Simplified format: symbol keys
    elsif system_seed.is_a?(Hash) && system_seed.key?(:wormholes)
      Array(system_seed[:wormholes]).count
    else
      0
    end
  end

  def extract_planets(system_seed)
    # Full seed format (JSON-path): string keys, nested under "celestial_bodies"
    if system_seed.is_a?(Hash) && system_seed.key?("celestial_bodies")
      Array(system_seed.dig("celestial_bodies", "terrestrial_planets"))
    # Simplified format: symbol keys, top-level :planets
    elsif system_seed.is_a?(Hash) && system_seed.key?(:planets)
      Array(system_seed[:planets])
    else
      nil
    end
  end

  def extract_semi_major_axis_au(planet)
    # Try string keys first (full seed format)
    if planet.is_a?(Hash) && planet.key?("orbits")
      orbit = Array(planet["orbits"]).first
      return orbit&.dig("semi_major_axis_au")&.to_f if orbit
    end

    # Try symbol keys (simplified format)
    if planet.is_a?(Hash) && planet.key?(:orbits)
      orbit = Array(planet[:orbits]).first
      return orbit&.dig(:semi_major_axis_au)&.to_f if orbit
    end

    nil
  end
end
