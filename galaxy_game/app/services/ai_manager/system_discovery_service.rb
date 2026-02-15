require_relative 'shared_context'

module AIManager
  class SystemDiscoveryService
    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Main entry point - discover and analyze all available systems
    def discover_available_systems
      systems = query_discoverable_systems

      systems.map do |system|
        analyze_system(system)
      end
    end

    # Discover systems within wormhole range of current settlements
    def discover_systems_in_range(settlement)
      current_system = settlement.solar_system
      wormhole_connections = find_wormhole_connections(current_system)

      candidate_systems = wormhole_connections.map do |connection|
        # Determine which system is the destination (not the current system)
        destination_system = if connection.solar_system_a == current_system
                               connection.solar_system_b
                             else
                               connection.solar_system_a
                             end
        next unless destination_system

        {
          system: destination_system,
          wormhole_distance: 1, # Direct connection
          connection_stability: connection.stability,
          connection_type: connection.wormhole_type
        }
      end.compact

      # Analyze each candidate system
      candidate_systems.map do |candidate|
        analysis = analyze_system(candidate[:system])
        analysis.merge(
          wormhole_distance: candidate[:wormhole_distance],
          connection_stability: candidate[:connection_stability],
          connection_type: candidate[:connection_type]
        )
      end
    end

    private

    # Sub-Task 1.1: Database Query Layer
    def query_discoverable_systems
      SolarSystem.includes(
        :terrestrial_planets,
        :gas_giants,
        :ice_giants,
        :moons,
        :dwarf_planets,
        :stars
      ).all # For now, include all systems. Filter by discovery status later
    end

    # Find wormhole connections from a system
    def find_wormhole_connections(system)
      Wormhole.where(solar_system_a: system).or(Wormhole.where(solar_system_b: system))
    end

    # Sub-Task 1.2-1.5: Complete system analysis
    def analyze_system(system)
      {
        system_id: system.id,
        identifier: system.identifier,
        name: system.name,
        tei_score: calculate_tei(system),
        resource_profile: assess_resources(system),
        wormhole_data: detect_wormholes(system),
        strategic_value: calculate_strategic_value(system),
        celestial_body_count: count_all_celestial_bodies(system),
        star_data: analyze_stars(system)
      }
    end

    # Sub-Task 1.2: TEI Calculation
    def calculate_tei(system)
      primary_planet = find_best_planet(system)
      return 0 unless primary_planet

      # TEI (Terraforming Earth Index) calculation based on 4 factors:
      # 40% Magnetic moment (radiation protection)
      # 30% Atmospheric pressure (breathing/surface conditions)
      # 20% Volatile presence (water/organic compounds)
      # 10% Solar flux (energy availability)

      magnetic_score = calculate_magnetic_score(primary_planet) * 0.4
      pressure_score = calculate_pressure_score(primary_planet) * 0.3
      volatile_score = calculate_volatile_score(primary_planet) * 0.2
      solar_score = calculate_solar_score(system) * 0.1

      total_score = magnetic_score + pressure_score + volatile_score + solar_score

      # Return as percentage (0-100)
      [total_score * 100, 100].min.round(1)
    end

    private

    def calculate_magnetic_score(planet)
      magnetic_moment = planet.magnetic_moment.to_f

      # Earth's magnetic moment is ~8e15 T*m³
      # Score based on how close to Earth-like protection
      earth_magnetic = 8e15
      ratio = magnetic_moment / earth_magnetic

      if ratio >= 0.8
        1.0 # Excellent protection
      elsif ratio >= 0.5
        0.7 # Good protection
      elsif ratio >= 0.2
        0.4 # Moderate protection
      elsif ratio > 0
        0.1 # Weak protection
      else
        0.0 # No protection
      end
    end

    def calculate_pressure_score(planet)
      return 0 unless planet.atmosphere

      pressure = planet.atmosphere.pressure.to_f

      # Earth-like pressure range: 0.5-2.0 bar
      if pressure >= 0.5 && pressure <= 2.0
        1.0 # Ideal pressure
      elsif pressure >= 0.2 && pressure <= 5.0
        0.7 # Manageable with technology
      elsif pressure > 0
        0.3 # Extreme conditions
      else
        0.0 # No atmosphere
      end
    end

    def calculate_volatile_score(planet)
      score = 0

      # Check hydrosphere
      if planet.hydrosphere
        liquid_water = planet.hydrosphere.state_distribution&.dig('liquid').to_f || 0
        ice_water = planet.hydrosphere.state_distribution&.dig('solid').to_f || 0
        vapor_water = planet.hydrosphere.state_distribution&.dig('gas').to_f || 0

        total_water = liquid_water + ice_water + vapor_water
        if total_water > 0.1 # 10% of surface
          score += 0.6
        elsif total_water > 0.01 # 1% of surface
          score += 0.3
        end
      end

      # Check atmosphere for organic volatiles
      if planet.atmosphere
        organic_gases = ['CH4', 'CO2', 'NH3', 'H2O']
        organic_mass = planet.atmosphere.gases.where(name: organic_gases).sum(:mass).to_f

        if organic_mass > 1e18 # Significant organic presence
          score += 0.4
        elsif organic_mass > 1e15 # Moderate organic presence
          score += 0.2
        end
      end

      [score, 1.0].min
    end

    def calculate_solar_score(system)
      primary_star = system.stars.order(mass: :desc).first
      return 0.5 unless primary_star # Default moderate score

      # Check if star is in habitable zone range
      # Main sequence stars: O,B,A,F,G,K,M
      spectral_type = (primary_star.spectral_class || primary_star.type_of_star)&.upcase

      case spectral_type
      when 'G' # Sun-like
        1.0
      when 'F', 'K' # Hot/cool suns
        0.8
      when 'A', 'M' # Very hot/cool
        0.6
      when 'B', 'O' # Extreme
        0.3
      else
        0.5 # Unknown/default
      end
    end

    # Sub-Task 1.3: Resource Assessment
    def assess_resources(system)
      all_bodies = get_all_celestial_bodies(system)
      geological_features = all_bodies.flat_map(&:geological_features)

      {
        metal_richness: calculate_metal_score(geological_features),
        volatile_availability: calculate_volatile_score(geological_features),
        rare_earth_potential: calculate_rare_earth_score(geological_features),
        energy_potential: calculate_energy_potential(system),
        construction_materials: assess_construction_materials(geological_features)
      }
    end

    # Sub-Task 1.4: Wormhole Detection
    def detect_wormholes(system)
      wormholes = find_wormhole_connections(system)

      return nil if wormholes.empty?

      wormhole_data = wormholes.map do |wormhole|
        # Determine which system is the destination (not the current system)
        destination_system = if wormhole.solar_system_a == system
                               wormhole.solar_system_b
                             else
                               wormhole.solar_system_a
                             end
        
        {
          wormhole_id: wormhole.id,
          type: wormhole.wormhole_type,
          stability: wormhole.stability,
          terminus_location: find_terminus_location(wormhole, system),
          destination_system: destination_system&.identifier,
          local_bubble_connection: is_local_bubble?(wormhole)
        }
      end

      {
        has_wormholes: true,
        wormhole_count: wormholes.count,
        connections: wormhole_data,
        network_centrality: calculate_network_centrality(wormholes)
      }
    end

    # Helper methods for resource assessment
    def calculate_metal_score(features)
      metal_features = features.select { |f| f.name =~ /metal|iron|nickel|copper|gold|platinum/i }
      score = metal_features.sum { |f| f.concentration.to_f * f.accessibility.to_f }
      [score / 10.0, 1.0].min # Normalize to 0-1
    end

    def calculate_volatile_score(features)
      volatile_features = features.select { |f| f.name =~ /water|ice|methane|ammonia|carbon_dioxide/i }
      score = volatile_features.sum { |f| f.concentration.to_f * f.accessibility.to_f }
      [score / 10.0, 1.0].min
    end

    def calculate_rare_earth_score(features)
      rare_earth_features = features.select { |f| f.name =~ /rare.earth|lanthanum|neodymium|dysprosium/i }
      score = rare_earth_features.sum { |f| f.concentration.to_f * f.accessibility.to_f }
      [score / 5.0, 1.0].min # Rare earths are valuable even in small amounts
    end

    def calculate_energy_potential(system)
      # Assess potential for solar, geothermal, fusion energy
      stars = system.stars
      planets = system.celestial_bodies.where(type: 'terrestrial')

      solar_potential = stars.sum { |star| star.luminosity.to_f }
      geothermal_potential = planets.sum { |planet| planet.geological_activity.to_f }

      {
        solar: [solar_potential / 10.0, 1.0].min,
        geothermal: [geothermal_potential / 5.0, 1.0].min,
        fusion_fuel: assess_fusion_fuel_potential(system)
      }
    end

    def assess_fusion_fuel_potential(system)
      # Look for deuterium, tritium, helium-3 sources
      ice_bodies = system.celestial_bodies.where(type: 'ice_moon')
      gas_giants = system.celestial_bodies.where(type: 'gas_giant')

      ice_potential = ice_bodies.sum { |body| body.hydrosphere&.total_water_mass.to_f / 1e18 }
      gas_potential = gas_giants.sum { |body| body.atmosphere&.gases&.find_by(name: 'He3')&.mass.to_f / 1e6 }

      [ice_potential + gas_potential, 1.0].min
    end

    def assess_construction_materials(features)
      construction_features = features.select { |f| f.name =~ /silica|aluminum|calcium|regolith/i }
      score = construction_features.sum { |f| f.concentration.to_f * f.accessibility.to_f }
      [score / 15.0, 1.0].min
    end

    # Strategic value calculation
    def calculate_strategic_value(system)
      base_score = 0

      # TEI bonus
      tei = calculate_tei(system)
      base_score += tei * 0.4

      # Resource richness bonus
      resources = assess_resources(system)
      resource_score = (resources[:metal_richness] + resources[:volatile_availability] + resources[:rare_earth_potential]) / 3.0
      base_score += resource_score * 0.3

      # Wormhole connectivity bonus
      wormhole_data = detect_wormholes(system)
      connectivity_bonus = wormhole_data ? (wormhole_data[:network_centrality] || 0) * 0.2 : 0
      base_score += connectivity_bonus

      # Energy potential bonus
      energy = calculate_energy_potential(system)
      energy_score = (energy[:solar] + energy[:geothermal] + energy[:fusion_fuel]) / 3.0
      base_score += energy_score * 0.1

      [base_score, 1.0].min
    end

    # Helper methods
    def find_best_planet(system)
      system.terrestrial_planets
        .order(mass: :desc)
        .first
    end

    def get_all_celestial_bodies(system)
      system.terrestrial_planets + system.gas_giants + system.ice_giants + system.moons + system.dwarf_planets
    end

    def count_all_celestial_bodies(system)
      system.terrestrial_planets.count + system.gas_giants.count + system.ice_giants.count + system.moons.count + system.dwarf_planets.count
    end

    def find_terminus_location(wormhole, system)
      # Find the endpoint in the given system
      endpoint = wormhole.endpoints.find do |ep|
        ep.solar_system == system
      end
      
      endpoint&.coordinates || "Unknown"
    end

    def is_local_bubble?(wormhole)
      local_bubble_systems = [
        'sol', 'alpha_centauri', 'barnards_star',
        'wolf_359', 'sirius', 'procyon', ' Altair'
      ]

      system_a_id = wormhole.solar_system_a&.identifier
      system_b_id = wormhole.solar_system_b&.identifier

      [system_a_id, system_b_id].compact.any? do |sys_id|
        local_bubble_systems.include?(sys_id.downcase)
      end
    end

    def calculate_network_centrality(wormholes)
      # Simple centrality measure based on connection count
      connections = wormholes.count
      [connections / 5.0, 1.0].min # Normalize
    end

    def analyze_stars(system)
      stars = system.stars
      return nil if stars.empty?

      primary_star = stars.order(mass: :desc).first

      {
        count: stars.count,
        primary_star: {
          spectral_type: primary_star.spectral_class || primary_star.type_of_star,
          mass: primary_star.mass,
          luminosity: primary_star.luminosity,
          temperature: primary_star.temperature
        }
      }
    end
  end
end