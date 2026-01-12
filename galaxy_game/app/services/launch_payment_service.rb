class LaunchPaymentService
  def self.pay_for_launch!(craft:, customer_accounts:, provider_accounts:, launch_config: {})
    blueprint_service = launch_config[:blueprint_service] || Lookup::BlueprintLookupService.new
    
    # Calculate mass and cost
    total_mass_kg = calculate_total_mass(craft, blueprint_service)
    launch_cost = calculate_launch_cost(total_mass_kg, launch_config)
    
    puts "  - Calculated craft mass: #{total_mass_kg.round(2)} kg"
    puts "  - Launch cost: #{launch_cost[:total]} #{launch_cost[:currency]}"
    
    # Process payment with flexible payment options
    process_payment(
      launch_cost: launch_cost,
      customer_accounts: customer_accounts,
      provider_accounts: provider_accounts,
      payment_config: launch_config[:payment] || {}
    )
  end

  private

  def self.find_unit_blueprint(blueprint_service, unit_type)
    # Try without category first (most reliable)
    bp = blueprint_service.find_blueprint(unit_type)
    return bp if bp
    
    # If that fails, try with categories
    %w[units computers energy propulsion storage].each do |cat|
      bp = blueprint_service.find_blueprint(unit_type, cat)
      return bp if bp
    end
    nil
  end

  def self.calculate_total_mass(craft, blueprint_service)
    # Use the craft's existing mass calculation if available (preferred)
    if craft.respond_to?(:calculate_mass)
      mass = craft.calculate_mass
      puts "    Using craft's built-in mass calculation: #{mass} kg"
      return mass
    end
    
    # Fallback: Manual calculation with corrected associations
    puts "    Using manual mass calculation fallback"
    
    # Get base craft mass with corrected blueprint lookup
    base_mass_kg = get_base_craft_mass(craft, blueprint_service)
    puts "    Craft base mass: #{base_mass_kg} kg"
    
    # Units mass
    units_mass_kg = craft.base_units.sum do |unit|
      if craft.respond_to?(:get_unit_mass)
        craft.get_unit_mass(unit.unit_type)
      else
        calculate_unit_mass_fallback(unit, blueprint_service)
      end
    end
    puts "    Units total mass: #{units_mass_kg} kg"
    
    # Modules mass (use correct association)
    modules_mass_kg = 0.0
    if craft.respond_to?(:base_modules)
      modules_mass_kg = craft.base_modules.sum do |mod|
        if craft.respond_to?(:get_module_mass)
          craft.get_module_mass(mod.module_type)
        else
          calculate_module_mass_fallback(mod, blueprint_service)
        end
      end
      puts "    Modules total mass: #{modules_mass_kg} kg"
    end
    
    # Rigs mass (use correct association)
    rigs_mass_kg = 0.0
    if craft.respond_to?(:base_rigs)
      rigs_mass_kg = craft.base_rigs.sum do |rig|
        if craft.respond_to?(:get_rig_mass)
          craft.get_rig_mass(rig.rig_type)
        else
          calculate_rig_mass_fallback(rig, blueprint_service)
        end
      end
      puts "    Rigs total mass: #{rigs_mass_kg} kg"
    end
    
    total = base_mass_kg + units_mass_kg + modules_mass_kg + rigs_mass_kg
    puts "    Total calculated mass: #{total} kg"
    total
  end

  def self.get_base_craft_mass(craft, blueprint_service)
    # Try the craft's method first
    return craft.get_base_craft_mass if craft.respond_to?(:get_base_craft_mass)
    
    # Fallback: Look up blueprint manually
    bp_id = craft.operational_data&.dig('blueprint_id') || 
            craft.default_blueprint_id ||
            "generic_satellite"
    
    craft_bp = blueprint_service.find_blueprint(bp_id)
    mass = craft_bp&.dig("physical_properties", "empty_mass_kg") || 
           craft_bp&.dig("physical_properties", "mass_kg")
    
    mass&.to_f || 2500.0  # Reasonable satellite fallback
  end

  def self.extract_unit_mass(unit_bp)
    # Try various mass property paths
    mass = unit_bp.dig("physical_properties", "empty_mass_kg") ||
           unit_bp.dig("physical_properties", "mass_kg")
    return mass.to_f if mass
    
    mass = unit_bp.dig("operational_data_reference", "physical_properties", "mass_kg")
    return mass.to_f if mass
    
    # Estimate from required materials
    if unit_bp["required_materials"]
      estimated_mass = unit_bp["required_materials"].values
        .select { |mat| mat["unit"] == "kilogram" }
        .sum { |mat| mat["amount"].to_f }
      return estimated_mass if estimated_mass > 0
    end
    
    0.0
  end

  def self.calculate_launch_cost(mass_kg, config)
    # Always use kg for calculations
    cost_per_kg = config.dig(:pricing, :cost_per_kg) || 544.22  # Default $1200/lb converted
    base_cost = config.dig(:pricing, :base_cost) || 0.0
    currency = config.dig(:pricing, :currency) || 'USD'
    
    total_cost = (mass_kg * cost_per_kg) + base_cost
    
    # Calculate display values
    mass_lbs = mass_kg * 2.20462
    cost_per_lb_equivalent = cost_per_kg * 2.20462
    
    puts "    Launch cost calculation: #{mass_kg.round(1)} kg × $#{cost_per_kg.round(2)}/kg = $#{total_cost.round(2)}"
    puts "    Display equivalent: #{mass_lbs.round(1)} lbs × $#{cost_per_lb_equivalent.round(2)}/lb = $#{total_cost.round(2)}"
    
    {
      total: total_cost.round(2),
      currency: currency,
      breakdown: {
        mass_kg: mass_kg,
        mass_lbs: mass_lbs,
        cost_per_kg: cost_per_kg,
        cost_per_lb_equivalent: cost_per_lb_equivalent,
        base_cost: base_cost
      }
    }
  end

  def self.process_payment(launch_cost:, customer_accounts:, provider_accounts:, payment_config:)
    # Flexible payment structure
    payment_methods = payment_config[:methods] || [
      { currency: 'GCC', max_percentage: 50 },
      { currency: 'USD', max_percentage: 100 }
    ]
    
    remaining_cost = launch_cost[:total]
    payments_made = []
    
    payment_methods.each do |method|
      break if remaining_cost <= 0
      
      currency_symbol = method[:currency]
      max_amount = (launch_cost[:total] * (method[:max_percentage] / 100.0)).round(2)
      
      customer_account = customer_accounts[currency_symbol.downcase.to_sym]
      provider_account = provider_accounts[currency_symbol.downcase.to_sym]
      
      next unless customer_account && provider_account
      
      available = customer_account.balance.to_f
      to_pay = [remaining_cost, max_amount, available].min.round(2)
      
      if to_pay > 0
        customer_account.transfer_funds(
          to_pay, 
          provider_account, 
          "Launch service fee (#{currency_symbol} portion)"
        )
        
        payments_made << { currency: currency_symbol, amount: to_pay }
        remaining_cost = (remaining_cost - to_pay).round(2)
      end
    end
    
    # Handle unpaid balance
    bond = nil
    if remaining_cost > 0 && payment_config[:allow_bonds]
      # Get the entities from the accounts using the proper association
      customer_entity = customer_accounts.values.first.accountable
      provider_entity = provider_accounts.values.first.accountable
    
      bond = create_bond(
        amount: remaining_cost,
        currency: launch_cost[:currency],
        customer: customer_entity,
        provider: provider_entity,
        payment_config: payment_config
      )
    end
    
    log_payment_results(payments_made, remaining_cost, bond, customer_accounts, provider_accounts)
    
    { 
      payments: payments_made, 
      unpaid_balance: remaining_cost, 
      bond: bond,
      success: remaining_cost == 0 || bond.present?
    }
  end

  def self.create_bond(amount:, currency:, customer:, provider:, payment_config:)
    return nil unless payment_config[:bond_terms]
    
    game = Game.new
    game_state = game.game_state
    currency_obj = Currency.find_by(symbol: currency)
    
    terms = payment_config[:bond_terms]
    issued_at = Date.new(game_state.year, 1, 1) + (game_state.day - 1)
    due_at = issued_at + (terms[:maturity_days] || 180)
    
    Bond.create!(
      issuer: customer,
      holder: provider,
      currency: currency_obj,
      amount: amount,
      issued_at: issued_at,
      due_at: due_at,
      status: :issued,
      description: terms[:description] || "Bond for unpaid launch cost"
    )
  end

  def self.log_payment_results(payments, unpaid, bond, customer_accounts, provider_accounts)
    # Use the proper association method
    customer_name = customer_accounts.values.first.accountable.name
    provider_name = provider_accounts.values.first.accountable.name
    
    puts "\n💰 Launch Payment Summary:"
    payments.each do |payment|
      puts "  ✅ #{customer_name} paid #{payment[:amount]} #{payment[:currency]} to #{provider_name}"
    end
    
    if bond
      puts "  🪙 #{customer_name} issued bond to #{provider_name} for #{unpaid} (Bond ID: #{bond.id})"
    elsif unpaid > 0
      puts "  ❌ Unpaid balance: #{unpaid}"
    end
    
    puts "\n📊 Final Balances:"
    customer_accounts.each do |currency, account|
      puts "  #{customer_name} #{currency.upcase}: #{account.reload.balance.to_f}"
    end
    provider_accounts.each do |currency, account|
      puts "  #{provider_name} #{currency.upcase}: #{account.reload.balance.to_f}"
    end
  end
end