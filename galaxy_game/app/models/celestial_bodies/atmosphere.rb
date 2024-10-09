module CelestialBodies
  class Atmosphere < ApplicationRecord
    belongs_to :celestial_body
    has_many :gases, class_name: 'Gas', dependent: :destroy

    # Run setup after creation
    after_create :set_defaults

    def set_defaults
      self.temperature = celestial_body.surface_temperature
      self.pressure = 0
      self.total_atmospheric_mass = 0
      self.atmosphere_composition = {}
      self.pollution = 0   # Default pollution level
      self.dust = {}       # Default dust composition
    end

    def destroy_gases
      gases.each do |gas|
        # Destroy the matching material in the celestial body
        material = celestial_body.materials.find_by(name: gas.name)
        material&.destroy
      end
      gases.destroy_all
    end    

    # Prevents `TerraSim` from running during reset
    def reset
      destroy_gases
  
      # Instantiate the material lookup service
      material_lookup = MaterialLookupService.new
  
      atmosphere_composition.each do |name, data|
        percentage = data["percentage"]
  
        # Use the material lookup service to find additional properties
        material = material_lookup.find_material(name)
  
        # Check if material is found and retrieve properties
        if material
          molar_mass = material['molar_mass']
          melting_point = material['melting_point']
          boiling_point = material['boiling_point']
          vapor_pressure = material['vapor_pressure']
  
          ppm = (percentage / 100.0) * 1_000_000
          mass = (percentage / 100.0) * total_atmospheric_mass
  
          # Create gas
          self.gases.create!(
            name: name,
            percentage: percentage,
            ppm: ppm,
            mass: mass,
            molar_mass: molar_mass || 0,
            atmosphere_id: self.id
          )
  
          # Create Material Object in the parent Celestial Body
          celestial_body.materials.create!(
            name: name,
            amount: mass
          )
        else
          puts "Warning: Material #{name} not found in MaterialLookupService."
        end
      end
  
      # Skip running TerraSim during reset
    end

    def add_gas(name, mass)
      # Ensure the mass is a positive value
      return if mass <= 0

      puts "Adding #{mass} kg of #{name} to the atmosphere."
       
      material = MaterialLookupService.new.find_material(name)
    
      if material.nil?
        raise ArgumentError, "Material '#{name}' not found in the lookup service."
      end
    
      molar_mass = material['molar_mass']
      melting_point = material['melting_point']
      boiling_point = material['boiling_point']
      vapor_pressure = material['vapor_pressure']
    
      existing_gas = gases.find_by(name: name)
    
      if existing_gas
        # Add mass to the existing gas
        existing_gas.mass += mass
        existing_gas.save

        # Update Material Object in the parent Celestial Body
        material = celestial_body.materials.find_by(name: name)
        material.update!(amount: material.amount + mass)
      else
        # Create new gas if it doesn't exist
        gases.create!(
          name: name,
          percentage: nil, # Percentage will be recalculated later
          ppm: nil, # Parts per million will be recalculated later
          mass: mass,
          molar_mass: molar_mass,
          atmosphere_id: self.id
        )

        # Create Material Object in the parent Celestial Body
        celestial_body.materials.create!(
          name: name,
          melting_point: melting_point,
          boiling_point: boiling_point,
          vapor_pressure: vapor_pressure,
          amount: mass,
          molar_mass: molar_mass,
          state: 'gas'
        )        
      end

      # Update total atmospheric mass and gas percentages
      update_total_atmospheric_mass
      recalculate_gas_percentages
    
      # Trigger TerraSim after gas addition
      run_terrasim_service
    end    

    def remove_gas(gas_name, mass_to_remove)
      gas = gases.find_by(name: gas_name)
      return unless gas

      # Update gas mass and ensure it doesn’t go below zero
      gas.mass = [gas.mass - mass_to_remove, 0].max
      gas.save!

      # Update Material Object in the parent Celestial Body
      material = celestial_body.materials.find_by(name: gas_name)
      material.update!(amount: [material.amount - mass_to_remove, 0].max)

      # Recalculate total atmospheric mass and percentages
      update_total_atmospheric_mass
      recalculate_gas_percentages

      # Trigger TerraSim after gas removal
      AtmosphereSimulationService.new(self.celestial_body).simulate
    end

    def update_gas_percentages
      return if total_atmospheric_mass.zero?

      gases.each do |gas|
        percentage = (gas.mass / total_atmospheric_mass) * 100
        gas.update!(percentage: percentage)
      end
    end

    def update_total_atmospheric_mass
      self.total_atmospheric_mass = gases.sum(:mass)
      save!
    end  

    def recalculate_gas_percentages
      return if total_atmospheric_mass.zero?

      gases.each do |gas|
        gas.update!(percentage: (gas.mass / total_atmospheric_mass) * 100)
      end
    end

    def calculate_pressure
      return unless celestial_body # Ensure the celestial body is present

      # Calculate the total gas mass directly from the mass attribute
      total_gas_mass = gases.sum(:mass)

      self.pressure = total_gas_mass / (celestial_body.radius**2 * celestial_body.gravity)
      save # Save the updated pressure to the database
    end

    def habitability_score
      if temperature.between?(273.15, 300.15) && pressure.between?(0.8, 1.2)
        "Habitable"
      else
        "Non-Habitable"
      end
    end

    # Run the simulation service after gases are updated
    def run_terrasim_service
      AtmosphereSimulationService.new(self.celestial_body).simulate
    end

  end
end
