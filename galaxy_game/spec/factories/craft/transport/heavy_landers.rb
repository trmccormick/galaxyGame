FactoryBot.define do
  factory :heavy_lander, class: 'Craft::Transport::HeavyLander' do
    sequence(:name) { |n| "Heavy Lander #{n}" }
    craft_name { 'heavy_lander' }
    craft_type { 'lander' }
    current_location { 'Lunar Surface' }
    operational_data {
      {
        'name' => 'heavy_lander',
        'craft_type' => 'lander',
        'category' => 'lander',
        'systems' => {},
        'operational_flags' => {
          'autonomous' => true,
          'human_rated' => true
        },
        'ports' => {
          'internal_module_ports' => 2,
          'external_module_ports' => 1,
          'fuel_storage_ports' => 1,
          'unit_ports' => 2,
          'external_ports' => 1,
          'propulsion_ports' => 2,
          'storage_ports' => 2
        }
      }
    }
    association :owner, factory: :player
  end
end