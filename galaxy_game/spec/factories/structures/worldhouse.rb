FactoryBot.define do
  factory :worldhouse, class: 'Structures::Worldhouse' do
    sequence(:name) { |n| "Worldhouse #{n}" }
    structure_name { "worldhouse" }
    current_population { 0 }
    association :settlement, factory: :base_settlement
    association :owner, factory: :player
    association :geological_feature, factory: :valley_feature
    
    operational_data do
      {
        "structure_type" => "worldhouse",
        "connection_systems" => {
          "power_distribution" => {"status" => "offline", "efficiency" => 85}
        },
        "container_capacity" => {
          "unit_slots" => [
            {"type" => "energy", "count" => 1},
            {"type" => "computers", "count" => 1}
          ],
          "module_slots" => [
            {"type" => "power", "count" => 1}
          ]
        },
        "operational_modes" => {
          "current_mode" => "standby",
          "available_modes" => [
            {"name" => "standby", "power_draw" => 250.0, "staff_required" => 2},
            {"name" => "production", "power_draw" => 2500.0, "staff_required" => 10}
          ]
        }
      }
    end
  end
end