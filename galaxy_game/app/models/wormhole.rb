class Wormhole < ApplicationRecord
  belongs_to :solar_system_a, class_name: 'SolarSystem'
  belongs_to :solar_system_b, class_name: 'SolarSystem'

  # This uses the generic has_many :locations pattern
  has_many :endpoints, 
           as: :locationable,
           class_name: 'Location::SpatialLocation', 
           dependent: :destroy

  has_many :stabilizers,
           class_name: 'Craft::BaseCraft',
           foreign_key: :stabilizing_wormhole_id,
           inverse_of: :stabilizing_wormhole

  enum wormhole_type: {
    traversable: 0,
    non_traversable: 1,
    one_way: 2
  }

  enum stability: { unstable: 0, stabilizing: 1, stable: 2 }

  scope :natural, -> { where(natural: true) }
  scope :artificial, -> { where(natural: false) }

  validates :solar_system_a, :solar_system_b, :wormhole_type, presence: true
  validate :different_systems
  validates :mass_limit, numericality: { greater_than: 0 }

  after_create :generate_endpoints

  # --- Satellite logic ---
  def stabilization_satellites
    # Current approach is fine for small to medium datasets
    satellites = Craft::BaseCraft.where(
      deployed: true, 
      craft_name: "Wormhole Stabilization Satellite"
    ).where.not(
      stabilizing_wormhole_id: id
    )
    
    # Debug information
    Rails.logger.debug "Found #{satellites.count} satellites with name 'Wormhole Stabilization Satellite'"
    satellites.each do |s|
      Rails.logger.debug "  Satellite #{s.id}: deployed=#{s.deployed}, craft_name=#{s.craft_name}"
    end
    
    # Filter satellites that are within range
    in_range = satellites.select do |satellite|
      # Use either spatial_location or celestial_location (location is a helper method)
      satellite_location = satellite.spatial_location
      next false unless satellite_location
      
      # Debug information
      Rails.logger.debug "  Checking satellite #{satellite.id} with location #{satellite_location.inspect}"
      
      # Check each endpoint for distance
      any_in_range = endpoints.any? do |endpoint|
        distance = calculate_distance(satellite_location, endpoint)
        Rails.logger.debug "    Distance to endpoint #{endpoint.id}: #{distance}, threshold: #{GameConstants::STABILIZER_EFFECTIVE_RANGE}"
        distance <= GameConstants::STABILIZER_EFFECTIVE_RANGE
      end
      
      Rails.logger.debug "  Satellite #{satellite.id} in range? #{any_in_range}"
      any_in_range
    end
    
    Rails.logger.debug "Returning #{in_range.count} satellites in range"
    in_range
  end

  def operational_stabilizers
    (stabilizers + stabilization_satellites).select(&:operational?).uniq
  end

  # --- Travel mechanics ---
  def safe_for_travel?
    stable? && !non_traversable? &&
      operational_stabilizers.count >= GameConstants::MIN_STABILIZERS_REQUIRED
  end

  def can_traverse?(mass, from_system)
    safe_for_travel? &&
      mass <= remaining_mass_limit(from_system) &&
      !(one_way? && traversed?)
  end

  def traverse!(mass, from_system)
    return false unless can_traverse?(mass, from_system)

    if from_system == solar_system_a
      self.mass_transferred_a += mass
      shift_endpoint_a! if should_shift_endpoint?(:a)
    else
      self.mass_transferred_b += mass
      shift_endpoint_b! if should_shift_endpoint?(:b)
    end

    self.traversed = true if one_way?
    save!
    true
  end

  def appearance_profile
    if natural?
      if artificial_station_built?
        :artificial_only_stabilized
      elsif stable? && !hazard_zone? && !exotic_resources?
        :naturally_anchored
      else
        :exotic_anomalous
      end
    else
      :artificial_only_stabilized
    end
  end

  # --- Private helpers ---
  private

  def remaining_mass_limit(from_system)
    transferred = from_system == solar_system_a ? mass_transferred_a : mass_transferred_b
    mass_limit - transferred
  end

  def should_shift_endpoint?(point)
    return false if (point == :a && point_a_stabilized) || (point == :b && point_b_stabilized)

    transferred = point == :a ? mass_transferred_a : mass_transferred_b
    transferred >= mass_limit
  end

  def shift_endpoint!(endpoint)
    return unless endpoint # Guard against nil endpoint

    endpoint.update!(
      x_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
      y_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
      z_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR)
    )
  end

  def shift_endpoint_a!
    endpoint = endpoints.find_by(spatial_context: solar_system_a)
    ActiveRecord::Base.transaction do
      shift_endpoint!(endpoint)
      self.mass_transferred_a = 0
      save!
    end
  end

  def shift_endpoint_b!
    endpoint = endpoints.find_by(spatial_context: solar_system_b)
    shift_endpoint!(endpoint)
    self.mass_transferred_b = 0
  end

  def calculate_distance(loc1, loc2)
    Math.sqrt(
      (loc1.x_coordinate - loc2.x_coordinate)**2 +
      (loc1.y_coordinate - loc2.y_coordinate)**2 +
      (loc1.z_coordinate - loc2.z_coordinate)**2
    )
  end

  def different_systems
    errors.add(:base, "Must connect different solar systems") if solar_system_a_id == solar_system_b_id
  end

  def generate_endpoints
    # Create endpoint for system A
    endpoints.create!(
      name: "Wormhole Point A-#{id}",
      spatial_context: solar_system_a,
      locationable: self,  # Add this line to set the locationable association
      x_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
      y_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
      z_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR)
    )

    # Create endpoint for system B
    endpoints.create!(
      name: "Wormhole Point B-#{id}",
      spatial_context: solar_system_b,
      locationable: self,  # Add this line to set the locationable association 
      x_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
      y_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
      z_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR)
    )
  end

  def endpoint_a
    endpoints.find_by(spatial_context: solar_system_a)
  end
  
  def endpoint_b
    endpoints.find_by(spatial_context: solar_system_b)
  end

  # --- Private helpers ---
  private
end
