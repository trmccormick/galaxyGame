module Logistics
  class InternalTransferService
    # Service for managing internal B2B contracts between NPCs
    # Handles predictable refueling/byproduct needs outside public market

    def self.create_internal_contract(from_settlement, to_settlement, material, quantity, transport_method = :orbital_transfer)
      return nil unless can_transfer?(from_settlement, to_settlement, material, quantity)

      contract = Logistics::Contract.create!(
        provider: find_or_create_provider(from_settlement),
        from_settlement: from_settlement,
        to_settlement: to_settlement,
        material: material,
        quantity: quantity,
        transport_method: transport_method,
        status: :pending,
        operational_data: {
          contract_type: 'internal_b2b',
          created_at: Time.current
        }
      )

      Rails.logger.info "[InternalTransfer] Created B2B contract #{contract.id}: #{quantity} #{material} from #{from_settlement.name} to #{to_settlement.name}"
      contract
    end

    def self.process_internal_transfers
      Logistics::Contract.where(status: :pending)
                        .each do |contract|
        process_contract(contract)
      end
    end

    private

    def self.can_transfer?(from_settlement, to_settlement, material, quantity)
      # Check if from_settlement has the material
      available = from_settlement.inventory&.current_storage_of(material) || 0
      return false if available < quantity

      # Check if to_settlement has storage capacity
      # For simplicity, assume settlements can always store more (this would need proper capacity checking)
      true
    end

    def self.find_or_create_provider(settlement)
      # Create or find a default organization for internal logistics
      organization = Organizations::BaseOrganization.find_or_create_by!(
        name: 'Internal Logistics System',
        identifier: 'INTERNAL_LOGISTICS'
      ) do |org|
        org.organization_type = 'corporation'
      end

      identifier = "#{settlement.name.parameterize}-logistics"
      Logistics::Provider.find_or_create_by!(
        name: "#{settlement.name} Logistics",
        identifier: identifier,
        organization: organization
      ) do |provider|
        provider.reliability_rating = 5.0
        provider.base_fee_per_kg = 0.01  # Very low cost for internal transfers
        provider.speed_multiplier = 1.0
        provider.capabilities = ['internal_transfer']
        provider.cost_modifiers = {}
        provider.time_modifiers = {}
      end
    end

    def self.process_contract(contract)
      return unless contract.pending?

      contract.mark_in_transit!
      contract.mark_delivered!

      Rails.logger.info "[InternalTransfer] Completed B2B transfer #{contract.id}"
    rescue StandardError => e
      Rails.logger.error "[InternalTransfer] Failed to process contract #{contract.id}: #{e.message}"
      contract.mark_failed!(e.message)
    end
  end
end