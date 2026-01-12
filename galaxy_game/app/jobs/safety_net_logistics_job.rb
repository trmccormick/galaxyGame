class SafetyNetLogisticsJob < ApplicationJob
  queue_as :default

  def perform(settlement_id)
    settlement = Settlement::BaseSettlement.find(settlement_id)
    
    # Check if construction material orders have been filled
    pending_orders = settlement.market_orders.where(order_type: :buy, status: :open)
    
    if pending_orders.any?
      Rails.logger.info "[SafetyNet] Settlement #{settlement.name} has unfilled orders, triggering AstroLift logistics"
      
      # Trigger AstroLift logistics contract for each unfilled order
      pending_orders.each do |order|
        create_astrolift_contract(settlement, order)
      end
    else
      Rails.logger.info "[SafetyNet] All orders filled for settlement #{settlement.name}"
    end
  end

  private

  def create_astrolift_contract(settlement, order)
    # Find AstroLift provider
    astrolift = Logistics::Provider.find_by(identifier: 'ASTROLIFT')
    return unless astrolift

    # Create logistics contract from Earth (assuming Earth settlement exists)
    earth_settlement = Settlement::BaseSettlement.find_by(name: 'Earth Base') || 
                      Settlement::BaseSettlement.surface.first
    
    return unless earth_settlement

    Logistics::Contract.create!(
      provider: astrolift,
      from_settlement: earth_settlement,
      to_settlement: settlement,
      material: order.resource,
      quantity: order.quantity,
      transport_method: :orbital_transfer,
      status: :pending,
      operational_data: {
        'safety_net' => true,
        'original_order_id' => order.id
      }
    )

    Rails.logger.info "[SafetyNet] Created AstroLift contract for #{order.quantity} #{order.resource} to #{settlement.name}"
  end
end