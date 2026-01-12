# app/models/location_record.rb
class LocationRecord < ApplicationRecord
    has_many :units, as: :location  # Establishing the polymorphic association
end
  
