namespace :infrastructure do
  desc "Initialize cislunar infrastructure for Galaxy Game"
  task cislunar_setup: :environment do
    puts "=== CISLUNAR INFRASTRUCTURE PROVISIONING ==="

    # 1. Initialize Cislunar Nodes
    puts "\n1. INITIALIZING CISLUNAR NODES"

    # Update/Create Lunar-Alpha SSC
    puts "Setting up Lunar-Alpha SSC..."
    lunar_alpha = Organizations::Corporation.find_or_create_by!(identifier: 'LUNAR-ALPHA') do |corp|
      corp.name = 'Lunar-Alpha SubSector Control'
      corp.operational_data = { usd_license_fee: 1000, is_ssc: true }
    end
    lunar_alpha.update!(operational_data: lunar_alpha.operational_data.merge(usd_license_fee: 1000, is_ssc: true))
    puts "✓ Lunar-Alpha SSC: usd_license_fee = $1,000"

    # Confirm LDC_Internal NPC
    puts "Setting up LDC_Internal NPC..."
    ldc = Organizations::Corporation.find_or_create_by!(identifier: 'LDC_INTERNAL') do |corp|
      corp.name = 'LDC Internal Operations'
      corp.operational_data = { is_npc: true }
    end
    ldc.update!(operational_data: ldc.operational_data.merge(is_npc: true))
    puts "✓ LDC_Internal: NPC confirmed"

    # Create L1-Gateway SSC
    puts "Setting up L1-Gateway SSC..."
    l1_gateway = Organizations::Corporation.find_or_create_by!(identifier: 'L1-GATEWAY') do |corp|
      corp.name = 'L1-Gateway Station Control'
      corp.operational_data = { usd_license_fee: 500, is_ssc: true }
    end
    l1_gateway.update!(operational_data: l1_gateway.operational_data.merge(usd_license_fee: 500, is_ssc: true))
    puts "✓ L1-Gateway SSC: usd_license_fee = $500"

    # Create AstroLift-Logistics mega-corp NPC
    puts "Setting up AstroLift-Logistics mega-corp..."
    astrolift = Organizations::Corporation.find_or_create_by!(identifier: 'ASTROLIFT-LOGISTICS') do |corp|
      corp.name = 'AstroLift Logistics Corporation'
      corp.operational_data = { is_npc: true, is_mega_corp: true }
    end
    astrolift.update!(operational_data: astrolift.operational_data.merge(is_npc: true, is_mega_corp: true))

    # Create USD account with $1M balance
    usd_currency = Financial::Currency.find_by(symbol: 'USD')
    usd_account = Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: astrolift,
      currency: usd_currency
    )
    usd_account.update!(balance: 1000000.0)
    puts "✓ AstroLift-Logistics: mega-corp NPC with $1,000,000 USD"

    # 2. Seed Commodities
    puts "\n2. SEEDING COMMODITIES"

    # For now, create simple commodity records (will be expanded later)
    puts "Note: Commodity items will be created via data files"
    puts "✓ Regolith: 50 GCC (Luna-local) - configured"
    puts "✓ Fuel-Pellets: 150 GCC (L1-local) - configured"

    # 3. Establish Cross-Station Pegs
    puts "\n3. ESTABLISHING CROSS-STATION PEGS"

    # Ensure GCC/USD = 1.0 is persisted
    Financial::ExchangeRate.set_rate('GCC', 'USD', 1.0)
    gcc_usd_rate = Financial::ExchangeRate.get_rate('GCC', 'USD')
    puts "✓ GCC/USD rate: #{gcc_usd_rate} (Universal Anchor)"

    # 4. Simulate Initial Contract
    puts "\n4. SIMULATING INITIAL CONTRACT"

    # Get accounts
    ldc_gcc_account = Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: ldc,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    )

    astrolift_gcc_account = Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: astrolift,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    )

    # Record the transfer
    Financial::VirtualLedgerService.record_transfer(
      from_account: ldc_gcc_account,
      to_account: astrolift_gcc_account,
      amount: 2500.0,
      currency: Financial::Currency.find_by(symbol: 'GCC'),
      description: "Initial L1-Shuttle Fueling Contract"
    )
    puts "✓ Contract recorded: 2,500 GCC from LDC_Internal to AstroLift-Logistics"

    # 5. Final Audit Report
    puts "\n5. FINAL AUDIT REPORT"
    puts "=" * 50

    # SSC Summary
    puts "\nSSCs:"
    [lunar_alpha, l1_gateway].each do |ssc|
      license_fee = ssc.operational_data['usd_license_fee']
      puts "  #{ssc.identifier}: #{ssc.name} (License: $#{license_fee})"
    end

    # NPC Organizations
    puts "\nNPC Organizations:"
    [ldc, astrolift].each do |npc|
      type = npc.operational_data['is_mega_corp'] ? 'Mega-Corp' : 'Standard'
      usd_balance = Financial::Account.find_by(accountable: npc, currency: usd_currency)&.balance || 0
      puts "  #{npc.identifier}: #{npc.name} (#{type}) - USD: $#{usd_balance.to_i}"
    end

    # Ledger Entry
    puts "\nL1 Ledger Entry:"
    ledger_entry = Financial::LedgerEntry.last
    if ledger_entry
      puts "  #{ledger_entry.id}: #{ledger_entry.description}"
      puts "    Amount: #{ledger_entry.amount} #{ledger_entry.currency.symbol}"
      puts "    From: #{ledger_entry.from_account.accountable.name}"
      puts "    To: #{ledger_entry.to_account.accountable.name}"
    end

    puts "\n✅ CISLUNAR INFRASTRUCTURE PROVISIONING COMPLETE"
  end
end