    # Cold Start Protocol: External Ignition mission for non-bloom systems
    def cold_start_external_ignition(system, source_system)
      return if legendary_pair?(system)
      em_units = 100
      loss_rate = calculate_material_loss(system, source_system)
      em_delivered = (em_units * (1 - loss_rate)).to_i
      mission = {
        mission_type: 'external_ignition',
        source_system: source_system[:system_id],
        target_system: system[:system_id],
        em_shipped: em_units,
        em_delivered: em_delivered,
        loss_rate: loss_rate
      }
      mission
    end

    def calculate_material_loss(target_system, source_system)
      # Example: 5-10% loss based on distance (AU)
      distance = (target_system[:distance_au] || 2.8) # fallback to Ceres-Mars
      loss = [0.05, 0.1].min + (distance / 10.0) * 0.01
      loss.clamp(0.05, 0.1)
    end

    def legendary_pair?(system)
      %w[djew-716790 fr-488530].include?(system[:system_id]) && system[:permanent_pair]
    end
# ConsortiumManager
# Handles orphaned Prize system, triggers AWS construction mission


module AIManager
  class ConsortiumManager
    MAX_AWS_LINKS = 3

    def initialize(wormhole_manager, station_placement_service, transit_fee_service)
      @wormhole_manager = wormhole_manager
      @station_placement_service = station_placement_service
      @transit_fee_service = transit_fee_service
      @aws_links = []
      @network_health_log = []
    end

    def handle_orphaned_prize_system(system)
      return unless system[:orphaned] && system[:prize]
      return if @aws_links.size >= MAX_AWS_LINKS
      em_pool = @wormhole_manager.get_hot_start_resource_pool(system)
      mission = create_aws_construction_mission(system, em_pool)
      aws_location = @station_placement_service.place_aws(system)
      activate_aws(system, aws_location, em_pool)
      @transit_fee_service.enable_fees(system)
      system[:orphaned] = false
      @aws_links << { system_id: system[:system_id], aws_location: aws_location, em_resource: em_pool, dividends: 0 }
      mission
    end

    def create_aws_construction_mission(system, em_pool)
      {
        mission_type: 'build_aws',
        blueprint: 'artificial_wormhole_station_mk1_bp.json',
        target_system: system[:system_id],
        em_resource: em_pool
      }
    end

    def activate_aws(system, location, em_pool)
      system[:aws_active] = true
      system[:aws_location] = location
      system[:em_resource_used] = em_pool
    end

    def log_dividends(system_id, amount)
      link = @aws_links.find { |l| l[:system_id] == system_id }
      return unless link
      link[:dividends] += amount
      @network_health_log << { system_id: system_id, timestamp: Time.now, dividends: link[:dividends] }
    end

    def network_health_dashboard
      @aws_links.map do |link|
        {
          system_id: link[:system_id],
          aws_location: link[:aws_location],
          dividends: link[:dividends]
        }
      end
    end
  end
end
