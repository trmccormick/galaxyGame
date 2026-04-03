FactoryBot.define do
  factory :blueprint, class: 'Blueprint' do
    association :player
    name { "Generic Panel Array" }
    description { "Test blueprint" }
    input_resources { "" }
    output_resources { "" }
    production_time { 1 }
    gcc_cost { 1 }

    trait :shipyard do
      blueprint_type { 'shipyard' }
      materials { [create(:material, material_type: 'steel', quantity: 100)] }
    end
  end
end