# app/models/concerns/atmospheric_processing.rb (shared by both units and modules)
module AtmosphericProcessing
  extend ActiveSupport::Concern
  
  def can_process_atmosphere?
    # ✅ For units with processing_capabilities, use that as the authoritative source
    if operational_data&.dig('processing_capabilities', 'atmospheric_processing')
      return operational_data.dig('processing_capabilities', 'atmospheric_processing', 'enabled') || false
    end
    
    # ✅ For modules/units without processing_capabilities, check operational modes
    has_atmospheric_operations?
  end
  
  def atmospheric_capabilities
    return {} unless can_process_atmosphere?
    
    # ✅ Initialize all capabilities to false first
    capabilities = {
      co2_to_o2: false,
      gas_conversion: false,
      co2_scrubbing: false,
      air_filtration: false,
      co2_venting: false
    }
    
    # ✅ Check processing_capabilities first (new template format)
    if operational_data&.dig('processing_capabilities', 'atmospheric_processing', 'enabled')
      processing_types = operational_data.dig('processing_capabilities', 'atmospheric_processing', 'types') || []
      capabilities[:co2_to_o2] = processing_types.include?('co2_to_oxygen')
      capabilities[:gas_conversion] = processing_types.include?('gas_conversion')
    end
    
    # ✅ Only check atmospheric operations if no processing_capabilities defined
    if !operational_data&.dig('processing_capabilities', 'atmospheric_processing') && has_atmospheric_operations?
      capabilities[:co2_scrubbing] = has_resource_flow?('air', 'stored_co2')
      capabilities[:air_filtration] = has_resource_flow?('unfiltered_air', 'filtered_air')
      capabilities[:co2_venting] = has_resource_flow?('CO₂', 'vented_CO₂')
    end
    
    capabilities
  end
  
  def process_atmosphere!(processing_type, target_parameters = {})
    return false unless can_process_atmosphere?
    
    case processing_type
    when :co2_to_o2_conversion
      process_co2_to_oxygen(target_parameters)
    when :co2_scrubbing
      scrub_co2_from_atmosphere(target_parameters)
    when :air_filtration
      filter_air(target_parameters)
    when :co2_venting
      vent_co2(target_parameters)
    else
      false
    end
  end
  
  def max_processing_rate(substance)
    return 0 unless can_process_atmosphere?
    
    input_resources = operational_data&.dig('input_resources') || []
    output_resources = operational_data&.dig('output_resources') || []
    
    # ✅ Find rate from input or output resources
    resource = input_resources.find { |r| r['id'] == substance } ||
               output_resources.find { |r| r['id'] == substance }
    
    resource&.dig('amount') || 0
  end
  
  private
  
  def has_processing_capabilities?
    # ✅ Units have processing_capabilities (new template format)
    operational_data&.dig('processing_capabilities', 'atmospheric_processing', 'enabled') || false
  end
  
  def has_atmospheric_operations?
    # ✅ Modules have atmospheric input/output resources
    return false unless operational_data
    
    input_resources = operational_data['input_resources'] || []
    output_resources = operational_data['output_resources'] || []
    
    atmospheric_substances = ['air', 'CO₂', 'oxygen', 'unfiltered_air', 'filtered_air', 'vented_CO₂']
    
    (input_resources + output_resources).any? do |resource|
      atmospheric_substances.include?(resource['id'])
    end
  end
  
  def has_resource_flow?(input_id, output_id)
    input_resources = operational_data&.dig('input_resources') || []
    output_resources = operational_data&.dig('output_resources') || []
    
    has_input = input_resources.any? { |r| r['id'] == input_id }
    has_output = output_resources.any? { |r| r['id'] == output_id }
    
    has_input && has_output
  end
  
  def process_co2_to_oxygen(target_parameters)
    # ✅ For units with CO2 → O2 conversion capability
    return false unless has_processing_capabilities?
    
    input_resources = operational_data&.dig('input_resources') || []
    output_resources = operational_data&.dig('output_resources') || []
    
    co2_input = input_resources.find { |r| r['id'] == 'CO₂' }
    o2_output = output_resources.find { |r| r['id'] == 'oxygen' }
    
    return false unless co2_input && o2_output
    
    # ✅ Get atmosphere from host structure/craft
    current_atmosphere = get_host_atmosphere
    return false unless current_atmosphere
    
    # ✅ Process the conversion using JSON data rates
    co2_required = co2_input['amount']
    o2_produced = o2_output['amount']
    
    if current_atmosphere.has_sufficient_gas?('CO2', co2_required)
      current_atmosphere.remove_gas('CO2', co2_required)
      current_atmosphere.add_gas('O2', o2_produced)
      
      # ✅ Consume energy if specified
      energy_required = operational_data&.dig('consumables', 'energy')
      consume_energy(energy_required) if energy_required && respond_to?(:consume_energy)
      
      true
    else
      false
    end
  end
  
  def scrub_co2_from_atmosphere(target_parameters)
    # ✅ For modules with CO2 scrubbing capability (like CO2_scrubber)
    return false unless has_resource_flow?('air', 'stored_co2')
    
    output_resources = operational_data&.dig('output_resources') || []
    co2_captured = output_resources.find { |r| r['id'] == 'stored_co2' }&.dig('amount') || 0
    
    current_atmosphere = get_host_atmosphere
    return false unless current_atmosphere
    
    # ✅ Check cartridge capacity
    return false unless check_cartridge_availability
    
    if current_atmosphere.has_sufficient_gas?('CO2', co2_captured)
      current_atmosphere.remove_gas('CO2', co2_captured)
      store_in_cartridge('stored_co2', co2_captured)
      
      # ✅ Consume energy
      energy_required = operational_data&.dig('consumables', 'energy')
      consume_energy(energy_required) if energy_required && respond_to?(:consume_energy)
      
      true
    else
      false
    end
  end
  
  def filter_air(target_parameters)
    # ✅ For modules with air filtration capability
    return false unless has_resource_flow?('unfiltered_air', 'filtered_air')
    
    input_resources = operational_data&.dig('input_resources') || []
    air_volume = input_resources.find { |r| r['id'] == 'unfiltered_air' }&.dig('amount') || 0
    
    efficiency = operational_data&.dig('operational_data', 'filter_efficiency') || 0.99
    
    current_atmosphere = get_host_atmosphere
    return false unless current_atmosphere
    
    # ✅ Remove contaminants based on filter efficiency
    contaminants_removed = current_atmosphere.filter_contaminants(efficiency)
    
    contaminants_removed > 0
  end
  
  def vent_co2(target_parameters)
    # ✅ For modules with CO2 venting capability  
    return false unless has_resource_flow?('CO₂', 'vented_CO₂')
    
    # ✅ Check operational modes (space vs atmosphere venting)
    venting_mode = target_parameters[:mode] || 'space'
    operational_modes = operational_data&.dig('operational_modes') || {}
    mode_data = operational_modes[venting_mode]
    
    return false unless mode_data
    
    output_resources = mode_data['output_resources'] || []
    vent_amount = output_resources.find { |r| r['id'] == 'vented_CO₂' }&.dig('amount') || 0
    
    current_atmosphere = get_host_atmosphere
    return false unless current_atmosphere
    
    if current_atmosphere.has_sufficient_gas?('CO2', vent_amount)
      current_atmosphere.remove_gas('CO2', vent_amount)
      # ✅ CO2 is vented to space or planetary atmosphere per mode
      true
    else
      false
    end
  end
  
  def get_host_atmosphere
    # ✅ Works for both units and modules
    if attachable&.respond_to?(:atmosphere) && attachable.atmosphere
      attachable.atmosphere
    elsif attachable&.respond_to?(:location) && attachable.location&.celestial_body&.atmosphere
      attachable.location.celestial_body.atmosphere
    else
      nil
    end
  end
  
  def check_cartridge_availability
    # ✅ For modules with cartridge systems
    max_capacity = operational_data&.dig('operational_data', 'cartridge_max_co2') || Float::INFINITY
    current_level = operational_data&.dig('operational_data', 'current_cartridge_level') || 0
    
    current_level < max_capacity
  end
  
  def store_in_cartridge(resource_name, amount)
    # ✅ For modules with storage systems
    return false unless operational_data&.dig('operational_data')
    
    current_level = operational_data['operational_data']['current_cartridge_level'] || 0
    max_capacity = operational_data['operational_data']['cartridge_max_co2'] || 25
    
    storable_amount = [amount, max_capacity - current_level].min
    if storable_amount > 0
      operational_data['operational_data']['current_cartridge_level'] = current_level + storable_amount
      save! if respond_to?(:save!)
      true
    else
      false
    end
  end
end