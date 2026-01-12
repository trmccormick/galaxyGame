module Docking
  extend ActiveSupport::Concern

  included do
    has_many :docked_crafts
    has_many :scheduled_arrivals
    has_many :scheduled_departures
  end

  def dock_craft(craft)
    return false if docked_crafts.count >= maximum_docking_capacity
    docked_crafts << craft
  end

  def undock_craft(craft)
    docked_crafts.delete(craft)
  end

  def available_docking_ports
    maximum_docking_capacity - docked_crafts.count
  end

  def schedule_arrival(craft, arrival_time)
    scheduled_arrivals.create(
      craft: craft,
      scheduled_time: arrival_time
    )
  end
end