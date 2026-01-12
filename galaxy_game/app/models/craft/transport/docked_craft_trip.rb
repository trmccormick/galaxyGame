# app/models/craft/transport/docked_craft_trip.rb
module Craft
    module Transport
      class DockedCraftTrip < ApplicationRecord
        belongs_to :scheduled_trip
        belongs_to :transport_craft
  
        attribute :docking_time, :datetime
        attribute :undocking_time, :datetime
      end
    end
  end