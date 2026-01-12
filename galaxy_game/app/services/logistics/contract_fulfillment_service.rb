module Logistics
  class ContractFulfillmentService
    # Service to handle logistics contract fulfillment
    # This would typically be called by a background job or scheduled task

    def self.fulfill_pending_contracts
      Logistics::Contract.where(status: :pending).find_each do |contract|
        fulfill_contract(contract)
      end
    end

    def self.fulfill_contract(contract)
      return unless contract.status == 'pending'

      begin
        # Mark contract as in transit
        contract.mark_in_transit!

        # Simulate delivery time (in a real implementation, this would be scheduled)
        # For now, we'll immediately deliver for testing
        deliver_contract(contract)

      rescue StandardError => e
        Rails.logger.error "Failed to fulfill logistics contract #{contract.id}: #{e.message}"
        contract.mark_failed!(e.message)
      end
    end

    def self.deliver_contract(contract)
      # Move items from transit hangar to destination settlement inventory
      from_settlement = contract.from_settlement
      to_settlement = contract.to_settlement

      # Remove from transit hangar
      transit_hangar = from_settlement.operational_data['transit_hangar'] || {}
      current_quantity = transit_hangar[contract.material] || 0

      if current_quantity < contract.quantity
        raise "Insufficient items in transit hangar: need #{contract.quantity}, have #{current_quantity}"
      end

      # Update transit hangar
      remaining_quantity = current_quantity - contract.quantity
      updated_transit = transit_hangar.merge(contract.material => remaining_quantity)
      updated_transit.delete(contract.material) if remaining_quantity <= 0

      from_settlement.update_columns(
        operational_data: from_settlement.operational_data.merge('transit_hangar' => updated_transit)
      )

      # Add to destination settlement inventory
      to_settlement.add_inventory(contract.material, contract.quantity)

      # Mark contract as delivered
      contract.mark_delivered!

      Rails.logger.info "Delivered #{contract.quantity} #{contract.material} from #{from_settlement.name} to #{to_settlement.name}"
    end

    def self.check_expired_contracts
      # Mark contracts that have been in transit too long as failed
      cutoff_time = 7.days.ago  # Contracts older than 7 days in transit are considered failed

      Logistics::Contract.where(status: :in_transit)
                        .where('started_at < ?', cutoff_time)
                        .find_each do |contract|
        contract.mark_failed!('Contract expired - delivery took too long')
        return_items_to_origin(contract)
      end
    end

    private

    def self.return_items_to_origin(contract)
      # Return items from transit hangar back to origin settlement inventory
      transit_hangar = contract.from_settlement.operational_data['transit_hangar'] || {}
      current_quantity = transit_hangar[contract.material] || 0

      if current_quantity >= contract.quantity
        # Remove from transit and add back to inventory
        remaining_transit = current_quantity - contract.quantity
        updated_transit = transit_hangar.merge(contract.material => remaining_transit)
        updated_transit.delete(contract.material) if remaining_transit <= 0

        contract.from_settlement.update_columns(
          operational_data: contract.from_settlement.operational_data.merge('transit_hangar' => updated_transit)
        )

        # Add back to origin inventory
        contract.from_settlement.add_inventory(contract.material, contract.quantity)
      end
    end
  end
end