FactoryBot.define do
  factory :atmosphere, class: 'CelestialBodies::Spheres::Atmosphere' do
    association :celestial_body
    temperature { 288 }  # Earth-like in Kelvin (approx 15°C)
    pressure { 1.0 }     # Earth-like in bar
    total_atmospheric_mass { 5.0e18 } # Earth-like in kg
    
    trait :earth_like do
      after(:create) do |atmosphere|
        create(:gas, atmosphere: atmosphere, name: "Nitrogen", percentage: 78)
        create(:gas, atmosphere: atmosphere, name: "Oxygen", percentage: 21)
        create(:gas, atmosphere: atmosphere, name: "Carbon Dioxide", percentage: 0.04)
        create(:gas, atmosphere: atmosphere, name: "Argon", percentage: 0.93)
      end
    end
    
    trait :mars_like do
      temperature { 210 }
      pressure { 0.006 }
      total_atmospheric_mass { 2.5e16 }
      
      after(:create) do |atmosphere|
        create(:gas, atmosphere: atmosphere, name: "Carbon Dioxide", percentage: 95)
        create(:gas, atmosphere: atmosphere, name: "Nitrogen", percentage: 2.7)
        create(:gas, atmosphere: atmosphere, name: "Argon", percentage: 1.6)
      end
    end
  end
end