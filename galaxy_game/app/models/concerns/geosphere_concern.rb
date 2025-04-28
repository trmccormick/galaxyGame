# app/models/concerns/geosphere_concern.rb
module GeosphereConcern
  extend ActiveSupport::Concern

  # Add error handling similar to AtmosphereConcern
  class GeosphereError < StandardError; end
  class InvalidMaterialError < GeosphereError; end
  class LayerError < GeosphereError; end

  included do
    LAYERS = [:crust, :mantle, :core].freeze
    has_many :materials, as: :materializable, dependent: :destroy
    
    before_validation :set_default_values, if: :new_record?
    after_save :update_material_records, if: :composition_changed?
    after_save :update_material_states, if: :saved_change_to_temperature?
  end
  
  # Reset to base values
  def reset
    return false unless base_values.present?
    
    # Restore from base values
    update!(
      crust_composition: base_values['crust_composition'],
      mantle_composition: base_values['mantle_composition'],
      core_composition: base_values['core_composition'],
      total_crust_mass: base_values['total_crust_mass'],
      total_mantle_mass: base_values['total_mantle_mass'],
      total_core_mass: base_values['total_core_mass'],
      geological_activity: base_values['geological_activity'],
      tectonic_activity: base_values['tectonic_activity'],
      temperature: base_values['temperature'],
      pressure: base_values['pressure']
    )
    
    true
  end
  
  # Extract volatiles based on temperature
  def extract_volatiles(temperature_increase = 0)
    return unless celestial_body&.atmosphere
    
    # Find volatile materials in the crust
    volatiles = materials.where(location: 'geosphere', is_volatile: true)
    return if volatiles.empty?
    
    # Base temperature for volatile release
    base_release_temp = 200 # K, rough approximation for CO2 ice
    
    # Calculate release factor based on temperature difference
    temp = celestial_body.surface_temperature || 273
    temp_with_increase = temp + temperature_increase
    temp_difference = [temp_with_increase - base_release_temp, 0].max
    release_factor = temp_difference * 0.0001 # 0.01% per degree K above base
    
    volatiles_released = {}
    
    # Process each volatile
    volatiles.each do |volatile|
      # Skip if mass is zero
      next if volatile.amount <= 0
      
      # Calculate mass to release
      release_amount = volatile.amount * release_factor
      
      # Don't extract more than a small fraction in one cycle
      max_extractable = volatile.amount * 0.01
      release_amount = [release_amount, max_extractable].min
      
      if release_amount > 0
        puts "Extracting #{release_amount.round(2)} kg of #{volatile.name} from regolith (temperature: #{temp_with_increase.round(1)}K)"
        
        # Transfer to atmosphere
        celestial_body.atmosphere.add_gas(volatile.name, release_amount)
        
        # Reduce in geosphere
        remove_material(volatile.name, release_amount, :crust)
        
        # Track for logging
        volatiles_released[volatile.name] = release_amount
      end
    end
    
    # Return released volatiles
    volatiles_released
  end
  
  # Add material to a specific layer
  def add_material(name, amount, layer = :crust)
    return false if amount <= 0
    
    # Validate layer
    unless LAYERS.include?(layer.to_sym)
      raise LayerError, "Invalid layer '#{layer}'. Must be one of: #{LAYERS.join(', ')}"
    end
    
    # Get material properties from lookup service
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(name)
    
    unless material_data
      raise InvalidMaterialError, "Material '#{name}' not found in the lookup service."
    end
    
    # Check if it's a gas - gases shouldn't be added to geosphere
    if material_data.dig('properties', 'state_at_room_temp') == 'gas'
      raise InvalidMaterialError, "Cannot add gas to geosphere. Use atmosphere.add_gas instead."
    end
    
    # Get current layer mass
    layer_mass_attr = "total_#{layer}_mass"
    current_mass = send(layer_mass_attr) || 0
    
    # Update the layer mass
    send("#{layer_mass_attr}=", current_mass + amount)
    
    # Create or update the material record - IMPORTANT CHANGE HERE
    material = materials.find_by(name: name.to_s)

    if material
      # Update existing material
      material.amount ||= 0
      material.amount += amount
      material.location = 'geosphere'  # Ensure location is set
      material.state = physical_state(name, temperature)
      material.is_volatile = material_data.dig('properties', 'is_volatile') || false
    else
      # Create new material
      material = materials.create!(
        name: name.to_s,
        amount: amount,
        location: 'geosphere',  # Explicitly set location
        state: physical_state(name, temperature),
        is_volatile: material_data.dig('properties', 'is_volatile') || false
      )
    end

    material.save!
    
    # Update composition percentages
    update_composition_percentages(layer)
    
    # Save changes
    save!
    
    # Return true to indicate success
    true
  end
  
  # Remove material from a specific layer
  def remove_material(name, amount, layer = :crust)
    return false if amount <= 0
    
    # Validate layer
    unless LAYERS.include?(layer.to_sym)
      raise LayerError, "Invalid layer '#{layer}'. Must be one of: #{LAYERS.join(', ')}"
    end
    
    # Find the material
    material = materials.find_by(name: name.to_s)
    return false unless material && material.amount.to_f > 0

    # Ensure location is set
    material.location = 'geosphere' if material && material.location.nil?
    
    # Calculate how much to actually remove
    amount_to_remove = [amount, material.amount].min
    
    # Update the material
    material.amount -= amount_to_remove
    
    if material.amount <= 0
      material.destroy
    else
      material.save!
    end
    
    # Update the layer mass
    layer_mass_attr = "total_#{layer}_mass"
    current_mass = send(layer_mass_attr) || 0
    send("#{layer_mass_attr}=", current_mass - amount_to_remove)
    
    # Update composition percentages
    update_composition_percentages(layer)
    
    # Save changes
    save!
    
    # Return the amount actually removed
    amount_to_remove
  end
  
  def calculate_tectonic_activity
    self.tectonic_activity = geological_activity > 50
    save!
    geological_activity
  end

  def update_geological_activity
    # Simple model based on temperature, mass ratio and core iron content
    heat_factor = [temperature.to_f / 6000.0, 1.0].min
    
    # Get mass factor
    total_geosphere_mass = total_crust_mass.to_f + total_mantle_mass.to_f + total_core_mass.to_f
    
    # Convert mass to float before division
    mass_value = celestial_body&.mass.to_f
    mass_value = 1.0e24 if mass_value.zero? # Default if zero
    
    mass_factor = [total_geosphere_mass / mass_value, 1.0].min
    
    # Get iron content in core
    iron_percentage = core_composition['Iron'].to_f / 100.0
    
    # Calculate geological activity
    activity = (heat_factor * 50) + (mass_factor * 30) + (iron_percentage * 20)
    activity = [[activity, 0].max, 100].min
    
    # Update fields
    self.geological_activity = activity.to_i
    self.tectonic_activity = activity > 50
    save!
    
    activity.to_i
  end
  
  def update_material_states
    materials.each do |material|
      current_state = material.state
      new_state = physical_state(material.name, temperature)
      
      if current_state != new_state
        material.update!(state: new_state)
      end
    end
    
    true
  end
  
  def physical_state(material_name, temp)
    # Get material properties from lookup
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(material_name)
    
    return 'solid' unless material_data && material_data['properties']
    
    properties = material_data['properties']
    melting_point = properties['melting_point'].to_f
    boiling_point = properties['boiling_point'].to_f
    
    # Return state based on temperature
    if temp > boiling_point
      'gas'
    elsif temp > melting_point
      'liquid'
    else
      'solid'
    end
  end
  
  def update_material_records
    LAYERS.each do |layer|
      # Fix the method call - should be total_layer_mass, not layer_mass
      layer_mass = send("total_#{layer}_mass")
      layer_composition = send("#{layer}_composition")
      
      next if layer_mass.nil? || layer_mass <= 0 || layer_composition.nil? || layer_composition.empty?
      
      # Process regular materials in composition
      layer_composition.each do |name, percentage|
        next if name.to_s == 'volatiles' || percentage.is_a?(Hash)
        
        material_amount = (percentage.to_f / 100.0) * layer_mass
        
        # Find or create material
        material = materials.find_or_initialize_by(name: name.to_s)
        material.location = 'geosphere'  # Add explicit assignment
        material.amount = material_amount
        material.state = physical_state(name.to_s, temperature)
        material.save!
      end
      
      # Process volatiles separately if they exist
      volatiles = layer_composition.dig('volatiles') || {}
      volatiles.each do |name, percentage|
        material_amount = (percentage.to_f / 100.0) * layer_mass
        
        # Find or create volatile material
        material = materials.find_or_initialize_by(name: name.to_s)
        material.location = 'geosphere'  # Add explicit assignment
        material.amount = material_amount
        material.state = physical_state(name.to_s, temperature)
        material.save!
      end
    end
  end
  
  private
  
  def composition_changed?
    saved_change_to_crust_composition? || 
    saved_change_to_mantle_composition? || 
    saved_change_to_core_composition? ||
    saved_change_to_total_crust_mass? ||
    saved_change_to_total_mantle_mass? ||
    saved_change_to_total_core_mass?
  end
  
  def set_default_values
    # Set default values to avoid nil errors
    self.crust_composition ||= {}
    self.mantle_composition ||= {}
    self.core_composition ||= {}
    self.total_crust_mass ||= 0
    self.total_mantle_mass ||= 0
    self.total_core_mass ||= 0
    self.geological_activity ||= 0
    
    # Store base values for reset functionality
    store_base_values
  end
  
  def store_base_values
    return if self.base_values.present? && !self.base_values.empty?
    
    # Store all current values without triggering callbacks
    self.base_values = {
      'crust_composition' => crust_composition,
      'mantle_composition' => mantle_composition,
      'core_composition' => core_composition,
      'total_crust_mass' => total_crust_mass,
      'total_mantle_mass' => total_mantle_mass,
      'total_core_mass' => total_core_mass,
      'geological_activity' => geological_activity,
      'tectonic_activity' => tectonic_activity,
      'temperature' => temperature,
      'pressure' => pressure
    }
    
    # IMPORTANT: Do not call save! here - instead update without callbacks
    update_column(:base_values, self.base_values) if persisted?
  end
  
  def update_composition_percentages(layer)
    # Get all materials for this layer
    layer_materials = materials.where(location: 'geosphere')
    
    # Get total layer mass
    layer_mass_attr = "total_#{layer}_mass"
    total_mass = send(layer_mass_attr) || 0
    
    return if total_mass <= 0
    
    # Initialize composition hash
    composition = {}
    
    # Calculate percentages for each material
    layer_materials.each do |material|
      percentage = (material.amount / total_mass) * 100
      composition[material.name] = percentage
    end
    
    # Update the composition attribute
    layer_composition_attr = "#{layer}_composition"
    send("#{layer_composition_attr}=", composition)
  end
  
  def calculate_heat_factor
    return 0.5 unless celestial_body&.surface_temperature
    
    # Calculate factor based on temperature (simplified)
    core_temp = temperature || (celestial_body.surface_temperature + 5000)
    [core_temp / 6000.0, 1.0].min # Cap at 1.0
  end
  
  def calculate_mass_factor
    return 0.5 unless celestial_body&.mass && celestial_body.mass > 0
    
    # Sum the layer masses
    total_layers_mass = 0
    LAYERS.each do |layer|
      mass_method = "total_#{layer}_mass"
      total_layers_mass += send(mass_method) if respond_to?(mass_method) && send(mass_method)
    end
    
    # Avoid division by zero
    return 0.5 if total_layers_mass == 0
    
    # Calculate ratio compared to celestial body mass
    [total_layers_mass / celestial_body.mass.to_f, 1.0].min
  end
  
  # Simplified model for radioactive heating
  def radioactive_decay
    # This could be enhanced with actual radioactive material content
    0.3 # Default moderate level for now
  end
end