FactoryBot.define do
  factory :enclosed_atmosphere, class: 'Atmosphere' do
    # ✅ FIX: Use celestial_body instead of container
    association :celestial_body, factory: :terrestrial_planet
    
    temperature { 293.15 }
    pressure { 101.325 }
    environment_type { 'enclosed' }
    sealing_status { false }
    pollution { 0.0 }
    total_atmospheric_mass { 0 }
    
    composition { {} }
    dust { {} }
    gas_changes { {} }
    base_values { {} }
    temperature_data { {} }

    trait :earth_like do
      composition do
        {
          "N2" => 78.08,
          "O2" => 20.95,
          "Ar" => 0.93,
          "CO2" => 0.04
        }
      end
    end

    trait :venus_like do
      temperature { 737.0 }
      pressure { 9200.0 }
      total_atmospheric_mass { 4.8e20 }
      composition do
        {
          "CO2" => 96.5,
          "N2" => 3.5
        }
      end
    end

    trait :mars_like do
      temperature { 210.0 }
      pressure { 0.636 }
      total_atmospheric_mass { 2.5e16 }
      composition do
        {
          "CO2" => 95.97,
          "Ar" => 1.93,
          "N2" => 1.89,
          "O2" => 0.146
        }
      end
    end

    trait :sealed do
      sealing_status { true }
    end

    trait :artificial do
      environment_type { 'artificial' }
      sealing_status { true }
    end

    trait :space_vacuum do
      temperature { 2.7 }
      pressure { 0.0 }
      total_atmospheric_mass { 0 }
      composition { {} }
    end

    # ✅ ADD: Specific enclosed environment traits
    trait :ship_atmosphere do
      environment_type { 'artificial' }
      sealing_status { true }
      temperature { 295.15 }  # 22°C - comfortable for crew
      pressure { 101.325 }
      composition do
        {
          "N2" => 78.0,
          "O2" => 22.0   # Slightly higher O2 for alertness
        }
      end
    end

    trait :habitat_atmosphere do
      environment_type { 'enclosed' }
      sealing_status { true }
      temperature { 293.15 }  # 20°C
      pressure { 101.325 }
      composition do
        {
          "N2" => 78.08,
          "O2" => 20.95,
          "Ar" => 0.93,
          "CO2" => 0.04
        }
      end
    end
  end
end