module CelestialBodies
  module MinorBodies
    class Protoplanet < CelestialBody
      include SolidBodyConcern

      # Protoplanets are large asteroids that are considered embryonic planets
      # They can have masses similar to dwarf planets but are in the asteroid belt
      validates :mass, numericality: { greater_than: 1e19, less_than_or_equal_to: 1e24 }, allow_nil: true

      # Set STI type
      before_validation :set_sti_type

      # Protoplanets are in hydrostatic equilibrium (round)
      def is_spherical?
        true
      end

      # Protoplanets have higher geological activity than regular asteroids
      def calculate_geological_activity
        return 20 unless mass.present?

        # Higher activity based on mass (embryonic planetary processes)
        mass_factor = mass.to_f / 1.0e21
        [mass_factor * 30, 60].min
      end

      # Material composition - protoplanets are differentiated
      def composition_type
        # Protoplanets have differentiated structures
        [:differentiated_metal_core, :differentiated_stony].sample
      end

      def estimated_mineral_value
        return 0 unless mass.present?

        # Higher value due to differentiation and accessibility
        value_per_kg = case composition_type
                      when :differentiated_metal_core then 50.0  # Very high value (iron-nickel core)
                      when :differentiated_stony then 15.0       # High value (processed materials)
                      else 10.0
                      end

        (mass * value_per_kg).to_i
      end

      private

      def set_sti_type
        self.type = 'CelestialBodies::MinorBodies::Protoplanet'
      end
    end
  end
end