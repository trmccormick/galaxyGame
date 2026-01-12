# app/models/location/base_location.rb
module Location
  class BaseLocation < ApplicationRecord
    self.abstract_class = true

    belongs_to :locationable, polymorphic: true, optional: true
  end
end
