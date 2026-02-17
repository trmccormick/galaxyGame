module AIManager
  class SuperMarsSettlementService
    # MoonlessPlanetPattern: Redirect asteroids as moons
    def moonless_planet_pattern(planet)
      asteroids = find_nearby_asteroids(planet)
      tug_craft = available_tug_craft(planet)
      redirected = []
      asteroids.each do |asteroid|
        if phobos_deimos_sized?(asteroid) && tug_craft.any?
          redirected << redirect_asteroid(asteroid, planet, tug_craft.pop)
        end
      end
      redirected
    end

    # LargeMoonPattern: Settle Luna-sized moon first
    def large_moon_pattern(planet)
      moon = find_luna_sized_moon(planet)
      return nil unless moon
      settle_moon(moon)
      build_l1_depot(planet, moon)
    end

    # Surface Accessibility Gate
    def build_depot(planet)
      if surface_accessible?(planet)
        harvest_resources(planet)
        build_l1_depot(planet)
      else
        import_station_components(planet)
      end
    end

    # I-Beam Configuration
    def configure_panels(depot, config)
      depot[:panels] = config
    end

    # Pattern selection logic
    def choose_pattern(planet)
      if moonless?(planet)
        moonless_planet_pattern(planet)
      elsif luna_sized_moon?(planet)
        large_moon_pattern(planet)
      else
        build_depot(planet)
      end
    end

    # --- Helper methods ---
    def moonless?(planet)
      planet[:moons].nil? || planet[:moons].empty?
    end

    def luna_sized_moon?(planet)
      planet[:moons]&.any? { |m| m[:size] == :luna }
    end

    def find_nearby_asteroids(planet)
      planet[:nearby_asteroids] || []
    end

    def phobos_deimos_sized?(asteroid)
      [:phobos, :deimos].include?(asteroid[:size])
    end

    def available_tug_craft(planet)
      planet[:tug_craft] || []
    end

    def redirect_asteroid(asteroid, planet, tug)
      { asteroid: asteroid, redirected_by: tug, target: planet[:name] }
    end

    def find_luna_sized_moon(planet)
      planet[:moons]&.find { |m| m[:size] == :luna }
    end

    def settle_moon(moon)
      moon[:settled] = true
      moon
    end

    def build_l1_depot(planet, moon=nil)
      { planet: planet[:name], moon: moon&.dig(:name), depot: :l1 }
    end

    def surface_accessible?(planet)
      planet[:surface_accessible]
    end

    def harvest_resources(planet)
      planet[:resources_harvested] = true
    end

    def import_station_components(planet)
      planet[:imported_station_components] = true
    end
  end
end
