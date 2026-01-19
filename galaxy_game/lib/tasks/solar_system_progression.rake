# lib/tasks/solar_system_progression.rake
require 'json'
require 'securerandom'

namespace :missions do
  namespace :solar_system do
    desc "Execute simplified solar system progression with observable GCC flows"
    task simple_progression: :environment do
      puts "\n🚀 === SOLAR SYSTEM ECONOMIC PROGRESSION ==="
      puts "Simplified deployment showing GCC flows and material transfers\n"

      progression = SimpleSolarProgression.new
      progression.execute_progression
    end

    desc "Execute complete solar system infrastructure deployment for living simulation"
    task living_simulation_setup: :environment do
      puts "\n🌌 === LIVING SIMULATION INITIALIZATION ==="
      puts "Deploying AI-established infrastructure for player entry\n"

      setup = LivingSimulationSetup.new
      setup.execute_full_deployment
    end
  end
end

class SimpleSolarProgression
  def initialize
    @corporations = {}
    @total_transfers = 0
  end

  def execute_progression
    puts "Setting up basic economic infrastructure..."

    # Create GCC currency
    gcc = Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
      c.name = 'Galactic Crypto Currency'
      c.is_system_currency = true
      c.precision = 8
    end
    puts "✓ GCC currency established"

    # PHASE 1: Lunar Development Corporation
    puts "\n🌙 PHASE 1: LUNAR DEVELOPMENT CORPORATION"
    create_lunar_corp
    show_gcc_status("Lunar Corp Created")

    # PHASE 2: Venus Atmospheric Corporation
    puts "\n🌑 PHASE 2: VENUS ATMOSPHERIC CORPORATION"
    create_venus_corp
    show_gcc_status("Venus Corp Created")

    # PHASE 3: Mars Industrial Corporation
    puts "\n🔴 PHASE 3: MARS INDUSTRIAL CORPORATION"
    create_mars_corp
    show_gcc_status("Mars Corp Created")

    # PHASE 4: Material Transfers
    puts "\n💰 PHASE 4: INTERPLANETARY MATERIAL TRANSFERS"
    execute_material_transfers

    # Final Status
    puts "\n📊 FINAL ECONOMIC STATUS"
    display_final_status
  end

  private

  def create_lunar_corp
    # Create LDC corporation
    ldc_org = Organizations::BaseOrganization.find_or_create_by!(identifier: 'LDC') do |o|
      o.name = "Lunar Development Corporation"
      o.organization_type = 'corporation'
      o.description = "Lunar resource extraction and GCC banking"
    end

    # Create LDC account
    ldc_account = Financial::Account.find_or_create_by!(
      accountable: ldc_org,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    ) do |a|
      a.balance = 10_000_000.0
    end

    @corporations[:ldc] = { organization: ldc_org, account: ldc_account }
    puts "✓ LDC established with 10,000,000 GCC"
  end

  def create_venus_corp
    # Create Venus corporation
    venus_org = Organizations::BaseOrganization.find_or_create_by!(identifier: 'VENUS_CORP') do |o|
      o.name = "Venus Atmospheric Corporation"
      o.organization_type = 'corporation'
      o.description = "Venus atmospheric gas harvesting"
    end

    # Create Venus account
    venus_account = Financial::Account.find_or_create_by!(
      accountable: venus_org,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    ) do |a|
      a.balance = 3_000_000.0
    end

    @corporations[:venus] = { organization: venus_org, account: venus_account }
    puts "✓ Venus Corp established with 3,000,000 GCC"
  end

  def create_mars_corp
    # Create Mars corporation
    mars_org = Organizations::BaseOrganization.find_or_create_by!(identifier: 'MARS_CORP') do |o|
      o.name = "Mars Industrial Corporation"
      o.organization_type = 'corporation'
      o.description = "Mars industrial manufacturing"
    end

    # Create Mars account
    mars_account = Financial::Account.find_or_create_by!(
      accountable: mars_org,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    ) do |a|
      a.balance = 4_000_000.0
    end

    @corporations[:mars] = { organization: mars_org, account: mars_account }
    puts "✓ Mars Corp established with 4,000,000 GCC"
  end

  def execute_material_transfers
    # Venus buys lunar materials from LDC
    material_cost = 500_000.0
    transfer_funds(@corporations[:venus][:account], @corporations[:ldc][:account],
                  material_cost, "Venus purchases lunar construction materials")
    puts "💰 Venus → LDC: #{material_cost} GCC (lunar materials)"

    # Mars buys atmospheric gases from Venus
    gas_cost = 200_000.0
    transfer_funds(@corporations[:mars][:account], @corporations[:venus][:account],
                  gas_cost, "Mars purchases atmospheric gases")
    puts "💨 Mars → Venus: #{gas_cost} GCC (CO2/N2 gases)"

    # Mars pays LDC for banking services
    banking_fee = 50_000.0
    transfer_funds(@corporations[:mars][:account], @corporations[:ldc][:account],
                  banking_fee, "Mars pays LDC banking fees")
    puts "🏛️ Mars → LDC: #{banking_fee} GCC (banking services)"
  end

  def transfer_funds(from_account, to_account, amount, description)
    from_account.update!(balance: from_account.balance - amount)
    to_account.update!(balance: to_account.balance + amount)
    @total_transfers += 1

    # Create transactions
    from_account.transactions.create!(
      amount: -amount,
      description: description,
      transaction_type: :transfer,
      recipient: to_account.accountable,
      currency: from_account.currency
    )

    to_account.transactions.create!(
      amount: amount,
      description: description,
      transaction_type: :transfer,
      recipient: from_account.accountable,
      currency: to_account.currency
    )
  end

  def show_gcc_status(phase)
    puts "\n💰 GCC STATUS AFTER #{phase.upcase}:"
    @corporations.each do |name, corp|
      balance = corp[:account].balance.round(2)
      puts "  #{name.to_s.upcase}: #{balance} GCC"
    end
  end

  def display_final_status
    puts "\n🏛️ CORPORATIONS:"
    @corporations.each do |name, corp|
      balance = corp[:account].balance.round(2)
      puts "  #{corp[:organization].name}: #{balance} GCC"
    end

    total_gcc = @corporations.values.sum { |corp| corp[:account].balance }
    puts "\n💎 TOTAL SYSTEM GCC: #{total_gcc}"
    puts "🔄 TOTAL TRANSACTIONS: #{@total_transfers}"

    most_valuable = @corporations.max_by { |_, corp| corp[:account].balance }
    puts "🏆 MOST VALUABLE: #{most_valuable[1][:organization].name}"

    puts "\n✅ Basic interplanetary economy operational!"
  end
