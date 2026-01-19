module AIManager
  class MarketStabilizationService
    # NPC acts as buyer/producer/importer of last resort to maintain market liquidity
    # Critical for new players who start with limited skills and GCC

    ESSENTIAL_ITEMS = [
      'oxygen', 'water', 'basic_structural_panels', 'circuit_boards',
      'basic_regolith_panels', 'life_support_filters', 'power_cells'
    ]

    NEW_PLAYER_ESSENTIALS = [
      'oxygen', 'water', 'basic_structural_panels', 'life_support_filters'
    ]

    def self.stabilize_market(settlement)
      results = []

      # 1. Critical fallback for new players - ensure basic survival items always available
      results << ensure_new_player_essentials(settlement)

      # 2. Buyer of Last Resort - Purchase unsold player goods
      results << handle_unsold_goods(settlement)

      # 3. Producer of Last Resort - Manufacture essential items when player production lags
      results << handle_production_shortages(settlement)

      # 4. Importer of Last Resort - Source items from various locations during shortages
      results << handle_import_shortages(settlement)

      # 5. Logistics Coordination - Manage delivery priorities
      results << coordinate_logistics(settlement)

      results.compact
    end

    def self.ensure_new_player_essentials(settlement)
      # Always ensure basic survival items are available for new players
      # This is critical - players must be able to survive even with minimal skills

      settlement_age_days = (Time.current - settlement.created_at) / 1.day
      is_new_settlement = settlement_age_days < 30 # Consider settlements "new" for first 30 days

      essentials_needed = if is_new_settlement
                           NEW_PLAYER_ESSENTIALS
                         else
                           ESSENTIAL_ITEMS
                         end

      essentials_needed.each do |item|
        inventory_level = settlement.inventory.items.find_by(name: item)&.amount || 0
        minimum_level = calculate_minimum_essential_level(settlement, item)

        if inventory_level < minimum_level
          # NPC immediately provides essential items - no delay for critical needs
          provide_essential_item(settlement, item, minimum_level - inventory_level)
          return { action: :new_player_support, item: item, amount: minimum_level - inventory_level, reason: :essential_fallback }
        end
      end

      { action: :new_player_support, status: :essentials_available }
    end

    private

    def self.handle_unsold_goods(settlement)
      # Find player sell orders that haven't been filled for extended period
      # Purchase at fair minimum price to ensure liquidity
      # This prevents players from having dead inventory

      # Implementation would check market orders and create NPC buy orders
      # Return status of purchases made
      { action: :buyer_of_last_resort, status: :checked, purchases_made: 0 }
    end

    def self.handle_production_shortages(settlement)
      # Identify essential items with low supply and no active player production
      # NPC manufactures these items to prevent critical shortages
      # Only if precursor infrastructure enables production

      essential_items = ESSENTIAL_ITEMS

      essential_items.each do |item|
        inventory_level = settlement.inventory.items.find_by(name: item)&.amount || 0
        minimum_threshold = calculate_minimum_threshold(settlement, item)

        if inventory_level < minimum_threshold
          # Check if settlement has precursor infrastructure for this item
          has_production_capability = settlement_has_production_capability?(settlement, item)

          if has_production_capability
            # Check if any players are producing this item
            active_production = check_active_player_production(settlement, item)

            unless active_production
              # NPC produces the item
              produce_item_for_market(settlement, item, minimum_threshold - inventory_level)
              return { action: :producer_of_last_resort, item: item, amount_produced: minimum_threshold - inventory_level }
            end
          end
        end
      end

      { action: :producer_of_last_resort, status: :no_action_needed }
    end

    def self.settlement_has_production_capability?(settlement, item)
      # Check if settlement has precursor-established infrastructure to produce this item
      # Precursor missions deploy units and structures that enable local production

      case item
      when 'oxygen'
        has_oxygen_production?(settlement)
      when 'water'
        has_water_production?(settlement)
      when 'basic_structural_panels', 'circuit_boards', 'power_cells'
        has_manufacturing_capability?(settlement)
      when 'basic_regolith_panels'
        has_regolith_processing?(settlement)
      when 'life_support_filters'
        has_life_support_manufacturing?(settlement)
      else
        false
      end
    end

    def self.has_oxygen_production?(settlement)
      # Check for electrolysis units or oxygen generation structures
      settlement.structures.where(structure_name: 'life_support').any? ||
      settlement.units.where("operational_data ->> 'capabilities' LIKE ?", '%oxygen%').any? ||
      settlement.units.where(unit_type: 'electrolysis').any?
    end

    def self.has_water_production?(settlement)
      # Check for water extraction or Sabatier units
      settlement.units.where("operational_data ->> 'capabilities' LIKE ?", '%water%').any? ||
      settlement.units.where(unit_type: 'sabatier').any? ||
      settlement.structures.where("operational_data ->> 'capabilities' LIKE ?", '%water%').any?
    end

    def self.has_manufacturing_capability?(settlement)
      # Check for fabrication units or manufacturing structures
      settlement.units.where(unit_type: 'fabricator').any? ||
      settlement.units.where(unit_type: 'cnt_fabricator').any? ||
      settlement.structures.where(structure_name: 'manufacturing').any?
    end

    def self.has_regolith_processing?(settlement)
      # Check for regolith harvesters or processing units
      settlement.units.where(unit_type: 'harvester').any? ||
      settlement.units.where("operational_data ->> 'capabilities' LIKE ?", '%regolith%').any?
    end

    def self.has_life_support_manufacturing?(settlement)
      # Check for life support structures or fabrication capability
      settlement.structures.where(structure_name: 'life_support').any? ||
      has_manufacturing_capability?(settlement)
    end

    def self.handle_import_shortages(settlement)
      # For items that cannot be produced locally and are in short supply
      # Source from Earth, other settlements, or cycler fleets

      import_candidates = identify_import_candidates(settlement)

      import_candidates.each do |item, shortage_amount|
        # Determine best import source based on time/cost
        import_source = determine_import_source(settlement, item, shortage_amount)

        case import_source[:type]
        when :earth
          ResourceAcquisitionService.process_external_import(settlement, item, shortage_amount)
        when :other_settlement
          create_inter_settlement_transfer(settlement, item, shortage_amount, import_source[:source_settlement])
        when :cycler
          schedule_cycler_delivery(settlement, item, shortage_amount, import_source[:cycler])
        end

        return { action: :importer_of_last_resort, item: item, amount: shortage_amount, source: import_source[:type] }
      end

      { action: :importer_of_last_resort, status: :no_action_needed }
    end

    def self.coordinate_logistics(settlement)
      # Manage multi-tier delivery system with realistic time delays
      # Priority: Player contracts > Cycler deliveries > NPC imports

      pending_deliveries = settlement.pending_deliveries.order(:priority)

      pending_deliveries.each do |delivery|
        case delivery.delivery_method
        when :player_contract
          # Fastest - hours to days
          expedite_player_delivery(delivery)
        when :cycler
          # Regular - days to weeks
          schedule_cycler_route(delivery)
        when :npc_import
          # Slowest - weeks to months
          arrange_external_import(delivery)
        end
      end

      { action: :logistics_coordination, deliveries_processed: pending_deliveries.count }
    end

    # Helper methods
    def self.calculate_minimum_essential_level(settlement, item)
      # Calculate minimum essential levels for critical items
      # Higher for new settlements to ensure survival
      base_levels = {
        'oxygen' => 100,
        'water' => 50,
        'basic_structural_panels' => 20,
        'life_support_filters' => 10,
        'circuit_boards' => 5,
        'basic_regolith_panels' => 15,
        'power_cells' => 8
      }

      settlement_age_days = (Time.current - settlement.created_at) / 1.day
      multiplier = settlement_age_days < 30 ? 2.0 : 1.0 # Double essentials for new settlements

      (base_levels[item] || 5) * multiplier
    end

    def self.provide_essential_item(settlement, item, amount)
      # NPC immediately provides essential items to settlement inventory
      # This is a direct provision - no manufacturing delay for critical items

      item_record = settlement.inventory.items.find_or_create_by(name: item)
      item_record.update(amount: item_record.amount + amount)

      Rails.logger.info "[MarketStabilization] Provided #{amount} #{item} as essential fallback to #{settlement.name}"
    end

    def self.check_active_player_production(settlement, item)
      # Check if any players have active manufacturing jobs for this item
      UnitAssemblyJob.where(
        base_settlement: settlement,
        unit_type: item,
        status: ['pending', 'in_progress', 'materials_pending']
      ).exists?
    end

    def self.produce_item_for_market(settlement, item, amount)
      # NPC manufactures item using unlimited blueprint access
      ManufacturingService.manufacture(item, settlement.owner, settlement, count: amount)
    end

    def self.identify_import_candidates(settlement)
      # Identify items that need importing
      import_needed = {}

      non_local_items = ['computers', 'advanced_electronics', 'rare_earth_metals']

      non_local_items.each do |item|
        inventory_level = settlement.inventory.items.find_by(name: item)&.amount || 0
        if inventory_level < 10 # Low threshold for import items
          import_needed[item] = 50 - inventory_level # Import enough to reach 50 units
        end
      end

      import_needed
    end

    def self.determine_import_source(settlement, item, amount)
      # Determine best source based on availability, time, and cost
      # Priority: Other settlements > Cycler fleets > Earth

      # Check other settlements in same system
      other_settlements = settlement.celestial_body.settlements.where.not(id: settlement.id)
      other_settlements.each do |other_settlement|
        if other_settlement.inventory.items.find_by(name: item)&.amount.to_i >= amount
          return { type: :other_settlement, source_settlement: other_settlement }
        end
      end

      # Check available cyclers
      available_cyclers = Cycler.where(status: :available)
      available_cyclers.each do |cycler|
        if cycler.inventory.items.find_by(name: item)&.amount.to_i >= amount
          return { type: :cycler, cycler: cycler }
        end
      end

      # Default to Earth import
      { type: :earth }
    end

    def self.create_inter_settlement_transfer(from_settlement, item, amount, to_settlement)
      # Create logistics contract for inter-settlement transfer
      LogisticsContract.create!(
        origin_settlement: from_settlement,
        destination_settlement: to_settlement,
        cargo_items: [{ name: item, quantity: amount }],
        priority: :standard,
        delivery_method: :inter_settlement
      )
    end

    def self.schedule_cycler_delivery(settlement, item, amount, cycler)
      # Schedule cycler to deliver item
      # This would integrate with cycler routing system
      { scheduled: true, cycler: cycler.id, item: item, amount: amount }
    end

    def self.expedite_player_delivery(delivery)
      # Prioritize player logistics contracts
      delivery.update(priority: :high)
    end

    def self.schedule_cycler_route(delivery)
      # Schedule regular cycler delivery
      delivery.update(estimated_delivery: Time.current + 3.days)
    end

    def self.arrange_external_import(delivery)
      # Arrange slower external import
      delivery.update(estimated_delivery: Time.current + 2.weeks)
    end
  end
end