FactoryBot.define do
  factory :job do
    association :owner, factory: :player
    association :settlement
    job_type { :material_processing }
    status { :in_progress }
    output_type { "component" }
    completes_at { 2.hours.from_now }
    blueprint { nil }
  end
end
