# spec/factories/structures/crater_dome.rb
FactoryBot.define do
  factory :crater_dome, class: 'Structures::CraterDome' do
    sequence(:name) { |n| "Crater Dome #{n}" }
    structure_name { "crater_dome" }
    structure_type { "crater_dome" }
    association :settlement, factory: :base_settlement
    association :owner, factory: :player
    operational_data {
      {
        'dimensions' => {
          'diameter' => 100.0,
          'depth' => 20.0
        },
        'status' => 'planned',
        'cover_status' => 'uncovered',
        'structure_type' => 'crater_dome',
        'layer_type' => 'primary',
        'notes' => 'Test dome',
        'completion_date' => nil,
        'estimated_completion' => nil
      }
    }
    current_population { 0 }

    trait :covered do
      operational_data {
        {
          'dimensions' => {
            'diameter' => 100.0,
            'depth' => 20.0
          },
          'status' => 'complete',
          'cover_status' => 'covered',
          'structure_type' => 'crater_dome',
          'layer_type' => 'both',
          'notes' => 'Covered dome',
          'completion_date' => Time.now.to_s,
          'estimated_completion' => nil
        }
      }
    end

    trait :with_dimensions do
      operational_data {
        {
          'dimensions' => {
            'diameter' => 150.0,
            'depth' => 30.0
          },
          'status' => 'planned',
          'cover_status' => 'uncovered',
          'structure_type' => 'crater_dome',
          'layer_type' => 'primary',
          'notes' => 'Test dome with custom dimensions',
          'completion_date' => nil,
          'estimated_completion' => nil
        }
      }
    end
  end
end
