# spec/factories/locations/celestial_location.rb
FactoryBot.define do
  factory :celestial_location, class: 'Location::CelestialLocation' do
    sequence(:name) { |n| "Location #{n}" }
    
    # ✅ Generate valid coordinates with proper decimal format
    coordinates do
      lat = sprintf("%.2f", rand(0.00..90.00))
      lng = sprintf("%.2f", rand(0.00..180.00))
      lat_dir = ['N', 'S'].sample
      lng_dir = ['E', 'W'].sample
      "#{lat}°#{lat_dir} #{lng}°#{lng_dir}"
    end
    
    association :celestial_body
    
    # NEW: Default to surface location (altitude = nil)
    altitude { nil }
    
    # Fix: Set the locationable association
    after(:build) do |location|
      location.locationable_type = 'CelestialBodies::CelestialBody'
      location.locationable_id = location.celestial_body_id
    end
    
    # ✅ Existing traits
    trait :luna_location do
      coordinates { "23.47°N 15.60°W" }
    end
    
    trait :earth_location do
      coordinates { "40.71°N 74.01°W" }
    end
    
    # ✅ NEW: Orbital traits
    trait :surface do
      altitude { 0 }
    end
    
    trait :low_orbit do
      altitude { rand(200_000..2_000_000) } # 200 km to 2,000 km
    end
    
    trait :medium_orbit do
      altitude { rand(2_000_000..35_000_000) } # 2,000 km to 35,000 km
    end
    
    trait :high_orbit do
      altitude { rand(35_786_000..100_000_000) } # 35,786 km to 100,000 km
    end
    
    trait :iss_orbit do
      altitude { 408_000 } # ~408 km, typical ISS altitude
    end
    
    trait :geostationary do
      altitude { 35_786_000 } # 35,786 km
      coordinates { "0.00°N 0.00°E" } # Geostationary orbits are equatorial
    end
    
    # Convenience trait for space stations
    trait :orbital do
      altitude { 20_000_000 } # 20,000 km - nice medium orbit
    end
  end
end