FactoryBot.define do
  factory :space_station, class: 'Settlement::OrbitalSettlement',
                          parent: :base_settlement do
    sequence(:name) { |n| "Space Station #{n}" }
    settlement_type { :station }
    current_population { 50 }

    operational_data {
      {
        'shell' => { 'status' => 'operational' },
        'dimensions' => {
          'width_m' => 100.0,
          'length_m' => 100.0,
          'height_m' => 50.0
        },
        'resource_management' => {
          'consumables' => {
            'energy_kwh' => { 'rate' => 1000, 'current_usage' => 800 }
          },
          'generated' => {
            'energy_kwh' => { 'rate' => 2000, 'current_output' => 1800 }
          }
        },
        'power_grid' => { 'status' => 'online', 'efficiency' => 0.95 }
      }
    }

    trait :planned do
      operational_data {
        {
          'shell' => { 'status' => 'planned' },
          'dimensions' => {
            'width_m' => 100.0,
            'length_m' => 100.0,
            'height_m' => 50.0
          }
        }
      }
    end

    trait :damaged do
      operational_data {
        {
          'shell' => { 'status' => 'damaged' },
          'dimensions' => {
            'width_m' => 100.0,
            'length_m' => 100.0,
            'height_m' => 50.0
          }
        }
      }
    end

    trait :with_habitat do
      after(:create) do |station|
        create(:base_unit,
          owner: station,
          attachable: station,
          unit_type: 'habitat',
          operational_data: {
            'life_support' => {
              'capacity' => 100,
              'status' => 'operational'
            }
          }
        )
      end
    end

    # Orbital depot variant
    factory :orbital_depot, class: 'Settlement::OrbitalSettlement' do
      sequence(:name) { |n| "Orbital Depot #{n}" }
      settlement_type { :outpost }
      current_population { 10 }
    end
  end
end
