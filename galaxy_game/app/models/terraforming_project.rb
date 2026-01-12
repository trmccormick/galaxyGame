class TerraformingProject < ApplicationRecord
  belongs_to :target_celestial_body, class_name: 'CelestialBodies::CelestialBody'
  belongs_to :source_celestial_body, class_name: 'CelestialBodies::CelestialBody', optional: true
  
  enum status: { pending: 0, active: 1, paused: 2, completed: 3, failed: 4 }
  enum project_type: { 
    atmospheric_transfer: 0, 
    moxie_processing: 1,
    magnetic_shield: 2,
    orbital_mirror: 3,
    albedo_modification: 4,
    temperature_control: 5,
    biosphere_seeding: 6,    # Add biosphere projects
    biodiversity_expansion: 7
  }
  
  # Project settings and progress
  serialize :settings, Hash
  serialize :progress_data, Hash
  
  def process_cycle
    # Use the appropriate service based on project type
    case project_type.to_sym
    when :atmospheric_transfer
      process_atm_transfer
    when :moxie_processing
      process_moxie
    when :biosphere_seeding
      process_biosphere_seeding
    else
      # Other project types
    end
    
    # Update progress tracking
    update_progress
    
    # Check if goals have been met
    check_completion
  end
  
  private
  
  def process_atm_transfer
    # Use the atmospheric transfer service for this cycle
    transfer_service = TerraSim::AtmosphericTransferService.new(
      source_celestial_body,
      target_celestial_body,
      settings: settings
    )
    
    # Calculate transfer capacity for this cycle
    cycle_capacity = calculate_cycle_capacity
    
    # Perform the transfer
    transfer_params = {
      capacity: cycle_capacity,
      efficiency: settings['efficiency'] || 0.98
    }
    
    # Add mode-specific parameters
    case settings['transfer_mode']
    when 'processed'
      transfer_params[:co2_ratio] = settings['co2_ratio'] || 0.8
      transfer_params[:n2_ratio] = settings['n2_ratio'] || 0.2
      transfer_params[:processing_efficiency] = settings['processing_efficiency'] || 0.95
    when 'selective'
      transfer_params[:gases] = settings['gases'] || { 'CO2' => cycle_capacity * 0.8, 'N2' => cycle_capacity * 0.2 }
    end
    
    # Perform the transfer  
    result = transfer_service.transfer_atmosphere(transfer_params)
    
    # Update progress tracking
    update_transferred_materials(result)
  end
  
  def process_moxie
    # Implement MOXIE processing directly on the target planet
  end
  
  def process_biosphere_seeding
    biosphere = target_celestial_body.biosphere
    return unless biosphere
    
    # Find all compatible biomes based on current conditions
    temperature = target_celestial_body.surface_temperature
    atmosphere = target_celestial_body.atmosphere
    humidity = calculate_humidity(atmosphere) # Helper method to estimate humidity
    
    # Find suitable biomes for these conditions
    suitable_biomes = Biome.biomes_for_conditions(temperature, humidity)
    
    # Seed 1-2 new biomes per cycle if suitable
    suitable_biomes.sample(2).each do |biome|
      next if biosphere.biomes.include?(biome)
      biosphere.planet_biomes.create(biome: biome)
    end
    
    # Update progress tracking
    self.progress_data['biomes_seeded'] ||= 0
    self.progress_data['biomes_seeded'] += 1
    
    # Update biosphere data
    biosphere.calculate_biodiversity_index
    
    save!
  end
  
  def calculate_cycle_capacity
    # Standard capacity based on fleet size and vehicle capacity
    base_capacity = settings['fleet_size'].to_i * settings['vehicle_capacity'].to_f
    
    # Apply any efficiency modifiers
    base_capacity * (settings['capacity_modifier'] || 1.0)
  end
  
  def update_transferred_materials(result)
    self.progress_data['materials_transferred'] ||= {}
    
    # Track total materials extracted and delivered
    result[:gases_extracted].each do |gas, amount|
      self.progress_data['materials_transferred'][gas.to_s] ||= 0
      self.progress_data['materials_transferred'][gas.to_s] += amount
    end
    
    # Track converted materials
    if result[:gases_produced].present?
      self.progress_data['materials_produced'] ||= {}
      result[:gases_produced].each do |gas, amount|
        self.progress_data['materials_produced'][gas.to_s] ||= 0
        self.progress_data['materials_produced'][gas.to_s] += amount
      end
    end
    
    self.progress_data['cycles_completed'] ||= 0
    self.progress_data['cycles_completed'] += 1
    
    save!
  end
  
  def update_progress
    # Calculate progress percentage based on target goals
    if settings['target_pressure']
      current = target_celestial_body.atmosphere.pressure
      initial = progress_data['initial_pressure'] || current
      target = settings['target_pressure']
      
      if target > initial
        # Goal is to increase pressure
        progress_pct = ((current - initial) / (target - initial) * 100).round(2)
        self.progress_data['completion_percentage'] = progress_pct
      else
        # Goal is to decrease pressure
        progress_pct = ((initial - current) / (initial - target) * 100).round(2)
        self.progress_data['completion_percentage'] = progress_pct
      end
    end
    
    save!
  end
  
  def check_completion
    # Check if project is complete
    if progress_data['completion_percentage'].to_f >= 100
      self.status = :completed
      save!
    end
  end
end