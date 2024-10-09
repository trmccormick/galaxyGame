# app/models/dome.rb
module Settlement
  class Dome < ApplicationRecord
    belongs_to :colony

    # Validations
    validates :name, presence: true
    validates :capacity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :current_occupancy, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validate :ensure_occupancy_does_not_exceed_capacity

    # Methods to calculate used and remaining capacity
    def used_capacity
      current_occupancy
    end

    def remaining_capacity
      total_capacity - domes.sum(:current_occupancy)
    end

    def total_capacity
      domes.sum(:capacity)
    end

    private

    def ensure_occupancy_does_not_exceed_capacity
      if current_occupancy > capacity
        errors.add(:current_occupancy, "can't be greater than capacity")
      end
    end
  end
end