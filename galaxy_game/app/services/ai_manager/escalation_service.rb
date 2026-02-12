module AIManager
  class EscalationService
    def self.handle_expired_buy_orders(expired_orders)
      expired_orders.each do |order|
        case determine_escalation_strategy(order)
        when :special_mission
          create_special_mission_for_order(order)
        when :automated_harvesting
          deploy_automated_harvesters(order)
        when :scheduled_import
          schedule_cycler_import(order)
        end
      end
    end

    def self.deploy_automated_harvesters(order)
      settlement = order.base_settlement
      material = order.resource
      quantity = order.quantity

      # Create automated harvester unit
      harvester = create_automated_harvester(settlement, material, quantity)

      # Deploy to appropriate location
      deploy_harvester_to_site(harvester, settlement.celestial_body, material)

      # Schedule completion
      schedule_harvester_completion(harvester, order)
    end

    def self.create_automated_harvester(settlement, material, quantity)
      case material.downcase
      when 'oxygen'
        Units::Robot.create!(
          name: "Automated Oxygen Harvester",
          settlement: settlement,
          operational_data: {
            'task_type' => 'atmospheric_harvesting',
            'target_material' => 'oxygen',
            'target_quantity' => quantity,
            'extraction_rate' => 10, # kg/hour
            'mobility_type' => 'stationary'
          }
        )
      when 'water'
        Craft::Harvester.create!(
          name: "Automated Water Extractor",
          settlement: settlement,
          operational_data: {
            'extraction_rate' => 50, # kg/hour
            'target_body' => settlement.celestial_body
          }
        )
      else
        # Regolith mining robot
        Units::Robot.create!(
          name: "Automated #{material.titleize} Miner",
          settlement: settlement,
          operational_data: {
            'task_type' => 'regolith_mining',
            'target_material' => material,
            'target_quantity' => quantity,
            'extraction_rate' => 25, # kg/hour
            'mobility_type' => 'wheeled'
          }
        )
      end
    end

    def self.deploy_harvester_to_site(harvester, celestial_body, material)
      # Deploy based on material type and celestial body characteristics
      case material.downcase
      when 'oxygen'
        # Deploy near atmosphere-rich areas
        harvester.update!(
          location: celestial_body,
          operational_data: harvester.operational_data.merge({
            'deployment_site' => 'atmospheric_processor',
            'coordinates' => find_atmospheric_site(celestial_body)
          })
        )
      when 'water'
        # Deploy near hydrosphere-rich areas
        harvester.update!(
          location: celestial_body,
          operational_data: harvester.operational_data.merge({
            'deployment_site' => 'ice_deposit',
            'coordinates' => find_hydrosphere_site(celestial_body)
          })
        )
      else
        # Deploy to regolith mining sites
        harvester.update!(
          location: celestial_body,
          operational_data: harvester.operational_data.merge({
            'deployment_site' => 'regolith_field',
            'coordinates' => find_regolith_site(celestial_body, material)
          })
        )
      end
    end

    def self.schedule_harvester_completion(harvester, order)
      # Calculate completion time based on extraction rate and quantity
      extraction_rate = harvester.operational_data['extraction_rate']
      target_quantity = order.quantity
      hours_to_complete = (target_quantity / extraction_rate.to_f).ceil

      completion_time = Time.current + hours_to_complete.hours

      # Schedule completion job
      HarvesterCompletionJob.set(wait_until: completion_time)
                              .perform_later(harvester.id, order.id)
    end

    private

    def self.determine_escalation_strategy(order)
      material = order.resource
      settlement = order.base_settlement

      # Priority 1: Special missions for critical resources
      return :special_mission if critical_resource?(material)

      # Priority 2: Automated harvesting if locally available
      return :automated_harvesting if can_harvest_locally?(settlement, material)

      # Priority 3: Scheduled imports as last resort
      :scheduled_import
    end

    def self.critical_resource?(material)
      ['oxygen', 'water', 'nitrogen', 'hydrogen'].include?(material.downcase)
    end

    def self.can_harvest_locally?(settlement, material)
      # Check if settlement's celestial body has the resource
      celestial_body = settlement.celestial_body
      case material.downcase
      when 'oxygen'
        celestial_body.atmosphere&.gases&.any? { |g| g.name == 'O2' }
      when 'water'
        celestial_body.hydrosphere&.total_liquid_mass&.positive?
      when 'nitrogen'
        celestial_body.atmosphere&.gases&.any? { |g| g.name == 'N2' }
      else
        # Check regolith composition for other materials
        celestial_body.composition&.dig('regolith', material.downcase)&.positive?
      end
    end

    def self.create_special_mission_for_order(order)
      settlement = order.base_settlement
      material = order.resource
      quantity = order.quantity

      # Calculate premium reward (2x normal rate)
      base_reward = calculate_base_reward(material, quantity)
      premium_reward = base_reward * 2

      # Create emergency mission
      EmergencyMissionService.create_emergency_mission(
        settlement,
        material.to_sym,
        reward: premium_reward,
        time_limit: 48.hours,
        priority: :high
      )
    end

    def self.schedule_cycler_import(order)
      settlement = order.base_settlement
      material = order.resource
      quantity = order.quantity

      # Find best import source
      import_source = find_best_import_source(settlement, material)

      # Calculate transport cost
      transport_cost = calculate_transport_cost(import_source, settlement, material, quantity)

      # Schedule on next available cycler
      schedule_import_delivery(
        material: material,
        quantity: quantity,
        source: import_source,
        destination: settlement,
        transport_cost: transport_cost,
        delivery_eta: calculate_delivery_time(import_source, settlement)
      )
    end

    def self.calculate_base_reward(material, quantity)
      # Use existing NPC price calculator
      price_per_unit = Market::NpcPriceCalculator.calculate_ask(nil, material)
      price_per_unit * quantity * 1.5 # 50% markup for player effort
    end

    def self.find_best_import_source(destination_settlement, material)
      # Priority: Earth, other settlements in system, orbital depots
      sources = [
        { type: :earth, location: 'Earth', cost_multiplier: 3.0 },
        { type: :settlement, location: find_nearby_settlements(destination_settlement), cost_multiplier: 1.5 },
        { type: :depot, location: find_orbital_depots(destination_settlement), cost_multiplier: 1.2 }
      ]

      sources.find { |source| can_supply?(source, material) } || sources.first
    end

    def self.calculate_transport_cost(import_source, destination, material, quantity)
      base_cost = Market::NpcPriceCalculator.calculate_ask(nil, material) * quantity
      distance_factor = calculate_distance_factor(import_source, destination)
      urgency_factor = 2.0 # Emergency import premium

      base_cost * distance_factor * urgency_factor
    end

    def self.calculate_delivery_time(import_source, destination)
      # Base delivery time plus distance calculation
      base_days = case import_source[:type]
                  when :earth then 180 # 6 months from Earth
                  when :settlement then 30 # 1 month inter-settlement
                  when :depot then 7 # 1 week from orbital depot
                  else 90
                  end

      Time.current + base_days.days
    end

    def self.find_nearby_settlements(settlement)
      # Find other settlements in the same solar system
      settlement.solar_system.settlements.where.not(id: settlement.id)
    end

    def self.find_orbital_depots(settlement)
      # Find orbital depots/stations in the same system
      settlement.solar_system.orbital_stations
    end

    def self.can_supply?(source, material)
      case source[:type]
      when :earth
        # Earth can supply most manufactured goods
        !['helium', 'deuterium'].include?(material.downcase) # Rare space resources
      when :settlement
        # Other settlements can supply local resources
        true # Assume they can supply for now
      when :depot
        # Orbital depots have processed materials
        true
      else
        false
      end
    end

    def self.calculate_distance_factor(source, destination)
      # Calculate distance-based cost multiplier
      case source[:type]
      when :earth then 5.0 # Earth is far
      when :settlement then 2.0 # Inter-settlement
      when :depot then 1.2 # Local depot
      else 3.0
      end
    end

    def self.find_atmospheric_site(celestial_body)
      # Find optimal atmospheric harvesting location
      # This would use celestial body data to find best pressure/temperature areas
      { latitude: 0, longitude: 0, altitude: 1000 } # Placeholder
    end

    def self.find_hydrosphere_site(celestial_body)
      # Find optimal hydrosphere harvesting location
      { latitude: -45, longitude: 30, depth: 100 } # Placeholder
    end

    def self.find_regolith_site(celestial_body, material)
      # Find optimal regolith mining location
      { latitude: 15, longitude: 45, depth: 2 } # Placeholder
    end
  end
end</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/services/ai_manager/escalation_service.rb