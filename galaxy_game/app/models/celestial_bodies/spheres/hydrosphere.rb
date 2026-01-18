module CelestialBodies
  module Spheres
    class Hydrosphere < ApplicationRecord
      include MaterialTransferable
      include HydrosphereConcern
      
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      has_many :liquid_materials, class_name: 'CelestialBodies::Materials::Liquid', dependent: :destroy
      has_many :materials, as: :materializable, dependent: :destroy
      
      validates :total_liquid_mass, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :temperature, presence: true
      validates :pressure, presence: true
      
      attr_accessor :simulation_running
      
      # JSONB field accessors - using generic names for liquid bodies
      store_accessor :water_bodies, :oceans, :lakes, :rivers, :ice_caps, :subsurface
      store_accessor :composition
      store_accessor :state_distribution
      
      # Alias for backward compatibility
      alias_method :groundwater, :subsurface
      alias_method :groundwater=, :subsurface=
      
      # Base values for reset functionality
      store_accessor :base_values, :base_liquid_bodies, :base_composition, :base_state_distribution,
                    :base_temperature, :base_pressure, :base_total_liquid_mass

      # Alias for backward compatibility and generic access
      alias_attribute :total_liquid_mass, :total_water_mass
      alias_attribute :liquid_bodies, :water_bodies
      alias_attribute :total_hydrosphere_mass, :total_water_mass

      after_initialize :set_defaults
      after_update :run_simulation, unless: :simulation_running
      
      # Setup liquid materials from celestial body
      def setup_liquid_materials
        update_liquid_materials_from_celestial_body
        calculate_liquid_volume
      end
      
      # Update liquid materials from celestial body
      def update_liquid_materials_from_celestial_body
        return unless celestial_body
        
        liquid_materials_from_body = celestial_body.materials.where(state: 'liquid')
        liquid_materials_from_body.each do |material|
          liquid_mat = liquid_materials.find_or_initialize_by(name: material.name)
          liquid_mat.amount ||= 0
          liquid_mat.amount += material.amount
          liquid_mat.save!
        end
        
        # Handle ice (solid water)
        ice_materials = celestial_body.materials.where(name: 'water', state: 'solid')
        total_ice = ice_materials.sum(:amount)
        self.ice = total_ice if total_ice > 0
      end
      
      # Calculate total liquid volume
      def calculate_liquid_volume
        total = (oceans || 0) + (lakes || 0) + (rivers || 0) + (ice || 0)
        self.liquid_volume = total
        total
      end
      
      # Update water cycle (simplified)
      def update_water_cycle
        # Melt ice if above freezing
        if temperature > 273.15 && ice > 0
          melt_amount = [ice * 0.1, ice].min # Melt 10% per cycle
          self.oceans += melt_amount
          self.ice -= melt_amount
          save!
        end
      end
      
      # Evaporate liquids
      def evaporate_liquids
        if evaporation_condition_met?
          total_liquid = (oceans || 0) + (lakes || 0) + (rivers || 0)
          evaporate_amount = total_liquid * 0.1 # Evaporate 10%
          
          # Distribute evaporation proportionally
          ocean_evap = oceans * 0.7
          lake_evap = lakes * 0.2
          river_evap = rivers * 0.1
          
          self.oceans -= ocean_evap
          self.lakes -= lake_evap
          self.rivers -= river_evap
          save!
        end
      end
      
      # Check if evaporation conditions are met
      def evaporation_condition_met?
        temperature > 273.15 && (oceans || 0) + (lakes || 0) + (rivers || 0) > 0
      end
      
      # Current temperature (alias for temperature)
      def current_temperature
        temperature
      end
      
      # Reset to base values
      def reset
        self.liquid_bodies = base_liquid_bodies.deep_dup if base_liquid_bodies
        self.composition = base_composition.deep_dup if base_composition
        self.state_distribution = base_state_distribution.deep_dup if base_state_distribution
        self.temperature = base_temperature
        self.pressure = base_pressure
        self.total_liquid_mass = base_total_liquid_mass
      end
      
      # Add liquid to hydrosphere
      def add_liquid(name_or_material, amount = nil, state = 'liquid')
        if name_or_material.is_a?(Material)
          material = name_or_material
          name = material.name
          amount = material.amount
        else
          name = name_or_material
          amount ||= 0
        end
        
        # Validate inputs
        raise ArgumentError, "Invalid amount" if amount <= 0
        raise ArgumentError, "Name required" if name.blank?
        
        # Get material data
        lookup_service = Lookup::MaterialLookupService.new
        material_data = lookup_service.find_material(name)
        
        # Allow basic materials even if not in lookup
        # unless material_data
        #   raise ArgumentError, "Material '#{name}' not found in the lookup service."
        # end
        
        # Create or update liquid material record
        liquid_material = liquid_materials.find_or_initialize_by(name: name)
        liquid_material.amount ||= 0
        liquid_material.amount += amount
        liquid_material.save!
        
        # Update liquid distribution
        update_liquid_distribution(name, amount)
        
        # Update total liquid mass
        self.total_liquid_mass ||= 0
        self.total_liquid_mass += amount
        save!
      end
      
      # Remove liquid from hydrosphere
      def remove_liquid(name, amount)
        # Validate inputs
        raise ArgumentError, "Invalid amount" if amount <= 0
        raise ArgumentError, "Name required" if name.blank?
        
        # Find liquid material
        liquid_material = liquid_materials.find_by(name: name)
        
        unless liquid_material
          raise ArgumentError, "Material '#{name}' not found in hydrosphere"
        end
        
        # Update liquid material
        liquid_material.amount -= amount
        
        if liquid_material.amount <= 0
          liquid_material.destroy
        else
          liquid_material.save!
        end
        
        # Update total liquid mass
        self.total_liquid_mass -= amount
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
        # Check if the celestial body is in an ocean by examining liquid bodies
        return false unless liquid_bodies
        
        # Either the liquid_bodies has oceans defined with significant volume
        # or liquid_bodies has a high percentage of liquid covering the surface
        if liquid_bodies['oceans'].present? && liquid_bodies['oceans'].to_f > 1.0e15
          return true
        end
        
        # Check state_distribution if no oceans defined
        if state_distribution && state_distribution['liquid'].to_f > 70
          return true
        end
        
        false
      end

      def ice
        # Get ice_caps from liquid_bodies hash
        ice_caps = liquid_bodies&.dig('ice_caps')
        if ice_caps.is_a?(Hash)
          ice_caps['volume'].to_f
        else
          ice_caps.to_f || 0.0
        end
      end

      def ice=(value)
        self.liquid_bodies ||= {}
        self.liquid_bodies['ice_caps'] = value
        save! if persisted?
      end

      def update_hydrosphere_volume
        total_volume = 0

        %w[oceans lakes rivers ice_caps].each do |body|
          value = liquid_bodies&.dig(body)
          if value.is_a?(Hash)
            total_volume += value['volume'].to_f
          else
            total_volume += value.to_f if value
          end
        end

        update(total_liquid_mass: total_volume)
      end

      def water_coverage
        return 0.0 unless celestial_body&.surface_area&.positive?
        total_water_area = (oceans.to_f || 0) + (lakes.to_f || 0) + (rivers.to_f || 0)
        (total_water_area / celestial_body.surface_area) * 100.0
      end      

      private
      
      def update_liquid_distribution(name, amount)
        # Default distribution: 70% oceans, 20% lakes, 10% rivers
        self.liquid_bodies ||= {}
        self.liquid_bodies['oceans'] ||= 0
        self.liquid_bodies['lakes'] ||= 0
        self.liquid_bodies['rivers'] ||= 0
        
        self.liquid_bodies['oceans'] += amount * 0.7
        self.liquid_bodies['lakes'] += amount * 0.2
        self.liquid_bodies['rivers'] += amount * 0.1
      end

      def set_defaults
        self.liquid_bodies ||= {}
        self.composition ||= {}
        self.state_distribution ||= { liquid: 0.0, solid: 0.0, vapor: 0.0 }
        
        # Set base values if not already set
        unless base_values.present?
          self.base_liquid_bodies = liquid_bodies.deep_dup
          self.base_composition = composition.deep_dup
          self.base_state_distribution = state_distribution.deep_dup
          self.base_temperature = temperature
          self.base_pressure = pressure
          self.base_total_liquid_mass = total_liquid_mass
        end
      end

      def run_simulation
        # Prevent recursive updates
        self.simulation_running = true
        
        # Call water_cycle_tick from the concern
        water_cycle_tick
        
        self.simulation_running = false
      end

      private

      def set_defaults
        set_base_values
      end

      def set_base_values
        self.base_values ||= {}
        self.base_values['base_liquid_bodies'] = {}
        self.base_values['base_composition'] = {}
        self.base_values['base_state_distribution'] = { 'liquid' => 0.0, 'solid' => 0.0, 'vapor' => 0.0 }
        self.base_values['base_temperature'] = 0.0
        self.base_values['base_pressure'] = 0.0
        self.base_values['base_total_liquid_mass'] = 0.0
      end

    end
  end
end
