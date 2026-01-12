FactoryBot.define do
  factory :blueprint do
    association :player
    name { "Generic Panel Array" }
    description { "Test blueprint" }
    input_resources { "" }
    output_resources { "" }
    production_time { 1 }
    gcc_cost { 1 }
  end
end