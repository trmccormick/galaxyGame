FactoryBot.define do
  factory :job do
    # Associations
    association :owner, factory: :player 
    association :settlement
    
    # Core Attributes
    job_type { :material_processing }
    status { :in_progress } # Changed from :pending to stay within your enum
    output_type { "Material" }
    completes_at { 1.hour.from_now }
    
    # Metadata
    specifications { { "name" => "Default Job Specs" } }

    # Traits
    trait :unit_assembly do
      job_type { :unit_assembly }
      output_type { "Unit" }
    end

    trait :overdue do
      status { :in_progress }
      completes_at { 1.hour.ago }
    end
  end
end