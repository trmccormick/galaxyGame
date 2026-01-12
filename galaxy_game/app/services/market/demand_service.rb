module Market
  class DemandService
    # Service for managing project-based demand and buy orders

    def self.create_project_buy_order(project:, material:, quantity:, price_per_unit:)
      # Find or create market condition for this material at the settlement
      market_condition = find_or_create_market_condition(project.settlement, material)

      # Create or update buy order
      order = Market::Order.find_or_initialize_by(
        orderable: project,
        resource: material,
        order_type: :buy
      )

      order.assign_attributes(
        market_condition: market_condition,
        base_settlement: project.settlement,
        quantity: quantity,
        price_per_unit: price_per_unit,
        expires_at: 24.hours.from_now
      )

      order.save!
      order
    end

    def self.update_project_demand
      # Update demand for all active mega projects
      MegaProject.active.each do |project|
        project.generate_buy_orders
      end

      # Clean up expired orders
      cleanup_expired_orders
    end

    def self.calculate_dynamic_price(settlement, material, urgency_factor = 1.0)
      base_price = Market::NpcPriceCalculator.calculate_ask(settlement, material) || 10.0

      # Apply urgency multiplier
      final_price = base_price * urgency_factor

      # Apply supply/demand adjustments
      supply_factor = calculate_supply_factor(settlement, material)
      demand_factor = calculate_demand_factor(settlement, material)

      (final_price * supply_factor * demand_factor).round(2)
    end

    def self.fulfill_buy_order(order, delivered_quantity, supplier)
      return false if delivered_quantity <= 0

      # Calculate payment amount
      payment_amount = order.price_per_unit * delivered_quantity

      # Process payment to supplier
      process_payment(order.base_settlement, supplier, payment_amount, order.resource)

      # Update order quantity
      order.quantity -= delivered_quantity
      if order.quantity <= 0
        order.destroy
      else
        order.save!
      end

      # Update project progress
      update_project_progress(order.orderable, order.resource, delivered_quantity)

      true
    end

    private

    def self.find_or_create_market_condition(settlement, material)
      # Find existing market condition or create new one
      Market::Condition.find_or_create_by!(
        marketplace: settlement.marketplace || Market::Marketplace.first,
        resource: material
      ) do |condition|
        condition.supply = 100
        condition.demand = 50
        condition.price = 10.0
      end
    end

    def self.calculate_supply_factor(settlement, material)
      # Check local inventory levels
      local_supply = settlement.inventory.current_storage_of(material)

      return 1.5 if local_supply <= 0   # No supply = 50% price increase
      return 1.2 if local_supply < 50   # Low supply = 20% increase
      return 1.1 if local_supply < 100  # Medium supply = 10% increase
      1.0 # Normal supply
    end

    def self.calculate_demand_factor(settlement, material)
      # Count active buy orders for this material
      active_orders = Market::Order.where(
        base_settlement: settlement,
        resource: material,
        order_type: :buy
      ).count

      return 1.3 if active_orders > 10  # High demand = 30% increase
      return 1.2 if active_orders > 5   # Medium demand = 20% increase
      return 1.1 if active_orders > 2   # Low demand = 10% increase
      1.0 # Normal demand
    end

    def self.process_payment(payer_settlement, payee, amount, material_description)
      # Get GCC currency
      gcc = Financial::Currency.find_by!(symbol: 'GCC')

      # Get payer account (settlement's GCC account)
      payer_account = payer_settlement.accounts.find_by!(currency: gcc)

      # Get payee account (player's GCC account)
      payee_account = payee.accounts.find_by!(currency: gcc)

      # Execute payment
      Financial::Account.transaction do
        payer_account.transfer_funds(amount, payee_account, "Payment for #{material_description} delivery")
      end

      Rails.logger.info("Processed payment: #{amount} GCC from #{payer_settlement.name} to #{payee.name} for #{material_description}")
    rescue => e
      Rails.logger.error("Payment processing failed: #{e.message}")
      raise e
    end

    def self.update_project_progress(project, material, quantity)
      return unless project.is_a?(MegaProject)

      # Update progress data
      progress_data = project.progress_data || {}
      delivered_materials = progress_data['delivered_materials'] || {}

      delivered_materials[material] ||= 0
      delivered_materials[material] += quantity

      progress_data['delivered_materials'] = delivered_materials
      project.update!(progress_data: progress_data)

      # Check if project is complete
      check_project_completion(project)
    end

    def self.check_project_completion(project)
      materials_needed = project.materials_needed
      if materials_needed.all? { |_, qty| qty <= 0 }
        project.update!(status: :completed, completed_at: Time.current)
        Rails.logger.info("Mega project completed: #{project.name}")
      end
    end

    def self.cleanup_expired_orders
      expired_orders = Market::Order.where('expires_at < ?', Time.current)
      expired_count = expired_orders.count
      expired_orders.destroy_all

      Rails.logger.info("Cleaned up #{expired_count} expired market orders") if expired_count > 0
    end
  end
end