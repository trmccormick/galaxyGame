FactoryBot.define do
  factory :cycler, class: 'Craft::Transport::Cycler' do
    craft_name { 'cycler_ship' }
    craft_type { 'cycler' }
    cycler_type { 'earth_mars' }
    orbital_period { 780 }
    current_trajectory_phase { 'transit' }
    maximum_docking_capacity { 4 }
    encounter_schedule { {} }

    transient do
      with_base_craft { true }
    end

    after(:create) do |cycler, evaluator|
      if evaluator.with_base_craft && cycler.base_craft.blank?
        base_craft = FactoryBot.create(:base_craft, craft_type: 'cycler')
        cycler.update!(base_craft: base_craft)
      end
    end
  end
end