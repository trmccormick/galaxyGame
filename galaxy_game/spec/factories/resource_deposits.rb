FactoryBot.define do
  factory :resource_deposit do
    association :depositable, factory: :celestial_body
    material_name { "water_ice" }
    initial_mass_kg { 1000.0 }
    current_mass_kg { 1000.0 }
    extraction_difficulty { 1.0 }
    depletion_curve { "linear" }
    status { :undiscovered }
    operational_data { {} }

    # By default, attach to a feature (survey event sets this)
    association :feature, factory: :adapted_feature
    celestial_location { nil }
    spatial_location { nil }

    trait :with_celestial_location do
      feature { nil }
      association :celestial_location, factory: :celestial_location
    end

    trait :with_spatial_location do
      feature { nil }
      spatial_location { association :location_spatial_location }
    end

    # Only build via DepositSpawner in tests simulating survey events
    to_create do |instance|
      raise "ResourceDeposits must be created via DepositSpawner (survey event), not directly via factory."
    end
  end
end
