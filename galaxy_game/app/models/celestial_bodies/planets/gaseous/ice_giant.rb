# app/models/celestial_bodies/planets/gaseous/ice_giant.rb
module CelestialBodies
  module Planets
    module Gaseous
      class IceGiant < GaseousPlanet # <-- IMPORTANT: Inherit from GaseousPlanet
        # This is CRUCIAL for STI: update the `type` column for new records
        before_validation :set_sti_type

        # Ice giants can't be terraformed in the traditional sense
        def terraformed?
          false
        end

        # Overriding habitability score for ice giants
        def habitability_score
          "Ice giants are not habitable."
        end

        # Add any specific attributes or methods unique to Ice Giants here
        # For example, methods related to their unique atmospheric composition (methane),
        # very cold temperatures, or potentially different magnetic fields.
        # Example:
        # validates :methane_percentage, numericality: { greater_than_or_equal_to: 1.0 }, allow_nil: true
        #
        # def has_methane_clouds?
        #   methane_percentage.to_f > 5.0 # Example logic
        # end

        private

        # New STI type setter
        def set_sti_type
          self.type = 'CelestialBodies::Planets::Gaseous::IceGiant'
        end
      end
    end
  end
end