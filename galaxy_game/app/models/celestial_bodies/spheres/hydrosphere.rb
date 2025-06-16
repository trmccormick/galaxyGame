module CelestialBodies
  module Spheres
    class Hydrosphere < ApplicationRecord
      include MaterialTransferable
      include HydrosphereConcern
      
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      has_many :liquid_materials, class_name: 'CelestialBodies::Materials::Liquid', dependent: :destroy
      has_many :materials, as: :materializable, dependent: :destroy
      
      attr_accessor :simulation_running
      
      # JSONB field accessors
      store_accessor :water_bodies, :oceans, :lakes, :rivers, :ice_caps, :groundwater
      store_accessor :composition
      store_accessor :state_distribution
      
      # Base values for reset functionality
      store_accessor :base_values, :base_water_bodies, :base_composition, :base_state_distribution,
                    :base_temperature, :base_pressure, :base_total_hydrosphere_mass

      validates :total_hydrosphere_mass, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :temperature, :pressure, presence: true

      after_initialize :set_defaults
      after_update :run_simulation, unless: :simulation_running
      
      # Reset to base values
      def reset
        self.water_bodies = base_water_bodies.deep_dup if base_water_bodies
        self.composition = base_composition.deep_dup if base_composition
        self.state_distribution = base_state_distribution.deep_dup if base_state_distribution
        self.temperature = base_temperature
        self.pressure = base_pressure
        self.total_hydrosphere_mass = base_total_hydrosphere_mass
        save!
      end
      
      # Add liquid to hydrosphere
      def add_liquid(name, amount, state = 'liquid')
        # Validate inputs
        raise ArgumentError, "Invalid amount" if amount <= 0
        raise ArgumentError, "Name required" if name.blank?
        
        # Get material data
        lookup_service = Lookup::MaterialLookupService.new
        material_data = lookup_service.find_material(name)
        
        unless material_data
          raise ArgumentError, "Material '#{name}' not found in the lookup service."
        end
        
        # Create or update liquid material record
        liquid_material = liquid_materials.find_or_initialize_by(name: name)
        liquid_material.amount ||= 0
        liquid_material.amount += amount
        liquid_material.save!
        
        # Update water distribution
        update_water_distribution(name, amount)
        
        # Update total water mass
        self.total_hydrosphere_mass ||= 0
        self.total_hydrosphere_mass += amount
        save!
      end
      
      # Remove liquid from hydrosphere
      def remove_liquid(name, amount)
        # Validate inputs
        raise ArgumentError, "Invalid amount" if amount <= 0
        raise ArgumentError, "Name required" if name.blank?
        
        # Find material
        material = materials.find_by(name: name.to_s, location: 'hydrosphere')
        
        unless material
          raise ArgumentError, "Material '#{name}' not found in hydrosphere"
        end
        
        # Update liquid material
        material.amount -= amount
        
        if material.amount <= 0
          material.destroy
        else
          material.save!
        end
        
        # Update total water mass
        self.total_hydrosphere_mass -= amount
        save!
        
        true
      end

      def transfer_material(material_name, amount, target_sphere)
        # Look in both materials and liquid_materials collections
        material = materials.find_by(name: material_name)
        liquid_material = liquid_materials.find_by(name: material_name) if respond_to?(:liquid_materials)
        
        selected_material = material || liquid_material
        return false unless selected_material && selected_material.amount >= amount

        # ✅ Use proper transaction and validation
        begin
          Material.transaction do
            # Update source material
            selected_material.amount -= amount
            if selected_material.amount <= 0
              selected_material.destroy!
            else
              selected_material.save!
            end
            
            # Create target material with proper associations
            target_material = target_sphere.materials.find_or_initialize_by(name: material_name)
            
            # ✅ Ensure all required associations are set
            target_material.celestial_body = target_sphere.celestial_body
            target_material.materializable = target_sphere
            target_material.state = 'liquid'
            target_material.location = target_sphere.class.name.demodulize.downcase
            
            target_material.amount ||= 0
            target_material.amount += amount
            target_material.save!
          end
          
          true
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Material transfer failed: #{e.message}"
          false
        end
      end

      def in_ocean?
        # Check if the celestial body is in an ocean by examining water bodies
        return false unless water_bodies
        
        # Either the water_bodies has oceans defined with significant volume
        # or water_bodies has a high percentage of liquid water covering the surface
        if water_bodies['oceans'].present? && water_bodies['oceans'].to_f > 1.0e15
          return true
        end
        
        # Check state_distribution if no oceans defined
        if state_distribution && state_distribution['liquid'].to_f > 70
          return true
        end
        
        false
      end

      def ice
        # Get ice_caps from water_bodies hash
        water_bodies&.dig('ice_caps').to_f || 0.0
      end

      def ice=(value)
        self.water_bodies ||= {}
        self.water_bodies['ice_caps'] = value
        save! if persisted?
      end

      def update_hydrosphere_volume
        # Use self instead of @hydrosphere since this is an instance method
        total_volume = 0
        total_volume += water_bodies&.dig('oceans').to_f || 0
        total_volume += water_bodies&.dig('lakes').to_f || 0
        total_volume += water_bodies&.dig('rivers').to_f || 0
        total_volume += water_bodies&.dig('ice_caps').to_f || 0
        
        update(total_hydrosphere_mass: total_volume)
      end

      def water_coverage
        return 0.0 unless celestial_body&.surface_area&.positive?
        total_water_area = (oceans || 0) + (lakes || 0) + (rivers || 0)
        (total_water_area / celestial_body.surface_area) * 100.0
      end      

      private
      
      def update_water_distribution(name, amount)
        # Default distribution: 70% oceans, 20% lakes, 10% rivers
        self.water_bodies ||= {}
        self.water_bodies['oceans'] ||= 0
        self.water_bodies['lakes'] ||= 0
        self.water_bodies['rivers'] ||= 0
        
        self.water_bodies['oceans'] += amount * 0.7
        self.water_bodies['lakes'] += amount * 0.2
        self.water_bodies['rivers'] += amount * 0.1
      end

      def set_defaults
        self.water_bodies ||= {}
        self.composition ||= {}
        self.state_distribution ||= { liquid: 0.0, solid: 0.0, vapor: 0.0 }
        
        # Set base values if not already set
        unless base_values.present?
          self.base_water_bodies = water_bodies.deep_dup
          self.base_composition = composition.deep_dup
          self.base_state_distribution = state_distribution.deep_dup
          self.base_temperature = temperature
          self.base_pressure = pressure
          self.base_total_hydrosphere_mass = total_hydrosphere_mass
        end
      end

      def run_simulation
        # Prevent recursive updates
        self.simulation_running = true
        
        # Call water_cycle_tick from the concern
        water_cycle_tick
        
        self.simulation_running = false
      end

    end
  end
end
