FactoryBot.define do
  factory :computer, class: 'Units::Computer' do
    sequence(:name) { |n| "Computer #{n}" }
    sequence(:identifier) { |n| "computer_#{SecureRandom.hex(4)}" }
    unit_type { 'basic_computer' }
    operational_data { {} }
    
    # Use an organization as the owner by default
    association :owner, factory: :organization
    
    # Attachable could be a satellite, rig, or other entity
    # By default, create without an attachable (standalone)
    attachable { nil }
    
    # Use a trait for adding specific operational data for mining
    trait :with_mining_data do
      operational_data {
        {
          'operational_properties' => {
            'mining_rate' => 2.0,
            'efficiency_upgrade' => 0.1,
            'power_consumption' => 15.0
          }
        }
      }
    end
    
    # Keep the old trait for backward compatibility
    trait :with_upgrades do
      mining_rate_value { 2.0 }
      efficiency_upgrade_value { 0.5 }
    end
    
    # Add trait for attaching to a satellite
    trait :attached_to_satellite do
      transient do
        satellite { create(:base_satellite, owner: owner) }
      end
      
      attachable { satellite }
    end
    
    # Add trait for attaching to a settlement
    trait :attached_to_settlement do
      transient do
        settlement { create(:base_settlement) }
      end
      
      attachable { settlement }
    end
    
    # Add trait for mining rig attachment
    trait :attached_to_rig do
      transient do
        rig { create(:base_rig, owner: owner) }
      end
      
      attachable { rig }
    end
  end
end