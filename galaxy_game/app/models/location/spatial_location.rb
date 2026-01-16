# app/models/location/spatial_location.rb
require_relative 'base_location'
module Location
  class SpatialLocation < BaseLocation
    self.table_name = 'spatial_locations'

    belongs_to :spatial_context, polymorphic: true, optional: true
    belongs_to :locationable, polymorphic: true, optional: true

    validates :x_coordinate, :y_coordinate, :z_coordinate,
                presence: true,
              numericality: { greater_than_or_equal_to: -Float::INFINITY,
                            less_than_or_equal_to: Float::INFINITY }

    validates :name, presence: true
    validates :x_coordinate, presence: true, numericality: true
    validates :y_coordinate, presence: true, numericality: true
    validates :z_coordinate, presence: true, numericality: true

    validate :unique_3d_position_within_context

    # Add scope to uniqueness validation
    validates :x_coordinate, uniqueness: { 
      scope: [:y_coordinate, :z_coordinate, :spatial_context_type, :spatial_context_id],
      message: 'position must be unique within the spatial context' 
    }

    def distance_to(other_location)
      Math.sqrt(
        (x_coordinate - other_location.x_coordinate) ** 2 +
        (y_coordinate - other_location.y_coordinate) ** 2 +
        (z_coordinate - other_location.z_coordinate) ** 2
      )
    end

    def update_location(coordinates)
      update(
        x_coordinate: coordinates[:x_coordinate],
        y_coordinate: coordinates[:y_coordinate],
        z_coordinate: coordinates[:z_coordinate]
      )
    end

    private

    def unique_3d_position_within_context
      return unless spatial_context && x_coordinate && y_coordinate && z_coordinate
      if SpatialLocation.where(
          spatial_context_type: spatial_context_type,
          spatial_context_id: spatial_context_id,
          x_coordinate: x_coordinate,
          y_coordinate: y_coordinate,
          z_coordinate: z_coordinate
        ).where.not(id: id).exists?
        errors.add(:base, 'This 3D position is already taken within this context')
      end
    end
  end
end