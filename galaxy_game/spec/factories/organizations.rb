FactoryBot.define do
  factory :organization, class: 'Organizations::BaseOrganization' do
    sequence(:name) { |n| "Test Organization #{n}" }
    sequence(:identifier) { |n| "ORG#{n}" }
    organization_type { 'corporation' }

    trait :consortium do
      organization_type { 'consortium' }
      operational_data { { 'membership_status' => 'active', 'status' => 'Active', 'total_capital' => 1_000_000 } }
    end
    
    # Skip account creation to avoid duplicates during testing
    after(:build) do |organization|
      if organization.respond_to?(:create_account_and_inventory)
        organization.define_singleton_method(:create_account_and_inventory) { nil }
      end
    end
    
    # Add account only when explicitly needed
    trait :with_account do
      after(:create) do |organization|
        create(:account, accountable: organization) unless organization.account
      end
    end
    
    # Add inventory when needed
    trait :with_inventory do
      after(:create) do |organization|
        create(:inventory, inventoryable: organization) unless organization.inventory
      end
    end
  end

  # Alias factory for corporations
  factory :corporation, parent: :organization do
    organization_type { 'corporation' }
    operational_data { { 'membership_status' => 'active', 'status' => 'Active' } }
  end

  factory :consortium, parent: :organization do
    organization_type { 'consortium' }
    operational_data { { 'membership_status' => 'active', 'status' => 'Active', 'total_capital' => 1_000_000 } }
  end
end