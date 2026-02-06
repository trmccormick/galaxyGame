# app/models/settlement/city.rb
module Settlement
  class City < BaseSettlement
    validates :location, presence: true

    # Override resource requirements to account for city-specific needs
    def resource_requirements
      super.merge({
        materials: celestial_body.materials  # Accessing raw materials from celestial body
      })
    end
  end
end