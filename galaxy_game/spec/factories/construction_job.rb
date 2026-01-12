FactoryBot.define do
  factory :construction_job do
    association :jobable, factory: [:crater_dome, :with_dimensions]
    association :settlement, factory: :base_settlement
    
    job_type { :crater_dome_construction }
    status { :scheduled }
    
    # Add target_values for common scenarios
    trait :with_target_values do
      transient do
        entity { create(:player) }
        service_provider { entity }
        layer_type { 'primary' }
      end
      
      after(:build) do |job, evaluator|
        job.target_values = { 
          layer_type: evaluator.layer_type,
          owner_id: evaluator.entity.id,
          owner_type: evaluator.entity.class.name,
          service_provider_id: evaluator.service_provider.id,
          service_provider_type: evaluator.service_provider.class.name
        }
      end
    end
    
    # Create a job ready to start construction
    trait :ready_to_start do
      status { :materials_pending }
      with_target_values
      
      after(:create) do |job, _evaluator|
        # Create fulfilled material requests
        create(:material_request, 
          requestable: job,
          material_type: "Steel",
          quantity_requested: 100,
          status: 'fulfilled'
        )
        
        create(:material_request, 
          requestable: job,
          material_type: "Glass",
          quantity_requested: 50,
          status: 'fulfilled'
        )
      end
    end
    
    # Create a job that's already in progress
    trait :in_progress do
      status { :in_progress }
      with_target_values
      
      after(:create) do |job, _evaluator|
        # Update the jobable status
        if job.jobable.respond_to?(:status=)
          job.jobable.update(status: 'under_construction')
        end
        
        # Set an estimated completion time
        job.update(estimated_completion: 24.hours.from_now)
      end
    end
  end
end