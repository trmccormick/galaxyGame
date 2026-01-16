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

    # You might need a specific trait for wormhole stabilizers
    trait :wormhole_stabilizer do
      craft_name { "Wormhole Stabilization Satellite" }
      deployed { true }
    end

    trait :player_constructed do
      association :owner, factory: :player
    end
  end
end