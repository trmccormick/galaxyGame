FactoryBot.define do
    trait :overdue do
      status { :in_progress }
      completes_at { 1.hour.ago }
    end
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
