module Logistics
  class ContractService
    # Service for managing internal B2B logistics contracts between NPC settlements
    # Handles predictable refueling and byproduct transfers outside public market

    def self.create_internal_transfer(from_settlement, to_settlement, material, quantity, transport_method = :orbital_transfer)
      # Validate settlements can participate
      return nil unless valid_settlement_pair?(from_settlement, to_settlement)

      # Check if from_settlement has the material
      available = from_settlement.inventory.current_storage_of(material)
      return nil if available < quantity

      # FIRST: Try to create a player-visible contract
      player_contract = create_player_contract(from_settlement, to_settlement, material, quantity, transport_method)

      if player_contract
        Rails.logger.info "[Logistics::Contract] Created player contract #{player_contract.id} for NPC transfer"
        return player_contract
      end

      # FALLBACK: Create direct NPC contract if no players available
      contract = Logistics::Contract.create!(
        from_settlement: from_settlement,
        to_settlement: to_settlement,
        material: material,
        quantity: quantity,
        transport_method: transport_method,
        status: :pending,
        scheduled_at: calculate_delivery_time(from_settlement, to_settlement, transport_method),
        operational_data: {
          purpose: 'internal_b2b_transfer',
          created_by: 'ai_manager'
        }
      )

      Rails.logger.info "[Logistics::Contract] Created direct NPC transfer: #{quantity} #{material} from #{from_settlement.name} to #{to_settlement.name}"
      contract
    end

    def self.execute_pending_contracts
      Logistics::Contract.pending.each do |contract|
        execute_contract(contract)
      end
    end

    def self.execute_contract(contract)
      return unless contract.pending?

      # Check if scheduled time has arrived
      return unless contract.scheduled_at <= Time.current

      # Transfer the material
      success = transfer_material(contract)

      if success
        contract.mark_delivered!
        Rails.logger.info "[Logistics::Contract] Delivered #{contract.quantity} #{contract.material} to #{contract.to_settlement.name}"
      else
        contract.mark_failed!("Transfer failed")
        Rails.logger.error "[Logistics::Contract] Failed to deliver contract ##{contract.id}"
      end
    end

    private

    def self.valid_settlement_pair?(from_settlement, to_settlement)
      # Both must be NPC settlements
      from_settlement.owner.nil? && to_settlement.owner.nil? &&
      from_settlement != to_settlement
    end

    def self.calculate_delivery_time(from_settlement, to_settlement, transport_method)
      base_time = case transport_method.to_sym
                  when :orbital_transfer then 2.hours
                  when :surface_conveyance then 6.hours
                  when :drone_delivery then 1.hour
                  else 4.hours
                  end

      # Add distance factor (simplified)
      distance_factor = calculate_distance_factor(from_settlement, to_settlement)
      base_time * distance_factor
    end

    def self.calculate_distance_factor(from_settlement, to_settlement)
      # Simplified distance calculation
      # In a real implementation, this would use actual orbital mechanics
      if from_settlement.location&.celestial_body == to_settlement.location&.celestial_body
        1.0 # Same body, surface transfer
      else
        2.0 # Different bodies, orbital transfer
      end
    end

    def self.transfer_material(contract)
      # Remove from source settlement
      contract.from_settlement.inventory.remove_item(
        contract.material,
        contract.quantity,
        "Delivered via logistics contract ##{contract.id}"
      )

      # Add to destination settlement
      contract.to_settlement.inventory.add_item(
        contract.material,
        contract.quantity,
        nil,
        { source: "Logistics contract from #{contract.from_settlement.name}" }
      )

      true
    rescue StandardError => e
      Rails.logger.error "[Logistics::Contract] Transfer failed: #{e.message}"
      false
    end

    private

    def self.create_player_contract(from_settlement, to_settlement, material, quantity, transport_method)
      # Calculate transport cost and reward
      transport_cost = Logistics::TransportCostService.calculate_cost_per_kg(
        from: from_settlement.location&.celestial_body&.identifier,
        to: to_settlement.location&.celestial_body&.identifier,
        resource: material
      )

      cargo_value = quantity * 100 # Simplified cargo valuation
      reward_amount = cargo_value * 0.1 + (transport_cost * quantity) # 10% margin + transport cost

      # Determine collateral requirement (50% of cargo value for NPC contracts)
      collateral_amount = cargo_value * 0.5

      contract_data = {
        issuer: from_settlement.owner || from_settlement, # Use settlement or its owner
        contract_type: :courier,
        location: from_settlement.location,
        status: :open,
        requirements: {
          pickup_location: from_settlement.name,
          delivery_location: to_settlement.name,
          cargo: { material: material, quantity: quantity },
          transport_method: transport_method
        },
        reward: { credits: reward_amount },
        collateral: { amount: collateral_amount, type: 'gcc' },
        security_terms: {
          collateral_required: true,
          insurance_available: true
        }
      }

      result = PlayerContractService.create_logistics_contract(contract_data)
      result[:contract]
    rescue StandardError => e
      Rails.logger.error "[Logistics::Contract] Failed to create player contract: #{e.message}"
      nil
    end
  end
end