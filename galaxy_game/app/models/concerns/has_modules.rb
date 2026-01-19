# app/models/concerns/has_modules.rb
module HasModules
  extend ActiveSupport::Concern

  included do
    has_many :base_modules, class_name: 'Modules::BaseModule', as: :attachable, dependent: :destroy
    alias_method :modules, :base_modules
  end

  def add_module(module_type, location: :internal)
    module_data = Lookup::ModuleLookupService.new.find_module(module_type.to_s)

    unless module_data
      errors.add(:base, "Invalid module type or data not found.")
      return "Invalid module type or data not found."
    end

    # Use the existing method without arguments (like the satellite model expects)
    max_modules = available_module_ports
    if max_modules.present? && base_modules.count >= max_modules.to_i
      errors.add(:base, "Max modules reached for this craft (#{max_modules}).")
      return "Max modules reached for this craft (#{max_modules})"
    end

    module_obj = Modules::BaseModule.new(
      identifier: "#{module_type}_#{SecureRandom.hex(4)}",
      name: module_data['name'] || module_type.humanize,
      module_type: module_type,
      operational_data: module_data,
      attachable: self
    )

    if module_obj.save
      apply_module_effects(module_obj)
      return module_obj
    else
      errors.add(:base, "Failed to create and attach module: #{module_obj.errors.full_messages.to_sentence}")
      return nil
    end
  end

  def remove_module(module_type, location: :internal)
    module_obj = base_modules.find_by(module_type: module_type)
    return "Module not found" unless module_obj

    begin
      revert_module_effects(module_obj)
      module_obj.destroy
      return module_obj.destroyed? ? "Module removed" : "Failed to remove module"
    rescue => e
      Rails.logger.error "Error removing module #{module_obj.id}: #{e.message}"
      return "Error removing module: #{e.message}"
    end
  end

  # New method that works with database records
  def apply_module_effects(module_obj)
    return false unless module_obj&.operational_data

    module_effects = module_obj.operational_data.dig('effects') || []
    
    module_effects.each do |effect|
      case effect['type']
      when 'thermal_management'
        apply_thermal_management_effect(effect)
      when 'efficiency_boost'
        apply_efficiency_boost(effect['target_system'], effect['value'])
      when 'power_consumption_reduction'
        apply_power_consumption_reduction(effect['value'])
      end
    end

    # Track applied effects in operational_data
    self.operational_data ||= {}
    self.operational_data['active_module_effects'] ||= []
    self.operational_data['active_module_effects'] << {
      'module_id' => module_obj.id,
      'module_type' => module_obj.module_type,
      'effects' => module_effects
    }

    save if respond_to?(:save)
  end

  # Alias for test compatibility
  def add_module_effect(module_obj)
    apply_module_effects(module_obj)
  end

  def revert_module_effects(module_obj)
    return false unless operational_data&.dig('active_module_effects')

    # Find and remove the module's effects
    effect_entry = operational_data['active_module_effects'].find { |e| e['module_id'] == module_obj.id }
    return false unless effect_entry

    effect_entry['effects'].each do |effect|
      case effect['type']
      when 'thermal_management'
        revert_thermal_management_effect(effect)
      when 'efficiency_boost'
        remove_efficiency_boost(effect['target_system'], effect['value'])
      when 'power_consumption_reduction'
        remove_power_consumption_reduction(effect['value'])
      end
    end

    # Remove from tracked effects
    operational_data['active_module_effects'].delete_if { |e| e['module_id'] == module_obj.id }
    save if respond_to?(:save)
  end

  # Alias for test compatibility
  def remove_module_effect(module_obj)
    revert_module_effects(module_obj)
  end

  def available_module_ports
    STDERR.puts "available_module_ports called on #{self.class.name}##{id}"
    ports_data = get_ports_data if respond_to?(:get_ports_data)
    STDERR.puts "respond_to?(:get_ports_data) = #{respond_to?(:get_ports_data)}"
    STDERR.puts "ports_data = #{ports_data.inspect}"
    return 0 unless ports_data
    
    internal = ports_data.dig('internal_module_ports') || 0
    external = ports_data.dig('external_module_ports') || 0
    total = internal + external
    STDERR.puts "internal=#{internal}, external=#{external}, total=#{total}"
    total
  end

  def determine_module_class(module_type)
    Modules::BaseModule
  end

  private

  def apply_thermal_management_effect(effect)
    heat_dissipation = effect.dig('parameters', 'heat_dissipation_kw') || 0
    
    if respond_to?(:operational_data) && operational_data
      self.operational_data['thermal_effects'] ||= {}
      current_dissipation = self.operational_data['thermal_effects']['heat_dissipation_kw'] || 0
      self.operational_data['thermal_effects']['heat_dissipation_kw'] = current_dissipation + heat_dissipation
    end
  end

  def apply_efficiency_boost(target_system, value)
    return unless operational_data && target_system && value

    self.operational_data['connection_systems'] ||= {}
    self.operational_data['connection_systems'][target_system] ||= {}
    
    current_efficiency = self.operational_data['connection_systems'][target_system]['efficiency'] || 0
    
    # Store original if not already stored
    self.operational_data['connection_systems'][target_system]['original_efficiency'] ||= current_efficiency
    
    # Apply boost
    new_efficiency = [current_efficiency + value, 100].min # Cap at 100%
    self.operational_data['connection_systems'][target_system]['efficiency'] = new_efficiency
  end

  def apply_power_consumption_reduction(value)
    return unless operational_data && value

    self.operational_data['resource_management'] ||= {}
    self.operational_data['resource_management']['consumables'] ||= {}
    self.operational_data['resource_management']['consumables']['energy_kwh'] ||= {}
    
    current_rate = self.operational_data['resource_management']['consumables']['energy_kwh']['rate'] || 0
    original_rate = self.operational_data['resource_management']['consumables']['energy_kwh']['original_rate'] || current_rate
    
    # Store original if not already stored
    self.operational_data['resource_management']['consumables']['energy_kwh']['original_rate'] ||= current_rate
    
    # Apply reduction (value is percentage)
    reduction_amount = current_rate * (value / 100.0)
    new_rate = [current_rate - reduction_amount, 0].max
    self.operational_data['resource_management']['consumables']['energy_kwh']['rate'] = new_rate
  end

  def revert_thermal_management_effect(effect)
    # Revert thermal effects
    heat_dissipation = effect['heat_dissipation_kw'] || 0
    
    if respond_to?(:operational_data) && operational_data&.dig('thermal_effects')
      current = self.operational_data['thermal_effects']['heat_dissipation'] || 0
      self.operational_data['thermal_effects']['heat_dissipation'] = [current - heat_dissipation, 0].max
    end
  end

  def remove_efficiency_boost(target_system, value)
    return unless operational_data && target_system && value

    system_data = operational_data.dig('connection_systems', target_system)
    return unless system_data

    original_efficiency = system_data['original_efficiency']
    return unless original_efficiency

    # Restore original efficiency
    system_data['efficiency'] = original_efficiency
    system_data.delete('original_efficiency')
  end

  def remove_power_consumption_reduction(value)
    return unless operational_data && value

    energy_data = operational_data.dig('resource_management', 'consumables', 'energy_kwh')
    return unless energy_data

    original_rate = energy_data['original_rate']
    return unless original_rate

    # Restore original rate
    energy_data['rate'] = original_rate
    energy_data.delete('original_rate')
  end

  # Add other effect methods as needed...
end
