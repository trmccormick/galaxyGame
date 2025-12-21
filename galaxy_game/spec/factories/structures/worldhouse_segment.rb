FactoryBot.define do
  factory :worldhouse_segment, class: 'Structures::WorldhouseSegment' do
    association :worldhouse, factory: :worldhouse
    
    sequence(:segment_index) { |n| n }  # Auto-incrementing index
    segment_type { 'residential' }
    status { 'planned' }
    coverage_status { 'uncovered' }
    
    operational_data do
      {
        "segment_type" => "residential",
        "capacity" => {
          "max_occupancy" => 1000,
          "current_occupancy" => 0
        },
        "systems" => {
          "life_support" => {"status" => "offline"},
          "climate_control" => {"status" => "offline"}
        }
      }
    end
  end
end