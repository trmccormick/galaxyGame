class SolarSystem < ApplicationRecord
    has_many :stars, class_name: 'Star'
    has_many :celestial_bodies
    has_many :terrestrial_planets
    has_many :gas_giants
    has_many :ice_giants
    has_many :moons
    has_many :dwarf_planets

    # Validations
    validates :name, presence: true, uniqueness: true
  
    # Callbacks
    before_create :generate_unique_name
    after_create :set_initial_star
  
    # Method to set or update the central star
    def load_star(params)
      star = stars.find_or_initialize_by(name: params[:name])
      star.update(params)
      save if changed?
    end

  # Method to determine the habitable zone
  def habitable_zone?(planet)
    return false unless stars.any? && planet.orbital_period

    stars.any? do |star|
      # Calculate habitable zone for each star
      star_mass = star.mass || 1.0 # Default to 1.0 solar mass if not provided
      semi_major_axis = ((planet.orbital_period / 365.25)**2 * star_mass)**(1.0 / 3.0)

      # Define habitable zone range
      inner_habitable_zone = 0.95
      outer_habitable_zone = 1.37

      semi_major_axis >= inner_habitable_zone && semi_major_axis <= outer_habitable_zone
    end
  end
  
    # Method to load and update different types of planets
    def load_terrestrial_planet(params)
      planet = terrestrial_planets.find_or_initialize_by(name: params[:name])
      planet.update(
        size: params[:size] || 1.0,             # Provide default values if missing
        gravity: params[:gravity] || 9.8,
        orbital_period: params[:orbital_period] || 365,
        surface_temperature: params[:surface_temperature] || 15,
        atmosphere_composition: params[:atmosphere_composition] || 'N2, O2'
      )
      planet.save!
    end
  
    def load_gas_giant(params)
      planet = gas_giants.find_or_initialize_by(name: params[:name])
      planet.update(
        size: params[:size] || 11.0,              # Set default values as per gas giant characteristics
        gravity: params[:gravity] || 24.79,
        orbital_period: params[:orbital_period] || 4331
      )
      planet.save!
    end
  
    def load_ice_giant(params)
      planet = ice_giants.find_or_initialize_by(name: params[:name])
      planet.update(params)
      planet.save!
    end
  
    def load_moon(params)
      moon = moons.find_or_initialize_by(name: params[:name])
      moon.update(params)
      moon.save!
    end
  
    def load_dwarf_planet(params)
      dwarf_planet = dwarf_planets.find_or_initialize_by(name: params[:name])
      dwarf_planet.update(params)
      dwarf_planet.save!
    end
  
    # Example: Calculate total mass of all planets and dwarf planets in the solar system
    def total_mass
      (terrestrial_planets.sum(:mass) || 0) +
      (gas_giants.sum(:mass) || 0) +
      (ice_giants.sum(:mass) || 0) +
      (dwarf_planets.sum(:mass) || 0)
    end
  
    private
  
    def set_initial_star
      # Logic to create an initial star if none exist
      stars.find_or_create_by(name: 'Sun') do |star|
        star.mass = 1.0 # Set default values for the star
        star.radius = 1.0
      end
    end

    # Generate a unique name only if none is provided
    def generate_unique_name
      return if self.name.present?

      loop do
        charset = Array('A'..'Z') + Array('0'..'9')
        self.name = Array.new(6) { charset.sample }.join
        break unless SolarSystem.exists?(name: self.name)
      end
    end
end