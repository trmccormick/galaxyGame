module Economics
  class CostValidator
    MINIMUM_COSTS = {
      # Minimum realistic costs for different types of infrastructure (GCC billions)
      orbital_station: 10.0,        # Smallest orbital station
      surface_outpost: 5.0,         # Small research outpost
      industrial_facility: 15.0,    # Basic industrial setup
      transportation_system: 8.0,   # Basic transport infrastructure
      research_facility: 3.0,       # Basic research lab
      power_system: 2.0,           # Basic power generation
      life_support_system: 1.0,     # Basic life support
    }.freeze

    REAL_WORLD_PRECEDENTS = {
      iss: 150_000_000_000,         # International Space Station (~$150B)
      apollo_program: 280_000_000_000, # Apollo moon program
      space_shuttle: 210_000_000_000, # Space Shuttle program
      hubble: 10_000_000_000,       # Hubble Space Telescope
      james_webb: 10_000_000_000,   # James Webb Space Telescope
      lunar_gateway: 2_700_000_000, # Lunar Gateway
      burj_khalifa: 1_500_000_000,  # World's tallest building
      three_gorges_dam: 32_000_000_000, # World's largest dam
      channel_tunnel: 15_000_000_000, # Channel Tunnel
    }.freeze

    class << self
      def validate_mission_cost(mission_data)
        issues = []

        # Check if costs exist
        unless mission_data['economic_analysis']
          issues << "Missing economic_analysis section"
          return issues
        end

        economics = mission_data['economic_analysis']
        initial_investment = parse_cost(economics['initial_investment_gcc'])

        # Check minimum costs based on mission type and location
        min_cost = calculate_minimum_cost(mission_data)
        if initial_investment < min_cost
          issues << "Initial investment (#{format_cost(initial_investment)}) is below minimum realistic cost (#{format_cost(min_cost)}) for #{mission_data['phase_id']}"
        end

        # Check cost scaling factors
        scaling_issues = validate_cost_scaling(economics['cost_scaling_factors'], mission_data)
        issues.concat(scaling_issues)

        # Check real-world comparison
        comparison_issues = validate_real_world_comparison(economics['real_world_cost_comparison'], initial_investment)
        issues.concat(comparison_issues)

        # Check ROI timeline
        roi_issues = validate_roi_timeline(economics, mission_data)
        issues.concat(roi_issues)

        issues
      end

      def validate_cost_scaling(scaling_factors, mission_data)
        issues = []

        return ["Missing cost_scaling_factors"] unless scaling_factors

        location = extract_location_from_mission(mission_data)
        expected_multipliers = expected_scaling_factors(location)

        # Check location multiplier
        actual_location = scaling_factors['location_multiplier'].to_f
        expected_location = expected_multipliers[:location]
        if (actual_location - expected_location).abs > expected_location * 0.5
          issues << "Location multiplier #{actual_location} seems unrealistic for #{location}. Expected ~#{expected_location}"
        end

        # Check distance multiplier
        actual_distance = scaling_factors['distance_multiplier'].to_f
        expected_distance = expected_multipliers[:distance]
        if (actual_distance - expected_distance).abs > expected_distance * 0.3
          issues << "Distance multiplier #{actual_distance} seems unrealistic for #{location}. Expected ~#{expected_distance}"
        end

        # Check complexity multiplier
        actual_complexity = scaling_factors['complexity_multiplier'].to_f
        expected_complexity = expected_multipliers[:complexity]
        if actual_complexity < expected_complexity * 0.7
          issues << "Complexity multiplier #{actual_complexity} may be too low for space infrastructure. Expected >=#{expected_complexity * 0.7}"
        end

        issues
      end

      def validate_real_world_comparison(comparison, actual_cost)
        issues = []

        return ["Missing real_world_cost_comparison"] unless comparison

        earth_cost = parse_cost(comparison['earth_equivalent_cost'])
        space_premium = comparison['space_cost_premium'].to_f

        calculated_premium = actual_cost.to_f / earth_cost.to_f

        if (calculated_premium - space_premium).abs > space_premium * 0.5
          issues << "Space cost premium (#{space_premium}x) doesn't match calculated premium (#{calculated_premium.round(1)}x)"
        end

        if space_premium < 5.0
          issues << "Space cost premium (#{space_premium}x) seems too low. Space infrastructure typically costs 10-50x Earth equivalent"
        end

        issues
      end

      def validate_roi_timeline(economics, mission_data)
        issues = []

        roi_months = economics['roi_timeline_months'].to_i
        initial_investment = parse_cost(economics['initial_investment_gcc'])
        monthly_revenue = parse_cost(economics['projected_monthly_revenue_gcc'])

        # Calculate break-even point
        break_even_months = (initial_investment.to_f / monthly_revenue.to_f).ceil

        if roi_months < break_even_months * 0.5
          issues << "ROI timeline (#{roi_months} months) seems unrealistically short. Break-even calculation suggests ~#{break_even_months} months"
        end

        if roi_months > 120 && mission_data['phase_id'].to_s.include?('industrial')
          issues << "ROI timeline (#{roi_months} months) seems too long for industrial infrastructure. Consider if costs are overestimated"
        end

        issues
      end

      private

      def parse_cost(cost_string)
        return 0 unless cost_string
        # Handle both string and numeric inputs
        if cost_string.is_a?(String)
          cost_string.gsub(/[^\d.]/, '').to_f
        else
          cost_string.to_f
        end
      end

      def format_cost(amount)
        if amount >= 1_000_000_000_000
          "#{(amount / 1_000_000_000_000.0).round(1)}T GCC"
        elsif amount >= 1_000_000_000
          "#{(amount / 1_000_000_000.0).round(1)}B GCC"
        elsif amount >= 1_000_000
          "#{(amount / 1_000_000.0).round(1)}M GCC"
        else
          "#{amount.round} GCC"
        end
      end

      def calculate_minimum_cost(mission_data)
        location = extract_location_from_mission(mission_data)
        mission_type = extract_mission_type(mission_data)

        base_min = MINIMUM_COSTS[mission_type] || 1.0

        # Apply location multiplier
        location_multiplier = case location
        when /mars/ then 3.0
        when /venus/ then 5.0
        when /jupiter|saturn/ then 8.0
        when /uranus|neptune/ then 12.0
        else 1.0
        end

        base_min * location_multiplier * 1_000_000_000 # Convert to GCC
      end

      def extract_location_from_mission(mission_data)
        # Extract location from phase_id or other fields
        phase_id = mission_data['phase_id'].to_s.downcase
        if phase_id.include?('venus')
          'venus'
        elsif phase_id.include?('mars')
          'mars'
        elsif phase_id.include?('luna')
          'luna'
        elsif phase_id.include?('jupiter')
          'jupiter'
        elsif phase_id.include?('saturn')
          'saturn'
        elsif phase_id.include?('uranus')
          'uranus'
        elsif phase_id.include?('neptune')
          'neptune'
        else
          'earth'
        end
      end

      def extract_mission_type(mission_data)
        # Determine mission type from tasks or description
        description = mission_data['description'].to_s.downcase
        tasks = mission_data['tasks'] || []

        if description.include?('industrial') || description.include?('foundry') || description.include?('manufacturing')
          :industrial_facility
        elsif description.include?('research') || description.include?('laboratory')
          :research_facility
        elsif description.include?('transport') || description.include?('cycler') || description.include?('elevator')
          :transportation_system
        elsif description.include?('station') || description.include?('orbital')
          :orbital_station
        elsif description.include?('outpost') || description.include?('base')
          :surface_outpost
        else
          :industrial_facility # default
        end
      end

      def expected_scaling_factors(location)
        case location
        when 'venus'
          { location: 30.0, distance: 5.0, complexity: 2.5 }
        when 'mars'
          { location: 20.0, distance: 5.0, complexity: 2.0 }
        when 'luna'
          { location: 12.0, distance: 2.0, complexity: 1.5 }
        when 'jupiter', 'saturn'
          { location: 40.0, distance: 12.0, complexity: 3.0 }
        when 'uranus', 'neptune'
          { location: 60.0, distance: 20.0, complexity: 4.0 }
        else
          { location: 1.0, distance: 1.0, complexity: 1.0 }
        end
      end
    end
  end
end