FactoryBot.define do
  factory :base_craft, class: 'Craft::BaseCraft' do
    sequence(:name) { |n| "Starship Test #{n}" }
    craft_name { 'Starship (Lunar Variant)' }
    craft_type { 'transport' }
    current_location { 'Shackleton Crater Base' }
    
    # Provide minimal operational_data to pass validation
    # This ensures the factory works even if mocking isn't set up
    operational_data do
      {
        'name' => 'Starship (Lunar Variant)',
        'craft_type' => 'transport',
        'systems' => {}
      }
    end
    
    association :owner, factory: :player
    
    # Define player-constructed trait that explicitly flags the craft
    trait :player_constructed do
      after(:create) do |craft|
        # Mark as player constructed by setting a flag in operational_data
        data = craft.operational_data || {}
        data['player_constructed'] = true
        craft.update_column(:operational_data, data)
      end
    end
    
    # Define a trait that manually forces unit building
    trait :with_units do
      after(:create) do |craft|
        craft.build_units_and_modules
      end
    end
    
    # Keep the location traits
    trait :in_space do
      after(:create) do |craft|
        craft.spatial_location = create(:spatial_location)
        craft.save!
      end
    end
    
    trait :on_surface do
      after(:create) do |craft|
        craft.celestial_location = create(:celestial_location)
        craft.save!
      end
    end

    trait :docked do
      association :docked_at, factory: :base_settlement
    end

    trait :operational do
      after(:create) do |craft|
        # Set systems to online in the operational_data
        data = craft.operational_data || {}
        data['systems'] = {'stabilizer_unit' => {'status' => 'online'}}
        craft.update_column(:operational_data, data)
      end
    end

    # Trait for wormhole stabilizers
    trait :wormhole_stabilizer do
      craft_name { "Wormhole Stabilization Satellite" }
      deployed { true }
      
      after(:create) do |craft|
        # Set systems to online
        data = craft.operational_data || {}
        data['systems'] = {'stabilizer_unit' => {'status' => 'online'}}
        craft.update_column(:operational_data, data)
      end
    end
    
    # Keep simple trait for backwards compatibility
    trait :simple do
      craft_name { "Starship" }
      craft_type { "spaceships" }
    end
  end
end