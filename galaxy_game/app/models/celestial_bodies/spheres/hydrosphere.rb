module CelestialBodies
  module Spheres
    class Hydrosphere < ApplicationRecord
      include MaterialTransferable
      include HydrosphereConcern
      
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      has_many :liquid_materials, dependent: :destroy
      has_many :materials, as: :materializable, dependent: :destroy
      
      attr_accessor :simulation_running
      
      # JSONB field accessors
      store_accessor :water_bodies, :oceans, :lakes, :rivers, :ice_caps, :groundwater
      store_accessor :composition
      store_accessor :state_distribution
      
      # Base values for reset functionality
      store_accessor :base_values, :base_water_bodies, :base_composition, :base_state_distribution,
                    :base_temperature, :base_pressure, :base_total_water_mass

      validates :total_water_mass, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
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
        self.total_water_mass = base_total_water_mass
        save!
      end
      
      # Add liquid material to the hydrosphere
      def add_liquid(name, amount)
        return if amount <= 0
        
        # Look up material properties
        lookup_service = Lookup::MaterialLookupService.new
        material_data = lookup_service.find_material(name)
        
        unless material_data
          raise ArgumentError, "Material '#{name}' not found in lookup service"
        end
        
        # Create or update liquid material record
        liquid_material = liquid_materials.find_or_initialize_by(name: name)
        liquid_material.amount ||= 0
        liquid_material.amount += amount
        liquid_material.save!
        
        # Update water distribution
        update_water_distribution(name, amount)
        
        # Update total water mass
        self.total_water_mass ||= 0
        self.total_water_mass += amount
        save!
      end
      
      # Remove liquid material from the hydrosphere
      def remove_liquid(name, amount)
        liquid_material = liquid_materials.find_by(name: name)
        return false unless liquid_material && liquid_material.amount >= amount
        
        # Update liquid material
        liquid_material.amount -= amount
        
        if liquid_material.amount <= 0
          liquid_material.destroy
        else
          liquid_material.save!
        end
        
        # Update total water mass
        self.total_water_mass -= amount
        save!
        
        true
      end

      def transfer_material(material_name, amount, target_sphere)
        # Look in both materials and liquid_materials collections
        material = materials.find_by(name: material_name)
        liquid_material = liquid_materials.find_by(name: material_name) if respond_to?(:liquid_materials)
        
        # For the test cases, prioritize the material over liquid_material
        selected_material = material || liquid_material
        return false unless selected_material && selected_material.amount >= amount

        target_material = target_sphere.materials.find_or_create_by(name: material_name) do |m|
          m.state = 'liquid'
        end

        Material.transaction do
          # Update the source material
          if selected_material.respond_to?(:amount=)
            selected_material.amount -= amount
            selected_material.destroy if selected_material.amount <= 0
            selected_material.save! if selected_material.persisted?
          end
          
          # Update the target material
          target_material.amount ||= 0
          target_material.amount += amount
          target_material.save!
        end
        
        true
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
          self.base_total_water_mass = total_water_mass
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
