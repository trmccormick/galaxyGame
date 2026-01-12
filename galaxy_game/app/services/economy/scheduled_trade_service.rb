module Economy
  class ScheduledTradeService
    # Monitors LDC Buy Orders on Luna Market for N2 and CO
    # If unfilled after scheduled interval, executes VirtualLedger transaction
    # Deducts from L1, adds to Luna inventory, transfers GCC based on market price

    SCHEDULED_INTERVAL = 1.hour # Configurable interval for checking unfilled orders

    def self.monitor_and_execute_scheduled_deliveries
      luna_location = Location::CelestialLocation.find_by(name: 'Moon')
      luna_settlement = Settlement::BaseSettlement.find_by(location: luna_location)
      luna_market = Market::Marketplace.find_by(settlement: luna_settlement)
      return unless luna_market

      ldc_org = Organizations::Corporation.find_by(identifier: 'LDC')
      return unless ldc_org

      # Find unfilled buy orders for N2 or CO from LDC on Luna market
      unfilled_orders = luna_market.orders.where(
        order_type: :buy,
        orderable: ldc_org,
        resource: ['N2', 'CO'],
        fulfilled_at: nil
      )

      unfilled_orders.each do |order|
        execute_scheduled_delivery(order)
      end
    end

    private

    def self.execute_scheduled_delivery(order)
      item_name = order.item_name
      quantity = order.quantity
      price_per_unit = order.price_per_unit

      # Find L1 Depot settlement and inventory
      l1_settlement = Settlement::BaseSettlement.find_by(name: /L1.*Station/)
      return unless l1_settlement

      l1_inventory = l1_settlement.inventory
      available = l1_inventory.items.find_by(name: item_name)&.amount || 0
      return if available < quantity

      # Find Luna settlement (Moon Subsurface Base)
      luna_settlement = Settlement::BaseSettlement.find_by(name: /Moon.*Subsurface/)
      return unless luna_settlement

      luna_inventory = luna_settlement.inventory

      # Accounts
      ldc_account = order.buyer.account
      astrolift_org = Organizations::Corporation.find_by(identifier: 'ASTROLIFT')
      return unless astrolift_org

      astrolift_account = astrolift_org.account

      total_gcc = quantity * price_per_unit

      # Check if LDC has enough GCC
      return if ldc_account.balance < total_gcc

      # Execute the transfer
      ActiveRecord::Base.transaction do
        # Deduct from L1 inventory
        l1_item = l1_inventory.items.find_by(name: item_name)
        l1_item.decrement!(:amount, quantity)

        # Add to Luna inventory
        luna_inventory.items.find_or_create_by(name: item_name) do |item|
          item.amount = 0
        end.increment!(:amount, quantity)

        # Transfer GCC from LDC to AstroLift
        ldc_account.decrement!(:balance, total_gcc)
        astrolift_account.increment!(:balance, total_gcc)

        # Record in Virtual Ledger
        Financial::VirtualLedgerService.record_transfer(
          from_account: ldc_account,
          to_account: astrolift_account,
          amount: total_gcc,
          currency: 'GCC',
          item: item_name,
          description: "Scheduled delivery of #{quantity} #{item_name} from L1 to Luna"
        )

        # Mark order as filled
        order.fulfill!
      end
    end

    def self.first_n2_delivery_completed?
      # For pipeline simulation, return true
      true
    end
  end
end