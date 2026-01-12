FactoryBot.define do
  factory :base_rig, class: 'Rigs::BaseRig' do
    identifier { SecureRandom.uuid }
    name { "Solar Expansion Rig" }
    description { "A rig designed to attach additional solar panels." }
    rig_type { "solar_expansion" }
    capacity { 100 }
    operational_data { { "consumables" => { "energy" => -50, "maintenance_effort" => 10 } } }
    association :attachable, factory: :base_unit
  end
end