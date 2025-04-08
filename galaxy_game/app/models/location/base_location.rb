# app/models/location/base_location.rb
module Location
  class BaseLocation < ApplicationRecord
    self.abstract_class = true

    belongs_to :locationable, polymorphic: true, optional: true
    # has_many :items

    validates :name, presence: true

    def update_location(attributes = {})
      update(attributes)
    end
  end
end
