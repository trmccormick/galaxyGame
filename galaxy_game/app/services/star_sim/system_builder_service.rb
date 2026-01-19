# app/services/star_sim/system_builder_service.rb
module StarSim
  class SystemBuilderService
    attr_reader :system_data, :name
    attr_accessor :debug_mode

    # Initializes the service.
    # @param name [String] The name of the star system to build.
    # @param debug_mode [Boolean] If true, enables verbose logging for debugging.
    def initialize(name: nil, debug_mode: false) # ADDED debug_mode as a keyword argument
      raise ArgumentError, "Must provide system_name" if name.nil?

      @name = name
      @lookup_service = Lookup::StarSystemLookupService.new # Assumed to fetch system data
      @system_data = @lookup_service.fetch(@name)

      unless @system_data
        raise "System not found for name: #{name}"
      end
      
      # Ensure keys are symbolized for consistent access
      @system_data = @system_data.deep_symbolize_keys

      @name_generator = NameGeneratorService.new # Assumed to generate identifiers
      @galaxy = nil
      @solar_system = nil
      @debug_mode = debug_mode # Assign the passed debug_mode value

      # Cache for created CelestialBody and Star objects, mapping identifier to object
      @created_celestial_bodies_cache = {}
      @created_stars_cache = {} # New cache for stars
    end   

    # Builds the entire star system within a transaction.
    # Uses a multi-pass approach to ensure parent bodies are created before children.
    def build!
      puts "Starting system build for #{@name}..." if @debug_mode
      ActiveRecord::Base.transaction do
        create_galaxy
        create_solar_system

        # Normalize celestial_bodies structure - handle both array and hash formats
        normalized_celestial_bodies = normalize_celestial_bodies_structure

        # Pass 1: Create all stars first, as they are often parents to planets
        (@system_data[:stars] || []).each do |star_data|
          create_star_record(star_data)
        end

        # Pass 2: Create all non-satellite celestial bodies (planets, dwarf planets, etc.)
        # These bodies might orbit stars or be parents to moons.
        normalized_celestial_bodies.each do |category, bodies_array|
          # Skip moons/satellites in this pass
          next if category.to_s.include?('moon') || category.to_s.include?('satellite') 
          (bodies_array || []).each do |body_data|
            create_celestial_body_record(body_data, category)
          end
        end

        # Pass 3: Create all satellites (moons).
        # Their parent bodies (planets) should now be in the database and cache.
        normalized_celestial_bodies.each do |category, bodies_array|
          if category.to_s.include?('moon') || category.to_s.include?('satellite') # Process moons/satellites in this pass
            (bodies_array || []).each do |body_data|
              create_celestial_body_record(body_data, category)
            end
          end
        end
      end
      puts "System build for #{@name} complete!" if @debug_mode
      @solar_system # Return the created solar system
    rescue => e
      puts "ERROR: System build failed for #{@name}: #{e.class}: #{e.message}"
      Rails.logger.error "StarSim::SystemBuilderService failed for #{@name}: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
      raise # Re-raise to rollback transaction
    end

    private

    # Normalizes celestial_bodies structure to handle both array and hash formats
    # Converts array format (from sol-complete.json) to hash format expected by the builder
    def normalize_celestial_bodies_structure
      celestial_bodies = @system_data[:celestial_bodies] || {}
      
      # If it's already a hash, return as-is
      return celestial_bodies if celestial_bodies.is_a?(Hash)
      
      # If it's an array (sol-complete.json format), group by type
      if celestial_bodies.is_a?(Array)
        grouped = {}
        celestial_bodies.each do |body|
          type = body[:type] || 'unknown'
          
          # Map types to categories
          category = case type
          when 'terrestrial_planet'
            'terrestrial_planets'
          when 'gas_giant'
            'gas_giants'  
          when 'ice_giant'
            'ice_giants'
          when 'dwarf_planet'
            'dwarf_planets'
          when 'moon'
            # Check if it's a major moon or regular moon
            if ['Luna', 'Titan', 'Ganymede', 'Callisto', 'Io', 'Europa', 'Rhea', 'Iapetus', 'Dione', 'Tethys', 'Enceladus', 'Mimas', 'Titania', 'Oberon', 'Umbriel', 'Ariel', 'Miranda'].include?(body[:name])
              'major_moons'
            else
              'moons'
            end
          else
            'other_bodies'
          end
          
          grouped[category] ||= []
          grouped[category] << body
        end
        return grouped
      end
      
      # Fallback for unexpected formats
      {}
    end

    # Creates or finds the main Galaxy record.
    def create_galaxy
      galaxy_data = @system_data[:galaxy] || {}
      
      galaxy_name = galaxy_data[:name] || "Unknown Galaxy"
      galaxy_identifier = galaxy_data[:identifier] || @name_generator.generate_identifier
      
      @galaxy = Galaxy.find_or_create_by!(name: galaxy_name) do |g|
        g.identifier = galaxy_identifier
        puts "Creating galaxy: #{galaxy_name}" if @debug_mode
      end
    end

    # Creates or finds the SolarSystem record.
    def create_solar_system
      solar_data = @system_data[:solar_system] || {}
      
      system_name = solar_data[:name] || name
      system_identifier = solar_data[:identifier] || @name_generator.generate_identifier
      
      @solar_system = SolarSystem.find_or_create_by!(name: system_name, galaxy: @galaxy) do |sys|
        sys.identifier = system_identifier
        puts "Creating solar system: #{system_name}" if @debug_mode
      end
    end

    # Creates or updates a Star record.
    # @param star_data [Hash] The attributes for the star from the JSON.
    # @return [CelestialBodies::Star, nil] The created/updated star, or nil if an error occurred.
    def create_star_record(star_data)
      identifier = star_data[:identifier] || @name_generator.generate_identifier
      star_name = star_data[:name] || identifier

      puts "Processing Star #{star_name} (Identifier: #{identifier})" if @debug_mode

      # Check if star already exists in cache or DB
      if @created_stars_cache.key?(identifier)
        puts "Star #{star_name} already in cache." if @debug_mode
        return @created_stars_cache[identifier]
      end
      
      existing_star = CelestialBodies::Star.find_by(identifier: identifier, solar_system: @solar_system)
      if existing_star
        puts "Star #{star_name} already exists in DB." if @debug_mode
        @created_stars_cache[identifier] = existing_star
        return existing_star
      end

      # Prepare attributes for Star creation
      # Exclude 'properties' as it's handled separately
      attrs = star_data.except(:properties) 
      attrs[:solar_system] = @solar_system # Assign solar system to star

      # Create the star
      star = CelestialBodies::Star.new(attrs)
      
      # Assign properties JSONB from JSON if present
      star.properties.merge!(star_data[:properties]) if star_data[:properties].present?

      if star.save
        puts "Successfully created Star #{star.name} (ID: #{star.id})" if @debug_mode
        @created_stars_cache[identifier] = star # Add to star cache
        star
      else
        puts "ERROR: Failed to create Star #{star_name}: #{star.errors.full_messages.join(', ')}"
        puts "Failed attributes: #{star.attributes.inspect}" if @debug_mode
        nil
      end
    end

    # Centralized method to create any CelestialBody record (Planet, Moon, DwarfPlanet etc.)
    # @param body_data [Hash] The attributes for the body from the JSON.
    # @param category [Symbol] The category (e.g., :planets, :moons) for context.
    def create_celestial_body_record(body_data, category = nil)
      identifier = body_data[:identifier] || @name_generator.generate_identifier
      body_name = body_data[:name] || identifier # Use identifier as fallback name
      
      puts "Processing #{body_name} (Identifier: #{identifier})" if @debug_mode

      # Check if body already exists in cache or DB to prevent re-creation
      if @created_celestial_bodies_cache.key?(identifier)
        puts "Body #{body_name} already in celestial bodies cache." if @debug_mode
        return @created_celestial_bodies_cache[identifier]
      end
      
      existing_body = CelestialBodies::CelestialBody.find_by(identifier: identifier, solar_system: @solar_system)
      if existing_body
        puts "Body #{body_name} already exists in DB." if @debug_mode
        @created_celestial_bodies_cache[identifier] = existing_body
        return existing_body
      end

      # Determine the model class using the new helper
      model_class = determine_model_class(body_data, category)
      unless model_class
        puts "WARNING: Could not determine model class for #{body_name} (type: #{body_data[:type]}, category: #{category}). Skipping." if @debug_mode
        return nil
      end
      
      # Prepare attributes, excluding custom fields like 'type' and 'parent_identifier'
      # and association data that will be created separately.
      # CRITICAL FIX: Add :parent_body to special_keys_to_exclude
      special_keys_to_exclude = [
        :type, :parent_identifier, :parent_body, :properties, # Handled explicitly
        :atmosphere, :hydrosphere, :geosphere_attributes, :star_distances # Handled as associations
      ]
      attrs = body_data.except(*special_keys_to_exclude)

      # Ensure solar_system is set for all celestial bodies
      attrs[:solar_system] = @solar_system

      # Ensure mass is numeric for DB compatibility
      if attrs[:mass]
        begin
          attrs[:mass] = BigDecimal(attrs[:mass].to_s)
        rescue ArgumentError, TypeError
          attrs[:mass] = nil
        end
      end

      # Handle parent relationships for satellites/moons (CRITICAL FIX: Use belongs_to association)
      # Now correctly uses :parent_body from JSON as the identifier string

      puts body_data.inspect if @debug_mode # DEBUG: Print body_data to see structure
      parent_identifier_from_json = body_data[:parent_identifier] || body_data[:parent_body]

      if parent_identifier_from_json.present?
        parent_identifier = parent_identifier_from_json # Use the identifier found in JSON
        # DEBUG: Print the parent identifier being looked up
        puts "DEBUG: Looking for parent with identifier: '#{parent_identifier}' for body '#{body_name}'" if @debug_mode
        # Look up the parent CelestialBody object from cache or DB
        parent_body_object = @created_celestial_bodies_cache[parent_identifier] || 
                             CelestialBodies::CelestialBody.find_by(identifier: parent_identifier)
        
        unless parent_body_object
          puts "ERROR: Parent '#{parent_identifier}' not found for #{body_name}. Skipping creation." if @debug_mode
          return nil
        end
        # Assign the parent object to the association. Rails will set the foreign key.
        attrs[:parent_celestial_body] = parent_body_object
        puts "Assigned parent #{parent_body_object.name} to #{body_name} via parent_celestial_body association." if @debug_mode
      end

      # Add source marker to properties
      attrs[:properties] ||= {}
      attrs[:properties]['source'] = 'system_builder'
      
      # Add special type-specific properties based on attributes, not names
      # This method should modify `attrs[:properties]`
      add_special_properties(attrs, body_data, model_class)
      
      # Create the body using the determined model class
      body = model_class.new(attrs)
      
      # Assign properties JSONB from JSON if present, after add_special_properties has run
      # This allows JSON to override or add to properties set by add_special_properties
      body.properties.merge!(body_data[:properties]) if body_data[:properties].present?

      if body.save
        puts "Successfully created #{body.class.name} #{body.name} (ID: #{body.id})" if @debug_mode
        @created_celestial_bodies_cache[identifier] = body # Add to cache
        
        # Create associated sphere and distance data AFTER the body is saved
        create_star_distances(body, body_data[:star_distances])
        create_atmosphere(body, body_data[:atmosphere]) if body_data[:atmosphere].present?
        create_hydrosphere(body, body_data[:hydrosphere]) if body_data[:hydrosphere].present?
        create_geosphere(body, body_data[:geosphere_attributes]) if body_data[:geosphere_attributes].present?
        # Always create a biosphere, using seed data if present, or defaults if not
        create_biosphere(body, body_data[:biosphere])

        body
      else
        puts "ERROR: Failed to create #{body_name} (#{model_class.name}): #{body.errors.full_messages.join(', ')}" if @debug_mode
        puts "Failed attributes: #{body.attributes.inspect}" if @debug_mode
        nil
      end
    end
    
    # Determines the correct STI model class based on body_data.
    # @param body_data [Hash] The data for the celestial body.
    # @param category [Symbol] The category from the JSON (e.g., :planets, :moons).
    # @return [Class] The ActiveRecord model class.
    def determine_model_class(body_data, category)
      # If 'type' is the full STI class name in JSON (e.g., "CelestialBodies::Planets::Rocky::TerrestrialPlanet")
      if body_data[:type].to_s.include?('::')
        return body_data[:type].to_s.constantize rescue nil
      end

      # Fallback to custom logic if 'type' is a simplified string (e.g., "terrestrial", "moon")
      case body_data[:type].to_s
      when "terrestrial" then CelestialBodies::Planets::Rocky::TerrestrialPlanet
      when "super_earth" then CelestialBodies::Planets::Rocky::SuperEarth
      when "carbon_planet" then CelestialBodies::Planets::Rocky::CarbonPlanet
      when "lava_world"
        body_data[:surface_temperature].to_f > 700 ? CelestialBodies::Planets::Rocky::LavaWorld : CelestialBodies::Planets::Rocky::TerrestrialPlanet

      when "gas_giant" then CelestialBodies::Planets::Gaseous::GasGiant
      when "ice_giant" then CelestialBodies::Planets::Gaseous::IceGiant
      when "hot_jupiter" then CelestialBodies::Planets::Gaseous::HotJupiter

      when "ocean_planet" then CelestialBodies::Planets::Ocean::OceanPlanet
      when "water_world" then CelestialBodies::Planets::Ocean::WaterWorld
      when "hycean" then CelestialBodies::Planets::Ocean::HyceanPlanet

      when "dwarf_planet" then CelestialBodies::MinorBodies::DwarfPlanet
      when "asteroid" then CelestialBodies::MinorBodies::Asteroid
      when "comet" then CelestialBodies::MinorBodies::Comet

      when "moon" then CelestialBodies::Satellites::Moon

      when "star" then CelestialBodies::Star

      else
        # Fallback if type not explicitly matched, try category
        case category.to_s
        when "major_moons", "moons", "satellites"
          CelestialBodies::Satellites::Moon
        when "stars" then CelestialBodies::Star
        else
          CelestialBodies::CelestialBody # Generic fallback
        end
      end
    end
    
    # Adds special properties to the attributes hash based on model class and data.
    # @param attrs [Hash] The attributes hash being built for the CelestialBody.
    # @param body_data [Hash] The raw data for the body from JSON.
    # @param model_class [Class] The determined STI model class.
    def add_special_properties(attrs, body_data, model_class)
      attrs[:properties] ||= {} # Ensure properties hash exists

      case model_class.name
      when /TerrestrialPlanet/
        if body_data[:surface_temperature].to_f > 500
          attrs[:properties]['volcanic_activity'] = 'high'
        end
        if body_data.dig(:hydrosphere, :water_coverage).to_f > 50
          attrs[:properties]['water_dominant'] = true
        elsif body_data.dig(:hydrosphere, :water_coverage).to_f > 0
          attrs[:properties]['has_water'] = true
        end
        if body_data[:magnetic_field].to_f > 30
          attrs[:properties]['strong_magnetosphere'] = true
        end
        
      when /GasGiant/
        attrs[:properties]['ring_system_probability'] = rand(0.0..1.0)
        attrs[:properties]['estimated_moon_count'] = body_data[:mass].to_f > 1e26 ? rand(30..80) : rand(5..30)
        
      when /IceGiant/
        attrs[:properties]['complex_weather_patterns'] = true
        attrs[:properties]['exotic_ices'] = ['methane', 'ammonia', 'water']
        
      when /LargeMoon/
        if body_data.dig(:hydrosphere, :ice_coverage).to_f > 50
          attrs[:properties]['subsurface_ocean_potential'] = 'high'
        end
        if body_data[:orbital_eccentricity].to_f > 0.01
          attrs[:properties]['tidal_heating'] = 'significant'
        end
        
      when /SmallMoon/
        if body_data[:density].to_f < 2.0
          attrs[:properties]['origin'] = 'likely_captured'
          attrs[:properties]['rubble_pile'] = true
        end
      end
    end
    
    # Creates StarDistance records for a celestial body.
    # @param body [CelestialBodies::CelestialBody] The body to create distances for.
    # @param star_distances_data [Array<Hash>] Array of star distance data from JSON.
    def create_star_distances(body, star_distances_data)
      body.star_distances.destroy_all # Clear existing to prevent duplicates on re-run
  
      if star_distances_data.present?
        star_distances_data.each do |star_distance_data|
          star_name = star_distance_data[:star_name]
          distance = star_distance_data[:distance]
          
          star = @solar_system.stars.find_by(name: star_name)
          if star
            body.star_distances.create!(
              star: star,
              distance: distance
            )
          else
            puts "WARNING: Star '#{star_name}' not found for #{body.name} star distance. Skipping." if @debug_mode
          end
        end
      elsif !body.star_distances.any? && @solar_system.stars.any? && body.respond_to?(:semi_major_axis) && body.semi_major_axis.present?
        # Fallback: If no explicit star distances but semi_major_axis is present, use primary star
        primary_star = @solar_system.stars.first # Assuming the first star is the primary
        if primary_star
          body.star_distances.create!(
            star: primary_star,
            distance: body.semi_major_axis * 149_597_870_700.0 # Convert AU to meters
          )
          puts "Created star distance for #{body.name} using semi_major_axis." if @debug_mode
        end
      end
    end
    
    # Creates an Atmosphere record for a celestial body.
    # @param body [CelestialBodies::CelestialBody] The body to create atmosphere for.
    # @param atmosphere_data [Hash] Atmosphere data from JSON.
    def create_atmosphere(body, atmosphere_data)
      return unless atmosphere_data.present?
      
      composition = atmosphere_data[:composition] || {}
      transformed_composition = {}
      composition.each do |key, value|
        if value.is_a?(Hash)
          transformed_composition[key.to_s] = value[:percentage] || value["percentage"]
        else
          transformed_composition[key.to_s] = value
        end
      end
      
      initial_values = {
        composition: transformed_composition,
        pressure: atmosphere_data[:pressure],
        total_atmospheric_mass: atmosphere_data[:total_atmospheric_mass],
        dust: atmosphere_data[:dust]
      }
      
      # Use `build_atmosphere` then `save!` to ensure it's part of the transaction
      atmo = body.build_atmosphere(
        initial_values.merge(
          base_values: initial_values.deep_dup
        )
      )
      
      # Set skip_simulation if the Atmosphere model supports it, to prevent its own callbacks
      atmo.skip_simulation = true if atmo.respond_to?(:skip_simulation=)
      
      atmo.save!
      
      # Manually initialize gases after atmosphere is saved
      atmo.initialize_gases if atmo.respond_to?(:initialize_gases)
      puts "Created atmosphere for #{body.name}." if @debug_mode
    end

    # Creates a Hydrosphere record for a celestial body.
    # @param body [CelestialBodies::CelestialBody] The body to create hydrosphere for.
    # @param hydrosphere_data [Hash] Hydrosphere data from JSON.
    def create_hydrosphere(body, hydrosphere_data)
      return unless hydrosphere_data.present?
      
      hydrosphere_attrs = hydrosphere_data.deep_dup
      
      if hydrosphere_attrs[:composition].is_a?(Array)
        transformed_composition = {}
        hydrosphere_attrs[:composition].each do |item|
          transformed_composition[item[:compound].to_s] = item[:percentage]
        end
        hydrosphere_attrs[:composition] = transformed_composition
      end

      if hydrosphere_attrs[:composition].nil? || (hydrosphere_attrs[:composition].is_a?(Array) && hydrosphere_attrs[:composition].empty?)
        hydrosphere_attrs[:composition] = { "H2O" => 100.0 }
      end
      
      if hydrosphere_attrs[:state_distribution].is_a?(Array)
        transformed_state_distribution = {}
        hydrosphere_attrs[:state_distribution].each do |item|
          transformed_state_distribution[item[:state].to_s] = item[:percentage]
        end
        hydrosphere_attrs[:state_distribution] = transformed_state_distribution
      end
      
      # Use `build_hydrosphere` then `save!`
      hydrosphere = body.build_hydrosphere(hydrosphere_attrs)
      
      hydrosphere.skip_simulation = true if hydrosphere.respond_to?(:skip_simulation=)
      
      hydrosphere.save!
      puts "Created hydrosphere for #{body.name}." if @debug_mode
    end

    # Creates a Geosphere record for a celestial body.
    # @param body [CelestialBodies::CelestialBody] The body to create geosphere for.
    # @param geosphere_data [Hash] Geosphere data from JSON.
    def create_geosphere(body, geosphere_data)
      return unless geosphere_data.present? && body.respond_to?(:create_geosphere!) # Check for method existence
      
      geosphere_attrs = geosphere_data.deep_dup
      
      stored_volatiles = {}
      
      if geosphere_attrs[:co2_reserves].present?
        co2_data = geosphere_attrs.delete(:co2_reserves)
        
        stored_volatiles['CO2'] = {
          'polar_caps' => co2_data['polar_cap_ice_mass'],
          'regolith' => co2_data['regolith_co2_stores_mass'],
          'clathrates' => co2_data['clathrate_potential_mass_high']
        }.compact
      end
      
      if geosphere_attrs[:stored_volatiles].present?
        volatiles_data = geosphere_attrs.delete(:stored_volatiles)
        volatiles_data.each do |compound, locations|
          stored_volatiles[compound] ||= {}
          stored_volatiles[compound].merge!(locations)
        end
      end
      
      # Use `build_geosphere` then `save!`
      geosphere = body.build_geosphere(geosphere_attrs)
      
      geosphere.skip_simulation = true if geosphere.respond_to?(:skip_simulation=)
      
      geosphere.stored_volatiles = stored_volatiles # Always set, even if empty
      
      geosphere.save!
      puts "Created geosphere for #{body.name}." if @debug_mode
    end

    # Creates a Biosphere record for a celestial body.
    # @param body [CelestialBodies::CelestialBody] The body to create biosphere for.
    # @param biosphere_data [Hash, nil] Biosphere data from JSON, or nil for defaults.
    def create_biosphere(body, biosphere_data = nil)
      return unless body.respond_to?(:build_biosphere)

      biosphere_attrs = biosphere_data ? biosphere_data.deep_dup : {}
        biosphere_attrs[:habitable_ratio] ||= 0.0
        biosphere_attrs[:biodiversity_index] ||= 0.0

      # Use `build_biosphere` then `save!` to ensure it's part of the transaction
      biosphere = body.build_biosphere(biosphere_attrs)
      biosphere.skip_simulation = true if biosphere.respond_to?(:skip_simulation=)
      biosphere.save!
      puts "Created biosphere for #{body.name}." if @debug_mode
    end  
  end
end
