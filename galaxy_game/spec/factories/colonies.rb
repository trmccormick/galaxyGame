FactoryBot.define do
  factory :colony do
    sequence(:name) { |n| "Test Colony #{n}" }
    
    # Use the :luna trait to create a lunar celestial body
    association :celestial_body, factory: [:celestial_body, :luna]
    
    # Skip account creation to avoid duplicates during testing
    after(:build) do |colony|
      if colony.respond_to?(:create_account_and_inventory)
        colony.define_singleton_method(:create_account_and_inventory) { nil }
      end
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
    
    # Also keep the with_settlements trait for backward compatibility
    trait :with_settlements do
      after(:build) do |colony|
        2.times do |i|
          settlement = build(:base_settlement, name: "Settlement #{i} for #{colony.name}")
          colony.settlements << settlement
        end
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
    
    # Different celestial body types
    trait :lunar do
      association :celestial_body, factory: [:celestial_body, :luna]
    end
    
    trait :martian do
      association :celestial_body, factory: [:celestial_body, :mars]
    end
    
    trait :earth do
      association :celestial_body, factory: [:celestial_body, :earth]
    end
  end
end