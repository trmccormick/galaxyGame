class HarvesterCompletionJob < ApplicationJob
  queue_as :default

  def perform(harvester_id, order_id)
    harvester = find_harvester(harvester_id)
    order = find_order(order_id)

    return unless harvester && order

    # Calculate harvested amount
    harvested_amount = calculate_harvested_amount(harvester, order)

    # Create inventory items for the settlement
    add_to_settlement_inventory(order.base_settlement, order.resource, harvested_amount)

    # Update order status
    fulfill_order(order, harvested_amount)

    # Clean up harvester
    deactivate_harvester(harvester)

    Rails.logger.info "[HarvesterCompletionJob] Completed harvesting #{harvested_amount} #{order.resource} for order #{order.id}"
  end

  private

  def find_harvester(harvester_id)
    Units::Robot.find_by(id: harvester_id) || Craft::Harvester.find_by(id: harvester_id)
  end

  def find_order(order_id)
    Market::Order.find_by(id: order_id)
  end

  def calculate_harvested_amount(harvester, order)
    # Calculate based on operational time and extraction rate
    extraction_rate = harvester.operational_data['extraction_rate'].to_f
    operational_hours = calculate_operational_hours(harvester)

    [extraction_rate * operational_hours, order.quantity].min
  end

  def calculate_operational_hours(harvester)
    # Calculate how long the harvester was operational
    created_at = harvester.created_at
    completed_at = Time.current

    ((completed_at - created_at) / 1.hour).to_f
  end

  def add_to_settlement_inventory(settlement, material, amount)
    # Add harvested materials to settlement inventory
    inventory = settlement.inventory || settlement.create_inventory

    inventory.add_item(material, amount)

    Rails.logger.info "[HarvesterCompletionJob] Added #{amount} #{material} to #{settlement.name} inventory"
  end

  def fulfill_order(order, amount)
    # Mark order as fulfilled
    order.update(status: :fulfilled)

    # Create transaction record
    Transaction.create!(
      from_account: settlement_fund_account(order.base_settlement),
      to_account: npc_fund_account,
      amount: order.total_cost,
      description: "Automated harvesting fulfillment for #{order.resource}",
      transaction_type: :resource_acquisition
    )
  end

  def deactivate_harvester(harvester)
    # Mark harvester as completed and available for reuse
    harvester.update(
      operational_data: harvester.operational_data.merge({
        'status' => 'completed',
        'completion_time' => Time.current
      })
    )
  end

  def settlement_fund_account(settlement)
    # Find or create settlement's fund account
    Account.find_or_create_by(
      accountable: settlement,
      currency: Currency.find_by(symbol: 'GCC')
    )
  end

  def npc_fund_account
    # NPC fund account for automated operations
    Account.find_or_create_by(
      accountable_type: 'NpcManager',
      currency: Currency.find_by(symbol: 'GCC')
    )
  end
end</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/jobs/harvester_completion_job.rb