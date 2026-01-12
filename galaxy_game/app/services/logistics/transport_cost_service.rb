# app/services/logistics/transport_cost_service.rb (Enhanced)
module Logistics
  class TransportCostService
    
    def self.calculate_cost_per_kg(from:, to:, resource:)
      return 0.0 if from == to

      # Determine transport category
      category = determine_category(resource)
      base_rate = EconomicConfig.transport_rate(category)

      # Infrastructure-aware dynamic pricing
      # If in-situ refueling is available at LEO, L1, or Luna, use lower cost for that leg
      # Example: Earth→LEO (initial cost), LEO→Luna (lower cost if refueling available)
      if from == 'earth' && to == 'luna'
        # Check for in-situ refueling at LEO or Luna
        if in_situ_refueling_available?('leo')
          # Earth→LEO at initial cost, LEO→Luna at minimum cost
          cost_earth_leo = base_rate * EconomicConfig.route_modifier('earth_to_leo')
          cost_leo_luna = base_rate * EconomicConfig.route_modifier('leo_to_luna')
          return (cost_earth_leo + cost_leo_luna).round(2)
        elsif in_situ_refueling_available?('luna')
          # Earth→Luna direct, but Luna refueling drops return cost
          cost_earth_luna = base_rate * EconomicConfig.route_modifier('earth_to_luna') * 0.5 # Reduced for refueling
          return cost_earth_luna.round(2)
        else
          # No infrastructure: use baseline Earth-Luna cost
          return (base_rate * EconomicConfig.route_modifier('earth_to_luna')).round(2)
        end
      end

      # Try specific route modifier first (for common routes)
      route_key = build_route_key(from, to)
      if EconomicConfig.route_modifier(route_key)
        # Use configured route
        modifier = EconomicConfig.route_modifier(route_key)
        return (base_rate * modifier).round(2)
      end

      # Otherwise, calculate dynamically using physics
      physics_based_cost(from, to, base_rate)

    end

    # Dummy implementation: in a real game, this would check the actual infrastructure state
    def self.in_situ_refueling_available?(location)
      # Example: check a global or DB state for available propellant at LEO/Luna
      # For now, return false (can be toggled in tests or by game state)
      false
    end
    
    def self.calculate_transport_cost(from_body, to_body, cargo_mass, options = {})
      route = RouteFinder.find_best_route(from_body, to_body)
      total_cost = 0.0
      total_time = 0.0

      route.each_leg do |leg|
        if leg.wormhole?
          cost = EconomicConfig.wormhole_cost
          time = EconomicConfig.wormhole_time
        else
          launch_cost = EconomicConfig.gravity_wells[leg.from] * EconomicConfig.launch_cost_per_kms * cargo_mass
          transit_cost = leg.distance * EconomicConfig.transit_cost_per_au * cargo_mass
          cost = launch_cost + transit_cost
          time = leg.distance / EconomicConfig.ship_speed_au_per_day
        end
        total_cost += cost
        total_time += time
      end

      { cost: total_cost, time: total_time }
    end

    private
    
    def self.physics_based_cost(from, to, base_rate_per_kg)
      # Use your existing RouteCostCalculator
      calculator = RouteCostCalculator.new
      
      # Get distance between locations
      distance = get_distance(from, to)
      
      # Calculate delta-v based route cost
      # This returns GCC for given mass
      delta_v_cost = calculator.calculate_route_cost(
        from: from,
        to: to,
        distance: distance,
        mass: 1.0  # For 1 kg
      )
      
      # Calibrate: RouteCostCalculator uses (delta_v * mass * 100)
      # We want result to be in same range as base_rate
      calibration_factor = base_rate_per_kg / 100.0
      
      (delta_v_cost * calibration_factor).round(2)
    end

    def self.determine_category(resource)
      case resource
      when /titanium/, /ore/, /water/
        'bulk_material'
      when /alloy/, /component/, /manufactured/
        'manufactured'
      when /electronics/, /medical/
        'high_tech'
      else
        'bulk_material'
      end
    end

    def self.build_route_key(from, to)
      "#{from.downcase}_to_#{to.downcase}"
    end
  end
end