module CelestialBodies
  class Geosphere < ApplicationRecord
    belongs_to :celestial_body

    # Attributes stored as JSON fields in the database
    store_accessor :crust, :mantle, :core, :resources

    # Validations
    validates :temperature, numericality: true
    validates :pressure, numericality: true

    # Resource extraction logic (unchanged)
    def extract_resources(resource, amount)
      return 0 unless crust[resource] && crust[resource] >= amount

      ActiveRecord::Base.transaction do
        crust[resource] -= amount
        resources[resource] = (resources[resource] || 0) + amount
        save!
      end
      amount
    end
  end
end



  