module HasSurfaceStorage
  extend ActiveSupport::Concern

  included do
    # Surface storage capabilities
    def surface_storage?
      true
    end

    def surface_storage_capacity
      case self
      when Settlement::BaseSettlement
        calculate_settlement_surface_storage
      else
        0
      end
    end

    private

    def calculate_settlement_surface_storage
      # Base surface storage calculation based on settlement type
      base_capacity = case settlement_type
      when 'outpost'
        1000
      when 'base'
        5000
      when 'colony'
        10000
      else
        500
      end

      # Modify based on celestial body conditions
      surface_modifier = celestial_body.surface_conditions_modifier
      (base_capacity * surface_modifier).to_i
    end
  end
end