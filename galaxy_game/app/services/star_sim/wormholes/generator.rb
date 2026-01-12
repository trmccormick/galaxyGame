# app/services/star_sim/wormholes/generator.rb
module StarSim::Wormholes
  # This class is responsible for generating wormholes between solar systems.
  # It creates a wormhole with two endpoints, one in each solar system.
  # The wormhole can be either natural or artificial, with different properties.
  #
  # Example usage:
  #   wormhole = Generator.create_wormhole(
  #     type: :natural,
  #     solar_system_a: solar_system_a,
  #     solar_system_b: solar_system_b
  #   )
  #
  # This will create a natural wormhole between the two specified solar systems.
  class Generator  
    def self.create_wormhole(type: :natural, solar_system_a:, solar_system_b:)
      wormhole = Wormhole.create!(
        galaxy_a: solar_system_a.galaxy,
        galaxy_b: solar_system_b.galaxy,
        solar_system_a: solar_system_a,
        solar_system_b: solar_system_b,
        stability: random_stability,
        formation_date: Time.current,
        decay_rate: random_decay_rate,
        power_requirement: type == :artificial ? random_power_requirement : 0,
        hazard_zone: rand < 0.2,
        exotic_resources: rand < 0.1
      )
      
      create_endpoint(wormhole: wormhole, endpoint_type: :entrance, solar_system: solar_system_a)
      create_endpoint(wormhole: wormhole, endpoint_type: :exit, solar_system: solar_system_b)
      
      wormhole
    end

    private

    def self.create_endpoint(wormhole:, endpoint_type:, solar_system:)
      coordinates = calculate_safe_coordinates(solar_system)
      
      location = SpatialLocation.create!(
        name: "Wormhole #{endpoint_type.capitalize} #{wormhole.id}",
        x_coordinate: coordinates[:x],
        y_coordinate: coordinates[:y],
        z_coordinate: coordinates[:z],
        spatial_context: solar_system
      )

      wormhole.update!(
        endpoint_type == :entrance ? {entrance: location} : {exit: location}
      )
    end

    def self.calculate_safe_coordinates(solar_system)
      primary_star = solar_system.stars.first
      return random_deep_space_coordinates unless primary_star&.spatial_location

      loop do
        coords = random_deep_space_coordinates
        distance = calculate_distance(coords, primary_star.spatial_location)
        return coords if distance > GameConstants::SAFE_DISTANCE_FROM_STAR && 
                        distance < GameConstants::MAX_DISTANCE_FROM_STAR
      end
    end

    def self.calculate_distance(coords, star_location)
      Math.sqrt(
        (coords[:x] - star_location.x_coordinate)**2 +
        (coords[:y] - star_location.x_coordinate)**2 +
        (coords[:z] - star_location.z_coordinate)**2
      )
    end

    def self.random_deep_space_coordinates
      {
        x: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
        y: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
        z: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR)
      }
    end

    def self.random_stability
      [:stable, :fluctuating, :collapsing].sample
    end

    def self.random_decay_rate
      rand(0.01..0.5)
    end

    def self.random_power_requirement
      rand(50..500)
    end
  end
end