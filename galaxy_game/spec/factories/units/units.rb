# spec/factories/units.rb
FactoryBot.define do
  factory :base_unit, class: 'Units::BaseUnit' do
    sequence(:identifier) { |n| "UNIT#{n}" }
    sequence(:name) { |n| "Test Unit #{n}" }
    unit_type { "basic_unit" } # Default to a generic unit type
    operational_data { {} }
    association :owner, factory: :organization
    attachable { nil }

    # Existing traits from your definition
    trait :housing do
      unit_type { "inflatable_habitat" }
    end

    trait :gas_storage do
      unit_type { "gas_storage" }
    end

    trait :power do
      unit_type { "solar_panel" }
    end

    trait :storage do
      unit_type { "storage_unit" }
    end

    trait :lox_tank do
      unit_type { "lox_tank" }
      operational_data do
        {
          'capacity' => 150000,
          'type' => 'liquid',
          'current_level' => 0,
          'human_rated' => false
        }
      end
    end

    trait :methane_tank do
      unit_type { "methane_tank" }
      operational_data do
        {
          'capacity' => 100000,
          'type' => 'liquid',
          'current_level' => 0,
          'human_rated' => false
        }
      end
    end

    trait :with_location do
      association :location, factory: :celestial_location
    end

    trait :with_rig do
      after(:create) do |unit|
        create(:base_rig, attachable: unit)
      end
    end

    trait :with_inventory do
      after(:create) do |unit|
        create(:inventory, storage_unit: unit)
      end
    end

    # --- NEW/UPDATED TRAITS AND FACTORIES FOR SPECIFIC UNIT TYPES ---

    trait :computer do
      unit_type { 'control_computer' } # Matches CONTROL_UNIT_TYPES
      name { 'Computer Unit' }
      operational_data do
        {
          'power_consumption' => 10,
          'processing_power' => 100,
          'human_rated' => false,
          'energy_required_value' => 10.0,
          'mining_rate_value' => 1.0,
          'efficiency_upgrade_value' => 0.0
        }
      end
    end
    factory :computer_unit, traits: [:computer] # Factory for computer units

    trait :robot do
      unit_type { 'robot' } # Matches LookupService 'robot'
      name { 'Robot Unit' }
      operational_data do
        {
          'human_rated' => false,
          'manufacturing_speed_bonus' => 0.1,
          'mobility_type' => 'wheels' # From LookupService mock
        }
      end
    end
    factory :robot_unit, traits: [:robot] # Factory for robot units

    trait :habitat do
      unit_type { 'inflatable_habitat_unit' } # Matches LookupService 'inflatable_habitat_unit'
      name { 'Inflatable Habitat Unit' }
      operational_data do
        {
          'human_rated' => true,
          'capacity' => 5 # From LookupService mock
        }
      end
    end
    factory :habitat_unit, traits: [:habitat] # Factory for habitat units

    trait :cargo_bay do
      unit_type { 'cargo_bay' } # Assuming a generic 'cargo_bay' unit_type for this
      name { 'Cargo Bay Unit' }
      operational_data do
        {
          'human_rated' => false,
          'cargo_capacity_bonus' => 500 # Example operational data
        }
      end
    end
    factory :cargo_bay_unit, traits: [:cargo_bay] # Factory for cargo bay units

    trait :battery do
      unit_type { 'battery' } # Matches LookupService 'battery'
      name { 'Battery Unit' }
      operational_data do
        {
          'human_rated' => false,
          'power_storage' => 1000 # From LookupService mock
        }
      end
    end
    factory :battery_unit, traits: [:battery] # Factory for battery units

    # Ensure :storage_unit factory is also defined if it's used directly
    factory :storage_unit, parent: :base_unit do # Assuming storage_unit is a base_unit
      unit_type { 'storage_unit' }
      name { 'Storage Unit' }
      operational_data do
        {
          'human_rated' => false,
          'capacity' => 0,
          'storage_capacity_m3' => 250.0,
          'max_load_kg' => 50000.0,
          'power_draw_kw' => 2.0
        }
      end
    end
  end
end