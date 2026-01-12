# app/services/photochemical_reaction_service.rb
# Simulates atmospheric photochemical reactions
# Including methane oxidation, ozone formation, etc.

class PhotochemicalReactionService
  def initialize(celestial_body)
    @celestial_body = celestial_body
  end
  
  def simulate(days_elapsed)
    return unless @celestial_body.atmosphere
    
    # Apply various photochemical processes
    oxidize_methane(days_elapsed)
    # Could add more in the future:
    # form_ozone(days_elapsed)
    # break_down_ammonia(days_elapsed)
  end
  
  private
  
  def oxidize_methane(time_step_days)
    atm = @celestial_body.atmosphere
    
    # CH4 + 2O2 → CO2 + 2H2O (photochemical oxidation)
    # This happens via hydroxyl radicals (OH) in the presence of UV
    
    ch4_gas = atm.gases.find_by(name: 'CH4')
    return unless ch4_gas && ch4_gas.mass > 0
    
    o2_gas = atm.gases.find_by(name: 'O2')
    return unless o2_gas && o2_gas.mass > 0 # Need O2 for oxidation
    
    # Methane atmospheric lifetime depends on:
    # 1. O2 concentration (more O2 → faster oxidation)
    # 2. UV flux (stellar constant)
    # 3. Temperature (higher temp → faster reactions)
    
    total_atm_mass = atm.total_atmospheric_mass
    o2_fraction = o2_gas.mass / total_atm_mass
    
    # Base reaction rate from game constants
    # GameConstants::ATMOSPHERE_SIMULATION[:base_reaction_rate] = 0.002 (0.2% per day at Earth-like)
    base_rate = GameConstants::ATMOSPHERE_SIMULATION[:base_reaction_rate]
    min_rate = GameConstants::ATMOSPHERE_SIMULATION[:reaction_rate_min]
    max_rate = GameConstants::ATMOSPHERE_SIMULATION[:reaction_rate_max]
    
    # Scale reaction rate by O2 availability (linear approximation)
    # At 21% O2: full Earth rate (0.002/day)
    # At 10% O2: half rate
    # At 5% O2: quarter rate
    earth_o2_fraction = 0.21
    if o2_fraction > 0.001
      o2_scaling = o2_fraction / earth_o2_fraction
      reaction_rate = base_rate * o2_scaling
    else
      # Very slow oxidation without O2
      reaction_rate = min_rate
    end
    
    # UV flux factor (stronger sun → faster breakdown)
    solar_constant = @celestial_body.solar_constant || GameConstants::ATMOSPHERE_SIMULATION[:solar_flux_reference]
    earth_solar_constant = GameConstants::ATMOSPHERE_SIMULATION[:solar_flux_reference]
    uv_factor = solar_constant / earth_solar_constant
    reaction_rate *= uv_factor
    
    # Temperature factor (higher temp → faster reactions)
    # Use Arrhenius-like scaling
    temp = atm.temperature || GameConstants::DEFAULT_TEMPERATURE  # FIXED: use .temperature not .temperature_kelvin
    earth_temp = GameConstants::DEFAULT_TEMPERATURE # 288.15 K
    temp_factor = Math.exp(0.05 * (temp - earth_temp) / earth_temp) # ~5% increase per 14K
    reaction_rate *= temp_factor
    
    # Clamp reaction rate to game constants bounds
    reaction_rate = reaction_rate.clamp(min_rate, max_rate)
    
    # Amount of CH4 to oxidize this time step (simple linear decay)
    ch4_to_oxidize = ch4_gas.mass * reaction_rate * time_step_days
    
    # Check if we have enough O2 for stoichiometry
    # CH4 (16 g/mol) + 2 O2 (32 g/mol each = 64 g/mol total)
    o2_needed = ch4_to_oxidize * (64.0 / 16.0) # 4x CH4 mass
    
    if o2_gas.mass < o2_needed
      # O2-limited: can only oxidize what O2 allows
      ch4_to_oxidize = o2_gas.mass * (16.0 / 64.0) # 0.25x O2 mass
      o2_to_consume = o2_gas.mass
    else
      # CH4-limited: normal decay
      o2_to_consume = o2_needed
    end
    
    return if ch4_to_oxidize <= 0
    
    # Remove reactants
    atm.remove_gas('CH4', ch4_to_oxidize)
    atm.remove_gas('O2', o2_to_consume)
    
    # Add products
    # CH4 (16) + 2O2 (64) → CO2 (44) + 2H2O (36)
    co2_produced = ch4_to_oxidize * (44.0 / 16.0) # 2.75x CH4 mass
    h2o_produced = ch4_to_oxidize * (36.0 / 16.0) # 2.25x CH4 mass
    
    atm.add_gas('CO2', co2_produced)
    
    # Add water to hydrosphere if possible
    if @celestial_body.hydrosphere&.respond_to?(:add_liquid)
      @celestial_body.hydrosphere.add_liquid('H2O', h2o_produced)
    end
    
    # Log significant reactions (> 1 Tt per time step)
    if ch4_to_oxidize > 1.0e12
      Rails.logger.info "[PhotochemicalReaction] #{@celestial_body.name}: Oxidized #{(ch4_to_oxidize / 1.0e12).round(2)} Tt CH4"
      Rails.logger.info "  → Produced #{(co2_produced / 1.0e12).round(2)} Tt CO2, #{(h2o_produced / 1.0e12).round(2)} Tt H2O"
      Rails.logger.info "  Reaction rate: #{(reaction_rate * 100).round(4)}% per day"
    end
    
    # Update atmospheric pressure after changes
    atm.update_pressure_from_mass! if atm.respond_to?(:update_pressure_from_mass!)
  end
end