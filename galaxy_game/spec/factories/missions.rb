FactoryBot.define do
  factory :mission do
    sequence(:identifier) { |n| "mission_#{n}" }
    association :settlement, factory: :base_settlement
    status { :in_progress }
    progress { 0 }
    operational_data { {} }
  end
end