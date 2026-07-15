# frozen_string_literal: true

# Backfill biosphere records for planets where liquid water can exist on surface,
# but biosphere records were not explicitly provided in seed JSON.
#
# This migration:
# 1. Respects JSON-provided biosphere data (if JSON has biosphere_attributes, record already exists)
# 2. Fills gaps for planets with liquid water that somehow lack biosphere records
# 3. Enables future flexibility: alien life (methane-based on Titan), terraformed worlds, etc.
#
# The system is DATA-DRIVEN: if JSON provides biosphere_attributes, use it. Otherwise,
# auto-create if liquid water is viable (planet can naturally support surface life).
class CreateMissingBiosphereRecords < ActiveRecord::Migration[7.0]
  def up
    # Find planets with liquid water that DON'T have biosphere records
    CelestialBodies::CelestialBody
      .joins(:hydrosphere)
      .left_joins(:biosphere)
      .where(celestial_bodies_spheres_biospheres: { id: nil })
      .find_each do |body|
        # Check if this body has liquid water on the surface
        liquid_water = body.hydrosphere&.state_distribution&.dig('liquid').to_f || 0
        next if liquid_water < 0.01

        # Only create biosphere for bodies where surface life is viable
        if body.can_support_surface_life? && !body.biosphere.present?
          body.create_biosphere_with_defaults(
            habitable_ratio: 0.95,
            biodiversity_index: 0.95,
            vegetation_cover: 0.75,
            biome_count: 10,
            soil_health: 80,
            soil_organic_content: 0.08,
            soil_microbial_activity: 0.8
          )
          Rails.logger.info "[Migration] Created biosphere for #{body.name} (liquid_water: #{liquid_water})"
        end
      end
  end

  def down
    # Remove biospheres created by this migration (those with exactly these default values)
    CelestialBodies::CelestialBody.joins(:biosphere).find_each do |body|
      next unless body.biosphere&.habitable_ratio == 0.95 &&
                  body.biosphere&.biodiversity_index == 0.95 &&
                  body.biosphere&.vegetation_cover == 0.75

      body.biosphere.destroy
    end
  end
end
