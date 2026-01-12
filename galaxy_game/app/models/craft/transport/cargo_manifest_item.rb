# app/models/craft/transport/cargo_manifest_item.rb
module Craft
    module Transport
      class CargoManifestItem < ApplicationRecord
        belongs_to :docked_craft_trip
        belongs_to :item
        belongs_to :order, optional: true
  
        attribute :quantity, :integer
      end
    end
end