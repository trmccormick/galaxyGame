FactoryBot.define do
  factory :colony do
    sequence(:name) { |n| "Test Colony #{n}" }
    
    association :celestial_body, factory: :celestial_body
    
    # Skip account creation to avoid duplicates during testing
    after(:build) do |colony|
      if colony.respond_to?(:create_account_and_inventory)
        colony.define_singleton_method(:create_account_and_inventory) { nil }
      end
      
      # Skip validation during build phase (from new colony factory)
      colony.define_singleton_method(:validate_minimum_settlements) { true }
    end
    
    # Skip validation when needed for account tests
    trait :skip_validation do
      after(:build) do |colony|
        colony.instance_variable_set(:@skip_settlement_validation, true)
      end
    end
    
    # This trait is needed by colony_spec.rb - adds multiple settlements BEFORE creating
    trait :with_multiple_settlements do
      # Add settlements during build phase
      after(:build) do |colony|
        # Create 2 settlements and add them
        2.times do |i|
          settlement = build(:base_settlement, name: "Settlement #{i} for #{colony.name}")
          colony.settlements << settlement
        end
      end
      
      # Add accounts and inventory after creation
      after(:create) do |colony|
        create(:account, accountable: colony) unless colony.account
        create(:inventory, inventoryable: colony) unless colony.inventory
      end
    end
    
    # Better version of with_settlements (taken from new factory)
    trait :with_settlements do
      after(:create) do |colony|
        # Create a main settlement
        create(:settlement, 
          :independent, # Important to avoid circular colony references!
          name: "#{colony.name} Hub",
          settlement_type: :base
        ).update(colony: colony) # Set colony after creation to avoid validation issues

        # Create a secondary settlement
        create(:outpost,
          :independent, # Important to avoid circular colony references!
          name: "#{colony.name} Outpost"
        ).update(colony: colony) # Set colony after creation to avoid validation issues
      end
    end
    
    # Ensure the colony has the minimum required settlements (from new factory)
    trait :with_minimum_settlements do
      after(:create) do |colony|
        # Create exactly two settlements (minimum required)
        create(:settlement, name: "#{colony.name} Base", colony: colony)
        create(:settlement, name: "#{colony.name} Outpost", colony: colony, settlement_type: :outpost)
      end
    end
    
    # Add account only when explicitly needed
    trait :with_account do
      after(:create) do |colony|
        create(:account, accountable: colony) unless colony.account
      end
    end

    # Add inventory when needed
    trait :with_inventory do
      after(:create) do |colony|
        create(:inventory, inventoryable: colony) unless colony.inventory
      end
    end
    
  end
end