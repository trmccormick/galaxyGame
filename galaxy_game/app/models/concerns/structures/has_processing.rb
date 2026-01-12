module Structures
  module HasProcessing
    extend ActiveSupport::Concern

    # Main method to execute a processing cycle
    def run_processing_cycle
      return false unless can_process?
      
      Rails.logger.debug("\n=== #{name} Processing Cycle Start ===")
      
      # Core steps for processing
      check_resource_levels
      prepare_processing_units
      delegate_processing_to_units
      collect_processing_results
      apply_structure_bonuses
      
      Rails.logger.debug("=== #{name} Processing Cycle End ===\n")
      true
    end
    
    # Check if structure can process
    def can_process?
      return false unless operational?
      return false unless current_mode == 'production'
      
      # Check if we have processing units installed
      processing_units.any?
    end
    
    # Get units capable of processing
    def processing_units
      base_units.select { |unit| unit.respond_to?(:process_resources) && unit.operational? }
    end
    
    # Check if any units need resources
    def needs_resources?
      processing_units.any? { |unit| unit.respond_to?(:needs_resources?) && unit.needs_resources? }
    end
    
    # Check current resource levels for processing
    def check_resource_levels
      return false unless inventory
      
      # Get required resources from operational data
      input_resources = operational_data&.dig('resource_management', 'consumables')
      return false unless input_resources.present?
      
      # Check if we have required resources
      input_resources.each do |resource_id, data|
        required = data['rate']
        available = inventory.get_resource_amount(resource_id)
        
        Rails.logger.debug("Resource check: #{resource_id} - Required: #{required}, Available: #{available}")
        
        if available < required
          Rails.logger.debug("Insufficient resources for processing")
          return false
        end
      end
      
      true
    end
    
    # Prepare units for processing
    def prepare_processing_units
      units = processing_units
      return false if units.empty?
      
      # Let each unit prepare for processing
      units.each do |unit|
        if unit.respond_to?(:prepare_for_processing)
          unit.prepare_for_processing
        end
      end
      
      true
    end
    
    # Delegate processing to individual units
    def delegate_processing_to_units
      units = processing_units
      return {} if units.empty?
      
      # Track results from each unit
      results = {}
      
      # Have each unit perform processing
      units.each do |unit|
        # Skip units that can't process
        next unless unit.respond_to?(:process_resources)
        
        # Get input resource requirements
        if unit.respond_to?(:required_resources)
          required = unit.required_resources
          
          # Provide resources from inventory if available
          required.each do |resource_id, amount|
            available = inventory.get_resource_amount(resource_id)
            
            if available >= amount
              # Remove from inventory
              inventory.remove_item(resource_id, amount)
              
              # Give to unit
              if unit.respond_to?(:receive_resource)
                unit.receive_resource(resource_id, amount)
              end
            end
          end
        end
        
        # Have unit process resources
        unit_results = unit.process_resources
        
        # Add results to overall results
        if unit_results.is_a?(Hash)
          unit_results.each do |resource_id, amount|
            results[resource_id] ||= 0
            results[resource_id] += amount
          end
        end
      end
      
      results
    end
    
    # Collect results from units
    def collect_processing_results
      units = processing_units
      return {} if units.empty?
      
      # Track total processed resources
      processed = {}
      
      # Collect output from each unit
      units.each do |unit|
        # Skip units that don't have output buffer
        next unless unit.respond_to?(:output_buffer)
        
        # Get output buffer
        output = unit.output_buffer
        
        # Add to inventory and track total
        output.each do |resource_id, amount|
          inventory.add_item(resource_id, amount)
          
          processed[resource_id] ||= 0
          processed[resource_id] += amount
          
          # Clear unit's output buffer
          unit.clear_output_buffer(resource_id) if unit.respond_to?(:clear_output_buffer)
        end
      end
      
      # Log results
      processed.each do |resource_id, amount|
        Rails.logger.debug("Processed: #{amount} of #{resource_id}")
      end
      
      processed
    end
    
    # Apply structure-level bonuses to processing
    def apply_structure_bonuses
      # Get structure bonuses from modules
      structure_modules = modules.select { |m| m.operational? }
      
      # No bonuses without modules
      return false if structure_modules.empty?
      
      # Apply quality bonuses
      quality_modules = structure_modules.select { |m| m.module_type.include?('quality') }
      
      return false if quality_modules.empty?
      
      if quality_modules.any?
        # Calculate quality bonus
        quality_bonus = quality_modules.sum { |m| m.operational_data&.dig('effects', 'quality_bonus') || 0 }
        
        # Apply to output resources
        output_resources = operational_data&.dig('resource_management', 'generated')
        return false unless output_resources.present?
        
        bonuses_applied = false
        output_resources.each do |resource_id, _|
          current = inventory.get_resource_amount(resource_id)
          
          if current > 0
            bonus_amount = (current * quality_bonus).round
            
            if bonus_amount > 0
              inventory.add_item(resource_id, bonus_amount)
              Rails.logger.debug("Quality bonus: +#{bonus_amount} #{resource_id}")
              bonuses_applied = true
            end
          end
        end
        
        bonuses_applied
      else
        false
      end
    end
  end
end