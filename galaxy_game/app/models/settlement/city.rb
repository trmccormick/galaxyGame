# app/models/settlement/city.rb
module Settlement
  class City < BaseSettlement
    belongs_to :celestial_body

    # Override resource requirements to account for city-specific needs
    def resource_requirements
      super.merge({
        materials: colony.celestial_body.materials  # Accessing raw materials from celestial body
      })
    end
  end
end