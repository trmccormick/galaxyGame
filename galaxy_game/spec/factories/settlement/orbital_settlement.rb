# frozen_string_literal: true

FactoryBot.define do
  factory :orbital_settlement, class: 'Settlement::OrbitalSettlement' do
    sequence(:name) { |n| "OrbitalSettlement#{n}" }
    association :location, factory: :celestial_location
    # Add minimal required attributes for a valid settlement
  end
end
