# app/models/enclosed_habitat/atmosphere.rb
module EnclosedHabitat
  class Atmosphere < ApplicationRecord
    include AtmosphereConcern

    belongs_to :enclosed_habitat

    private

    def default_temperature
      293.15 # Default to 20°C for enclosed habitats
    end
  end
end
  