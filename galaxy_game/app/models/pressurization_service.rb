# Generic pressurization service for any environment with atmospheric_data
class PressurizationService
  def initialize(environment)
    @environment = environment
    @atmosphere = environment.atmospheric_data
  end

  def pressurize
    # Ensure atmosphere exists
    ensure_atmosphere_exists!
    
    return if @atmosphere.stable?

    needed_gases = gas_requirements
    available = @atmosphere.available_gases

    needed_gases.each do |gas, amount_needed|
      if available[gas] && available[gas] > 0
        transfer_amount = [amount_needed, available[gas]].min
        available[gas] -= transfer_amount
        @atmosphere.composition[gas] ||= 0
        @atmosphere.composition[gas] += transfer_amount
      end
    end

    @atmosphere.pressure = calculate_new_pressure
    @atmosphere.save!
  end

  private

  def ensure_atmosphere_exists!
    return if @atmosphere.present?
    
    # Create atmosphere for airless environments
    @atmosphere = create_vacuum_atmosphere
    @environment.reload if @environment.persisted?
    @atmosphere = @environment.atmospheric_data
  end

  def create_vacuum_atmosphere
    case @environment
    when CelestialBodies::Features::BaseFeature
      Atmosphere.create!(
        structure: @environment,
        temperature: 293.15, # 20°C
        pressure: 0.0, # Vacuum
        environment_type: 'enclosed',
        total_atmospheric_mass: 0.0,
        composition: {},
        target_composition: default_target_composition,
        target_pressure: default_target_pressure
      )
    when Structures::BaseStructure, Settlement::SpaceStation
      Atmosphere.create!(
        structure: @environment,
        temperature: 293.15,
        pressure: 0.0,
        environment_type: 'enclosed',
        total_atmospheric_mass: 0.0,
        composition: {},
        target_composition: default_target_composition,
        target_pressure: default_target_pressure
      )
    end
  end

  def default_target_composition
    # Earth-like atmosphere: 78% N2, 21% O2, 1% Ar
    { 'N2' => 0.78, 'O2' => 0.21, 'Ar' => 0.01 }
  end

  def default_target_pressure
    101.325 # 1 atm in kPa
  end

  def gas_requirements
    target = @atmosphere.target_composition || default_target_composition
    current = @atmosphere.composition || {}
    target_pressure = @atmosphere.target_pressure || default_target_pressure
    current_pressure = @atmosphere.pressure || 0.0

    needed = {}
    target.each do |gas, ratio|
      target_amount = ratio * target_pressure
      current_amount = current[gas].to_f * current_pressure
      needed[gas] = [target_amount - current_amount, 0].max
    end
    needed
  end

  def calculate_new_pressure
    total_gas = @atmosphere.composition.values.sum
    target_composition = @atmosphere.target_composition || default_target_composition
    target_pressure = @atmosphere.target_pressure || default_target_pressure
    
    if target_composition.values.sum > 0
      total_gas / target_composition.values.sum * target_pressure
    else
      0.0
    end
  end
end
