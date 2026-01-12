FactoryBot.define do
  factory :special_mission do
    association :settlement, factory: :base_settlement
    material { 'oxygen' }
    required_quantity { 500.0 }
    reward_eap { 1000.0 }
    bonus_multiplier { 1.0 }
    status { :open }
    operational_data { { mission_type: 'emergency_supply' } }
  end
end
