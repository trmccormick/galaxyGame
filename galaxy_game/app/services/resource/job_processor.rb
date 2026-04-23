class Resource::JobProcessor
  def self.process_jobs
    # Process jobs that are ready to complete
    complete_ready_contracts
  end

  def self.complete_ready_contracts
    # Find contracts that should be complete based on arrival time
    ready_contracts = Logistics::Contract.where(status: [:in_transit, :pending])
                                         .where('arrives_at <= ?', Time.current)

    ready_contracts.each do |contract|
      complete_contract(contract)
    end
  end

  def self.complete_contract(contract)
    # Add delivered resources to inventory
    settlement = contract.to_settlement
    resource_name = contract.material
    amount = contract.quantity

    # Find or create inventory item
    item = settlement.inventory.items.find_or_initialize_by(name: resource_name)
    item.amount ||= 0
    item.amount += amount
    item.save!

    # Mark contract as delivered
    contract.mark_delivered!

    Rails.logger.info "[Resource] Logistics contract delivered: Added #{amount} of #{resource_name} to inventory"

    # Check for material requests that can be fulfilled
    check_material_requests(settlement, resource_name)
  end

  def self.check_material_requests(settlement, resource_name)
    pending_requests = MaterialRequest.pending_requests
                                      .where(material_name: resource_name)
                                      .where(requestable_type: ['ConstructionJob', 'UnitAssemblyJob'])
                                      .where(requestable_id: settlement.construction_jobs.pluck(:id) + 
                                                             settlement.unit_assembly_jobs.pluck(:id))

    pending_requests.each do |request|
      available = settlement.inventory.available(resource_name)

      if available >= request.quantity_requested
        request.update(
          status: 'fulfilled',
          fulfilled_at: Time.current
        )
        Rails.logger.info "[Resource] Material request for #{request.quantity_requested} #{resource_name} fulfilled"
      elsif available > 0
        request.update(
          status: 'partially_fulfilled',
          quantity_fulfilled: available
        )
      end
    end
  end
end