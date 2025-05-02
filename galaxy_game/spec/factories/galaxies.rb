FactoryBot.define do
  factory :galaxy do
    sequence(:name) { |n| "Galaxy #{n}" }
    sequence(:identifier) { |n| "GLX-#{n}" }
    
    # Add existing fields from your migration
    galaxy_type { "spiral" }  # String, not enum
    age_in_billions { 13 }    # Age in billions of years
    star_count { 200000 }     # Number of stars
    mass { 1.5e12 }           # Solar masses
    diameter { 100000 }       # Light years
    
    # Skip validations in test
    after(:build) do |galaxy|
      galaxy.define_singleton_method(:validate_solar_systems) { true } if galaxy.respond_to?(:validate_solar_systems)
    end
  end
end