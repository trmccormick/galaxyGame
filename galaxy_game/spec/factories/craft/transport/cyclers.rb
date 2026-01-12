FactoryBot.define do
  factory :cycler, class: 'Craft::Transport::Cycler' do
    craft_name { 'cycler_ship' }
    craft_type { 'cycler' }
    cycler_type { 'earth_mars' }
    orbital_period { 780 }
    current_trajectory_phase { 'transit' }
    maximum_docking_capacity { 4 }
    encounter_schedule { {} }
  end
end