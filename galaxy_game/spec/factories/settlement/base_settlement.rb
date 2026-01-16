# spec/factories/settlement/settlements.rb
FactoryBot.define do
  # Base Settlement - parent factory that others inherit from
  factory :base_settlement, class: 'Settlement::BaseSettlement' do
    sequence(:name) { |n| "Base Settlement #{n}" }
    settlement_type { :base }
    current_population { 5 }
    
    # Add default operational_data
    operational_data {
      {
        'consumption_rates' => {
          'food' => 2,
          'water' => 1,
          'energy' => 3
        },
        'resource_management' => {
          'consumables' => {
            'energy_kwh' => {'rate' => 1000, 'current_usage' => 800}
          },
          'generated' => {
            'energy_kwh' => {'rate' => 2000, 'current_output' => 1800}
          }
        },
        'power_grid' => {'status' => 'online', 'efficiency' => 0.95}
      }
    }

    association :owner, factory: :player
    association :location, factory: :celestial_location
    
    # Independent settlement (no colony)
    trait :independent do
      colony { nil }
    end

    # Skip account creation to avoid duplicates during testing
    after(:build) do |settlement|
      # Only override the callback if it exists
      if settlement.respond_to?(:create_account_and_inventory)
        settlement.define_singleton_method(:create_account_and_inventory) { nil }
      end
      
      # Add default inventory without capacity
      settlement.build_inventory if settlement.inventory.nil?
      
      # Handle build_units_and_modules if it exists
      if settlement.respond_to?(:build_units_and_modules)
        settlement.define_singleton_method(:build_units_and_modules) { true }
      end
    end

    # Add account only when explicitly needed
    trait :with_account do
      after(:create) do |settlement|
        create(:account, accountable: settlement) unless settlement.account
      end
    end

    trait :with_storage do
      after(:create) do |settlement|
        create(:base_unit, :storage,
          owner: settlement,
          attachable: settlement,
          operational_data: {
            'capacity' => 100000,
            'storage' => {
              'liquid' => 250000,
              'gas' => 200000
            }
          }
        )
      end
    end
    
    # Station trait for orbital stations
    trait :station do
      settlement_type { :station }
      sequence(:name) { |n| "Orbital Station #{n}" }
      
      # Ensure no account is created for stations
      after(:build) do |settlement|
        if settlement.respond_to?(:create_account_and_inventory)
          settlement.define_singleton_method(:create_account_and_inventory) { nil }
        end
      end
    end
    
    # Settlement with specific resources
    trait :with_construction_materials do
      after(:create) do |settlement|
        %w[Steel Glass Planetary\ Regolith Aluminum Carbon Plastics].each do |material|
          settlement.inventory.items.create!(
            name: material,
            amount: 1000,
            material_type: "raw_material",
            storage_method: "bulk_storage"
          )
        end
      end
    end

    # Add the for_energy_testing trait here:
    trait :for_energy_testing do
      operational_data {
        {
          'resource_management' => {
            'consumables' => {
              'energy_kwh' => {'rate' => 1000, 'current_usage' => 1000}
            },
            'generated' => {
              'energy_kwh' => {'rate' => 1500, 'current_output' => 1500}
            }
          },
          'power_grid' => {'status' => 'optimal', 'efficiency' => 1.0},
          'battery' => {
            'capacity' => 100.0,
            'current_charge' => 50.0,
            'drain_rate' => 5.0,
            'discharge_efficiency' => 0.9
          }
        }
      }
    end
  end
  
  # Standard Settlement - inherits from base_settlement
  factory :settlement, class: 'Settlement::Settlement', parent: :base_settlement do
    sequence(:name) { |n| "Settlement #{n}" }
    current_population { 10 }
  end

  # City - inherits from settlement
  factory :city, class: 'Settlement::City', parent: :settlement do
    sequence(:name) { |n| "City #{n}" }
    settlement_type { :city }
    current_population { 500 }
  end
  
  # Outpost - inherits from settlement
  factory :outpost, class: 'Settlement::Outpost', parent: :settlement do
    sequence(:name) { |n| "Outpost #{n}" }
    settlement_type { :outpost }
    current_population { 25 }
  end
  
  # Space Station - inherits from base_settlement
  factory :space_station, class: 'Settlement::SpaceStation', parent: :base_settlement do
    sequence(:name) { |n| "Space Station #{n}" }
    settlement_type { :space_station }
    current_population { 50 }
  end

  # Orbital Depot - inherits from space_station
  factory :orbital_depot, class: 'Settlement::OrbitalDepot', parent: :space_station do
    sequence(:name) { |n| "Orbital Depot #{n}" }
    settlement_type { :outpost }
    current_population { 10 }
  end
end