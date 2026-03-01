  def about
    # Simple about page for Learn More link
  end
class LandingController < ApplicationController
  def index
    # Mock data for initial UI
    @ai_decisions_today = 147
    @settlements_count = 8
    @systems_count = 4
    @wormholes_count = 5
    @gcc_volume = 120_000
    @active_missions_count = 3
    @expansion_rate = 12
    @prize_worlds_count = 2
    @active_systems = [
      OpenStruct.new(name: 'Sol System', identifier: 'SOL', settlements: [1,2], celestial_bodies: [1,2,3], wormholes: [1]),
      OpenStruct.new(name: 'Alpha Centauri', identifier: 'ALPHA-C', settlements: [1], celestial_bodies: [1,2], wormholes: []),
      OpenStruct.new(name: 'FR-488530', identifier: 'FR-488530', settlements: [1,2,3], celestial_bodies: [1,2,3,4], wormholes: [1,2]),
      OpenStruct.new(name: 'DJEW-716790', identifier: 'DJEW-716790', settlements: [], celestial_bodies: [1], wormholes: [])
    ]
    @recent_activities = [
      OpenStruct.new(type: 'emergency', title: 'Mars: Emergency oxygen mission created', description: 'AI dispatched supply mission to Mars', created_at: 2.hours.ago),
      OpenStruct.new(type: 'colony', title: 'FR-488530: Prize World colony established', description: 'New colony founded on prize world', created_at: 4.hours.ago),
      OpenStruct.new(type: 'harvester', title: 'Venus: Atmospheric harvester deployed', description: 'AI deployed new harvester on Venus', created_at: 6.hours.ago)
    ]
  end
end
