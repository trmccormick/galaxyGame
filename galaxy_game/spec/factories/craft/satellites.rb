# spec/factories/craft/satellites.rb
FactoryBot.define do
  factory :base_satellite, class: 'Craft::Satellite::BaseSatellite' do
    sequence(:name) { |n| "Satellite #{n}" }
    craft_name { "Generic Satellite" }
    craft_type { "generic_satellite" }
    deployed { false }
    current_location { nil }

    # ✅ ADDED: Associate an owner by default, using the :player factory
    # This ensures the 'owner' validation passes for all created satellites.
    association :owner, factory: :player

    trait :wormhole_stabilizer do
      craft_name { "Wormhole Stabilization Satellite" }
      craft_type { "wormhole_stabilization_satellite" }
      deployed { true }

      after(:create) do |satellite|
        data = satellite.operational_data || {}
        data['systems'] = data.fetch('systems', {}).deep_merge('stabilizer_unit' => { 'status' => 'online' })
        satellite.update_column(:operational_data, data)
        satellite.reload
      end
    end
  end
end