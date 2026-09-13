# frozen_string_literal: true

# TransitEngine computes interplanetary transfer windows, departure/arrival tracking,
# and arrival-gate checks for the Luna precursor mission pipeline.
#
# This is a STATELESS computation service — it returns hashes, not ActiveRecords.
# State management (which crafts are in transit) is the responsibility of the caller
# (rake tasks or AIManager services). Craft inherit from ApplicationRecord, NOT
# Units::BaseUnit, so they are NOT ticked by Game#process_units.
#
# === Orbital Data Epoch Reference ===
# All mean_anomaly values in sol.json / sol-complete.json use J2000.0 epoch:
#   J2000.0 = 2000-01-01T12:00:00 TT (Terrestrial Time)
#   Julian Date 2451545.0
#
# When computing phase angles for launch windows, TransitEngine accounts for the
# time delta between J2000.0 and the current simulation date, propagating mean_anomaly
# forward using Kepler's equation:
#   M(t) = M_0 + n * (t - t_0)
# where n = 360.0 / orbital_period_days (mean motion in degrees/day)
#
# Reference frame convention:
#   - Planets (Earth, Venus, Mars, Jupiter): heliocentric (semi_major_axis from Sol)
#   - Moons (Luna, Titan): parent-centric (semi_major_axis from parent body)
#   - NEVER mix the two — Luna's semi_major_axis is 384_400_000 m (Earth-Moon), NOT
#     its heliocentric distance (~149_600_000_000 m). A prior bug pasted Mars's values
#     into Luna's entry; see sol.json line 510 fix commit.
class Mission::TransitEngine

  # J2000.0 epoch constant (Terrestrial Time)
  J2000_EPOCH = Time.utc(2000, 1, 1, 12, 0, 0).freeze
  J2000_JULIAN_DAY = 2_451_545.0

  # Gravitational parameter of Sol (km^3/s^2) — used for delta-v calculations
  MU_SUN = 1.32712440018e11 # km^3/s^2

  # ---------------------------------------------------------------------------
  # Public API — transfer window calculation
  # ---------------------------------------------------------------------------

  ##
  # Calculate the next transfer window from one body to another using real orbital data.
  #
  # Reads orbital_elements from CelestialBody records (populated by known data, StarSim,
  # or survey discovery) and computes phase angles, delta-v, and transit duration dynamically.
  #
  # @param from_body [String] departure body identifier (e.g., "EARTH-01", "LUNA-01")
  # @param to_body   [String] arrival body identifier (e.g., "VENUS-01", "LUNA-01")
  # @param launch_date [Date, nil] launch date; defaults to today
  # @return [Hash] { departure_date: Date, arrival_date: Date, transit_days: Integer,
  #                  phase_angle_deg: Float, delta_v_km_s: Float, synodic_period_days: Float }
  def self.calculate_transfer_window(from_body, to_body, launch_date = nil)
    launch_date ||= Time.current.to_date

    from_orbitals = orbital_data(from_body)
    to_orbitals   = orbital_data(to_body)

    # Fall back to hardcoded baselines if orbital data is unavailable (unknown/surveyed bodies)
    if from_orbitals.nil? || to_orbitals.nil?
      return fallback_transfer_window(from_body, to_body, launch_date)
    end

    transit_days = compute_transit_days_dynamic(from_orbitals, to_orbitals, launch_date)
    phase_angle  = compute_phase_angle(from_orbitals, to_orbitals, launch_date)
    delta_v      = compute_hohmann_delta_v(from_orbitals, to_orbitals)
    synodic      = compute_synodic_period(from_orbitals, to_orbitals)

    {
      departure_date:     launch_date,
      arrival_date:       launch_date + transit_days,
      transit_days:       transit_days,
      phase_angle_deg:    phase_angle.round(2),
      delta_v_km_s:       delta_v.round(3),
      synodic_period_days: synodic.round(1)
    }
  end

  # ---------------------------------------------------------------------------
  # Transfer window availability (real version — checks synodic periods)
  # ---------------------------------------------------------------------------

  ##
  # Check if a transfer window is open between two bodies on a given date.
  #
  # Uses phase angle to determine if the bodies are in a favorable alignment
  # for Hohmann transfer (phase angle within ±15° of optimal).
  #
  # @param from_body [String]
  # @param to_body   [String]
  # @param date      [Date]
  # @return [Boolean] true if phase angle is within acceptable window
  def self.transfer_window_open?(from_body, to_body, date)
    from_orbitals = orbital_data(from_body)
    to_orbitals   = orbital_data(to_body)

    return true if from_orbitals.nil? || to_orbitals.nil? # Unknown bodies — assume open

    phase_angle = compute_phase_angle(from_orbitals, to_orbitals, date)
    optimal     = compute_optimal_phase_angle(from_orbitals, to_orbitals)

    # Window is open if phase angle is within ±15° of optimal
    (phase_angle - optimal).abs <= 15.0
  end

  # ---------------------------------------------------------------------------
  # Departure scheduling
  # ---------------------------------------------------------------------------

  ##
  # Schedule a craft departure and return a transit record.
  #
  # @param craft_id   [String] unique identifier for the craft
  # @param from_body  [String] departure body
  # @param to_body    [String] arrival body
  # @param launch_date [Date, nil] launch date
  # @return [Hash] transit record with status, dates, and payload slot
  def self.schedule_departure(craft_id, from_body, to_body, launch_date = nil)
    window = calculate_transfer_window(from_body, to_body, launch_date)

    {
      craft_id:       craft_id,
      status:         :in_transit,
      from_body:      from_body,
      to_body:        to_body,
      departure_date: window[:departure_date],
      arrival_date:   window[:arrival_date],
      transit_days:   window[:transit_days],
      phase_angle:    window[:phase_angle_deg],
      delta_v_km_s:   window[:delta_v_km_s],
      payload:        nil # Set when manifest is loaded
    }
  end

  # ---------------------------------------------------------------------------
  # Arrival checking
  # ---------------------------------------------------------------------------

  ##
  # Check if a craft has arrived given the current simulation day offset.
  #
  # @param transit_record [Hash] record returned by schedule_departure
  # @param sim_day        [Integer] number of days from launch in the simulation
  # @return [Boolean] true if sim_day >= transit_days
  def self.has_arrived?(transit_record, sim_day)
    sim_day >= transit_record[:transit_days]
  end

  ##
  # Days remaining until a craft arrives from the current simulation day.
  #
  # @param transit_record [Hash] record returned by schedule_departure
  # @param sim_day        [Integer] number of days from launch in the simulation
  # @return [Integer] positive = days remaining, negative = days overdue
  def self.days_remaining(transit_record, sim_day)
    transit_record[:transit_days] - sim_day
  end

  # ---------------------------------------------------------------------------
  # Offload gate checks
  # ---------------------------------------------------------------------------

  ##
  # Check if N₂ offload can proceed given infrastructure readiness.
  #
  # @param tank_farm_ready      [Boolean] whether inflatable tanks are deployed
  # @param tank_count           [Integer] number of deployed cryo tanks
  # @param minimum_required     [Integer] minimum tanks needed for offload
  # @return [Hash] { allowed: Boolean, reason: String }
  def self.can_offload_n2?(tank_farm_ready:, tank_count: 0, minimum_required: 3)
    if !tank_farm_ready
      return { allowed: false, reason: "Tank farm infrastructure not complete" }
    end

    if tank_count < minimum_required
      return { allowed: false, reason: "Insufficient tanks deployed (#{tank_count} < #{minimum_required})" }
    end

    { allowed: true, reason: "All offload requirements met" }
  end

  # ---------------------------------------------------------------------------
  # Orbital data lookup (reads from CelestialBody records)
  # ---------------------------------------------------------------------------

  ##
  # Look up orbital_elements for a body by identifier.
  #
  # Returns the raw hash from the CelestialBody's JSONB column, or nil if not found.
  # This is the single source of truth — never recompute orbital parameters here.
  #
  # @param body_identifier [String] e.g., "EARTH-01", "LUNA-01"
  # @return [Hash, nil] { semi_major_axis: Float, eccentricity: Float, inclination: Float, mean_anomaly: Float }
  def self.orbital_data(body_identifier)
    body = CelestialBodies::CelestialBody.find_by(identifier: body_identifier.to_s.upcase)
    return nil unless body

    orbitals = body.orbital_elements
    return nil if orbitals.nil? || orbitals.empty?

    # Normalize keys to snake_case for consistency
    orbitals.transform_keys { |k| k.to_s.gsub(/([A-Z]+)/) { |_| "_\1" }.downcase }
  end

  # ---------------------------------------------------------------------------
  # Phase angle computation (J2000.0 epoch propagation)
  # ---------------------------------------------------------------------------

  ##
  # Compute the current phase angle between two bodies at a given date.
  #
  # Propagates mean_anomaly from J2000.0 epoch forward to the target date using:
  #   M(t) = M_0 + n * (t - t_0)
  # where n = 360.0 / orbital_period_days (mean motion in degrees/day)
  #
  # @param from_orbitals [Hash] orbital_elements for departure body
  # @param to_orbitals   [Hash] orbital_elements for arrival body
  # @param date          [Date] the date to compute phase angle at
  # @return [Float] phase angle in degrees (0-360)
  def self.compute_phase_angle(from_orbitals, to_orbitals, date)
    from_m = propagated_mean_anomaly(from_orbitals, date)
    to_m   = propagated_mean_anomaly(to_orbitals, date)

    # Phase angle is the difference in mean anomaly (simplified — assumes coplanar orbits)
    angle = (to_m - from_m).modulo(360.0)
    angle
  end

  ##
  # Propagate mean_anomaly from J2000.0 epoch to a target date.
  #
  # @param orbitals [Hash] orbital_elements with :mean_anomaly and :orbital_period_days
  # @param date     [Date] target date
  # @return [Float] propagated mean anomaly in degrees (0-360)
  def self.propagated_mean_anomaly(orbitals, date)
    m_0 = orbitals[:mean_anomaly].to_f
    period_days = orbitals[:orbital_period_days].to_f

    return m_0 if period_days.zero? # Guard against zero-period bodies

    days_since_j2000 = (date.to_date - J2000_EPOCH.to_date).to_i
    mean_motion = 360.0 / period_days # degrees per day

    ((m_0 + mean_motion * days_since_j2000) % 360.0)
  end

  ##
  # Compute the optimal phase angle for a Hohmann transfer.
  #
  # NOTE: Eccentricity is NOT factored in — all orbits are approximated as circular.
  # The orbital_elements hash includes an eccentricity field, but it is currently
  # unused by TransitEngine's calculations. Adding eccentricity-aware math would
  # require true anomaly computation (solving Kepler's equation for E given M),
  # then converting to true anomaly ν via tan(ν/2) = sqrt((1+e)/(1-e)) * tan(E/2).
  #
  # For an outer-to-inner transfer (e.g., Earth→Venus):
  #   φ_optimal = 180° - (transfer_angle)
  # For an inner-to-outer transfer (e.g., Venus→Earth):
  #   φ_optimal = transfer_angle - 180°
  #
  # @param from_orbitals [Hash] departure body orbitals
  # @param to_orbitals   [Hash] arrival body orbitals
  # @return [Float] optimal phase angle in degrees
  def self.compute_optimal_phase_angle(from_orbitals, to_orbitals)
    a_from = orbit_radius_km(from_orbitals)
    a_to   = orbit_radius_km(to_orbitals)

    return 0.0 if a_from.zero? || a_to.zero?

    # Hohmann transfer half-angle: θ = arccos(sqrt(a_from / (a_from + a_to)))
    ratio = a_from.to_f / (a_from + a_to).to_f
    theta_rad = Math.acos(ratio.clamp(0.0, 1.0))

    # Convert to degrees and compute optimal phase angle
    theta_deg = theta_rad * (180.0 / Math::PI)

    if a_to > a_from
      # Inner → outer: target body must lead by theta_deg
      theta_deg
    else
      # Outer → inner: target body must trail by (180 - theta_deg)
      180.0 - theta_deg
    end
  end

  # ---------------------------------------------------------------------------
  # Delta-v computation (Hohmann transfer)
  # ---------------------------------------------------------------------------

  ##
  # Compute the delta-v required for a Hohmann transfer between two circular orbits.
  #
  # Uses the standard two-impulse Hohmann formula:
  #   Δv₁ = sqrt(μ/r₁) * (sqrt(2*r₂/(r₁+r₂)) - 1)
  #   Δv₂ = sqrt(μ/r₂) * (1 - sqrt(2*r₁/(r₁+r₂)))
  #   Δv_total = |Δv₁| + |Δv₂|
  #
  # @param from_orbitals [Hash] departure body orbitals (semi_major_axis in meters)
  # @param to_orbitals   [Hash] arrival body orbitals (semi_major_axis in meters)
  # @return [Float] total delta-v in km/s
  def self.compute_hohmann_delta_v(from_orbitals, to_orbitals)
    r1 = orbit_radius_km(from_orbitals)
    r2 = orbit_radius_km(to_orbitals)

    return 0.0 if r1.zero? || r2.zero?

    # Convert semi_major_axis from meters to km for delta-v calculation
    r1_km = r1 / 1000.0
    r2_km = r2 / 1000.0

    # For heliocentric transfers (planets), use Sol's gravitational parameter
    mu = MU_SUN

    # First impulse: leave initial orbit
    v1 = Math.sqrt(mu / r1_km)
    v_transfer_peri = v1 * Math.sqrt((2.0 * r2_km) / (r1_km + r2_km))
    dv1 = (v_transfer_peri - v1).abs

    # Second impulse: circularize at target orbit
    v2 = Math.sqrt(mu / r2_km)
    v_transfer_apo = v2 * Math.sqrt((2.0 * r1_km) / (r1_km + r2_km))
    dv2 = (v2 - v_transfer_apo).abs

    (dv1 + dv2)
  end

  ##
  # Compute the synodic period between two bodies.
  #
  # The synodic period is the time between successive optimal transfer windows.
  #   P_synodic = |P₁ * P₂| / |P₂ - P₁|
  #
  # @param from_orbitals [Hash] departure body orbitals
  # @param to_orbitals   [Hash] arrival body orbitals
  # @return [Float] synodic period in days
  def self.compute_synodic_period(from_orbitals, to_orbitals)
    p1 = from_orbitals[:orbital_period_days].to_f
    p2 = to_orbitals[:orbital_period_days].to_f

    return Float::INFINITY if p1.zero? || p2.zero?

    (p1 * p2).abs / (p2 - p1).abs
  end

  # ---------------------------------------------------------------------------
  # Dynamic transit day computation (replaces hardcoded constants)
  # ---------------------------------------------------------------------------

  ##
  # Compute transit days dynamically from orbital data.
  #
  # Uses Hohmann transfer time: t = π * sqrt((r₁ + r₂)³ / (8μ))
  # Returns the transfer half-period in days.
  #
  # @param from_orbitals [Hash] departure body orbitals
  # @param to_orbitals   [Hash] arrival body orbitals
  # @param launch_date   [Date] launch date (for phase angle check)
  # @return [Integer] transit duration in days (rounded up)
  def self.compute_transit_days_dynamic(from_orbitals, to_orbitals, launch_date)
    r1 = orbit_radius_km(from_orbitals)
    r2 = orbit_radius_km(to_orbitals)

    return fallback_transit_days(from_orbitals, to_orbitals) if r1.zero? || r2.zero?

    # Hohmann transfer half-period: t = π * sqrt((r₁ + r₂)³ / (8μ))
    # Result is in seconds; convert to days
    mu_km3s2 = MU_SUN
    semi_major_sum = (r1 + r2) / 2.0 # km

    transfer_seconds = Math::PI * Math.sqrt((semi_major_sum**3) / (8.0 * mu_km3s2))
    transfer_days = transfer_seconds / (24.0 * 3600.0)

    # Check if phase angle is favorable; if not, add synodic wait time
    phase_angle = compute_phase_angle(from_orbitals, to_orbitals, launch_date)
    optimal     = compute_optimal_phase_angle(from_orbitals, to_orbitals)
    phase_diff  = (phase_angle - optimal).abs

    if phase_diff > 15.0
      synodic = compute_synodic_period(from_orbitals, to_orbitals)
      # Estimate wait time as fraction of synodic period proportional to phase error
      wait_fraction = phase_diff / 180.0
      transfer_days += (synodic * wait_fraction).to_i
    end

    transfer_days.ceil
  end

  ##
  # Fallback: use hardcoded baselines when orbital data is unavailable.
  #
  # @param from_orbitals [Hash] departure body orbitals (may be nil)
  # @param to_orbitals   [Hash] arrival body orbitals (may be nil)
  # @return [Integer] transit duration in days
  def self.fallback_transit_days(from_orbitals, to_orbitals)
    # If we have at least one body's orbital data, use it for a rough estimate
    if from_orbitals && to_orbitals
      r1 = orbit_radius_km(from_orbitals)
      r2 = orbit_radius_km(to_orbitals)
      return 0 if r1.zero? && r2.zero?

      mu_km3s2 = MU_SUN
      semi_major_sum = (r1 + r2) / 2.0
      transfer_seconds = Math::PI * Math.sqrt((semi_major_sum**3) / (8.0 * mu_km3s2))
      return [transfer_seconds / (24.0 * 3600.0)].ceil
    end

    # Ultimate fallback: hardcoded baselines for unknown bodies
    365
  end

  ##
  # Fallback transfer window when orbital data is unavailable.
  #
  # @param from_body [String] departure body identifier
  # @param to_body   [String] arrival body identifier
  # @param launch_date [Date] launch date
  # @return [Hash] transfer window with fallback values
  def self.fallback_transfer_window(from_body, to_body, launch_date)
    Rails.logger.warn("[TransitEngine] Orbital data unavailable for #{from_body} or #{to_body} — using fallback transit-days estimate, not real phase-angle calculation")
    transit_days = compute_transit_days(from_body, to_body)

    {
      departure_date:     launch_date,
      arrival_date:       launch_date + transit_days,
      transit_days:       transit_days,
      phase_angle_deg:    nil,
      delta_v_km_s:       nil,
      synodic_period_days: nil
    }
  end

  # ---------------------------------------------------------------------------
  # Legacy hardcoded constants (kept for backward compatibility)
  # ---------------------------------------------------------------------------

  def self.earth_to_venus_transit_days; 146; end
  def self.earth_to_luna_transit_days; 7; end
  def self.earth_to_titan_transit_days; 1388; end
  def self.earth_to_mars_transit_days; 259; end
  def self.luna_to_earth_transit_days; earth_to_luna_transit_days; end
  def self.luna_to_venus_transit_days; earth_to_venus_transit_days; end
  def self.luna_to_titan_transit_days; earth_to_titan_transit_days; end
  def self.luna_to_mars_transit_days; earth_to_mars_transit_days; end

  # ---------------------------------------------------------------------------
  # Legacy transit day computation (kept for backward compatibility)
  # ---------------------------------------------------------------------------

  ##
  # Compute transit days using hardcoded baselines.
  # Kept for backward compatibility — prefer compute_transit_days_dynamic.
  #
  # @param from_body [String]
  # @param to_body   [String]
  # @return [Integer] transit duration in days
  def self.compute_transit_days(from_body, to_body)
    from_key = from_body.to_s.upcase.gsub(/[-\d]+/, '')
    to_key   = to_body.to_s.upcase.gsub(/[-\d]+/, '')
    key = "#{from_key}_#{to_key}"

    case key
    when "EARTH_LUNA", "LUNA_EARTH"
      earth_to_luna_transit_days
    when "EARTH_VENUS", "LUNA_VENUS"
      earth_to_venus_transit_days
    when "EARTH_TITAN", "LUNA_TITAN"
      earth_to_titan_transit_days
    when "EARTH_MARS", "LUNA_MARS"
      earth_to_mars_transit_days
    else
      365
    end
  end

  # ---------------------------------------------------------------------------
  # Internal helpers
  # ---------------------------------------------------------------------------

  ##
  # Convert semi_major_axis from meters to km.
  #
  # @param orbitals [Hash] orbital_elements with :semi_major_axis in meters
  # @return [Float] radius in km, or 0 if unavailable
  def self.orbit_radius_km(orbitals)
    return 0.0 if orbitals.nil?

    sma = orbitals[:semi_major_axis].to_f
    return 0.0 if sma.zero?

    # semi_major_axis is stored in meters; convert to km
    sma / 1000.0
  end
end
