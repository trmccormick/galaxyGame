# filepath: spec/factories/unit_assembly_jobs.rb
FactoryBot.define do
  factory :unit_assembly_job do
    association :base_settlement, factory: :base_settlement  # Use correct association
    unit_type { 'test_unit' }
    count { 1 }
    status { 'materials_pending' }
    priority { 'medium' }
    specifications do
      {
        'name' => 'Test Unit',
        'production_data' => {
          'manufacturing_time_hours' => 1
        }
      }
    end
  end
end