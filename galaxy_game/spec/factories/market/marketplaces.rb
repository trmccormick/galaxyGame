# --- spec/factories/market/marketplaces.rb (Fixed) ---
FactoryBot.define do
  factory :marketplace, class: 'Market::Marketplace' do
    # Requires a settlement that can act as the NPC market maker
    # FIX: Removed the reference to the non-existent trait :with_market_methods
    association :settlement, factory: :base_settlement 
    
    # Ensure the required MarketCondition is created after the marketplace
    after(:create) do |marketplace|
        # Create a default condition for the Battery Pack
        create(:market_condition, marketplace: marketplace, resource: 'Battery Pack')
    end
  end
end