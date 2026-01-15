# app/models/structures/hangar.rb
module Structures
  class Hangar < BaseStructure
    # Hangars are special structures built into access points
    
    has_one :access_point, class_name: 'Structures::AccessPoint', as: :connected_structure
    has_many :docked_vehicles, class_name: 'Vehicles::BaseVehicle', foreign_key: 'docked_at_id'
    has_many :docked_crafts, class_name: 'Crafts::BaseCraft', foreign_key: 'docked_at_id'
    
    before_validation :set_structure_type
    
    # Capacity management
    def at_capacity?
      rover_count >= rover_capacity && small_craft_count >= small_craft_capacity
    end
    
    def rover_count
      docked_vehicles.where(vehicle_type: 'rover').count
    end
    
    def small_craft_count
      docked_crafts.where(craft_type: ['shuttle', 'lander']).count
    end
    
    def rover_capacity
      operational_data&.dig('capacity', 'rover') || 0
    end
    
    def small_craft_capacity
      operational_data&.dig('capacity', 'small_craft') || 0
    end
    
    # Docking methods
    def dock_vehicle(vehicle)
      return false if at_capacity?
      return false if rover_count >= rover_capacity && vehicle.vehicle_type == 'rover'
      
      # Dock the vehicle
      vehicle.update(docked_at: self, status: 'docked')
      true
    end
    
    def dock_craft(craft)
      return false if at_capacity?
      return false if small_craft_count >= small_craft_capacity
      
      # Dock the craft
      craft.update(docked_at: self, status: 'docked')
      true
    end
    
    private
    
    def set_structure_type
      self.structure_type = 'hangar'
      self.structure_name = operational_data&.dig('hangar_type')&.titleize || 'Hangar'
    end
    
    # ✅ ATMOSPHERIC OVERRIDES: Only specify construction differences
    def atmosphere_type
      'artificial' # Constructed facility
    end
    
    def default_sealing_status
      true # Built sealed for vehicle operations
    end
    
    def calculate_atmospheric_mass
      # Hangars need more atmospheric mass due to vehicle operations
      volume = operational_data&.dig('volume') || 
               (rover_capacity * 100 + small_craft_capacity * 200) # Estimate
      
      volume * 1.225 # Standard atmosphere density
    end
    
    # ❌ REMOVE: def default_pressure (inherit from celestial body)
    # ❌ REMOVE: def default_temperature (inherit from celestial body) 
    # ❌ REMOVE: def get_celestial_atmosphere_data override
  end
end