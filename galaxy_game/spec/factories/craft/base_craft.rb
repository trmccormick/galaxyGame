# spec/factories/craft/base_craft.rb
FactoryBot.define do
  factory :base_craft, class: 'Craft::BaseCraft' do
    sequence(:name) { |n| "Starship#{n}" }
    craft_name { "Starship" }
    craft_type { "spaceships" }  # Changed from "spaceship" to "spaceships" to match CATEGORIES
    operational_data { {
      'resources' => {
        'stored' => {}
      }
    } }
    
    association :owner, factory: :player
    
    trait :docked do
      association :docked_at, factory: :base_settlement
    end
  end
end