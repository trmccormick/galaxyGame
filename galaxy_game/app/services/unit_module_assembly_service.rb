# Requires for the BlueprintLookupService (sole source of blueprint definitions).
require 'lookup/blueprint_lookup_service'

# Requires for the specific operational metadata lookup services.
# These services provide the operational properties and fit data.
require 'lookup/craft_lookup_service'
require 'lookup/unit_lookup_service'
require 'lookup/module_lookup_service'
require 'lookup/rig_lookup_service'

class UnitModuleAssemblyService
  # This service assembles a target (e.g., a Craft or Settlement) by consuming
  # items from inventory and creating functional components.
  
  # Class method that takes named parameters
  def self.build_units_and_modules(target:, settlement_inventory:)
    Rails.logger.info "Starting assembly for #{target.class.name} ID: #{target.id}"
    
    # Get recommended fit from target's operational data
    recommended_fit = target.operational_data&.dig('recommended_fit')
    unless recommended_fit
      Rails.logger.warn "No recommended fit found for #{target.class.name} ID: #{target.id}"
      return target
    end
    
    # Process each component type
    if recommended_fit['units'].present?
      process_units(recommended_fit['units'], target, settlement_inventory)
    end
    
    if recommended_fit['modules'].present?
      process_modules(recommended_fit['modules'], target, settlement_inventory)
    end
    
    if recommended_fit['rigs'].present?
      process_rigs(recommended_fit['rigs'], target, settlement_inventory)
    end
    
    # Process any custom port configurations
    if target.operational_data['custom_port_configurations'].present?
      process_custom_ports(target.operational_data['custom_port_configurations'], target, settlement_inventory)
    end
    
    # Log results
    Rails.logger.info "Assembly complete. Units: #{target.base_units.count}, Modules: #{target.modules.count}, Rigs: #{target.rigs.count}"
    
    # Return the target
    target
  rescue => e
    Rails.logger.error "Error in build_units_and_modules: #{e.message}\n#{e.backtrace.join("\n")}"
    target
  end
  
  private
  
  def self.process_units(units, target, inventory)
    Array(units).each do |unit_data|
      unit_id = unit_data['id']
      count = unit_data['count'] || 1
      port_type = unit_data['port_type'] || 'unit_port'
      
      count.times do |i|
        # Find item in inventory
        item = inventory.items.find_by(name: unit_id)
        unless item && item.amount > 0
          Rails.logger.warn "Item not found or zero amount: #{unit_id}"
          next
        end
        
        # Generate port name
        port_name = generate_port_name(port_type, target, i+1)
        
        # Create unit with only valid fields
        unit = target.base_units.new(
          unit_type: unit_id,
          name: unit_id.humanize,
          identifier: "#{unit_id}_#{SecureRandom.hex(4)}",
          operational_data: {'port' => port_name},
          owner: target.owner # Set the owner to the same as the target's owner
        )
        
        # Save unit
        if unit.save
          # Only remove from inventory if unit creation succeeded
          if item.amount > 1
            item.update!(amount: item.amount - 1)
          else
            item.destroy!
          end
        else
          Rails.logger.error "Failed to create unit: #{unit.errors.full_messages.join(', ')}"
        end
      end
    end
  end
  
  def self.process_modules(modules, target, inventory)
    Array(modules).each do |module_data|
      module_id = module_data['id']
      count = module_data['count'] || 1
      port_type = module_data['port_type'] || 'module_slot'
      
      count.times do |i|
        # Find item in inventory
        item = inventory.items.find_by(name: module_id)
        next unless item && item.amount > 0
        
        # Generate port name
        port_name = generate_port_name(port_type, target, i+1)
        
        # Create module with only valid fields
        mod = target.modules.new(
          module_type: module_id,
          name: module_id.humanize,
          identifier: "#{module_id}_#{SecureRandom.hex(4)}",
          operational_data: {'port' => port_name}
        )
        
        # Save module
        if mod.save
          # Only remove from inventory if module creation succeeded
          if item.amount > 1
            item.update!(amount: item.amount - 1)
          else
            item.destroy!
          end
        else
          Rails.logger.error "Failed to create module: #{mod.errors.full_messages.join(', ')}"
        end
      end
    end
  end
  
  def self.process_rigs(rigs, target, inventory)
    Array(rigs).each do |rig_data|
      rig_id = rig_data['id']
      count = rig_data['count'] || 1
      port_type = rig_data['port_type'] || 'rig_mount'
      
      count.times do |i|
        # Find item in inventory
        item = inventory.items.find_by(name: rig_id)
        next unless item && item.amount > 0
        
        # Generate port name
        port_name = generate_port_name(port_type, target, i+1)
        
        # Create rig with required fields
        rig = target.rigs.new(
          rig_type: rig_id,
          name: rig_id.humanize,
          operational_data: {'port' => port_name},
          description: "#{rig_id.humanize} rig",
          capacity: 100
        )
        
        # Save rig
        if rig.save
          # Only remove from inventory if rig creation succeeded
          if item.amount > 1
            item.update!(amount: item.amount - 1)
          else
            item.destroy!
          end
        else
          Rails.logger.error "Failed to create rig: #{rig.errors.full_messages.join(', ')}"
        end
      end
    end
  end
  
  def self.process_custom_ports(custom_configs, target, inventory)
    return unless custom_configs.is_a?(Array)
    
    custom_configs.each do |config|
      item_id = config['item_id']
      count = config['count'] || 1
      port_type = config['port_type'] || 'custom_port'
      
      # For landing gear, treat as a unit
      if item_id == 'landing_gear' || item_id == 'retractable_landing_legs'
        process_landing_gear(item_id, count, port_type, target, inventory)
        next
      end
      
      # Determine component type from item name
      if item_id.include?('module')
        process_custom_module(item_id, count, port_type, target, inventory)
      elsif item_id.include?('rig')
        process_custom_rig(item_id, count, port_type, target, inventory)
      else
        process_custom_unit(item_id, count, port_type, target, inventory)
      end
    end
  end
  
  def self.process_custom_unit(item_id, count, port_type, target, inventory)
    count.times do |i|
      item = inventory.items.find_by(name: item_id)
      next unless item && item.amount > 0
      
      # Generate port name
      port_name = generate_port_name(port_type, target, i+1)
      
      # Create unit with custom port
      unit = target.base_units.new(
        unit_type: item_id,
        name: item_id.humanize,
        identifier: "#{item_id}_#{SecureRandom.hex(4)}",
        operational_data: {'port' => port_name},
        owner: target.owner
      )
      
      if unit.save
        # Only remove from inventory if unit creation succeeded
        if item.amount > 1
          item.update!(amount: item.amount - 1)
        else
          item.destroy!
        end
      else
        Rails.logger.error "Failed to create custom unit: #{unit.errors.full_messages.join(', ')}"
      end
    end
  end
  
  def self.process_custom_module(item_id, count, port_type, target, inventory)
    count.times do |i|
      item = inventory.items.find_by(name: item_id)
      next unless item && item.amount > 0
      
      # Generate port name
      port_name = generate_port_name(port_type, target, i+1)
      
      # Create module with custom port
      mod = target.modules.new(
        module_type: item_id,
        name: item_id.humanize,
        identifier: "#{item_id}_#{SecureRandom.hex(4)}",
        operational_data: {'port' => port_name}
      )
      
      if mod.save
        # Only remove from inventory if module creation succeeded
        if item.amount > 1
          item.update!(amount: item.amount - 1)
        else
          item.destroy!
        end
      else
        Rails.logger.error "Failed to create custom module: #{mod.errors.full_messages.join(', ')}"
      end
    end
  end
  
  def self.process_custom_rig(item_id, count, port_type, target, inventory)
    count.times do |i|
      item = inventory.items.find_by(name: item_id)
      next unless item && item.amount > 0
      
      # Generate port name
      port_name = generate_port_name(port_type, target, i+1)
      
      # Create rig with custom port and required fields
      rig = target.rigs.new(
        rig_type: item_id,
        name: item_id.humanize,
        operational_data: {'port' => port_name},
        description: "#{item_id.humanize} rig",
        capacity: 100
      )
      
      if rig.save
        # Only remove from inventory if rig creation succeeded
        if item.amount > 1
          item.update!(amount: item.amount - 1)
        else
          item.destroy!
        end
      else
        Rails.logger.error "Failed to create custom rig: #{rig.errors.full_messages.join(', ')}"
      end
    end
  end
  
  def self.process_landing_gear(item_id, count, port_type, target, inventory)
    count.times do |i|
      item = inventory.items.find_by(name: item_id)
      next unless item && item.amount > 0
      
      # Create as a specialized unit with landing gear port
      port_name = port_type # Use the specified port type, usually 'landing_gear_mount'
      
      # Create landing gear unit
      unit = target.base_units.new(
        unit_type: item_id,
        name: "#{item_id.humanize}",
        identifier: "#{item_id}_#{SecureRandom.hex(4)}",
        operational_data: {'port' => port_name},
        owner: target.owner
      )
      
      if unit.save
        # Only remove from inventory if unit creation succeeded
        if item.amount > 1
          item.update!(amount: item.amount - 1)
        else
          item.destroy!
        end
      else
        Rails.logger.error "Failed to create landing gear: #{unit.errors.full_messages.join(', ')}"
      end
    end
  end

  def self.generate_port_name(port_type, target, index)
    # For special components like landing legs
    if port_type == 'landing_gear_mount'
      return 'landing_gear_mount'
    end
    
    # Normal port naming
    "#{port_type}_#{index}"
  end
end