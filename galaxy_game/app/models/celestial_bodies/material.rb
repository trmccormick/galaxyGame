module CelestialBodies
  class Material < ApplicationRecord
    belongs_to :celestial_body
    belongs_to :materializable, polymorphic: true, optional: true

    # Ensure these enums are correctly defined
    enum state: { solid: 0, liquid: 1, gas: 2 }
    enum location: {
      'atmosphere' => 0,
      'surface' => 1,
      'geosphere' => 2,
      'hydrosphere' => 3,
      'crust' => 4,
      'mantle' => 5,
      'core' => 6
    }
    
    # Add enum for layer (optional but can be helpful)
    enum layer: {
      'crust' => 0,
      'mantle' => 1,
      'core' => 2,
      'unknown' => 3
    }, _prefix: true
    
    validates :name, presence: true
    validates :amount, numericality: { greater_than_or_equal_to: 0 }
    
    # Transfer material to another sphere
    def transfer_to(target, transfer_amount)
      # Don't transfer more than we have
      transfer_amount = [amount, transfer_amount.to_f].min
      return 0 if transfer_amount <= 0
      
      # Special case handling for atmosphere
      if target.is_a?(CelestialBodies::Spheres::Atmosphere)
        # If transferring to atmosphere, use add_gas
        if gas?
          target.add_gas(name, transfer_amount)
        else
          # Create a gas in the target
          target.add_gas(name, transfer_amount)
        end
      elsif target.respond_to?(:materials)
        # Create a new material in the target
        target_location = target.class.name.demodulize.downcase.to_sym
        target_material = target.materials.find_or_initialize_by(
          name: name,
          location: target_location
        )
        
        # Determine state in new location
        target_temp = target.temperature
        new_state = if target.is_a?(CelestialBodies::Spheres::Atmosphere)
                      'gas'
                    elsif materializable.respond_to?(:physical_state)
                      materializable.physical_state(name, target_temp)
                    else
                      state
                    end
        
        # Update target material
        target_material.state = new_state
        target_material.amount ||= 0
        target_material.amount += transfer_amount
        target_material.save!
      end
      
      # Reduce our amount
      self.amount -= transfer_amount
      
      if amount <= 0
        destroy
      else
        save!
      end
      
      # Return the amount transferred
      transfer_amount
    end
    
    # Helper methods to check state
    def solid?
      state == 'solid'
    end
    
    def liquid?
      state == 'liquid'
    end
    
    def gas?
      state == 'gas'
    end
    
    # Get material properties from lookup service
    def properties
      @properties ||= Lookup::MaterialLookupService.new.find_material(name)
    end
    
    def molar_mass
      properties&.dig('properties', 'molar_mass')
    end
    
    def melting_point
      properties&.dig('properties', 'melting_point')
    end
    
    def boiling_point
      properties&.dig('properties', 'boiling_point')
    end
  end
end