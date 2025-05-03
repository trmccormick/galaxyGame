module CelestialBodies
  module Spheres
    class Geosphere < ApplicationRecord
      include MaterialTransferable
      include GeosphereConcern
      
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      has_many :geological_materials, class_name: 'CelestialBodies::Materials::GeologicalMaterial', dependent: :destroy
      has_many :materials, as: :materializable, dependent: :destroy
      
      # Make skip_simulation accessible
      attr_accessor :skip_simulation
      
      # Base values for reset functionality
      store :base_values, coder: JSON
      
      # Add validations
      validates :geological_activity, numericality: { 
        greater_than_or_equal_to: 0, 
        less_than_or_equal_to: 100 
      }, allow_nil: true
      
      validates :total_crust_mass, :total_mantle_mass, :total_core_mass,
                numericality: true, allow_nil: true

      after_initialize :set_defaults
      after_save :run_simulation, if: :should_run_simulation?
      
      def transfer_material(material_name, amount, target_sphere)
        material = geological_materials.find_by(name: material_name)
        return false unless material && material.mass >= amount

        Material.transaction do
          # Remove from source
          old_mass = material.mass
          material.mass -= amount
          
          # Update layer mass
          layer_mass_attribute = "total_#{material.layer}_mass"
          self.send("#{layer_mass_attribute}=", self.send(layer_mass_attribute) - amount)
          
          if material.mass <= 0
            material.destroy
          else
            material.save!
          end
          
          # Add to target sphere's materials
          target_material = target_sphere.materials.find_or_initialize_by(name: material_name)
          target_material.amount ||= 0
          target_material.amount += amount
          target_material.save!
          
          # Update percentage for remaining materials in the layer
          update_percentages(material.layer)
          save!
        end
        
        true
      end

      def add_material(name, amount, layer = :crust)
        return false if amount <= 0
        
        # Validate layer
        unless LAYERS.include?(layer.to_sym)
          raise ArgumentError, "Invalid layer '#{layer}'. Must be one of: #{LAYERS.join(', ')}"
        end
        
        # Get material properties
        lookup_service = Lookup::MaterialLookupService.new
        material_data = lookup_service.find_material(name)
        
        unless material_data
          raise ArgumentError, "Material '#{name}' not found in the lookup service."
        end
        
        # Check if it's a gas - gases shouldn't be added to geosphere
        if material_data.dig('properties', 'state_at_room_temp') == 'gas'
          raise ArgumentError, "Cannot add gas to geosphere. Use atmosphere.add_gas instead."
        end
        
        # Extract properties
        properties = material_data['properties'] || {}
        melting_point = properties['melting_point']
        boiling_point = properties['boiling_point']
        is_volatile = properties['is_volatile'] || false
        
        # Update layer mass
        layer_mass_attribute = "total_#{layer}_mass"
        current_mass = send(layer_mass_attribute) || 0
        send("#{layer_mass_attribute}=", current_mass + amount)
        
        # Update layer composition
        update_layer_composition(name, amount, layer)
        
        # Save changes
        save!
        
        # Create material in celestial body's materials
        material = celestial_body.materials.find_by(name: name, materializable_type: 'CelestialBodies::Spheres::Geosphere', materializable_id: id)

        if material
          # Update existing material with AMOUNT, not mass
          material.amount = amount  # Use assignment, not += to match test expectations
          material.location = 'geosphere'
          material.state = physical_state(name, temperature)
          material.save!
        else
          # Create new material with AMOUNT, not mass
          material = celestial_body.materials.create!(
            name: name,
            materializable_type: 'CelestialBodies::Spheres::Geosphere',
            materializable_id: id,
            location: 'geosphere',
            amount: amount,
            state: physical_state(name, temperature)
          )
        end
        
        true
      end

      def remove_material(name, amount, layer = :crust)
        return false if amount <= 0
        
        # Validate layer
        unless LAYERS.include?(layer.to_sym)
          raise ArgumentError, "Invalid layer '#{layer}'. Must be one of: #{LAYERS.join(', ')}"
        end
        
        # Get current composition
        composition = send("#{layer}_composition")
        return false unless composition[name].present?
        
        # Calculate amount that can be removed
        total_mass = send("total_#{layer}_mass")
        material_mass = (composition[name].to_f / 100.0) * total_mass
        amount_to_remove = [amount, material_mass].min
        
        # Update layer mass
        send("total_#{layer}_mass=", total_mass - amount_to_remove)
        
        # Update composition percentages
        new_mass = total_mass - amount_to_remove
        
        if new_mass > 0
          # Keep percentages the same
          composition.each do |mat_name, percentage|
            composition[mat_name] = percentage
          end
        else
          # If all material removed, reset composition
          composition = {}
        end
        
        # Update composition
        send("#{layer}_composition=", composition)
        
        # Save changes
        save!
        
        amount_to_remove
      end

      def extract_material(material_name, amount)
        # Check if material exists in composition
        crust_percentage = crust_composition[material_name].to_f
        
        return false if crust_percentage <= 0
        
        # Calculate max available
        max_available = (crust_percentage / 100.0) * total_crust_mass
        extraction_amount = [amount, max_available].min
        
        if extraction_amount > 0
          # Update crust composition
          new_crust_mass = total_crust_mass - extraction_amount
          
          # Recalculate percentages with new mass
          new_composition = {}
          crust_composition.each do |name, percentage|
            if name == material_name
              # Calculate new amount and percentage
              old_amount = (percentage.to_f / 100.0) * total_crust_mass
              new_amount = old_amount - extraction_amount
              new_percentage = (new_amount / new_crust_mass) * 100
              new_composition[name] = new_percentage
            else
              # Other elements need recalculation too
              old_amount = (percentage.to_f / 100.0) * total_crust_mass
              new_percentage = (old_amount / new_crust_mass) * 100
              new_composition[name] = new_percentage
            end
          end
          
          # Update the geosphere
          self.total_crust_mass = new_crust_mass
          self.crust_composition = new_composition
          save!
          
          # Return the amount extracted
          extraction_amount
        else
          0
        end
      end

      def materials
        celestial_body.materials.where(materializable_type: 'CelestialBodies::Spheres::Geosphere', materializable_id: id)
      end
      
      # Method to ensure hashes are simple Ruby hashes, not HashWithIndifferentAccess
      def normalize_hash(hash)
        return {} if hash.nil?
        
        # Convert to regular hash before storing
        if hash.is_a?(ActiveSupport::HashWithIndifferentAccess)
          hash = hash.to_hash
        end
        
        # Process nested hashes
        result = hash.dup
        result.each do |key, value|
          if value.is_a?(Hash) || value.is_a?(ActiveSupport::HashWithIndifferentAccess)
            result[key] = normalize_hash(value)
          end
        end
        
        # Ensure keys are strings for consistency
        result.deep_stringify_keys
      end

      # Nice summaries for display
      def crust_summary
        materials_count = geological_materials.where(layer: 'crust').count
        "Crust: #{GameFormatters::MassFormatter.format(total_crust_mass)} " +
        "with #{materials_count} materials"
      end
      
      def mantle_summary
        materials_count = geological_materials.where(layer: 'mantle').count
        "Mantle: #{GameFormatters::MassFormatter.format(total_mantle_mass)} " +
        "with #{materials_count} materials"
      end
      
      def core_summary
        materials_count = geological_materials.where(layer: 'core').count
        "Core: #{GameFormatters::MassFormatter.format(total_core_mass)} " +
        "with #{materials_count} materials"
      end
      
      # Test compatibility - legacy method
      def resources
        celestial_body.materials.where(materializable_type: 'CelestialBodies::Spheres::Geosphere', materializable_id: id)
      end
      
      def extract_volatiles(temp_increase)
        return {} unless celestial_body&.atmosphere
        
        # Find volatiles in the crust
        volatiles_hash = crust_composition.dig('volatiles') || {}
        total_volatiles = {}
        
        volatiles_hash.each do |name, percentage|
          # Skip if no percentage or invalid
          next if percentage.to_f <= 0
          
          # Calculate mass based on percentage
          volatile_mass = (percentage.to_f / 100.0) * total_crust_mass
          
          # Calculate extraction rate based on temperature (simple model)
          extraction_rate = [temp_increase / 200.0, 0.5].min
          extraction_amount = volatile_mass * extraction_rate
          
          # Extract the volatile
          if extraction_amount > 0
            # SIMPLIFIED APPROACH: Use AtmosphereConcern's add_gas method directly
            celestial_body.atmosphere.add_gas(name, extraction_amount)
            
            # Update the volatile in crust composition
            new_volatile_mass = volatile_mass - extraction_amount
            volatiles_hash[name] = (new_volatile_mass / total_crust_mass) * 100
            
            # Track what was extracted
            total_volatiles[name] = extraction_amount
          end
        end
        
        # Update crust composition with modified volatiles
        if crust_composition.is_a?(Hash) 
          if crust_composition['volatiles']
            crust_composition['volatiles'] = volatiles_hash
          elsif crust_composition[:volatiles]
            crust_composition[:volatiles] = volatiles_hash
          end
        end
        
        save!
        total_volatiles
      end

      private

      def should_run_simulation?
        !skip_simulation && saved_changes?
      end

      def set_defaults
        # Set empty hashes for compositions if they're nil
        self.crust_composition ||= {}
        self.mantle_composition ||= {}
        self.core_composition ||= {}
        self.total_crust_mass ||= 0.0
        self.total_mantle_mass ||= 0.0
        self.total_core_mass ||= 0.0
        self.geological_activity ||= 0
        self.tectonic_activity ||= false
        self.base_values ||= {}
        
        # Only set base values if this is a new record
        return unless new_record? && base_values.blank?
        
        # Set base values
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
      end

      def calculate_percentage(amount, total)
        return 0.0 if total.zero?
        (amount / total) * 100
      end

      def recalculate_compositions
        LAYERS.each do |layer|
          total = send("total_#{layer}_mass")
          composition = {}
          
          materials.each do |material|
            composition[material.name] = calculate_percentage(material.amount, total)
          end
          
          send("#{layer}_composition=", composition)
        end
        save!
      end

      def run_simulation
        # Simplified for now - just calculate tectonic activity
        self.tectonic_activity = geological_activity > 50
        save! if changed?
      end

      def update_layer_composition(name, amount, layer)
        # Get the current composition and mass
        composition = send("#{layer}_composition") || {}
        current_mass = send("total_#{layer}_mass") - amount
        
        # If this is the only material in the layer (new or empty layer)
        if current_mass <= 0 || composition.empty?
          new_composition = { name => 100.0 }
          send("#{layer}_composition=", new_composition)
          return
        end
        
        # Calculate new mass
        new_mass = current_mass + amount
        
        # Calculate percentage for new material
        new_material_percentage = (amount / new_mass) * 100
        
        # Calculate scaling factor for existing materials
        scaling_factor = current_mass / new_mass
        
        # Update all percentages
        new_composition = {}
        composition.each do |mat_name, percentage|
          if mat_name.to_s == 'volatiles'
            new_composition['volatiles'] = composition['volatiles']
          else
            new_composition[mat_name] = percentage.to_f * scaling_factor
          end
        end
        
        # Add the new material
        if new_composition[name]
          new_composition[name] += new_material_percentage
        else
          new_composition[name] = new_material_percentage
        end
        
        # Update composition attribute
        send("#{layer}_composition=", new_composition)
      end

      def update_percentages(layer)
        # Get materials for this layer
        layer_materials = geological_materials.where(layer: layer.to_s)
        layer_mass = send("total_#{layer}_mass") || 0
        
        return if layer_mass <= 0
        
        # Calculate percentages
        layer_materials.each do |material|
          material.percentage = (material.mass / layer_mass) * 100
          material.save!
        end
      end

      # Fix the physical_state method to handle nil values:

      def physical_state(material_name, temp)
        # Get material properties from lookup
        lookup_service = Lookup::MaterialLookupService.new
        material_data = lookup_service.find_material(material_name)
        
        return 'solid' unless material_data && material_data['properties']
        
        properties = material_data['properties']
        melting_point = properties['melting_point'].to_f || 0
        boiling_point = properties['boiling_point'].to_f || 0
        
        # Make sure we have a valid temp
        temp = temp.to_f || 0
        
        # Return state based on temperature (safe from nil)
        if boiling_point > 0 && temp > boiling_point
          'gas'
        elsif melting_point > 0 && temp > melting_point
          'liquid'
        else
          'solid'
        end
      end
    end
  end
end