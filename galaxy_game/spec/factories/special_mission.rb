FactoryBot.define do
  factory :special_mission do
    association :settlement, factory: :base_settlement
    material { 'oxygen' }
    required_quantity { 100 }
    reward_eap { 1000.0 }
    status { :open }
    bonus_multiplier { 1.0 }
    operational_data { {} }
  end
end