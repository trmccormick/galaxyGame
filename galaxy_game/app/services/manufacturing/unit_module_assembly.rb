# Requires for the BlueprintLookupService (sole source of blueprint definitions).
require 'lookup/blueprint_lookup_service'

# Requires for the specific operational metadata lookup services.
# These services provide the operational properties and fit data.
require 'lookup/craft_lookup_service'
require 'lookup/unit_lookup_service'
require 'lookup/module_lookup_service'
require 'lookup/rig_lookup_service'

class Manufacturing::UnitModuleAssembly
  attr_reader :craft_item, :owner, :settlement, :variant
  
  # Constructor to support the pattern in the test
  def initialize(craft_item: nil, owner: nil, settlement: nil, variant: nil)
    @craft_item = craft_item
    @owner = owner
    @settlement = settlement
    @variant = variant
    @settlement_inventory = settlement&.inventory
  end
  
  # Instance method for creating a new craft from an inventory item
  def build_units_and_modules
    # Create a new craft from the craft_item
    craft_data = Lookup::CraftLookupService.new.find_craft(variant || craft_item.metadata['craft_type'])
    return nil unless craft_data
    
    # Create the craft with necessary attributes
    craft = Craft::BaseCraft.create!(
      name: craft_item.name,
      craft_name: craft_data['name'],
      craft_type: craft_item.metadata['craft_type'],
      owner: owner,
      operational_data: craft_data
    )
    
    # Create inventory for the craft
    craft.create_inventory! unless craft.inventory
    
    # Remove the craft item from settlement inventory
    craft_item.destroy!
    
    # Add the recommended units to the craft
    recommended_fit = craft_data.dig('recommended_units') || craft_data.dig('recommended_fit')
    if recommended_fit
      # Structure the data to match the expected format
      formatted_fit = {}
      if recommended_fit.is_a?(Array)
        formatted_fit = {'units' => recommended_fit}
      else
        formatted_fit = recommended_fit
      end
      
      # Call the class method to build units and modules
      self.class.build_units_and_modules(
        target: craft,
        settlement_inventory: @settlement_inventory
      )
    end
    
    craft.reload
    craft
  end

  # Class method that takes named parameters
  def self.build_units_and_modules(target:, settlement_inventory:)
    Rails.logger.info "Starting assembly for #{target.class.name} ID: #{target.id}"
    
    # Get recommended fit from target's operational data
    recommended_fit = target.operational_data&.dig('recommended_fit')
    
    # Fall back to recommended_units if recommended_fit is not present
    if !recommended_fit && target.operational_data&.dig('recommended_units')
      recommended_fit = {'units' => target.operational_data['recommended_units']}
    end
    
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
    
    # Return the target
    target
  rescue => e
    Rails.logger.error "Error in build_units_and_modules: #{e.message}\n#{e.backtrace.join("\n")}"
    target
  end
  
  # Class method to disconnect a unit and return it to inventory
  def self.disconnect_unit(unit:, settlement_inventory:)
    Rails.logger.info "Disconnecting unit: #{unit.unit_type} (#{unit.identifier})"
    
    # Detach the unit from its parent (set attachable to nil)
    unit.update!(attachable_id: nil, attachable_type: nil)
    
    # Add the unit back to inventory as an item
    settlement_inventory.add_item(unit.unit_type, 1, unit.owner)
    
    Rails.logger.info "Unit #{unit.unit_type} returned to inventory"
    
    unit
  rescue => e
    Rails.logger.error "Error disconnecting unit: #{e.message}\n#{e.backtrace.join("\n")}"
    raise
  end
  
  private
  
  def self.process_units(units, target, inventory)
    Array(units).each do |unit_data|
      unit_id = unit_data['id']
      count = unit_data['count'] || 1
      port_type = unit_data['port_type'] || 'unit_port'
      Rails.logger.info "Processing unit: #{unit_id}, count: #{count}"

      count.times do |i|
        item = inventory.items.find_by(name: unit_id) || 
               inventory.items.find_by("metadata->>'unit_type' = ?", unit_id) ||
               inventory.items.find_by(name: "#{unit_id.humanize} Item")

        Rails.logger.info "  Attempt #{i+1} for #{unit_id}: item=#{item&.name}, amount=#{item&.amount}"

        unless item && item.amount > 0
          Rails.logger.warn "Item not found or zero amount: #{unit_id}"
          next
        end

        port_name = generate_port_name(port_type, target, i+1)
        unit = target.base_units.new(
          unit_type: unit_id,
          name: unit_id.humanize,
          identifier: "#{unit_id}_#{SecureRandom.hex(4)}",
          operational_data: {'port' => port_name},
          owner: target.owner
        )

        if unit.save
          Rails.logger.info "  Created unit: #{unit.unit_type} (#{unit.identifier})"
          if item.amount > 1
            item.update!(amount: item.amount - 1)
            Rails.logger.info "  Decremented inventory for #{item.name}, new amount: #{item.amount}"
          else
            item.destroy!
            Rails.logger.info "  Destroyed inventory item #{item.name}"
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
      Rails.logger.info "Processing module: #{module_id}, count: #{count}"
      
      count.times do |i|
        # Find item in inventory
        item = inventory.items.find_by(name: module_id) || 
               inventory.items.find_by("metadata->>'module_type' = ?", module_id) ||
               inventory.items.find_by(name: "#{module_id.humanize} Item")
        
        Rails.logger.info "  Attempt #{i+1} for #{module_id}: item=#{item&.name}, amount=#{item&.amount}"
        
        next unless item && item.amount > 0
        
        # Generate port name
        port_name = generate_port_name(port_type, target, i+1)
        
        # Create module with only valid fields - including attachable if it uses polymorphic association
        mod = target.modules.new(
          module_type: module_id,
          name: module_id.humanize,
          identifier: "#{module_id}_#{SecureRandom.hex(4)}",
          operational_data: {'port' => port_name},
          attachable: target  # Set polymorphic association
        )
        
        # Save module
        if mod.save
          Rails.logger.info "  Created module: #{mod.module_type} (#{mod.identifier})"
          # Only remove from inventory if module creation succeeded
          if item.amount > 1
            item.update!(amount: item.amount - 1)
            Rails.logger.info "  Decremented inventory for #{item.name}, new amount: #{item.amount}"
          else
            item.destroy!
            Rails.logger.info "  Destroyed inventory item #{item.name}"
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
      Rails.logger.info "Processing rig: #{rig_id}, count: #{count}"
      
      count.times do |i|
        # Find item in inventory
        item = inventory.items.find_by(name: rig_id) || 
               inventory.items.find_by("metadata->>'rig_type' = ?", rig_id) ||
               inventory.items.find_by(name: "#{rig_id.humanize} Item")
        
        Rails.logger.info "  Attempt #{i+1} for #{rig_id}: item=#{item&.name}, amount=#{item&.amount}"
        
        next unless item && item.amount > 0
        
        # Generate port name
        port_name = generate_port_name(port_type, target, i+1)
        
        # Create rig with required fields - including attachable if it uses polymorphic association
        rig = target.rigs.new(
          rig_type: rig_id,
          name: rig_id.humanize,
          identifier: "#{rig_id}_#{SecureRandom.hex(4)}",
          operational_data: {'port' => port_name},
          description: "#{rig_id.humanize} rig",
          capacity: 100,
          attachable: target  # Set polymorphic association
        )
        
        # Save rig
        if rig.save
          Rails.logger.info "  Created rig: #{rig.rig_type} (#{rig.name})"
          # Only remove from inventory if rig creation succeeded
          if item.amount > 1
            item.update!(amount: item.amount - 1)
            Rails.logger.info "  Decremented inventory for #{item.name}, new amount: #{item.amount}"
          else
            item.destroy!
            Rails.logger.info "  Destroyed inventory item #{item.name}"
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
      item = inventory.items.find_by(name: item_id) || 
             inventory.items.find_by("metadata->>'unit_type' = ?", item_id) ||
             inventory.items.find_by(name: "#{item_id.humanize} Item")
      
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
      item = inventory.items.find_by(name: item_id) || 
             inventory.items.find_by("metadata->>'module_type' = ?", item_id) ||
               inventory.items.find_by(name: "#{item_id.humanize} Item")
      
      next unless item && item.amount > 0
      
      # Generate port name
      port_name = generate_port_name(port_type, target, i+1)
      
      # Create module with custom port
      mod = target.modules.new(
        module_type: item_id,
        name: item_id.humanize,
        identifier: "#{item_id}_#{SecureRandom.hex(4)}",
        operational_data: {'port' => port_name},
        attachable: target  # Set polymorphic association
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
      item = inventory.items.find_by(name: item_id) || 
             inventory.items.find_by("metadata->>'rig_type' = ?", item_id) ||
             inventory.items.find_by(name: "#{item_id.humanize} Item")
      
      next unless item && item.amount > 0
      
      # Generate port name
      port_name = generate_port_name(port_type, target, i+1)
      
      # Create rig with custom port and required fields
      rig = target.rigs.new(
        rig_type: item_id,
        name: item_id.humanize,
        operational_data: {'port' => port_name},
        description: "#{item_id.humanize} rig",
        capacity: 100,
        attachable: target  # Set polymorphic association
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
    Rails.logger.info "Processing landing gear: #{item_id}, count: #{count}"
    count.times do |i|
      item = inventory.items.find_by(name: item_id) || 
             inventory.items.find_by("metadata->>'unit_type' = ?", item_id) ||
             inventory.items.find_by(name: "#{item_id.humanize} Item") ||
             inventory.items.find_by(name: "Retractable Landing Legs")

      Rails.logger.info "  Attempt #{i+1} for landing gear #{item_id}: item=#{item&.name}, amount=#{item&.amount}"

      next unless item && item.amount > 0

      port_name = port_type
      unit = target.base_units.new(
        unit_type: item_id,
        name: "#{item_id.humanize}",
        identifier: "#{item_id}_#{SecureRandom.hex(4)}",
        operational_data: {'port' => port_name},
        owner: target.owner
      )

      if unit.save
        Rails.logger.info "  Created landing gear unit: #{unit.unit_type} (#{unit.identifier})"
        if item.amount > 1
          item.update!(amount: item.amount - 1)
          Rails.logger.info "  Decremented inventory for #{item.name}, new amount: #{item.amount}"
        else
          item.destroy!
          Rails.logger.info "  Destroyed inventory item #{item.name}"
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