# spec/factories/celestial_bodies/star_distances.rb
FactoryBot.define do
  factory :star_distance, class: 'CelestialBodies::StarDistance' do
    # Fix the associations to use explicit build strategy
    association :celestial_body, strategy: :build
    association :star, factory: :star, strategy: :create
    distance { 1.496e11 } # Earth-Sun distance in meters
  end
end