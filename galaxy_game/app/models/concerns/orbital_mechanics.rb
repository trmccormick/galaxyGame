module OrbitalMechanics
  extend ActiveSupport::Concern

  included do
    has_many :orbital_bodies, as: :primary, class_name: 'CelestialBodies::CelestialBody' if respond_to?(:has_many) && !method_defined?(:orbital_bodies)
    has_one :spatial_location, as: :spatial_context, dependent: :destroy if respond_to?(:has_one) && !method_defined?(:spatial_location)
    
    # ✅ Add orbital relationship associations
    has_one :orbital_relationship, as: :secondary_body, dependent: :destroy if respond_to?(:has_one) && !method_defined?(:orbital_relationship)
    has_many :orbital_children, class_name: 'OrbitalRelationship', as: :primary_body if respond_to?(:has_many) && !method_defined?(:orbital_children)
  end

  # ✅ Enhanced orbital relationship methods
  def primary_body
    respond_to?(:orbital_relationship) ? orbital_relationship&.primary_body : nil
  end
  
  def primary_body=(body)
    if respond_to?(:orbital_relationship)
      if body.nil?
        orbital_relationship&.destroy
      elsif orbital_relationship
        orbital_relationship.update!(primary_body: body)
      else
        create_orbital_relationship_with(body)
      end
    end
  end
  
  def orbital_distance
    if respond_to?(:orbital_relationship)
      orbital_relationship&.orbital_distance || 
      (spatial_location && primary_body&.spatial_location ? 
       spatial_location.distance_to(primary_body.spatial_location) : nil)
    else
      spatial_location && primary_body&.spatial_location ? 
      spatial_location.distance_to(primary_body.spatial_location) : nil
    end
  end
  
  def energy_from_primary
    respond_to?(:orbital_relationship) ? orbital_relationship&.energy_input || 0 : 0
  end
  
  def in_stable_orbit?
    respond_to?(:orbital_relationship) ? orbital_relationship&.stable_orbit? || false : false
  end

  # ✅ Enhanced orbital mechanics using relationships
  def orbital_period_around(primary)
    if respond_to?(:orbital_relationship) && orbital_relationship&.primary_body == primary
      return orbital_relationship.calculated_orbital_period
    end
    
    # Fallback to spatial calculation
    return nil unless spatial_location && primary.spatial_location
    distance = spatial_location.distance_to(primary.spatial_location)
    Math.sqrt((4 * Math::PI**2 * distance**3) / (6.67430e-11 * (mass + primary.mass)))
  end

  def calculate_orbital_velocity
    return nil unless primary_body && spatial_location
    Math.sqrt((GameConstants::GRAVITATIONAL_CONSTANT * primary_body.mass) / orbital_distance)
  end

  def hill_sphere_radius
    return nil unless primary_body && orbital_distance
    orbital_distance * (mass / (3 * primary_body.mass))**(1.0/3.0)
  end

  def lagrange_points
    return nil unless primary_body && orbital_distance
    distance = orbital_distance
    {
      l1: calculate_l1_point(distance),
      l2: calculate_l2_point(distance),
      l3: calculate_l3_point(distance),
      l4: calculate_l4_point(distance),
      l5: calculate_l5_point(distance)
    }
  end

  def barycenter_with(other_body)
    return nil unless spatial_location && other_body.spatial_location
    total_mass = mass + other_body.mass
    x = (spatial_location.x_coordinate * mass + other_body.spatial_location.x_coordinate * other_body.mass) / total_mass
    y = (spatial_location.y_coordinate * mass + other_body.spatial_location.y_coordinate * other_body.mass) / total_mass
    z = (spatial_location.z_coordinate * mass + other_body.spatial_location.z_coordinate * other_body.mass) / total_mass
    [x, y, z]
  end
  
  private
  
  def create_orbital_relationship_with(body)
    # Override in subclasses to set appropriate relationship_type
    OrbitalRelationship.create!(
      primary_body: body,
      secondary_body: self,
      relationship_type: default_relationship_type(body),
      distance: spatial_location&.distance_to(body.spatial_location),
      semi_major_axis: spatial_location&.distance_to(body.spatial_location)
    )
  end
  
  def default_relationship_type(primary)
    case [primary.class.name, self.class.name]
    when ->(p, s) { p.include?('Star') && s.include?('Planet') }
      'star_planet'
    when ->(p, s) { p.include?('Planet') && s.include?('Moon') }
      'planet_moon'
    when ->(p, s) { p.include?('Star') && s.include?('Star') }
      'binary_star'
    else
      'generic_orbit'
    end
  end
end