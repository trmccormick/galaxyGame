FactoryBot.define do
  factory :player do
    sequence(:name) { |n| "Player #{n}" }
    active_location { "Lunar Base Alpha" }
    biography { "A space explorer" }
    
    # Skip account creation to avoid duplicates during testing
    after(:build) do |player|
      if player.respond_to?(:create_account)
        player.define_singleton_method(:create_account) { nil }
      end
    end
    
    # Add account only when explicitly needed
    trait :with_account do
      after(:create) do |player|
        create(:account, accountable: player) unless player.account
      end
    end
    
    # Add inventory only when explicitly needed
    trait :with_inventory do
      after(:create) do |player|
        create(:inventory, inventoryable: player) unless player.inventory
      end
    end
  end
end