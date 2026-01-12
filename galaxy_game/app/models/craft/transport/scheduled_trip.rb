# app/models/craft/transport/scheduled_trip.rb
module Craft
    module Transport
      class ScheduledTrip < ApplicationRecord
        belongs_to :cycler
        belongs_to :departure_location, polymorphic: true
        has_many :docked_craft_trips, dependent: :destroy
  
        serialize :destinations, Array
  
        attribute :departure_time, :datetime
  
        def next_destination(current_location)
          # Implementation to find the next destination
          # ...
        end
      end
    end
  end