class Galaxy < ApplicationRecord
  has_many :solar_systems
  has_one :spatial_location, as: :spatial_context, class_name: 'Location::SpatialLocation', dependent: :destroy

  # Add enum for galaxy_type
  enum galaxy_type: {
    spiral: "spiral",
    elliptical: "elliptical",
    irregular: "irregular",
    ring: "ring",
    lenticular: "lenticular"
  }, _prefix: true

  # Validations
  validates :identifier, presence: true, uniqueness: true  
  
  # Callbacks
  before_create :generate_unique_name

  def name
    super.presence || identifier
  end

  # Calculate total mass (stars + dark matter)
  def total_mass
    # Default estimation if mass isn't set
    base_mass = self.mass || 1.0e12
    
    # Dark matter is typically 5-6x visible matter
    base_mass * 6.0
  end
  
  private

  # Generate a unique name only if none is provided
  def generate_unique_name
    return if read_attribute(:name).present?
    
    loop do
      charset = Array('A'..'Z') + Array('0'..'9')
      self.name = Array.new(6) { charset.sample }.join
      break unless Galaxy.exists?(name: self.name)
    end
  end
end