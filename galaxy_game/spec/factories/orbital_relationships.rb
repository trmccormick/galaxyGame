FactoryBot.define do
  factory :orbital_relationship do
    association :primary_body, factory: :star
    association :secondary_body, factory: :terrestrial_planet
    relationship_type { 'star_planet' }
    distance { 1.496e11 }  # 1 AU
    semi_major_axis { 1.496e11 }
    eccentricity { 0.0167 }  # Earth's eccentricity
    inclination { 0.0 }
    orbital_period { 365.25 }
    
    trait :star_planet do
      association :primary_body, factory: :star
      association :secondary_body, factory: :terrestrial_planet
      relationship_type { 'star_planet' }
    end
    
    trait :planet_moon do
      association :primary_body, factory: :terrestrial_planet
      association :secondary_body, factory: :moon
      relationship_type { 'planet_moon' }
      distance { 3.844e8 }  # Earth-Moon distance
      semi_major_axis { 3.844e8 }
      orbital_period { 27.3 }
      eccentricity { 0.0549 }
    end
    
    trait :binary_star do
      association :primary_body, factory: :star
      association :secondary_body, factory: :star
      relationship_type { 'binary_star' }
      distance { 2.3e10 }  # Typical binary separation
      orbital_period { 100.0 }
    end
    
    trait :highly_eccentric do
      eccentricity { 0.8 }
    end
    
    trait :with_epoch do
      epoch_time { 1.year.ago }
      mean_anomaly_at_epoch { 0.0 }
    end
  end
end