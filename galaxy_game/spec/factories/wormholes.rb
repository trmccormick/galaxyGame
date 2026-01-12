# spec/factories/wormholes.rb
FactoryBot.define do
  factory :wormhole do
    association :solar_system_a, factory: :solar_system
    association :solar_system_b, factory: :solar_system
    mass_limit { 1000 }
    mass_transferred_a { 0 }
    mass_transferred_b { 0 }
    wormhole_type { :traversable }
    stability { :stable }
    traversed { false }
    point_a_stabilized { false }
    point_b_stabilized { false }
  end
end