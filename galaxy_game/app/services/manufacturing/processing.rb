# app/services/manufacturing/processing.rb
class Manufacturing::Processing
  def initialize(owner, blueprint_name)
    @owner = owner
    @blueprint = Lookup::BlueprintLookupService.new.find_blueprint(blueprint_name)
    raise "Blueprint not found: #{blueprint_name}" unless @blueprint

    # Find the player's inventory
    @inventory = find_owners_inventory
    raise "Player has no inventory" unless @inventory
    
    # Get owner's current location (could be a CelestialLocation or SpatialLocation)
    @current_location = find_owners_current_location
  end

  def process
    ActiveRecord::Base.transaction do
      # Check if player has enough GCC
      verify_gcc
      
      # Check and deduct materials
      handle_materials
      
      # Create the unassembled items based on the blueprint outcome
      create_unassembled_items
      
      # Create any byproducts
      handle_byproducts
      
      "Production complete: #{@blueprint['name']}"
    end
  rescue => e
    Rails.logger.error("Processing failed: #{e.message}")
    raise
  end

  private
  
  def find_owners_inventory
    return @owner.inventory if @owner.respond_to?(:inventory) && @owner.inventory.present?
    nil
  end
  
  def find_owners_current_location
    # If owner has a direct reference to their location
    if @owner.respond_to?(:location) && @owner.location.present?
      return @owner.location
    end
    
    # If owner has a reference to a craft that has a location
    if @owner.respond_to?(:active_craft) && @owner.active_craft.present? && @owner.active_craft.respond_to?(:location)
      return @owner.active_craft.location
    end
    
    # If owner has a reference to a location name
    if @owner.respond_to?(:active_location) && @owner.active_location.present?
      # Try to find celestial location first
      celestial_location = CelestialLocation.find_by(name: @owner.active_location)
      return celestial_location if celestial_location.present?
      
      # Then try spatial location
      spatial_location = SpatialLocation.find_by(name: @owner.active_location)
      return spatial_location if spatial_location.present?
    end
    
    # If all else fails
    raise "Cannot determine owner's current location"
  end
  
  def verify_gcc
    cost = @blueprint['cost_gcc'] || 0
    if cost > 0 && @owner.account.balance < cost
      raise "Insufficient GCC"
    end
    
    # Deduct the cost if there is one
    @owner.account.withdraw(cost, "Cost for building #{@blueprint['name']}") if cost > 0
  end

  def handle_materials
    materials = @blueprint['materials'] || []
    materials.each do |material|
      material_name = material['name']
      required_amount = material['amount'].to_f
      
      # Find matching materials in inventory
      matching_items = @inventory.items.where(name: material_name)
      total_available = matching_items.sum(:amount)
      
      # Check if enough material is available
      if total_available < required_amount
        raise "Insufficient resources: #{material_name} (need #{required_amount}, have #{total_available})"
      end
      
      # Consume materials from inventory
      remaining_to_use = required_amount
      matching_items.each do |item|
        if item.amount <= remaining_to_use
          # Use entire item
          remaining_to_use -= item.amount
          item.destroy
        else
          # Use partial item
          item.remove_quantity(remaining_to_use)
          remaining_to_use = 0
        end
        
        break if remaining_to_use <= 0
      end
    end
  end

  def create_unassembled_items
    # Handle different blueprint formats
    if @blueprint['units']
      # If blueprint has 'units' array, create those items
      @blueprint['units'].each do |unit|
        unit_name = unit['name']
        quantity = unit['quantity'].to_i
        
        # Create the unassembled item
        Item.create!(
          name: "Unassembled #{unit_name}",
          amount: quantity,
          material_type: :manufactured_good,
          storage_method: :assembly_storage,
          owner: @owner,
          inventory: @inventory,
          metadata: {
            'blueprint_name' => @blueprint['name'],
            'item_type' => unit['type'],
            'assembled_name' => unit_name,
            'production_date' => Time.current
          }
        )
      end
    elsif @blueprint['outcome']
      # If blueprint has single 'outcome', create that item
      outcome_name = @blueprint['outcome']
      quantity = @blueprint['quantity'] || 1
      
      # Create the unassembled item
      Item.create!(
        name: "Unassembled #{outcome_name}",
        amount: quantity,
        material_type: :manufactured_good,
        storage_method: :assembly_storage,
        owner: @owner,
        inventory: @inventory,
        metadata: {
          'blueprint_name' => @blueprint['name'],
          'item_type' => @blueprint['unit_type'] || 'component',
          'assembled_name' => outcome_name,
          'production_date' => Time.current
        }
      )
    else
      raise "Invalid blueprint format: No units or outcome specified"
    end
  end

  def handle_byproducts
    byproducts = @blueprint['byproducts'] || []
    byproducts.each do |byproduct|
      material_name = byproduct['material']
      amount = byproduct['amount'].to_f
      
      # Create the byproduct item in inventory
      Item.create!(
        name: material_name,
        amount: amount,
        material_type: determine_material_type(material_name),
        storage_method: determine_storage_method(material_name),
        owner: @owner,
        inventory: @inventory
      )
    end
  end
  
  # Helper methods for determining item properties
  def determine_material_type(name)
    return :scrap if name.include?('Scrap')
    return :processed_material if name.start_with?('Processed')
    return :component if name.end_with?('Component')
    return :manufactured_good
  end
  
  def determine_storage_method(name)
    return :hazardous_storage if name.include?('Toxic') || name.include?('Radioactive')
    return :pressurized_storage if name.include?('Gas') || name == 'Oxygen' || name == 'Hydrogen'
    return :bulk_storage if name.include?('Scrap')
    return :standard_storage
  end
end

