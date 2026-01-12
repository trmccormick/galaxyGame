# app/services/ai_manager/scout_logic.rb
module AIManager
  class ScoutLogic
    attr_reader :system_data, :probe_data, :system_architect

    def initialize(system_data, probe_data = nil, system_architect: nil)
      @system_data = system_data
      @probe_data = probe_data
      @system_architect = system_architect
    end

    # System-agnostic scouting method for any procedural system
    def analyze_system_patterns
      Rails.logger.info "[ScoutLogic] Initiating system-agnostic scouting analysis"

      # Extract celestial bodies from system data
      celestial_bodies = extract_celestial_bodies(@system_data)

      # Detect primary system characteristic
      primary_characteristic = detect_primary_characteristic(celestial_bodies)

      # Identify best settlement target
      target_body = identify_target_body(celestial_bodies, primary_characteristic)

      # Find terraformable bodies
      terraformable_bodies = identify_terraformable_bodies(celestial_bodies)

      # Find resource-rich bodies
      resource_rich_bodies = identify_resource_rich_bodies(celestial_bodies)

      # Detect water sources
      water_sources = detect_water_sources(celestial_bodies)

      # Calculate EM signatures for wormhole mapping
      em_signatures = calculate_em_signatures(celestial_bodies)

      # Initialize analysis hash
      analysis = {
        primary_characteristic: primary_characteristic,
        target_body: target_body,
        terraformable_bodies: terraformable_bodies,
        resource_rich_bodies: resource_rich_bodies,
        water_sources: water_sources,
        em_signatures: em_signatures,
        celestial_bodies_count: celestial_bodies.count,
        analysis_timestamp: Time.current
      }

      # Enhance with probe data if available
      if @probe_data
        analysis[:em_signatures] = @probe_data.dig(:findings, :em_signatures) || em_signatures
        analysis[:threat_level] = @probe_data.dig(:findings, :threat_assessment, :overall_threat_level) || 'unknown'
        analysis[:resource_confidence] = calculate_confidence_from_probes
        analysis[:probe_enhanced] = true
        analysis[:probe_deployment_time] = @probe_data[:deployment_time]
      else
        analysis[:threat_level] = 'unknown'
        analysis[:resource_confidence] = 0.5
        analysis[:probe_enhanced] = false
      end

      analysis
    end

    private

    # Extract celestial bodies from system data (handles both Sol format and procedural format)
    def extract_celestial_bodies(system_data)
      celestial_bodies_data = system_data["celestial_bodies"] || []

      all_bodies = []

      if celestial_bodies_data.is_a?(Array)
        # Sol format: array of bodies
        celestial_bodies_data.each do |body|
          all_bodies << body
          # Add moons if they exist
          if body["moons"]
            body["moons"].each do |moon|
              moon["orbiting_body"] = body["name"]
              all_bodies << moon
            end
          end
        end
      else
        # Procedural format: hash of categories
        celestial_bodies_data.each do |category, bodies|
          next unless bodies.is_a?(Array)

          bodies.each do |body|
            all_bodies << body

            # Add moons if they exist
            if body["moons"]
              body["moons"].each do |moon|
                moon["orbiting_body"] = body["name"]
                all_bodies << moon
              end
            end
          end
        end
      end

      all_bodies
    end

    # Detect primary system characteristic based on patterns
    def detect_primary_characteristic(celestial_bodies)
      # Luna Pattern: large moon (>1e22 kg) with surface resources
      large_moons = celestial_bodies.select do |body|
        body["type"] == "moon" && (body["mass_kg"].to_f > 1e22) && body["surface_resources"]&.any?
      end
      return :large_moon_with_resources if large_moons.any?

      # Mars Pattern: 2+ small moons (1e18-1e20 kg) + asteroid belt
      small_moons = celestial_bodies.select do |body|
        body["type"] == "moon" && (body["mass_kg"].to_f.between?(1e18, 1e20))
      end
      asteroid_belts = celestial_bodies.select { |body| body["type"] == "asteroid_belt" }
      return :small_moons_with_belt if small_moons.size >= 2 && asteroid_belts.any?

      # Venus Pattern: dense atmosphere + no surface access
      venus_like = celestial_bodies.select do |body|
        (body["type"] == "planet" || body["type"] == "terrestrial_planet") &&
        body["atmosphere"]&.dig("density")&.to_f > 1.0 &&
        !body["surface_accessible"]
      end
      return :atmospheric_planet_no_surface_access if venus_like.any?

      # Titan Pattern: gas giant + resource-rich moons
      gas_giants = celestial_bodies.select { |body| body["type"] == "gas_giant" }
      resource_rich_moons = celestial_bodies.select do |body|
        body["type"] == "moon" && body["resources"]&.any?
      end
      return :gas_giant_with_moons if gas_giants.any? && resource_rich_moons.any?

      # Default pattern
      :generic_system
    end

    # Identify best settlement target based on primary characteristic
    def identify_target_body(celestial_bodies, primary_characteristic)
      case primary_characteristic
      when :large_moon_with_resources
        # Target the large moon
        celestial_bodies.find { |body| body["type"] == "moon" && body["mass_kg"].to_f > 1e22 }
      when :small_moons_with_belt
        # Target the planet with small moons
        planet_with_moons = celestial_bodies.find do |body|
          body["type"] == "planet" && body["moons"]&.any? do |moon|
            moon["mass_kg"].to_f.between?(1e18, 1e20)
          end
        end
        planet_with_moons || celestial_bodies.find { |body| body["type"] == "planet" }
      when :atmospheric_planet_no_surface_access
        # Target the atmospheric planet (for orbital operations)
        celestial_bodies.find do |body|
          body["atmosphere"]&.dig("density")&.> 1.0 && !body["surface_accessible"]
        end
      when :gas_giant_with_moons
        # Target the most resource-rich moon
        resource_rich_moons = celestial_bodies.select do |body|
          body["type"] == "moon" && body["resources"]&.any?
        end
        resource_rich_moons.max_by { |moon| moon["resources"]&.size || 0 }
      else
        # Generic: prefer terraformable planets, then resource-rich bodies
        terraformable = identify_terraformable_bodies(celestial_bodies).first
        return terraformable if terraformable

        resource_rich = identify_resource_rich_bodies(celestial_bodies).first
        return resource_rich if resource_rich

        # Fallback to first planet
        celestial_bodies.find { |body| body["type"] == "planet" }
      end
    end

    # Identify terraformable bodies
    def identify_terraformable_bodies(celestial_bodies)
      celestial_bodies.select do |body|
        (body['type'] == 'planet' || body['type'] == 'terrestrial' || body['type'] == 'terrestrial_planet') &&
        (body['terraforming_difficulty'] || body['engineered_atmosphere'] ||
         body['atmosphere']&.dig('breathable') || body['biosphere_attributes'])
      end
    end

    # Identify resource-rich bodies
    def identify_resource_rich_bodies(celestial_bodies)
      celestial_bodies.select do |body|
        body['resources']&.any? || body['type'] == 'moon' || body['type'] == 'asteroid'
      end
    end

    # Detect water sources (ice asteroids, gas giants, icy moons)
    def detect_water_sources(celestial_bodies)
      water_sources = []

      # Ice-rich asteroids
      ice_asteroids = celestial_bodies.select do |body|
        body["type"] == "asteroid" && (body["composition"]&.dig("water_ice")&.to_f || 0) > 0.1
      end
      water_sources.concat(ice_asteroids.map { |body| { type: :ice_asteroid, body: body } })

      # Gas giants (for atmospheric water extraction)
      gas_giants = celestial_bodies.select { |body| body["type"] == "gas_giant" }
      water_sources.concat(gas_giants.map { |body| { type: :gas_giant, body: body } })

      # Icy moons
      icy_moons = celestial_bodies.select do |body|
        body["type"] == "moon" && (body["composition"]&.dig("water_ice")&.to_f || 0) > 0.1
      end
      water_sources.concat(icy_moons.map { |body| { type: :icy_moon, body: body } })

      water_sources
    end

    # Calculate EM signatures for wormhole location mapping
    def calculate_em_signatures(celestial_bodies)
      signatures = []

      celestial_bodies.each do |body|
        next unless body["type"] && body["mass_kg"]

        # Calculate basic EM signature based on type and mass
        base_signature = case body["type"]
        when "star" then 100.0
        when "gas_giant" then 50.0
        when "planet", "terrestrial_planet" then 25.0
        when "moon" then 10.0
        when "asteroid" then 1.0
        else 5.0
        end

        # Adjust by mass
        mass_factor = Math.log10(body["mass_kg"].to_f + 1) / 30.0 # Normalize
        signature_strength = base_signature * (1 + mass_factor)

        signatures << {
          body_name: body["name"],
          body_type: body["type"],
          signature_strength: signature_strength.round(2),
          coordinates: body["coordinates"] || [0, 0, 0]
        }
      end

      signatures.sort_by { |sig| -sig[:signature_strength] } # Strongest first
    end

    # Calculate resource confidence score from probe data
    def calculate_confidence_from_probes
      return 0.5 unless @probe_data

      resource_assessment = @probe_data.dig(:findings, :resource_assessment)
      return 0.5 unless resource_assessment

      # Base confidence on probe assessment quality
      base_confidence = case resource_assessment[:assessment_quality]
                       when 'high' then 0.9
                       when 'medium' then 0.7
                       when 'low' then 0.4
                       else 0.5
                       end

      # Adjust for threat level
      threat_penalty = case @probe_data.dig(:findings, :threat_assessment, :overall_threat_level)
                      when 'high' then 0.2
                      when 'moderate' then 0.1
                      when 'low' then 0.0
                      else 0.0
                      end

      [base_confidence - threat_penalty, 0.0].max
    end
  end
end
