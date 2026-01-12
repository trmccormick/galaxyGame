module Units
  class Robot < BaseUnit
    include EnergyManagement    # For power usage/generation
    include BatteryManagement   # For battery state and operations
    include RechargeBehavior

    # No direct validation for mobility_type as it's in operational_data
    # If presence is required, use a custom validation:
    validate :mobility_type_present_in_operational_data

    # Custom getter for mobility_type from operational_data
    def mobility_type
      operational_data['mobility_type']
    end

    # Custom setter for mobility_type into operational_data
    def mobility_type=(value)
      operational_data['mobility_type'] = value
    end

    # Override battery_drain with robot-specific logic
    def battery_drain
      case mobility_type # This will now call the custom getter
      when 'wheels' then 2.0
      when 'legs' then 3.0
      else 1.0
      end
    end

    def assign_task(task)
      self.operational_data['task_queue'] ||= []
      self.operational_data['task_queue'] << task
      save!
    end

    def execute_current_task
       queue = operational_data['task_queue'] ||= []
       return if queue.empty?

       task = queue.first
       case task['type']
       when 'move'
         move_to(task['target'])
       when 'scan'
         scan_area
       else
         Rails.logger.warn("Unknown task: #{task.inspect}")
       end

       queue.shift
       save!
    end

    def move_to(location)
      consume_battery(5) # Stubbed cost
      operational_data['last_location'] = location
      save!
    end

    def scan_area
      consume_battery(3)
      operational_data['last_scan'] = {
        timestamp: Time.now,
        result: "Basic terrain scan completed."
      }
      save!
    end

    def status
      return "idle" if (operational_data['task_queue'] || []).empty?
      "busy"
    end

    def needs_recharge?
      battery_percentage < 20
    end    

    def as_status_payload
        {
            id: id,
            name: name,
            battery: {
            percent: battery_percentage.round,
            level: battery_level,
            capacity: battery_capacity
            },
            task_queue: operational_data['task_queue'] || [],
            status: status
        }
    end

    private

    def mobility_type_present_in_operational_data
      unless operational_data['mobility_type'].present?
        errors.add(:mobility_type, "must be present in operational data")
      end
    end
  end
end

