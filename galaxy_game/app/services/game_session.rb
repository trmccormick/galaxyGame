# app/services/game_session.rb
module GameSession
  class << self
    attr_accessor :current_celestial_body, :current_star, :current_system, :current_galaxy

    def setup(celestial_body, star)
      @current_celestial_body = celestial_body
      @current_star = star
      @current_system = celestial_body&.solar_system
      @current_galaxy = fetch_galaxy_data
    end

    def fetch_galaxy_data
      ApiService.fetch_galaxy_data
    end

    def import_celestial_body(celestial_body_id)
      data = ApiService.fetch_celestial_body_data(celestial_body_id)
      @current_celestial_body = CelestialBody.find_or_create_by(id: celestial_body_id) do |body|
        body.assign_attributes(data)
      end
    end

    def show_galaxy_info
      puts "Current system count: #{@current_galaxy.size}" if @current_galaxy
    end

    def clear_system_nav
      # Implement logic to clear the system navigation UI
    end

    private

    def update_system_nav
      clear_system_nav
      @current_galaxy.each do |system|
        system_nav.append(system['name'])
      end
    end
  end
end
  