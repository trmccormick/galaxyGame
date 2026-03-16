# spec/factories/structures/crater_dome.rb
FactoryBot.define do
  factory :crater_dome, class: 'Structures::CraterDome' do
    name { "Test Crater Dome" }
    structure_name { "Crater Dome" }
    layer_type { 'primary' }
    
    # Accept diameter and depth as parameters
    transient do
      diameter { 400 }
      depth { 40 }
    end
    
    # Initialize operational_data directly
    after(:build) do |dome, evaluator|
      dome.operational_data ||= {}
      dome.operational_data['dimensions'] ||= {}
      dome.operational_data['dimensions']['diameter'] = evaluator.diameter
      dome.operational_data['dimensions']['depth'] = evaluator.depth
      dome.operational_data['status'] = 'planned'
      dome.operational_data['layer_type'] = 'primary'
    end
    
    # If you need to support the dimensions hash format:
    trait :with_dimensions do
      transient do
        dimensions { { diameter: 400, depth: 40 } }
      end
      
      after(:build) do |dome, evaluator|
        # Override the default dimensions with the trait's dimensions
        dome.operational_data ||= {}
        dome.operational_data['dimensions'] ||= {}
        dome.operational_data['dimensions']['diameter'] = evaluator.dimensions[:diameter]
        dome.operational_data['dimensions']['depth'] = evaluator.dimensions[:depth]
      end
    end
    
    association :owner, factory: :player
    association :location, factory: :celestial_location
    association :settlement, factory: :base_settlement, strategy: :create
    
    # Dome in different states
    trait :under_construction do
      after(:build) do |dome|
        dome.status = "under_construction"
      end
    end
    
    trait :operational do
      status { "operational" }
    end
    
    # Dome with specific layer
    trait :with_primary_layer do
      status { "primary_layer_complete" }
    end
    
    trait :with_secondary_layer do
      status { "secondary_layer_complete" }
    end
  end
end