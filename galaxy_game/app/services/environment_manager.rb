class EnvironmentManager
  def self.start_pressurization(pressurization_job)
    # Get the environment that needs pressurization
    environment = pressurization_job.jobable
    target_pressure = pressurization_job.target_values[:pressure]
    
    # Collect all the fulfilled materials
    provided_gases = {}
    pressurization_job.material_requests.fulfilled.each do |request|
      provided_gases[request.material_name] = request.quantity_fulfilled
    end
    
    # Start the pressurization process with provided gases
    service = PressurizationService.new(environment)
    result = service.pressurize(target_pressure, provided_gases)
    
    if result[:success]
      pressurization_job.update!(
        status: 'completed',
        completion_date: Time.current,
        result_data: result
      )
      
      # Trigger any other systems that need to respond to pressurization
      notify_pressurization_complete(environment)
    else
      pressurization_job.update!(
        status: 'failed',
        result_data: result
      )
      
      # Log the failure
      Rails.logger.error "Pressurization failed: #{result[:message]}"
    end
    
    result
  end
  
  def self.notify_pressurization_complete(environment)
    # Notify relevant systems about completed pressurization
    
    # Update habitability status
    if environment.respond_to?(:atmospheric_data) && environment.atmospheric_data.habitable?
      environment.update(habitable: true) if environment.respond_to?(:habitable=)
    end
    
    # Trigger life support systems to activate
    LifeSupportSystem.activate(environment) if defined?(LifeSupportSystem)
    
    # Notify settlement AI about the change
    if environment.respond_to?(:settlement) && environment.settlement
      SettlementAI.process_event(environment.settlement, 'pressurization_complete', environment)
    end
  end
  
  # Other environment management methods...
end