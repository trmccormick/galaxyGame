# app/models/celestial_bodies/planets/rocky/terrestrial_planet.rb
module CelestialBodies
  module Planets
    module Rocky
      class TerrestrialPlanet < RockyPlanet # <-- IMPORTANT: Inherit from RockyPlanet
        has_many :star_distances, class_name: 'CelestialBodies::StarDistance', foreign_key: 'celestial_body_id', dependent: :destroy
        accepts_nested_attributes_for :star_distances, allow_destroy: true
        
        # Add or uncomment any specific validations/methods for TerrestrialPlanet here.
        # (Your original code snippet had some commented out parts like TerraformingConcern)
        # You can keep all the methods from the original TerrestrialPlanet here.

        # This is CRUCIAL for STI: update the `type` column for new records
        before_validation :set_sti_type

        # All your existing methods from the original TerrestrialPlanet go here
        # e.g., update_gravity, atmosphere_composition, habitable_zone?, habitability_score, etc.
        validates :surface_temperature, numericality: true, allow_nil: true

        def atmosphere_composition
          atmosphere&.gases&.pluck(:name, :percentage)&.to_h || {}
        end

        def habitable_zone?
          return false unless stars.any?

          stars.all? do |star|
            distance = star_distances.find_by(star: star)&.distance
            next false unless distance

            distance.between?(star.inner_habitable_zone, star.outer_habitable_zone)
          end
        end

        def habitability_score
          return 0 unless atmosphere&.gases.present?

          scores = {
            temperature: temperature_score,
            pressure: pressure_score,
            atmosphere: atmosphere_score,
            gravity: gravity_score
          }

          scores.values.sum / scores.length
        end

        private

        # New STI type setter
        def set_sti_type
          self.type = 'CelestialBodies::Planets::Rocky::TerrestrialPlanet'
        end

        # All your existing private methods...
        def temperature_score
          return 0 unless surface_temperature
          case surface_temperature
          when 273..300 then 1.0
          when 250..273, 300..320 then 0.5
          else 0.0
          end
        end

        def pressure_score
          return 0 unless atmosphere&.pressure
          case atmosphere.pressure
          when 0.8..1.2 then 1.0
          when 0.5..0.8, 1.2..2.0 then 0.5
          else 0.0
          end
        end

        def atmosphere_score
          return 0 unless atmosphere&.gases&.any?

          required_gases = {
            'N2' => (65..80),
            'O2' => (15..25)
          }

          scores = required_gases.map do |gas, range|
            percentage = atmosphere.gases.find_by(name: gas)&.percentage || 0
            range.include?(percentage) ? 1.0 : 0.0
          end

          scores.sum / scores.length
        end

        def gravity_score
          return 0 unless gravity
          case gravity
          when 0.8..1.2 then 1.0
          when 0.5..0.8, 1.2..2.0 then 0.5
          else 0.0
          end
        end

        def calculated_atmospheric_pressure
          TerraSim::Simulator.new(self).calc_current
          # Return the current simulated pressure from the atmosphere sphere
          atmosphere&.pressure || known_pressure
        end
      end
    end
  end
end