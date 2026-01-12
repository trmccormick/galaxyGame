# app/models/concerns/units/has_processing.rb
module Units
  module HasProcessing
    extend ActiveSupport::Concern

    def process_resources(resource_name = 'regolith')
      Rails.logger.debug("\n=== HasProcessing#process_resources Start ===")
      Rails.logger.debug("Processing #{resource_name} with unit: #{name} (#{unit_type})")
      Rails.logger.debug("Initial gas buffer level: #{get_buffer_level('gas_buffer')}")
      Rails.logger.debug("Initial water buffer level: #{get_buffer_level('water_buffer')}")

      return false unless operational_data && @unit_info && celestial_body && resource_name == 'regolith'
      return false unless operational_data['processing_capabilities']&.dig('thermal_extraction')

      # Get and verify input rate for regolith
      input_config = @unit_info.dig('input_resources')&.find { |r| r['id'] == resource_name }
      input_rate = input_config&.dig('amount')
      Rails.logger.debug("Input rate for #{resource_name}: #{input_rate}")
      return false unless input_rate

      # Consume input material
      consumed = consume(resource_name, input_rate)
      Rails.logger.debug("Consumed material: #{consumed}")
      return false unless consumed

      # ✅ FIX: Use existing celestial_body association instead of non-existent service
      celestial_body_composition = celestial_body&.geosphere&.crust_composition
      Rails.logger.debug("Celestial body composition: #{celestial_body_composition.inspect}")
      return false unless celestial_body_composition&.dig('volatiles')

      extraction_efficiency = operational_data['processing_capabilities']['thermal_extraction']['efficiency'] || 0.85

      # Process outputs based on the planet's volatile composition
      extracted_count = 0
      celestial_body_composition['volatiles'].each do |volatile, percentage|
        material = Lookup::MaterialLookupService.new.find_material(volatile)
        next unless material

        amount = (input_rate * (percentage / 100.0) * extraction_efficiency).round(3)
        Rails.logger.debug("Extracting #{volatile}: #{amount} kg")

        case material['properties']&.dig('state_at_room_temp')
        when 'Gas'
          stored = store_in_buffer('gas_buffer', volatile, amount)
          Rails.logger.debug("Stored #{volatile} in gas buffer: #{stored}")
          extracted_count += stored ? 1 : 0
        when 'Liquid'
          stored = store_in_buffer('water_buffer', volatile, amount)
          Rails.logger.debug("Stored #{volatile} in water buffer: #{stored}")
          extracted_count += stored ? 1 : 0
        end
      end

      Rails.logger.debug("Final gas buffer level: #{get_buffer_level('gas_buffer')}")
      Rails.logger.debug("Final water buffer level: #{get_buffer_level('water_buffer')}")
      Rails.logger.debug("=== HasProcessing#process_resources End ===\n")

      extracted_count > 0
    end

    def geosphere_capabilities
      capabilities = {
        volatile_extraction: false,
        thermal_extraction: false,
        mineral_extraction: false,
        regolith_processing: false
      }

      return capabilities unless operational_data&.dig('processing_capabilities')

      case unit_type
      when 'planetary_volatiles_extractor'
        capabilities[:volatile_extraction] = true
        capabilities[:regolith_processing] = true
      when 'thermal_extraction_unit'
        capabilities[:thermal_extraction] = true
        capabilities[:volatile_extraction] = true
      when 'lunar_oxygen_extractor'
        capabilities[:volatile_extraction] = true
        capabilities[:thermal_extraction] = true
      when 'mining_drill'
        capabilities[:mineral_extraction] = true
      end

      capabilities
    end

    def process_geosphere!(processing_type, target_parameters = {})
      case processing_type
      when :volatile_extraction, :regolith_processing
        # Use existing process_resources method
        resource_name = target_parameters[:resource_name] || 'regolith'
        process_resources(resource_name)
      when :thermal_extraction
        thermal_extract_volatiles(target_parameters)
      when :mineral_extraction
        extract_minerals(target_parameters)
      else
        false
      end
    end

    private

    def thermal_extract_volatiles(target_parameters)
      return false unless unit_type == 'thermal_extraction_unit'

      lookup_service = Lookup::UnitLookupService.new
      unit_data = lookup_service.find_unit(unit_type)
      return false unless unit_data

      # Get thermal process data from JSON
      thermal_process = unit_data.dig('processing_capabilities', 'processes')
        &.find { |p| p['name'] == 'volatile_extraction' }
      return false unless thermal_process

      # ✅ FIX: Use existing celestial body association
      celestial_body_composition = celestial_body&.geosphere&.crust_composition
      return false unless celestial_body_composition&.dig('volatiles')

      input_rate = thermal_process.dig('input', 'rate', 'max') || 5
      efficiency = thermal_process['efficiency'] || 0.95

      # Consume regolith
      consumed = consume('regolith', input_rate)
      return false unless consumed

      # Extract volatiles based on composition and efficiency  
      extracted_count = 0
      celestial_body_composition['volatiles'].each do |volatile, percentage|
        material = Lookup::MaterialLookupService.new.find_material(volatile)
        next unless material

        amount = (input_rate * (percentage / 100.0) * efficiency).round(3)

        case material['properties']&.dig('state_at_room_temp')
        when 'Gas'
          stored = store_in_buffer('gas_storage', volatile, amount)
          extracted_count += stored ? 1 : 0
        when 'Liquid'
          stored = store_in_buffer('liquid_storage', volatile, amount)
          extracted_count += stored ? 1 : 0
        end
      end

      extracted_count > 0
    end

    def extract_minerals(target_parameters)
      return false unless unit_type == 'mining_drill'

      # Mining logic using lookup services
      lookup_service = Lookup::UnitLookupService.new
      unit_data = lookup_service.find_unit(unit_type)
      return false unless unit_data

      # Basic mineral extraction
      target_mineral = target_parameters[:target_mineral] || 'Iron'
      extraction_rate = unit_data.dig('resource_management', 'mining_rates', 'general') || 100

      # ✅ FIX: Use existing celestial body association
      minerals = celestial_body&.geosphere&.crust_composition&.dig('minerals') || {}

      mineral_percentage = minerals[target_mineral]
      return false unless mineral_percentage&.> 0

      extracted_amount = extraction_rate * (mineral_percentage / 100.0)
      store_resource(target_mineral, extracted_amount)

      true
    end
  end
end