FactoryBot.define do
  factory :base_settlement, class: 'Settlement::BaseSettlement' do
    sequence(:name) { |n| "Base Settlement #{n}" }
    settlement_type { :base }
    current_population { 5 }

    operational_data {
      {
        'consumption_rates' => {
          'food' => 2,
          'water' => 1,
          'energy' => 3
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

    transient do
      owner_type { :development_corporation }
    end
    association :location, factory: :celestial_location

    after(:build) do |settlement, evaluator|
      settlement.owner ||= case evaluator.owner_type
                          when :development_corporation
                            build(:development_corporation)
                          when :player
                            build(:player)
                          else
                            build(:development_corporation)
                          end
      if settlement.respond_to?(:create_account_and_inventory)
        settlement.define_singleton_method(:create_account_and_inventory) { nil }
      end
      settlement.build_inventory if settlement.inventory.nil?
      if settlement.respond_to?(:build_units_and_modules)
        settlement.define_singleton_method(:build_units_and_modules) { true }
      end
    end

    trait :independent do
      colony { nil }
    end

    trait :with_account do
      after(:build) do |settlement|
        # Override the disable — allow account creation for this trait
        settlement.define_singleton_method(:create_account_and_inventory) { nil } if settlement.respond_to?(:create_account_and_inventory)
      end
      after(:create) do |settlement|
        unless settlement.account
          gcc = Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
            c.name = 'Galactic Crypto Currency'
            c.is_system_currency = true
            c.precision = 8
          end
          Financial::Account.create!(
            accountable: settlement,
            currency: gcc,
            balance: 1_000.00,
            lock_version: 0
          )
          settlement.reload
        end
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

    trait :with_construction_materials do
      after(:create) do |settlement|
        %w[Steel Glass Planetary\ Regolith Aluminum Carbon Plastics].each do |material|
          settlement.inventory.items.create!(
            name: material,
            amount: 1000,
            material_type: 'raw_material',
            storage_method: 'bulk_storage'
          )
        end
      end
    end

    trait :with_critical_resources do
      after(:create) do |settlement|
        %w[oxygen water nitrogen].each do |resource|
          settlement.inventory.items.create!(
            name: resource,
            amount: 1000,
            material_type: 'critical_resource',
            storage_method: 'bulk_storage'
          )
        end
      end
    end

    trait :for_energy_testing do
      operational_data {
        {
          'resource_management' => {
            'consumables' => {
              'energy_kwh' => { 'rate' => 1000, 'current_usage' => 1000 }
            },
            'generated' => {
              'energy_kwh' => { 'rate' => 1500, 'current_output' => 1500 }
            }
          },
          'power_grid' => { 'status' => 'optimal', 'efficiency' => 1.0 },
          'battery' => {
            'capacity' => 100.0,
            'current_charge' => 50.0,
            'drain_rate' => 5.0,
            'discharge_efficiency' => 0.9
          }
        }
      }
    end

    trait :station do
      settlement_type { :station }
    end

    # Standard settlement variant
    factory :settlement, class: 'Settlement::BaseSettlement' do
      sequence(:name) { |n| "Settlement #{n}" }
      association :owner, factory: :player

      transient do
        celestial_body { nil }
      end

      after(:build) do |settlement, evaluator|
        if evaluator.celestial_body
          settlement.location ||= build(:celestial_location,
            celestial_body: evaluator.celestial_body)
        end
      end
    end
  end
end