# spec/factories/shell_printing_jobs.rb
FactoryBot.define do
  factory :shell_printing_job do
    association :settlement, factory: :base_settlement
    association :printer_unit, factory: :unit
    association :inflatable_tank, factory: :unit
    
    status { 'pending' }
    production_time_hours { 10.0 }
    progress_hours { 0.0 }
    materials_consumed { {} }
    metadata { {} }

    trait :in_progress do
      status { 'in_progress' }
      started_at { Time.current }
      progress_hours { 5.0 }
    end

    trait :completed do
      status { 'completed' }
      started_at { 1.day.ago }
      completed_at { Time.current }
      progress_hours { 10.0 }
    end

    trait :with_materials do
      materials_consumed do
        {
          'inert_waste' => {
            'amount' => 1400,
            'composition' => {
              'oxides' => {
                'SiO2' => 43.0,
                'Al2O3' => 24.0
              }
            }
          },
          '3D-Printed I-Beam Mk1' => {
            'amount' => 5,
            'composition' => {}
          }
        }
      end
    end
  end
end