# spec/factories/settlement/base_settlement.rb
FactoryBot.define do
  factory :base_settlement, class: 'Settlement::BaseSettlement' do
    sequence(:name) { |n| "Settlement #{n}" }
    current_population { 6 }
    settlement_type { :base }
    association :owner, factory: :player
    association :location, factory: :celestial_location

    # Add default inventory
    after(:build) do |settlement|
      settlement.build_inventory if settlement.inventory.nil?
    end

    trait :independent do
      owner { nil }
    end

    trait :with_storage do
      after(:create) do |settlement|
        create(:base_unit, :storage,
          owner: settlement,
          attachable: settlement,
          operational_data: {
            'storage' => {
              'liquid' => 250000,
              'gas' => 200000
            }
          }
        )
      end
    end
  end
end
