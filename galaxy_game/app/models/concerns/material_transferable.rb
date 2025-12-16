module MaterialTransferable
  extend ActiveSupport::Concern

  included do
    after_save :set_location_defaults, if: :saved_change_to_id?
  end

  def transfer_material(material_name, amount, target)
    # Get material data to standardize name
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(material_name)
    
    unless material_data
      Rails.logger.warn "Material '#{material_name}' not found in materials database"
      return false
    end
    
    # Use ID for general materials
    material_id = material_data['id']
    
    # Different handling based on target type
    source_material = materials.find_by(name: material_id)
    return false unless source_material && source_material.amount >= amount

    # ✅ Better error handling for different sphere types
    begin
      Material.transaction do
        source_material.update!(amount: source_material.amount - amount)
        
        # For atmosphere targets, use chemical formula
        if target.is_a?(CelestialBodies::Spheres::Atmosphere)
          chemical_formula = material_data['chemical_formula']
          target.add_gas(chemical_formula, amount) if chemical_formula
        # For hydrosphere targets, special handling
        elsif target.is_a?(CelestialBodies::Spheres::Hydrosphere)
          target.add_liquid(material_id, amount)
        # For other targets, use consistent ID
        else
          target_material = target.materials.find_or_create_by(name: material_id) do |m|
            m.state = source_material.state
            m.celestial_body = target.celestial_body
            m.materializable = target  # ✅ Ensure this is set
          end
          target_material.update!(amount: target_material.amount + amount)
        end
      end
      
      true
    rescue => e
      Rails.logger.error "Transfer failed: #{e.message}"
      false
    end
  end

  private

  def after_material_transfer(material_name, amount)
    # Override in each sphere model for specific behavior
  end

  def set_location_defaults
    # Safety check to avoid errors with nil celestial_body
    return unless respond_to?(:celestial_body) && celestial_body.present?
    
    # Only update materials with nil location
    materials.where(location: nil).find_each do |material|
      # Use update_column to bypass callbacks
      material.update_column(:location, default_location) if material.persisted?
    end
  end

  def default_location
    # This should match the materializable type
    if self.is_a?(CelestialBodies::Spheres::Geosphere)
      'geosphere'
    elsif self.is_a?(CelestialBodies::Spheres::Atmosphere)
      'atmosphere'
    elsif self.is_a?(CelestialBodies::Spheres::Hydrosphere)
      'hydrosphere'
    else
      'unknown'
    end
  end

  # Add this helper method
  def update_total_mass
    if self.is_a?(CelestialBodies::Spheres::Geosphere) && 
       respond_to?(:total_crust_mass) && 
       respond_to?(:total_mantle_mass) && 
       respond_to?(:total_core_mass)
      self.total_geosphere_mass = total_crust_mass + total_mantle_mass + total_core_mass
      save!
    end
  end

  # Helper to update the appropriate mass based on sphere type
  def update_appropriate_mass
    if respond_to?(:update_total_mass)
      update_total_mass
    elsif respond_to?(:update_total_atmospheric_mass) 
      update_total_atmospheric_mass
    elsif respond_to?(:update_total_hydrosphere_mass)
      update_total_hydrosphere_mass
    end
  end
end