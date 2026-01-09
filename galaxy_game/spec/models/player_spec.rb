# spec/models/player_spec.rb
require 'rails_helper'
require 'support/mock_craft_lookup_service'

RSpec.describe Player, type: :model do
  let!(:celestial_body) { create(:large_moon, :luna) }
  # let!(:location_on_surface) { create(:location, :on_celestial_body, celestial_body: celestial_body) }
  let!(:location_on_surface) { Location::CelestialLocation.create(name: "Test Location #{SecureRandom.hex(4)}", coordinates: "#{SecureRandom.hex(4)}°N #{SecureRandom.hex(4)}°E", celestial_body: celestial_body) }
  let!(:craft) { create(:base_craft) }
  let!(:player) { create(:player, active_location: craft.name) }
  # let!(:item) { create(:item, inventory: player.inventory, location: location_on_surface) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(player).to be_valid
    end

    it 'is not valid without a name' do
      player.name = nil
      expect(player).not_to be_valid
    end

    it 'is not valid without an active_location' do
      player.active_location = nil
      expect(player).not_to be_valid
    end
  end

  describe 'account balance' do
    it 'has a balance of 1000' do
      expect(player.account.balance).to eq(1000)
    end
  end

  describe 'inventory at active location' do
    it 'raises an error if active location is not set' do
      player.active_location = nil
      expect { player.inventory_at_active_location }.to raise_error(ArgumentError, "Player does not have an active location set.")
    end

    it 'returns the inventory at the active location' do
      expect(player.inventory_at_active_location).to eq(craft.inventory)
    end
  end

  # describe 'retrieves items at the current location' do
  #   it 'retrieves items at the current location' do
  #     player.update(active_location: craft.name)
  #     expect(player.inventory.items.where(location: location_on_surface)).to include(item)
  #   end
  # end
end