end

class LivingSimulationSetup
  def initialize
    @corporations = {}
    @settlements = {}
    @total_tasks = 0
  end

  def execute_full_deployment
    start_time = Time.current

    # PHASE 1: Establish GCC Currency
    puts "\n💰 PHASE 1: ESTABLISH GALACTIC CURRENCY"
    establish_gcc_currency

    # PHASE 2: Lunar Development Corporation & Base
    puts "\n🌙 PHASE 2: LUNAR INFRASTRUCTURE DEPLOYMENT"
    deploy_lunar_infrastructure

    # PHASE 3: L1 Station & Logistics Hub
    puts "\n🛰️ PHASE 3: L1 LOGISTICS HUB"
    deploy_l1_station

    # PHASE 4: Venus Atmospheric Corporation & Operations
    puts "\n🌑 PHASE 4: VENUS ATMOSPHERIC OPERATIONS"
    deploy_venus_operations

    # PHASE 5: Mars Industrial Corporation & Manufacturing
    puts "\n🔴 PHASE 5: MARS INDUSTRIAL COMPLEX"
    deploy_mars_operations

    # PHASE 6: Interplanetary Market Establishment
    puts "\n💱 PHASE 6: INTERPLANETARY MARKET NETWORK"
    establish_market_network

    # PHASE 7: AI Learning Pattern Recognition
    puts "\n🤖 PHASE 7: AI PATTERN LEARNING INITIALIZATION"
    initialize_ai_learning

    # Final Status
    display_living_simulation_status(start_time)
  end

  private

  def establish_gcc_currency
    gcc = Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
      c.name = 'Galactic Crypto Currency'
      c.is_system_currency = true
      c.precision = 8
    end
    puts "✓ GCC currency established as system currency"
    @total_tasks += 1
  end

  def deploy_lunar_infrastructure
    # Create LDC Corporation
    ldc_org = Organizations::BaseOrganization.find_or_create_by!(identifier: 'LDC') do |o|
      o.name = "Lunar Development Corporation"
      o.organization_type = 'corporation'
      o.description = "Lunar resource extraction and GCC banking"
    end

    ldc_account = Financial::Account.find_or_create_by!(
      accountable: ldc_org,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    ) do |a|
      a.balance = 10_000_000.0
    end

    @corporations[:ldc] = { organization: ldc_org, account: ldc_account }

    # Deploy Lunar Base via AI Mission Execution
    puts "  Executing lunar precursor mission..."
    execute_lunar_precursor_mission(ldc_org)

    puts "✓ Lunar infrastructure deployed - Base operational with ISRU"
    @total_tasks += 5
  end

  def execute_lunar_precursor_mission(corporation)
    # Get/create Moon
    moon = CelestialBodies::CelestialBody.find_or_create_by!(identifier: 'MOON') do |body|
      body.name = "Moon"
      body.mass = 7.34e22
      body.radius = 1737.4
      body.gravity = 1.62
      body.atmosphere = { 'N2' => 0.0, 'O2' => 0.0, 'CO2' => 0.0 }
      body.geosphere = { 'regolith' => 100.0 }
    end

    # Create lunar location
    lunar_location = Location::CelestialLocation.find_or_create_by!(
      name: "Mare Tranquillitatis Base",
      celestial_body: moon
    ) do |loc|
      loc.coordinates = "0.0°N 0.0°E"
      loc.altitude = 0.0
    end

    # Create lunar settlement
    settlement = Settlement::BaseSettlement.create!(
      name: "Luna Base Alpha",
      location: lunar_location,
      settlement_type: 'base',
      owner: corporation
    )

    # Deploy basic infrastructure (simplified)
    deploy_settlement_units(settlement, [
      { name: 'Solar Panel Array', quantity: 10 },
      { name: 'Regolith Processor', quantity: 5 },
      { name: 'I-Beam Fabricator', quantity: 3 },
      { name: 'Oxygen Extractor', quantity: 2 }
    ])

    @settlements[:luna] = settlement

    # Establish Luna Market
    luna_market = Market::Marketplace.find_or_create_by(settlement: settlement)
    puts "    ✓ Luna market established with GCC/USD coupling"
  end

  def deploy_l1_station
    # Create L1 Station as co-owned logistics hub
    earth = CelestialBodies::CelestialBody.find_or_create_by!(identifier: 'EARTH') do |body|
      body.name = "Earth"
      body.mass = 5.97e24
      body.radius = 6371.0
    end

    l1_location = Location::CelestialLocation.find_or_create_by!(
      name: "Earth-Moon L1 Point",
      celestial_body: earth
    ) do |loc|
      loc.coordinates = "L1 Lagrange Point"
      loc.altitude = 384400.0 # Earth-Moon distance
    end

    # Co-owned by LDC and AstroLift
    astrolift_org = Organizations::BaseOrganization.find_or_create_by!(identifier: 'ASTROLIFT') do |o|
      o.name = "AstroLift Logistics"
      o.organization_type = 'corporation'
      o.description = "Interplanetary logistics and harvesting"
    end

    settlement = Settlement::BaseSettlement.create!(
      name: "L1 Logistics Depot",
      location: l1_location,
      settlement_type: 'station',
      owner: @corporations[:ldc][:organization] # Primary owner
    )

    # Mark as co-owned
    settlement.update!(operational_data: {
      co_owners: ['LDC', 'ASTROLIFT'],
      purpose: 'logistics_hub',
      cycler_capacity: 1000
    })

    @settlements[:l1] = settlement

    puts "✓ L1 Station deployed as co-owned logistics hub"
    @total_tasks += 3
  end

  def deploy_venus_operations
    # Create Venus Corporation
    venus_org = Organizations::BaseOrganization.find_or_create_by!(identifier: 'VENUS_CORP') do |o|
      o.name = "Venus Development Corporation"
      o.organization_type = 'corporation'
      o.description = "Venus atmospheric gas harvesting"
    end

    venus_account = Financial::Account.find_or_create_by!(
      accountable: venus_org,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    ) do |a|
      a.balance = 3_000_000.0
    end

    @corporations[:venus] = { organization: venus_org, account: venus_account }

    # Deploy Venus orbital station
    venus = CelestialBodies::CelestialBody.find_or_create_by!(identifier: 'VENUS') do |body|
      body.name = "Venus"
      body.mass = 4.87e24
      body.radius = 6051.8
      body.atmosphere = { 'CO2' => 96.5, 'N2' => 3.5 }
    end

    venus_location = Location::CelestialLocation.find_or_create_by!(
      name: "Venus Orbital Station",
      celestial_body: venus
    ) do |loc|
      loc.coordinates = "0.0°N 0.0°E"
      loc.altitude = 1000.0
    end

    settlement = Settlement::BaseSettlement.create!(
      name: "Venus Gas Processing Station",
      location: venus_location,
      settlement_type: 'station',
      owner: venus_org
    )

    deploy_settlement_units(settlement, [
      { name: 'Atmospheric Harvester', quantity: 8 },
      { name: 'Gas Processor', quantity: 6 },
      { name: 'CO2 Extractor', quantity: 4 }
    ])

    @settlements[:venus] = settlement

    puts "✓ Venus atmospheric operations deployed"
    @total_tasks += 4
  end

  def deploy_mars_operations
    # Create Mars Corporation
    mars_org = Organizations::BaseOrganization.find_or_create_by!(identifier: 'MARS_CORP') do |o|
      o.name = "Mars Development Corporation"
      o.organization_type = 'corporation'
      o.description = "Mars industrial manufacturing"
    end

    mars_account = Financial::Account.find_or_create_by!(
      accountable: mars_org,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    ) do |a|
      a.balance = 4_000_000.0
    end

    @corporations[:mars] = { organization: mars_org, account: mars_account }

    # Deploy Mars base
    mars = CelestialBodies::CelestialBody.find_or_create_by!(identifier: 'MARS') do |body|
      body.name = "Mars"
      body.mass = 6.39e23
      body.radius = 3389.5
      body.atmosphere = { 'CO2' => 95.3, 'N2' => 2.7 }
    end

    mars_location = Location::CelestialLocation.find_or_create_by!(
      name: "Mars Prime Base",
      celestial_body: mars
    ) do |loc|
      loc.coordinates = "0.0°N 0.0°E"
      loc.altitude = 0.0
    end

    settlement = Settlement::BaseSettlement.create!(
      name: "Mars Industrial Complex",
      location: mars_location,
      settlement_type: 'base',
      owner: mars_org
    )

    deploy_settlement_units(settlement, [
      { name: 'Manufacturing Plant', quantity: 6 },
      { name: 'Assembly Bay', quantity: 4 },
      { name: 'Terraforming Unit', quantity: 2 }
    ])

    @settlements[:mars] = settlement

    puts "✓ Mars industrial operations deployed"
    @total_tasks += 4
  end

  def deploy_settlement_units(settlement, units)
    units.each do |unit_spec|
      unit = Unit.find_by(name: unit_spec[:name]) || Unit.create!(
        name: unit_spec[:name],
        unit_type: 'infrastructure'
      )

      SettlementUnit.create!(
        settlement: settlement,
        unit: unit,
        quantity: unit_spec[:quantity],
        operational: true
      )
    end
  end

  def establish_market_network
    # Create inter-settlement market connections
    @settlements.each do |name, settlement|
      market = Market::Marketplace.find_or_create_by(settlement: settlement)

      # Add some initial market conditions
      case name
      when :luna
        create_market_condition(market, 'O2', 100.0, 50.0)
        create_market_condition(market, 'I-Beam', 10.0, 500.0)
      when :venus
        create_market_condition(market, 'CO2', 1000.0, 20.0)
        create_market_condition(market, 'N2', 500.0, 30.0)
      when :mars
        create_market_condition(market, 'Manufacturing', 50.0, 200.0)
      end
    end

    puts "✓ Interplanetary market network established"
    @total_tasks += 2
  end

  def create_market_condition(market, resource, supply, price)
    condition = Market::MarketCondition.find_or_create_by(
      market: market,
      resource: resource
    ) do |mc|
      mc.supply = supply
      mc.demand = supply * 0.8
      mc.price = price
    end
  end

  def initialize_ai_learning
    # Initialize precursor learning service
    learning_service = AIManager::PrecursorLearningService.new

    # Record initial deployment patterns
    @settlements.each do |name, settlement|
      pattern = {
        celestial_body: settlement.location.celestial_body.identifier,
        settlement_type: settlement.settlement_type,
        infrastructure_count: settlement.units.count,
        operational_status: 'active'
      }

      learning_service.record_mission_performance(
        "initial_#{name}_deployment",
        pattern,
        { success: true, tasks_completed: 1 }
      )
    end

    puts "✓ AI learning patterns initialized from Sol system deployments"
    @total_tasks += 1
  end

  def display_living_simulation_status(start_time)
    end_time = Time.current
    duration = end_time - start_time

    puts "\n🌌 === LIVING SIMULATION STATUS ==="
    puts "Corporations Established:"
    @corporations.each do |key, corp|
      balance = corp[:account].balance.round(2)
      puts "  • #{corp[:organization].name}: #{balance} GCC"
    end

    puts "\nSettlements Deployed:"
    @settlements.each do |key, settlement|
      puts "  • #{settlement.name} (#{settlement.settlement_type})"
      puts "    └─ #{settlement.units.count} infrastructure units operational"
    end

    puts "\nMarket Network:"
    puts "  • Luna Market: O2, I-Beams available"
    puts "  • Venus Market: CO2, N2 processing"
    puts "  • Mars Market: Manufacturing capacity"
    puts "  • L1 Depot: Interplanetary logistics hub"

    puts "\nAI Learning:"
    puts "  • Pattern recognition initialized"
    puts "  • Deployment templates captured"
    puts "  • Ready for wormhole expansion"

    puts "\n⏱️  Living simulation established in #{duration.round(2)} seconds"
    puts "🎯 Total infrastructure tasks: #{@total_tasks}"
    puts "\n✨ Players can now enter the game with operational markets and bases!"
    puts "   AI Manager continues autonomous foothold expansion using learned patterns."
  end
end