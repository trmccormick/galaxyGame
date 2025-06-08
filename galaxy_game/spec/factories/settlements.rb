# spec/factories/settlements.rb
FactoryBot.define do
  factory :settlement, class: 'Settlement::Settlement' do
    name { "Independent Mars Settlement" }
    current_population { 1000 }
    
    colony # Assumes you have a factory for colony

    # Optionally, specify a colony when creating a settlement
    trait :with_colony do
      association :colony
    end
  end

  # Consolidate both factories into this one
  factory :base_settlement, class: 'Settlement::BaseSettlement' do
    sequence(:name) { |n| "Settlement #{n}" }
    current_population { 6 }
    settlement_type { :base }
    association :owner, factory: :player
    association :location, factory: :celestial_location

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
        settlement.build_units_and_modules
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
    
    # Associate with an organization instead of player
    trait :with_organization_owner do
      association :owner, factory: :organization
    end
    
    # Special trait for energy management testing
    trait :for_energy_testing do
      # Override the callback before the model is created
      after(:build) do |settlement|
        # Important: Override the callback BEFORE it's triggered
        settlement.define_singleton_method(:build_units_and_modules) do
          # Do nothing - this prevents the error
          true
        end
        
        # Define operational_data methods if needed
        unless settlement.respond_to?(:operational_data)
          settlement.define_singleton_method(:operational_data) do
            @virtual_operational_data ||= {}
          end
          
          settlement.define_singleton_method(:operational_data=) do |data|
            @virtual_operational_data = data
          end
        end
      end
    end
  end
end