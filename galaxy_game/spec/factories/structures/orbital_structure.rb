FactoryBot.define do
  factory :orbital_structure, class: 'Structures::OrbitalStructure' do
    sequence(:name) { |n| "Orbital Structure #{n}" }
    structure_name { "orbital_structure" }
    structure_type { "orbital_structure" }
    current_population { 0 }
    association :settlement, factory: :orbital_settlement
    association :owner, factory: :player
    # Removed geological_feature association; not present on OrbitalStructure
    operational_data { { "structure_type" => "orbital_structure" } }
  end
end
