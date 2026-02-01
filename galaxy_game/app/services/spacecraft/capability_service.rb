module Spacecraft
  class CapabilityService
    SPACECRAFT_TYPES = {
      chemical_rocket: {
        name: 'Chemical Rocket',
        propulsion: :chemical,
        delta_v_capacity: 8.0, # km/s
        exhaust_velocity: 3.5, # km/s
        thrust_to_weight: 0.05,
        mass_ratio: 0.1, # Payload fraction
        reliability: 0.95,
        cost_per_kg_payload: 10000, # credits
        development_year: 1950
      },
      nuclear_thermal: {
        name: 'Nuclear Thermal Rocket',
        propulsion: :nuclear_thermal,
        delta_v_capacity: 12.0,
        exhaust_velocity: 8.0,
        thrust_to_weight: 0.03,
        mass_ratio: 0.15,
        reliability: 0.90,
        cost_per_kg_payload: 25000,
        development_year: 2035
      },
      ion_drive: {
        name: 'Ion Drive',
        propulsion: :ion_drive,
        delta_v_capacity: 25.0,
        exhaust_velocity: 30.0,
        thrust_to_weight: 0.001,
        mass_ratio: 0.05,
        reliability: 0.85,
        cost_per_kg_payload: 50000,
        development_year: 2045
      },
      nuclear_electric: {
        name: 'Nuclear Electric Propulsion',
        propulsion: :nuclear_electric,
        delta_v_capacity: 35.0,
        exhaust_velocity: 50.0,
        thrust_to_weight: 0.0005,
        mass_ratio: 0.03,
        reliability: 0.80,
        cost_per_kg_payload: 75000,
        development_year: 2050
      },
      antimatter_catalyzed: {
        name: 'Antimatter Catalyzed Rocket',
        propulsion: :antimatter,
        delta_v_capacity: 50.0,
        exhaust_velocity: 100.0,
        thrust_to_weight: 0.02,
        mass_ratio: 0.20,
        reliability: 0.70,
        cost_per_kg_payload: 200000,
        development_year: 2070
      }
    }.freeze

    CYCLER_TYPES = {
      earth_venus_cycler: {
        name: 'Earth-Venus Cycler',
        route: [:earth, :venus],
        period_days: 584, # ~1.6 years (Venus synodic period)
        delta_v_requirement: 6.5,
        preferred_spacecraft: [:chemical_rocket, :nuclear_thermal],
        cargo_capacity: 50000, # kg
        passenger_capacity: 20
      },
      earth_mars_cycler: {
        name: 'Earth-Mars Cycler',
        route: [:earth, :mars],
        period_days: 780, # ~2.1 years (Mars synodic period)
        delta_v_requirement: 8.0,
        preferred_spacecraft: [:nuclear_thermal, :ion_drive],
        cargo_capacity: 75000,
        passenger_capacity: 15
      },
      venus_mars_cycler: {
        name: 'Venus-Mars Cycler',
        route: [:venus, :mars],
        period_days: 414, # ~1.13 years (Venus-Mars synodic period)
        delta_v_requirement: 4.5,
        preferred_spacecraft: [:chemical_rocket, :nuclear_thermal],
        cargo_capacity: 35000,
        passenger_capacity: 12
      }
    }.freeze

    class << self
      def available_spacecraft_types(current_year = Time.current.year)
        SPACECRAFT_TYPES.select do |type, specs|
          specs[:development_year] <= current_year
        end
      end

      def calculate_transfer_time(origin, destination, spacecraft_type, launch_date = Time.current)
        # Get spacecraft specifications
        craft_specs = SPACECRAFT_TYPES[spacecraft_type.to_sym]
        return nil unless craft_specs

        # Use orbital mechanics to calculate base transfer
        transfer_data = OrbitalMechanics::TransferCalculator.calculate_transfer_time(
          origin, destination, launch_date, craft_specs[:propulsion]
        )

        return nil unless transfer_data

        # Adjust for spacecraft-specific characteristics
        adjusted_time = adjust_for_spacecraft_capabilities(transfer_data, craft_specs)

        transfer_data.merge(
          adjusted_transfer_days: adjusted_time,
          spacecraft_specs: craft_specs,
          fuel_requirements: calculate_fuel_requirements(transfer_data[:delta_v_required], craft_specs),
          reliability_factor: craft_specs[:reliability]
        )
      end

      def find_optimal_cycler_route(origin, destination, cargo_weight = 0, current_year = Time.current.year)
        route_key = "#{origin}_#{destination}_cycler".to_sym
        cycler_data = CYCLER_TYPES[route_key]

        return nil unless cycler_data

        # Check if we have appropriate spacecraft technology
        available_craft = available_spacecraft_types(current_year).keys
        suitable_craft = cycler_data[:preferred_spacecraft] & available_craft

        return nil if suitable_craft.empty?

        # Calculate current position in cycler orbit
        cycler_position = calculate_cycler_position(cycler_data, Time.now)

        # Determine if launch window is available
        launch_window = check_launch_window(cycler_data, cycler_position)

        {
          cycler_type: route_key,
          route_data: cycler_data,
          available_spacecraft: suitable_craft,
          next_launch_window: launch_window,
          cargo_capacity_utilization: cargo_weight.to_f / cycler_data[:cargo_capacity],
          estimated_travel_days: cycler_data[:period_days] / 2 # Half orbit for one-way
        }
      end

      def calculate_fuel_requirements(delta_v_kms, craft_specs)
        # Simplified fuel calculation using rocket equation
        # m = m0 * e^(-Δv/Ve)
        # Fuel mass = m0 - payload_mass

        # Assume 20% payload fraction for calculations
        payload_fraction = craft_specs[:mass_ratio]
        exhaust_velocity = craft_specs[:exhaust_velocity] * 1000 # Convert to m/s
        delta_v = delta_v_kms * 1000 # Convert to m/s

        # Rocket equation: ln(m0/mf) = Δv/Ve
        # m0/mf = e^(Δv/Ve)
        mass_ratio = Math.exp(delta_v / exhaust_velocity)

        # Fuel mass = total_mass - payload_mass
        # total_mass = payload_mass / payload_fraction
        # fuel_mass = total_mass * (1 - 1/mass_ratio)

        total_mass = 1000 / payload_fraction # Assume 1000kg payload for calculation
        fuel_mass = total_mass * (1 - 1/mass_ratio)

        fuel_mass.round
      end

      private

      def adjust_for_spacecraft_capabilities(transfer_data, craft_specs)
        base_days = transfer_data[:transfer_time_days]

        # Adjust based on propulsion efficiency
        efficiency_factor = craft_specs[:exhaust_velocity] / 3.5 # Chemical baseline
        adjusted_days = base_days / Math.sqrt(efficiency_factor)

        # Adjust for thrust-to-weight ratio (affects spiral time for low-thrust systems)
        if craft_specs[:thrust_to_weight] < 0.01
          # Low-thrust systems take longer to spiral out/in
          spiral_penalty = 1 / Math.sqrt(craft_specs[:thrust_to_weight] * 100)
          adjusted_days *= spiral_penalty
        end

        adjusted_days.round
      end

      def calculate_cycler_position(cycler_data, current_time)
        # Calculate position in cycler orbit (simplified)
        period_days = cycler_data[:period_days]
        days_since_epoch = (current_time - Time.new(2024, 1, 1)) / (24 * 3600) # Convert to days

        # Position as fraction of orbit (0.0 to 1.0)
        (days_since_epoch % period_days) / period_days.to_f
      end

      def check_launch_window(cycler_data, position)
        # Simplified launch window calculation
        # In reality, this would be much more complex based on actual orbital mechanics

        # Assume launch windows occur when the cycler is properly aligned
        # This is a major simplification
        window_duration_days = 30 # Launch window duration
        next_window_start = Time.now + rand(100) * 24 * 3600 # Random days for simulation

        {
          start_date: next_window_start,
          end_date: next_window_start + window_duration_days * 24 * 3600,
          duration_days: window_duration_days,
          optimal_launch_date: next_window_start + (window_duration_days / 2) * 24 * 3600
        }
      end
    end
  end
end