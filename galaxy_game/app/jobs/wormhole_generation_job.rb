# app/jobs/wormhole_generation_job.rb
class WormholeGenerationJob
  include Sidekiq::Job
  queue_as :default

  def perform
    eligible_systems = find_eligible_systems

    # Fallback: create a new system if none are eligible
    if eligible_systems.empty?
      new_system = create_new_system
      eligible_systems = [new_system] if new_system
    end

    # Attempt to generate wormholes for each eligible system
    eligible_systems.each do |system|
      StarSim::Wormholes::Service.generate_connection(source_system: system)
    end

    # Schedule the next cycle
    WormholeGenerationJob.set(wait: GameConstants::WORMHOLE_GENERATION_INTERVAL).perform_later
  end

  private

  def find_eligible_systems
    SolarSystem
      .where.not(id: active_systems)
      .joins(<<~SQL.squish)
        LEFT OUTER JOIN wormholes 
        ON solar_systems.id = wormholes.solar_system_a_id 
        OR solar_systems.id = wormholes.solar_system_b_id
      SQL
      .group("solar_systems.id")
      .having("COUNT(wormholes.id) < ?", GameConstants::MAX_WORMHOLES_PER_SYSTEM)
      .where("random() < ?", GameConstants::WORMHOLE_GENERATION_CHANCE)
      .limit(GameConstants::MAX_NEW_WORMHOLES_PER_CYCLE)
  end

  def active_systems
    SolarSystem
      .joins(:wormholes_as_system_a)
      .or(SolarSystem.joins(:wormholes_as_system_b))
      .distinct
      .select(:id)
  end

  def create_new_system
    galaxy = Galaxy.order("RANDOM()").first
    return unless galaxy

    new_system = SolarSystem.create!(
      name: "Unknown System",
      identifier: "SYS-#{SecureRandom.hex(4)}",
      galaxy: galaxy,
      discovery_state: :undiscovered
    )

    StarSim::SystemGeneratorService.new(new_system).generate!(
      num_stars: rand(1..3),
      num_planets: rand(0..8)
    )

    new_system
  end
end

