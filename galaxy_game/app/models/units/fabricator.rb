# app/models/units/fabricator.rb

# app/models/units/fabricator.rb
module Units
  # Fabricator units handle manufacturing/printing of parts and materials.
  # Only include logic unique to fabricators here. Use concerns for shared logic.
  class Fabricator < BaseUnit
    # --- Extension Plan ---
    # 1. Include concerns for shared logic (energy, resource management, etc.)
    #    include EnergyManagement
    #    include ResourceProcessing


    # 2. Define unique fabrication routines (e.g., print_part, queue_job)
    #    def print_part(part_name)
    #      # Implement part printing logic using operational_data
    #    end

    # 2a. Check if the fabricator is available for a new job
    # Usage: return true if no active job is assigned to this unit
    def available?
      # Example: Job.where(unit: self, status: :pending).none?
      # Replace with actual job association/lookup as needed
      !Job.exists?(unit: self, status: [:pending, :in_progress])
    end

    # 3. Override or extend base methods only as needed
    #    def tick
    #      super
    #      # Run fabrication jobs, handle queues, etc.
    #    end

    # 4. Use operational_data for configuration (e.g., supported parts, print speed)
    #    def supported_parts
    #      operational_data['supported_parts'] || []
    #    end

    # 5. Add extension points for future features (e.g., maintenance, upgrades)
    #    def perform_maintenance
    #      # Placeholder for future implementation
    #    end

    # --- End Extension Plan ---
  end
end
