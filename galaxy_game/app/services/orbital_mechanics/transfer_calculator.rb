module OrbitalMechanics
  class TransferCalculator
    # Orbital periods in Earth days
    ORBITAL_PERIODS = {
      earth: 365.25,
      venus: 224.7,
      mars: 686.98,
      luna: 27.32 # Sidereal month
    }.freeze

    # Semi-major axes in AU
    SEMI_MAJOR_AXES = {
      earth: 1.0,
      venus: 0.723,
      mars: 1.524,
      luna: 1.0 # Relative to Earth
    }.freeze

    # Gravitational parameters (km³/s²)
    MU_SUN = 1.327e20
    MU_EARTH = 3.986e14

    class << self
      def calculate_transfer_time(origin, destination, launch_date = Time.current, spacecraft_type = :chemical)
        origin_data = get_celestial_body_data(origin)
        dest_data = get_celestial_body_data(destination)

        return nil unless origin_data && dest_data

        # Calculate current mean anomalies
        origin_m = mean_anomaly(origin_data[:period], launch_date)
        dest_m = mean_anomaly(dest_data[:period], launch_date)

        # Calculate optimal transfer window
        transfer_window = find_optimal_transfer_window(origin_m, dest_m, origin_data, dest_data)

        # Calculate transfer time based on spacecraft capabilities
        delta_v = hohmann_transfer_delta_v(origin_data[:semi_major], dest_data[:semi_major])
        transfer_time_days = calculate_transfer_duration(delta_v, spacecraft_type)

        {
          launch_date: launch_date + (transfer_window[:wait_days] * 24 * 3600), # Convert days to seconds
          transfer_time_days: transfer_time_days,
          arrival_date: launch_date + (transfer_window[:wait_days] * 24 * 3600) + (transfer_time_days * 24 * 3600),
          delta_v_required: delta_v,
          spacecraft_type: spacecraft_type,
          transfer_type: transfer_window[:type],
          synodic_period_days: synodic_period(origin_data[:period], dest_data[:period])
        }
      end

      def find_optimal_transfer_window(origin_m, dest_m, origin_data, dest_data)
        # Calculate phase angle between planets
        phase_angle = (dest_m - origin_m) % (2 * Math::PI)

        # For Hohmann transfers, we want planets to be 180 degrees apart for opposition
        # or 0 degrees for conjunction transfers
        target_phase = case [origin_data[:name], dest_data[:name]].sort
        when ['earth', 'mars']
          Math::PI # Opposition transfer (180 degrees)
        when ['earth', 'venus']
          0 # Inferior conjunction transfer
        when ['venus', 'mars']
          Math::PI # Opposition transfer
        else
          Math::PI # Default to opposition
        end

        # Calculate days to wait for optimal alignment
        angular_velocity_diff = (2 * Math::PI / dest_data[:period]) - (2 * Math::PI / origin_data[:period])
        days_to_optimal = if angular_velocity_diff != 0
          ((target_phase - phase_angle) / angular_velocity_diff).abs
        else
          0
        end

        # Ensure we don't wait more than half the synodic period
        synodic = synodic_period(origin_data[:period], dest_data[:period])
        days_to_optimal = days_to_optimal % synodic

        if days_to_optimal > synodic / 2
          days_to_optimal = synodic - days_to_optimal
        end

        {
          wait_days: days_to_optimal,
          type: target_phase == Math::PI ? :opposition : :conjunction
        }
      end

      def hohmann_transfer_delta_v(r1_au, r2_au)
        # Convert AU to km
        r1 = r1_au * 1.496e8
        r2 = r2_au * 1.496e8

        # Hohmann transfer delta-V calculation
        mu = MU_SUN

        # Velocity at first orbit
        v1 = Math.sqrt(mu / r1)
        # Velocity at transfer orbit perigee
        vt1 = Math.sqrt(mu * (2/r1 - 1/((r1+r2)/2)))
        # Delta-V for first burn
        dv1 = vt1 - v1

        # Velocity at second orbit
        v2 = Math.sqrt(mu / r2)
        # Velocity at transfer orbit apogee
        vt2 = Math.sqrt(mu * (2/r2 - 1/((r1+r2)/2)))
        # Delta-V for second burn
        dv2 = v2 - vt2

        (dv1 + dv2).abs / 1000 # Convert to km/s
      end

      def calculate_transfer_duration(delta_v_kms, spacecraft_type)
        # Transfer time based on spacecraft propulsion and delta-V requirements
        propulsion_specs = {
          chemical: { exhaust_velocity: 3.5, thrust_to_weight: 0.05 },
          nuclear_thermal: { exhaust_velocity: 8.0, thrust_to_weight: 0.03 },
          ion_drive: { exhaust_velocity: 30.0, thrust_to_weight: 0.001 },
          nuclear_electric: { exhaust_velocity: 50.0, thrust_to_weight: 0.0005 }
        }

        spec = propulsion_specs[spacecraft_type] || propulsion_specs[:chemical]

        # Simplified rocket equation for transfer time
        # T = (m * Ve / F) * ln(m_full / m_empty)
        # For approximation, assume constant thrust and specific impulse

        # Convert delta-V to m/s
        delta_v = delta_v_kms * 1000

        # Specific impulse (seconds)
        isp = spec[:exhaust_velocity] / 9.81

        # Approximate transfer time (highly simplified)
        # Real calculations would use numerical integration
        base_transfer_days = case delta_v_kms
        when 0..5 then 100 + rand(50)  # Earth-Moon like
        when 5..10 then 200 + rand(100) # Earth-Venus/Mars
        when 10..15 then 300 + rand(150) # Venus-Mars
        else 400 + rand(200) # Deep space
        end

        # Adjust based on propulsion efficiency
        efficiency_factor = spec[:exhaust_velocity] / 3.5 # Chemical baseline
        adjusted_days = base_transfer_days / Math.sqrt(efficiency_factor)

        adjusted_days.round
      end

      def synodic_period(period1, period2)
        # Synodic period between two orbiting bodies
        (period1 * period2).abs / (period1 - period2).abs
      end

      def mean_anomaly(orbital_period_days, date)
        # Calculate mean anomaly at given date
        # This is a simplified calculation
        days_since_epoch = (date - Time.new(2024, 1, 1)) / (24 * 3600) # Convert seconds to days
        mean_motion = 2 * Math::PI / orbital_period_days
        (mean_motion * days_since_epoch) % (2 * Math::PI)
      end

      private

      def get_celestial_body_data(identifier)
        case identifier.to_s.downcase
        when 'earth'
          { name: :earth, period: ORBITAL_PERIODS[:earth], semi_major: SEMI_MAJOR_AXES[:earth] }
        when 'venus'
          { name: :venus, period: ORBITAL_PERIODS[:venus], semi_major: SEMI_MAJOR_AXES[:venus] }
        when 'mars'
          { name: :mars, period: ORBITAL_PERIODS[:mars], semi_major: SEMI_MAJOR_AXES[:mars] }
        when 'luna', 'moon'
          { name: :luna, period: ORBITAL_PERIODS[:luna], semi_major: SEMI_MAJOR_AXES[:luna] }
        else
          nil
        end
      end
    end
  end
end