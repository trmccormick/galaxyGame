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

    validates :name, presence: true, uniqueness: true
    validate :unique_3d_position

    def distance_to(other_location)
      Math.sqrt(
        (x_coordinate - other_location.x_coordinate) ** 2 +
        (y_coordinate - other_location.y_coordinate) ** 2 +
        (z_coordinate - other_location.z_coordinate) ** 2
      )
    end

    private

    def unique_3d_position
      return unless x_coordinate && y_coordinate && z_coordinate
      if SpatialLocation.where(
          x_coordinate: x_coordinate,
          y_coordinate: y_coordinate,
          z_coordinate: z_coordinate
        ).where.not(id: id).exists?
        errors.add(:base, 'This 3D position is already taken')
      end
    end
  end
end
