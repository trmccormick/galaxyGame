# app/models/plant_environment.rb

class PlantEnvironment < ApplicationRecord
    belongs_to :plant
    belongs_to :environment

    validates :plant_id, presence: true
    validates :environment_id, presence: true
    validates :plant_id, uniqueness: { scope: :environment_id, message: "should be unique within this environment" }
end
  