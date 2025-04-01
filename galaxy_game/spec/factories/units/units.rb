# spec/factories/units.rb
FactoryBot.define do
  factory :base_unit, class: 'Units::BaseUnit' do   
    sequence(:identifier) { |n| "UNIT#{n}" }         
    sequence(:name) { |n| "Test Unit #{n}" }
    unit_type { "storage_unit" }

    # Required associations
    association :owner, factory: :base_settlement
    attachable { owner }

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
          'current_level' => 0
        }
      end
    end

    trait :methane_tank do
      unit_type { "methane_tank" }
      operational_data do
        {
          'capacity' => 100000,
          'type' => 'liquid',
          'current_level' => 0
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
  end

  factory :computer, class: 'Units::Computer' do
    unit_type { 'computer' }
    operational_data { {} }
    
    trait :with_upgrades do
      mining_rate { 2.0 }
      efficiency_upgrade { 0.5 }
    end
  end  
end
