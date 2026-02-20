# spec/factories/craft/base_craft.rb
FactoryBot.define do
  factory :base_craft, class: 'Craft::BaseCraft' do
    sequence(:name) { |n| "Starship#{n}" }
    craft_name { "Starship" }
    craft_type { "spaceships" }
    operational_data { {
      'systems' => {},
      'resources' => {
        'stored' => {}
      }
    } }

    association :owner, factory: :player

    trait :docked do
      association :docked_at, factory: :base_settlement
    end

    trait :operational do
      operational_data { {'systems' => {'stabilizer_unit' => {'status' => 'online'}}} }
    end


    after(:create) do |craft, _evaluator|
      unless craft.inventory
        FactoryBot.create(:inventory, inventoryable: craft)
        craft.reload
      end
    end

    # You might need a specific trait for wormhole stabilizers
    trait :wormhole_stabilizer do
      craft_name { "Wormhole Stabilization Satellite" }
      deployed { true }
    end

    trait :player_constructed do
      association :owner, factory: :player
    end
  end

  factory :craft_harvester, class: 'Craft::Harvester' do
    sequence(:name) { |n| "Harvester#{n}" }
    craft_name { "Harvester" }
    craft_type { "harvesters" }
    extraction_rate { 1.2 }
    operational_data {
      {
        'systems' => {},
        'resources' => {
          'stored' => {}
        },
        'extraction_rate' => extraction_rate
      }
    }

    association :owner, factory: :player

    # Allow association with a settlement or another craft in tests
    transient do
      docked_at { nil }
      docked_at_type { nil }
    end

    after(:create) do |harvester, evaluator|
      unless harvester.inventory
        FactoryBot.create(:inventory, inventoryable: harvester)
        harvester.reload
      end
      if evaluator.docked_at && evaluator.docked_at_type
        harvester.docked_at = evaluator.docked_at
        harvester.docked_at_type = evaluator.docked_at_type
      end
    end
  end
end