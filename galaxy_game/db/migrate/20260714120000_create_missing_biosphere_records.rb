# frozen_string_literal: true

# Backfill biosphere records for planets where liquid water can exist on surface.
# Fixes data integrity gap where planets have terrain_map but no biosphere record.
class CreateMissingBiosphereRecords < ActiveRecord::Migration[7.2]
  def up
    # Find all celestial bodies that:
    # 1. Have a hydrosphere with liquid water
    # 2. Do NOT already have a biosphere record
    bodies_needing_biosphere = CelestialBodies::CelestialBody.joins(:hydrosphere)
      .where('biospheres.id' => nil)
      .left_joins(biosphere: :celestial_body)
      .where.not(id: CelestialBodies::CelestialBody.where.not(biosphere_id: nil).select(:id))
      .find_each do |body|
        # Check if this body can support surface life (liquid water exists)
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
    # Remove biospheres created by this migration (those with default values)
    CelestialBodies::CelestialBody.joins(:biosphere).find_each do |body|
      next unless body.biosphere&.habitable_ratio == 0.95 &&
                  body.biosphere&.biodiversity_index == 0.95

      body.biosphere.destroy
    end
  end
end
