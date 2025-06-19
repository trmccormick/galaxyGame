FactoryBot.define do
  factory :base_module, class: 'Modules::BaseModule' do
    sequence(:identifier) { |n| "MODULE#{n}" }
    sequence(:name) { |n| "Test Module #{n}" }
    description { "Test module description" }
    module_type { "life_support" }
    energy_cost { 10 }
    maintenance_materials { { "steel" => 5 } }
    module_class { "basic" }

    # Required associations
    # association :owner, factory: :base_settlement
    # attachable { owner }

    trait :airlock do
      name { "Airlock Module" }
      module_type { "airlock" }
      description { "Airlock module for pressurized access" }
      energy_cost { 5 }
      maintenance_materials { { "steel" => 10 } }
      module_class { "basic" }
    end

    trait :co2_scrubber do
      name { "CO2 Scrubber Module" }
      module_type { "co2_scrubber" }
      description { "CO2 scrubbing module for life support" }
      energy_cost { 15 }
      maintenance_materials { { "steel" => 5, "filters" => 2 } }
      module_class { "life_support" }
    end

    trait :from_lookup do
      name { nil }
      description { nil }  
      energy_cost { nil }
      module_class { nil }
      operational_data { nil }
      maintenance_materials { nil }
    end
  end
end