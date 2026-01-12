module AIManager
  class ResourcePlanner
    # This class handles resource planning and procurement
    
    def initialize(settlement)
      @settlement = settlement
    end
    
    # Generate a resource procurement plan
    def generate_procurement_plan
      # Identify resource shortfalls
      shortfalls = identify_resource_shortfalls
      
      # Skip if no shortfalls
      return nil if shortfalls.empty?
      
      # Create a plan for gathering each resource
      plan = {
        priority_resources: [],
        secondary_resources: [],
        long_term_resources: []
      }
      
      shortfalls.each do |resource, amount|
        priority = determine_resource_priority(resource)
        procurement_method = determine_procurement_method(resource) # <-- Updated logic here
        
        resource_plan = {
          resource: resource,
          amount_needed: amount,
          procurement_method: procurement_method,
          estimated_time: estimate_procurement_time(resource, amount, procurement_method)
        }
        
        case priority
        when 'critical', 'high'
          plan[:priority_resources] << resource_plan
        when 'medium'
          plan[:secondary_resources] << resource_plan
        else
          plan[:long_term_resources] << resource_plan
        end
      end
      
      plan
    end
    
    # Execute the resource procurement plan
    def execute_procurement_plan(plan)
      return false unless plan
      
      # Start with priority resources
      plan[:priority_resources].each do |resource_plan|
        # Planner delegates the execution to the Fulfillment Service
        initiate_fulfillment(resource_plan) 
      end
      
      # Then secondary resources if capacity allows
      if resource_gathering_capacity_available?
        plan[:secondary_resources].each do |resource_plan|
          initiate_fulfillment(resource_plan)
        end
      end
      
      # Long term resources only if everything else is handled
      if all_critical_resources_sufficient? && resource_gathering_capacity_available?
        plan[:long_term_resources].first(3).each do |resource_plan|
          initiate_fulfillment(resource_plan)
        end
      end
      
      true
    end
    
    # Check current resource jobs
    def resource_job_status
      # Using a placeholder for ResourceJob model
      jobs = ResourceJob.where(settlement: @settlement).active 
      
      {
        total_jobs: jobs.count,
        by_type: jobs.group(:job_type).count,
        by_resource: jobs.group(:resource_type).count,
        estimated_completion: jobs.order(:estimated_completion).first&.estimated_completion
      }
    rescue NameError # Handle if ResourceJob model doesn't exist yet
      { status: "ResourceJob model missing." }
    end
    
    private
    
    def identify_resource_shortfalls
      shortfalls = {}
      
      # Check inventory against requirements
      required_resources = calculate_required_resources
      
      required_resources.each do |resource, amount|
        # Assuming inventory exists and responds to :available
        current_amount = @settlement.inventory.available(resource) rescue 0 
        
        if current_amount < amount
          shortfalls[resource] = amount - current_amount
        end
      end
      
      shortfalls
    end
    
    def calculate_required_resources
      # Placeholder: Real requirements would come from construction queue, life support, etc.
      {
        'Oxygen' => 1000,
        'Steel' => 500,
        'RareMetals' => 100 # This must be imported (External Trade)
      }
    end
    
    # Various calculation methods...
    
    def determine_resource_priority(resource)
      case resource
      when 'Oxygen', 'Water', 'Food'
        'critical'
      when 'Steel', 'Glass', 'Aluminum'
        'high'
      when 'Copper', 'Silicon', 'Carbon'
        'medium'
      else
        'low'
      end
    end
    
    # --- UPDATED METHOD ---
    def determine_procurement_method(resource)
      # Check for internal manufacturing/mining first.
      if resource_locally_available?(resource)
        'local_mining' # Raw resources
      elsif can_be_manufactured?(resource)
        'manufacturing' # Finished goods
      else
        # If neither, we must trade. Determine if it's local trade (GCC) or external trade (USD).
        AIManager::ResourceAcquisitionService.acquisition_method_for(resource).to_s
      end
    end
    # ----------------------

    # --- NEW EXECUTION DELEGATION ---
    def initiate_fulfillment(resource_plan)
      Rails.logger.info "[Planner] Initiating fulfillment for #{resource_plan[:resource]} via #{resource_plan[:procurement_method]}"
      
      if resource_plan[:procurement_method].to_s.include?('trade')
        # If the plan calls for trade (local or external), we defer to the Fulfillment Service.
        AIManager::ResourceFulfillmentService.fulfill_supply_need(
          @settlement, 
          resource_plan[:resource], 
          resource_plan[:amount_needed]
        )
      elsif resource_plan[:procurement_method] == 'local_mining'
        # For mining/manufacturing, we would create a specific internal job (not using the services pipeline yet).
        create_resource_job(resource_plan)
      end
    end
    # --------------------------------

    # Placeholder helper methods
    def resource_locally_available?(resource)
      %w[Oxygen Water Regolith].include?(resource)
    end
    
    def can_be_manufactured?(resource)
      %w[Steel Aluminum Glass].include?(resource)
    end
    
    def create_resource_job(resource_plan)
      # Placeholder: Creates an internal job record (e.g., Robot mining job)
      Rails.logger.debug "Creating internal job: #{resource_plan[:procurement_method]} for #{resource_plan[:resource]}"

      # Process mining byproducts if applicable
      if resource_plan[:procurement_method] == 'local_mining'
        Manufacturing::ByproductManufacturingService.process_mining_byproducts(
          @settlement,
          resource_plan[:resource],
          resource_plan[:amount_needed]
        )
      end
    end
    
    def resource_gathering_capacity_available?
      # Placeholder
      true
    end
    
    def all_critical_resources_sufficient?
      # Placeholder
      true
    end
    
    def estimate_procurement_time(resource, amount, method)
      # Placeholder
      method.include?('external') ? '7 days' : '1 day'
    end

    def prioritize_oxygen_refill
      # Prioritize oxygen refill tasks
      # This could involve prioritizing oxygen production or procurement
      Rails.logger.info "[ResourcePlanner] Prioritizing oxygen refill tasks"
      # Implementation: modify procurement plans to prioritize oxygen
    end

    public

    def prioritize_energy_for_o2_generation
      # Allocate energy for O2 generation from CO2 on Mars
      Rails.logger.info "[ResourcePlanner] Prioritizing energy allocation for O2 generation on Mars"
      # Implementation: adjust energy allocation for MOXIE or similar systems
    end

    def prioritize_energy_for_gas_generation(gas_type)
      # Allocate energy for gas generation
      Rails.logger.info "[ResourcePlanner] Prioritizing energy allocation for #{gas_type} generation"
      # Implementation: adjust energy allocation for gas generation systems
    end
  end
end