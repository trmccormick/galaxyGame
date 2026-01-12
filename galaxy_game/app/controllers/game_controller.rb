class GameController < ApplicationController
  def index
    @game_state = get_or_create_game_state
    @game_state.update_time! if @game_state.running

    @solar_system = SolarSystem.find_by(name: 'Sol')
    if @solar_system.nil?
      StarSim::SystemBuilderService.new(name: 'Sol').build!
      @solar_system = SolarSystem.find_by(name: 'Sol')
    end

    if @solar_system
      @celestial_bodies = @solar_system.celestial_bodies.includes(:atmosphere).to_a
    else
      @celestial_bodies = []
    end

    @planet_count = @celestial_bodies.reject(&:is_moon).count

    @celestial_bodies.each do |body|
      body.define_singleton_method(:is_moon) { respond_to?(:parent_celestial_body) && parent_celestial_body.present? }
      body.define_singleton_method(:body_category) do
        case self.class.name
        when /TerrestrialPlanet/ then 'terrestrial'
        when /GasGiant/ then 'gas_giant'
        when /Star/ then 'star'
        when /Moon/ then 'moon'
        else 'unknown'
        end
      end
      Rails.logger.debug("Celestial body: #{body.name}, category: #{body.body_category}, is_moon: #{body.is_moon}")
    end

    respond_to do |format|
      format.html
      format.json do
        celestial_bodies_json = @celestial_bodies.map do |body|
          {
            name: body.name,
            identifier: body.identifier,
            body_category: body.body_category,
            is_moon: body.is_moon,
            parent_body_identifier: body.respond_to?(:parent_celestial_body) ? body.parent_celestial_body&.identifier : nil,
            orbital_period: body.orbital_period,
            surface_temperature: body.surface_temperature
          }
        end.to_json
        render json: { celestial_bodies_json: celestial_bodies_json }
      end
    end
  end

  def toggle_running
    @game_state = get_or_create_game_state
    @game_state.toggle_running!
    render json: {
      running: @game_state.running,
      time: { year: @game_state.year, day: @game_state.day }
    }
  end

  def set_speed
    @game_state = get_or_create_game_state
    speed = params[:speed].to_i.clamp(1, 5)
    @game_state.update!(speed: speed)
    head :ok
  end

  def jump_time
    @game_state = get_or_create_game_state
    days = params[:days].to_i.clamp(1, 365)
    @game_state.day += days
    while @game_state.day >= 365
      @game_state.year += 1
      @game_state.day -= 365
    end
    @game_state.save!
    head :ok
  end

  def state
    @game_state = get_or_create_game_state
    @game_state.update_time! if @game_state.running
    render json: {
      running: @game_state.running,
      speed: @game_state.speed,
      time: { year: @game_state.year, day: @game_state.day }
    }
  end

  def simulation
    @solar_system = SolarSystem.find_by(id: params[:id])
    if @solar_system.nil?
      flash[:error] = "Solar system not found"
      redirect_to root_path
      return
    end
    @star = @solar_system.stars.first
  end

  private

  def get_or_create_game_state
    GameState.first_or_create!
  end
end
