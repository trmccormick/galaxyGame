# app/models/concerns/material_management_concern.rb
module MaterialManagementConcern
  extend ActiveSupport::Concern

  # Add error handling
  class MaterialError < StandardError; end
  class InvalidMaterialError < MaterialError; end
  class InsufficientMaterialError < MaterialError; end

  included do
    # Any class methods or validations
  end

  # Add a material to the celestial body
  def add_material(name, amount)
    # Validate inputs properly
    raise InvalidMaterialError, "Invalid amount value" if amount <= 0
    raise InvalidMaterialError, "Material name required" if name.blank?
    
    # Get material data to ensure it exists and get standardized ID
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(name)
    
    unless material_data
      raise InvalidMaterialError, "Material '#{name}' not found in materials database"
    end
    
    # Use the material ID for consistency in general materials
    material_id = material_data['id']
    
    # Find or create the material with standardized ID
    material = materials.find_or_initialize_by(name: material_id)
    material.amount ||= 0
    material.amount += amount
    material.save!
    
    # Only update atmosphere for gases, and only in a controlled way
    if has_gas_properties?(material_id)
      # For atmosphere, use chemical formula
      chemical_formula = material_data['chemical_formula']
      update_atmosphere_for_gas(chemical_formula, amount)
    end
    
    material
  end

  # Remove a material from the celestial body
  def remove_material(name, amount)
    # Validate inputs
    raise InvalidMaterialError, "Invalid amount value" if amount <= 0
    raise InvalidMaterialError, "Material name required" if name.blank?
    
    # Get material data to ensure it exists and get standardized ID
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(name)
    
    unless material_data
      raise InvalidMaterialError, "Material '#{name}' not found in materials database"
    end
    
    # Use the material ID for consistency
    material_id = material_data['id']
    
    # Find the material by standardized ID
    material = materials.find_by(name: material_id)
    
    # Check if we have enough
    unless material && material.amount >= amount
      raise InsufficientMaterialError, "Not enough #{material_id} available"
    end
    
    # Update the material amount
    material.amount -= amount
    
    # Remove or save
    if material.amount <= 0
      material.destroy
    else
      material.save!
    end
    
    # Only update atmosphere for gases, and only in a controlled way
    if has_gas_properties?(material_id)
      # For atmosphere, use chemical formula
      chemical_formula = material_data['chemical_formula']
      update_atmosphere_for_gas(chemical_formula, -amount)
    end
    
    true
  end

  private

  def has_gas_properties?(name)
    material_service = Lookup::MaterialLookupService.new
    material_data = material_service.find_material(name)
    
    material_data && 
    material_data['properties'] && 
    material_data['properties']['state_at_room_temp'] &&
    material_data['properties']['state_at_room_temp'].downcase == 'gas'
  end

  # This is the key fix - handle gas updates explicitly
  def update_atmosphere_for_gas(formula_name, amount)
    return unless atmosphere

    if amount > 0
      # Add gas to atmosphere using chemical formula
      existing_gas = atmosphere.gases.find_by(name: formula_name)
      
      if existing_gas
        existing_gas.update_column(:mass, existing_gas.mass + amount)
      else
        atmosphere.gases.create!(
          name: formula_name, 
          mass: amount,
          percentage: calculate_gas_percentage(formula_name, amount)
        )
      end
      
      atmosphere.update_total_atmospheric_mass
    else
      # Remove gas from atmosphere
      existing_gas = atmosphere.gases.find_by(name: formula_name)
      return unless existing_gas
      
      if existing_gas.mass <= amount.abs
        existing_gas.destroy
      else
        existing_gas.update_column(:mass, existing_gas.mass - amount.abs)
      end
      
      atmosphere.update_total_atmospheric_mass
    end
  end
  
  def calculate_gas_percentage(name, amount)
    return 100 unless atmosphere && atmosphere.gases.any?
    
    total_mass = atmosphere.gases.sum(:mass) + amount
    (amount / total_mass) * 100
  end
end