# spec/factories/component_production_jobs.rb
FactoryBot.define do
  factory :component_production_job do
    association :settlement, factory: :base_settlement
    association :printer_unit, factory: :base_unit
    
    component_blueprint_id { '3d_printed_ibeam' }
    component_name { '3D-Printed I-Beam' }
    quantity { 1 }
    status { 'pending' }
    production_time_hours { 2.0 }
    progress_hours { 0.0 }
    materials_consumed { {} }
    import_cost_gcc { 0.0 }
    metadata { {} }

    trait :in_progress do
      status { 'in_progress' }
      started_at { Time.current }
      progress_hours { 1.0 }
    end

    trait :completed do
      status { 'completed' }
      started_at { 1.day.ago }
      completed_at { Time.current }
      progress_hours { 2.0 }
    end

    trait :failed do
      status { 'failed' }
      started_at { 1.day.ago }
      completed_at { Time.current }
      metadata { { 'failure_reason' => 'Test failure' } }
    end

    trait :with_materials do
      materials_consumed do
        {
          'inert_waste' => {
            'amount' => 90,
            'composition' => {
              'oxides' => {
                'SiO2' => 43.0,
                'Al2O3' => 24.0
              }
            }
          }
        }
      end
    end
  end
end