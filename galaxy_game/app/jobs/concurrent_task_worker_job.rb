class ConcurrentTaskWorkerJob < ApplicationJob
  queue_as :default

  def perform(mission_id, task, task_index)
    engine = AIManager::TaskExecutionEngine.new(mission_id)
    
    # Execute the task
    result = engine.send(:execute_task, task)
    
    if result
      # Handle manufacturing byproducts for printing tasks
      handle_manufacturing_byproducts(task, engine.settlement)
      
      # Mark task as completed in the engine
      engine.send(:mark_concurrent_task_completed, task)
      
      Rails.logger.info("Concurrent task #{task['task_id']} completed successfully")
    else
      Rails.logger.error("Concurrent task #{task['task_id']} failed")
      # Handle task failure
    end
  end
  
  private
  
  def handle_manufacturing_byproducts(task, settlement)
    return unless settlement
    
    # Only generate byproducts during active task progress (daylight/sufficient solar power)
    solar_factor = settlement.location&.solar_output_factor || 1.0
    return if solar_factor <= 0.1
    
    case task['task_id']
    when 'print_ibeams', 'print_shell_panels'
      # Generate trace amounts of O2 and H2O from regolith heating
      generate_regolith_volatiles(settlement)
    end
  end
  
  # This method simulates the release of trace amounts of oxygen and water as byproducts
  # during certain manufacturing/printing tasks (e.g., 'print_ibeams', 'print_shell_panels').
  # It is intended to represent minor volatile release from heating depleted regolith,
  # not from primary resource extraction.
  #
  # The main volatile extraction pipeline (TEU → PVE) handles the bulk removal of volatiles
  # and oxides from regolith, producing depleted regolith as a byproduct. This function
  # only models the small, residual release that might occur when depleted regolith is
  # further processed or heated during construction tasks.
  #
  # The values here are intentionally minimal and do not reflect the full regolith
  # composition. Major resource extraction logic is centralized in MaterialProcessingService.
  # Do not use this function for primary volatile extraction or double-counting resources.
  def generate_regolith_volatiles(settlement)
    # Add trace amounts of oxygen and water from lunar regolith processing
    o2_amount = 0.001 # kg of O2
    h2o_amount = 0.0005 # kg of H2O
    
    # Add to settlement inventory
    settlement.inventory.add_item('O2', o2_amount)
    settlement.inventory.add_item('H2O', h2o_amount)
    
    Rails.logger.info("Generated #{o2_amount}kg O2 and #{h2o_amount}kg H2O from regolith processing")
  end
end
