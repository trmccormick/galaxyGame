# app/models/concerns/cryptocurrency_mining.rb
module CryptocurrencyMining
  extend ActiveSupport::Concern

  included do
    has_many :base_units, as: :attachable
  end

  # Method to mine cryptocurrency using computer units
  def mine_gcc
    return 0 unless can_mine_gcc?
    
    # Check power availability
    if respond_to?(:has_sufficient_power?) && !has_sufficient_power?
      Rails.logger.warn("#{self.class.name} ##{id}: Insufficient power for mining operation")
      
      # Try to use battery if available
      if respond_to?(:battery_level) && battery_level > 0
        power_needed = power_required_for_mining
        if battery_level >= power_needed
          # We can use battery power
          consume_battery(power_needed)
        else
          # Not enough battery power
          return 0
        end
      else
        # No battery or insufficient charge
        return 0
      end
    end
    
    # Track total mined amount
    total_mined = 0

    # Use all computer units for mining with enhanced efficiency
    mining_units.each do |unit|
      # Calculate mining output for this unit with satellite-level effects
      base_amount = unit.mine(mining_difficulty, unit_efficiency)
      
      # Apply satellite-level effects
      enhanced_amount = apply_mining_effects(base_amount)
      total_mined += enhanced_amount
    end
    
    # Account the power used
    if respond_to?(:consume_energy)
      consume_energy(power_required_for_mining)
    end
    
    # Add the mined amount to the account
    if total_mined > 0 && respond_to?(:account) && account.present?
      account.deposit(total_mined, "GCC Mining Operation")
      if respond_to?(:funds)
        self.funds += total_mined
        save! if respond_to?(:save!)
      end
      
      # Create mining log if the model supports it
      create_mining_log(total_mined) if respond_to?(:create_mining_log)
      
      # Or create it manually:
      if defined?(MiningLog)
        owner_type_value = self.class.base_class.name || self.class.table_name.classify
        MiningLog.create!(
          owner_type: owner_type_value,
          owner_id: self.id,
          amount_mined: total_mined,  # ✅ Fixed column name
          currency: 'GCC',
          mined_at: Time.current,     # ✅ Fixed column name
          operational_details: {
            power_used: power_required_for_mining,
            power_generation: respond_to?(:power_generation) ? power_generation : 0,
            power_usage: respond_to?(:power_usage) ? power_usage : 0,
            efficiency_factors: {
              thermal: calculate_thermal_efficiency_boost,
              processing: calculate_processing_boost
            },
            mining_units_count: mining_units.count,
            base_mining_rate: mining_units.sum { |u| u.mine(1.0, 1.0) },
            thermal_boost_kw: respond_to?(:operational_data) ? operational_data&.dig('thermal_effects', 'heat_dissipation_kw') || 0 : 0,
            processing_multiplier: respond_to?(:operational_data) ? operational_data&.dig('processing_effects', 'boost_multiplier') || 1.0 : 1.0,
            direct_boost_gcc: respond_to?(:operational_data) ? operational_data&.dig('mining_effects', 'boost_gcc_per_hour') || 0 : 0
          }
        )
      end
    end

    total_mined
  end

  # Apply satellite-level mining effects from modules and rigs
  def apply_mining_effects(base_amount)
    enhanced_amount = base_amount
    
    # Apply thermal efficiency boost (from radiator modules)
    thermal_multiplier = calculate_thermal_efficiency_boost
    enhanced_amount *= thermal_multiplier
    
    # Apply processing boost (from GPU rigs)
    processing_multiplier = calculate_processing_boost
    enhanced_amount *= processing_multiplier
    
    # Apply direct mining boost (from specialized rigs)
    direct_boost = calculate_direct_mining_boost
    enhanced_amount += direct_boost
    
    enhanced_amount
  end

  # Calculate thermal efficiency boost from cooling modules
  def calculate_thermal_efficiency_boost
    return 1.0 unless respond_to?(:operational_data) && operational_data
    
    # Check for thermal effects from radiator modules
    heat_dissipation = operational_data.dig('thermal_effects', 'heat_dissipation_kw').to_f
    if heat_dissipation > 0
      # 2% efficiency boost per 10kW of heat dissipation
      boost = 1.0 + (heat_dissipation / 10.0) * 0.02
      Rails.logger.info("Thermal boost applied: #{((boost - 1) * 100).round(1)}% from #{heat_dissipation}kW cooling")
      return boost
    end
    
    # Alternative: check active module effects
    if operational_data['active_module_effects']
      thermal_effects = operational_data['active_module_effects'].select do |effect|
        effect['effects']&.any? { |e| e['type'] == 'thermal_management' }
      end
      
      unless thermal_effects.empty?
        total_heat_dissipation = thermal_effects.sum do |effect|
          effect['effects']
            .select { |e| e['type'] == 'thermal_management' }
            .sum { |e| e['heat_dissipation_kw'].to_f }
        end
        
        if total_heat_dissipation > 0
          boost = 1.0 + (total_heat_dissipation / 10.0) * 0.02
          Rails.logger.info("Thermal boost from modules: #{((boost - 1) * 100).round(1)}%")
          return boost
        end
      end
    end
    
    1.0 # No thermal boost
  end

  # Calculate processing boost from GPU rigs
  def calculate_processing_boost
    return 1.0 unless respond_to?(:operational_data) && operational_data
    
    # Check processing effects
    boost_multiplier = operational_data.dig('processing_effects', 'boost_multiplier').to_f
    if boost_multiplier > 1.0
      Rails.logger.info("Processing boost applied: #{((boost_multiplier - 1) * 100).round(1)}%")
      return boost_multiplier
    end
    
    # Alternative: check active rig effects
    if operational_data['active_rig_effects']
      processing_effects = operational_data['active_rig_effects'].select do |effect|
        effect['effects']&.any? { |e| e['type'] == 'processing_boost' }
      end
      
      unless processing_effects.empty?
        total_multiplier = processing_effects.inject(1.0) do |multiplier, effect|
          effect_multiplier = effect['effects']
            .select { |e| e['type'] == 'processing_boost' }
            .map { |e| e['boost_multiplier'].to_f }
            .first || 1.0
          multiplier * effect_multiplier
        end
        
        if total_multiplier > 1.0
          Rails.logger.info("Processing boost from rigs: #{((total_multiplier - 1) * 100).round(1)}%")
          return total_multiplier
        end
      end
    end
    
    1.0 # No processing boost
  end

  # Calculate direct mining boost from specialized rigs
  def calculate_direct_mining_boost
    return 0.0 unless respond_to?(:operational_data) && operational_data
    
    # Check direct mining effects
    direct_boost = operational_data.dig('mining_effects', 'boost_gcc_per_hour').to_f
    if direct_boost > 0
      # Convert hourly rate to test period rate (assuming 0.18 multiplier)
      test_period_boost = direct_boost * 0.18
      Rails.logger.info("Direct mining boost: +#{test_period_boost.round(1)} GCC")
      return test_period_boost
    end
    
    # Alternative: check active rig effects
    if operational_data['active_rig_effects']
      mining_effects = operational_data['active_rig_effects'].select do |effect|
        effect['effects']&.any? { |e| e['type'] == 'mining_boost' }
      end
      
      unless mining_effects.empty?
        total_boost = mining_effects.sum do |effect|
          effect['effects']
            .select { |e| e['type'] == 'mining_boost' }
            .sum { |e| e['boost_gcc_per_hour'].to_f }
        end
        
        if total_boost > 0
          test_period_boost = total_boost * 0.18
          Rails.logger.info("Direct mining boost from rigs: +#{test_period_boost.round(1)} GCC")
          return test_period_boost
        end
      end
    end
    
    0.0 # No direct boost
  end

  # Enhanced unit efficiency that includes satellite-level modifiers
  def unit_efficiency
    base_efficiency = 1.0
    
    # Could add satellite-level efficiency modifiers here
    # For now, individual unit effects are handled in apply_mining_effects
    
    base_efficiency
  end

  # Get all units that can mine
  def mining_units
    # Check if we have base_units relation
    return [] unless respond_to?(:base_units)
    
    # Get computers from base_units and wrap them in adapters
    base_units.select do |unit| 
      unit.is_a?(Units::Computer) || 
      (unit.respond_to?(:unit_type) && unit.unit_type.to_s.include?('computer'))
    end.map do |unit|
      # Wrap each unit in a mining adapter
      MiningUnitAdapter.new(unit)
    end
  end

  # Determine if entity can mine GCC
  def can_mine_gcc?
    # Must have an account and at least one mining unit
    (respond_to?(:account) && account.present?) && mining_units.any?
  end

  # Get the mining difficulty (can be overridden by subclasses)
  def mining_difficulty
    # Default mining difficulty, can be customized in subclasses
    1.0
  end

  # Helper method to calculate power needed for mining
  def power_required_for_mining
    # Base power requirement
    base_requirement = 35.0 # kW
    
    # Add power requirements for each mining unit
    mining_units.sum do |unit|
      unit_requirement = if unit.respond_to?(:power_usage)
                          unit.power_usage
                        else
                          wrapped_unit = unit.instance_variable_get(:@unit)
                          if wrapped_unit.respond_to?(:operational_data)
                            wrapped_unit.operational_data&.dig('operational_properties', 'power_consumption_kw') || 0
                          else
                            0
                          end
                        end
      unit_requirement
    end + base_requirement
  end

  private

  # Create a mining log entry if the model has a mining_logs association
  def create_mining_log(amount)
    return unless respond_to?(:mining_logs)
    
    mining_logs.create!(
      amount: amount,
      timestamp: Time.current,
      success: true
    )
  end

  # Inner class to adapt any unit to the mining interface
  class MiningUnitAdapter
    def initialize(unit)
      @unit = unit
    end
    
    def mine(difficulty, efficiency_multiplier)
      # For Computer units, use their native mining method
      if @unit.respond_to?(:mining_rate_value)
        base_rate = @unit.mining_rate_value
      else
        # For other computer-like units, calculate based on operational data
        base_rate = extract_mining_rate || 45.0  # Better default for advanced_computer
      end
      
      base_rate * difficulty * efficiency_multiplier
    end
    
    private
    
    def extract_mining_rate
      # Extract mining rate from operational data using various possible paths
      return 45.0 unless @unit.respond_to?(:operational_data)
      
      @unit.operational_data&.dig('mining', 'base_rate_gcc_per_hour') || 
      @unit.operational_data&.dig('operational_properties', 'base_mining_rate_gcc_per_hour') ||
      @unit.operational_data&.dig('performance', 'mining_power') ||
      @unit.operational_data&.dig('mining', 'gcc_per_hour') || 45.0  # Default for advanced_computer
    end
  end
end