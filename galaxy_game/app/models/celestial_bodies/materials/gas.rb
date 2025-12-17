# app/models/celestial_bodies/materials/gas.rb
module CelestialBodies
  module Materials
    # The issue is that when we inherit from ::Gas, we're inheriting its association
    # which expects the top-level Atmosphere class
    class Gas < ApplicationRecord
      include MaterialPropertiesConcern
      
      # Define our own association instead of inheriting from ::Gas
      self.table_name = 'gases'
      
      # Use foreign_key to explicitly specify the column name
      belongs_to :atmosphere, 
                 class_name: 'CelestialBodies::Spheres::Atmosphere',
                 foreign_key: 'atmosphere_id'
      
      # Remove name validation since it's now in the concern
      # validates :name, presence: true
      
      validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
      validates :ppm, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :mass, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :molar_mass, numericality: { greater_than_or_equal_to: 0 }, presence: true
      
      # set_molar_mass_from_material is now in the concern
      # but we still need to call it
      before_validation :set_molar_mass_from_material
      before_validation :normalize_name_to_formula
            # Always store the chemical formula as the name
            def normalize_name_to_formula
              if name.present?
                mat = Lookup::MaterialLookupService.new.find_material(name)
                formula = mat && mat['chemical_formula'].present? ? mat['chemical_formula'] : name
                self.name = formula
              end
            end
      
      # Calculate moles of gas based on the material's amount and molar mass
      def moles(amount)
        return 0 unless amount && molar_mass
        (amount / molar_mass).to_f
      end
      
      private
      
      # Remove set_molar_mass_from_material since it's in the concern
      
      # Override the default_state method from the concern
      def default_state
        'gas'
      end
    end
  end
end