module CelestialBodies
  module Planets
    module Rocky
      class CarbonPlanet < RockyPlanet
        # Carbon planets have distinctive compositions
        validate :validate_carbon_composition
        
        # Set STI type
        before_validation :set_sti_type
        
        # Carbon planets are typically denser than silicate planets
        validates :density, numericality: { greater_than: 5.0 }, allow_nil: true
        
        # Override density calculation to account for carbon-rich composition
        def calculate_density
          # Carbon planets are denser than similar silicate planets
          # (graphite/diamond core instead of iron)
          base_density = super
          carbon_factor = 1.2 # 20% denser due to carbon
          
          base_density * carbon_factor
        end
        
        # Specialized surface features
        def surface_features
          features = []
          
          # Basic rocky features
          features << "rocky_terrain"
          features << "carbon_rich_crust"
          
          # Potential diamond features
          features << "diamond_formations"
          features << "graphite_plains"
          
          # Carbide minerals
          features << "silicon_carbide_deposits"
          features << "titanium_carbide_features"
          
          # Atmosphere-related features if present
          if atmosphere.present?
            gas_names = atmosphere.gases.pluck(:name)
            
            if gas_names.include?("CO2") || gas_names.include?("CO")
              features << "carbon_monoxide_clouds"
            end
            
            if gas_names.include?("CH4")
              features << "methane_lakes"
            end
          end
          
          features
        end
        
        # Carbon planets may have different habitability
        def habitability_factors
          factors = super || {}
          
          # Carbon biochemistry potential
          factors[:carbon_based_life] = "exotic_carbon_chemistry"
          
          # Challenging environment
          factors[:surface_conditions] = "inhospitable_to_earth_life"
          
          # Could potentially support silicon-carbon hybrid chemistry
          factors[:exotic_biochemistry] = "possible"
          
          factors
        end
        
        # Estimate diamond layer thickness
        def estimate_diamond_layer
          return nil unless mass.present? && radius.present?
          
          # Carbon planets likely have a significant diamond layer
          # beneath the crust due to pressure
          earth_mass_ratio = mass / 5.97e24
          core_radius = estimate_core_size
          
          # Diamond layer sits between core and crust
          crust_thickness = radius * 0.01 # Estimated 1% of radius is crust
          diamond_layer_thickness = (radius - core_radius - crust_thickness) * 0.4
          
          # Higher mass = higher pressure = more diamonds
          diamond_layer_thickness * [earth_mass_ratio, 0.5].max
        end
        
        private
        
        def set_sti_type
          self.type = 'CelestialBodies::Planets::Rocky::CarbonPlanet'
        end
        
        def validate_carbon_composition
          return unless geosphere.present? && geosphere.crust_composition.present?
          
          carbon_content = 0
          
          # Check for carbon in various forms in crust composition
          if geosphere.crust_composition['elements'].present?
            carbon_content += geosphere.crust_composition['elements']['C'].to_f
          end
          
          if geosphere.crust_composition['compounds'].present?
            carbon_compounds = geosphere.crust_composition['compounds'].keys.select { |k| k.include?('C') }
            carbon_compounds.each do |compound|
              carbon_content += geosphere.crust_composition['compounds'][compound].to_f
            end
          end
          
          if carbon_content < 25.0
            errors.add(:geosphere, "must have at least 25% carbon content for a carbon planet")
          end
        end
      end
    end
  end
end