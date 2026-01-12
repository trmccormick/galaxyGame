# app/services/mission_generator_service.rb
class MissionGeneratorService
  def initialize(ai_manager:, biome_status:)
    @ai_manager = ai_manager
    @biome_status = biome_status
  end

  def check_and_generate_missions
    if oxygen_deficit?
      create_oxygen_delivery_mission
    end

    # Extend with other checks (water, food, etc.) as needed
  end

  private

  def oxygen_deficit?
    current = @biome_status[:oxygen_level]
    required = @biome_status[:oxygen_required]
    current < required
  end

  def create_oxygen_delivery_mission
    profile = {
      "mission_id" => "oxygen_resupply_#{SecureRandom.hex(3)}",
      "name" => "Emergency Oxygen Resupply",
      "description" => "Deliver oxygen tanks to #{@ai_manager.location_name} to stabilize life support systems.",
      "manifest_file" => "oxygen_delivery_basic.json", # stored in your mission data folder
      "phases" => [
        { "step" => "pickup", "location" => "nearest_market" },
        { "step" => "delivery", "location" => @ai_manager.location_name }
      ]
    }

    MissionContractService.create_from_profile(profile, @ai_manager)
  end
end
