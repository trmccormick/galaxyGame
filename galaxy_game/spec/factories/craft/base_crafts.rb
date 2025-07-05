FactoryBot.define do
  factory :base_craft, class: 'Craft::BaseCraft' do
    sequence(:name) { |n| "Starship Test #{n}" }
    craft_name { 'Starship (Lunar Variant)' }
    craft_type { 'transport' }
    current_location { 'Shackleton Crater Base' }
    
    # Provide operational_data including a comprehensive ports definition
    operational_data do
      {
        'name' => 'Starship (Lunar Variant)',
        'craft_type' => 'transport',
        'systems' => {}, # Keep existing systems hash
        'operational_flags' => {
          'autonomous' => false,
          'human_rated' => false  # Default to non-human rated
        },
        'ports' => {  # Use string keys consistently
          'internal_module_ports' => 8,
          'external_module_ports' => 2,
          'fuel_storage_ports' => 2,
          'unit_ports' => 4,
          'external_ports' => 2,
          'propulsion_ports' => 6,
          'storage_ports' => 3
        }
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
    # trait :wormhole_stabilizer do
    #   craft_name { "Wormhole Stabilization Satellite" }
    #   deployed { true }
      
    #   after(:create) do |craft|
    #     # Set systems to online
    #     data = craft.operational_data || {}
    #     data['systems'] = {'stabilizer_unit' => {'status' => 'online'}}
    #     craft.update_column(:operational_data, data)
    #   end
    # end
    
    # Keep simple trait for backwards compatibility
    trait :simple do
      craft_name { "Starship" }
      craft_type { "spaceships" }
    end

    # Add a human-rated trait
    trait :human_rated do
      after(:create) do |craft|
        data = craft.operational_data || {}
        data['operational_flags'] ||= {}
        data['operational_flags']['human_rated'] = true
        craft.update_column(:operational_data, data)
      end
    end
    
    # Add a life_support trait
    trait :with_life_support do
      after(:create) do |craft|
        data = craft.operational_data || {}
        data['recommended_fit'] ||= {}
        data['recommended_fit']['units'] ||= []
        
        life_support_units = [
          { 'id' => 'starship_habitat_unit', 'count' => 1 },
          { 'id' => 'waste_management_unit', 'count' => 1 },
          { 'id' => 'co2_oxygen_production_unit', 'count' => 1 },
          { 'id' => 'water_recycling_unit', 'count' => 1 }
        ]
        
        data['recommended_fit']['units'].concat(life_support_units)
        craft.update_column(:operational_data, data)
      end
    end
  end
end