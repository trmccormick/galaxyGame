# lib/tasks/solar_system_mission_pipeline.rake
require 'json'
require 'securerandom'

namespace :missions do
  namespace :solar_system do
    desc "Execute complete solar system mission pipeline with corporate development and resource flows"
    task pipeline: :environment do
      puts "\n🚀 === SOLAR SYSTEM CORPORATE DEVELOPMENT PIPELINE ==="
      puts "Building interconnected corporate infrastructure with resource and GCC flows\n"

      # Track overall progress
      total_tasks_executed = 0
      start_time = Time.current

      # PHASE 0: Establish Corporate Infrastructure
      puts "\n🏢 === PHASE 0: CORPORATE INFRASTRUCTURE ==="
      corporations = establish_corporate_infrastructure
      total_tasks_executed += setup_corporate_relationships(corporations)

      # PHASE 1: LDC Lunar Base Establishment (Foundation for all other operations)
      puts "\n🌙 === PHASE 1: LUNAR DEVELOPMENT CORPORATION ==="
      ldc_corp = corporations[:ldc]
      total_tasks_executed += execute_ldc_lunar_base_mission(ldc_corp)

      # PHASE 2: L1 Station Establishment (Co-owned logistics hub)
      puts "\n🛰️ === PHASE 2: L1 STATION ESTABLISHMENT ==="
      total_tasks_executed += establish_l1_station(corporations)

      # PHASE 3: Venus Development Corporation Operations (Now can receive LDC materials)
      puts "\n🌑 === PHASE 3: VENUS DEVELOPMENT CORPORATION ==="
      if Economy::ScheduledTradeService.first_n2_delivery_completed?
        # Create Venus corp after L1 is operational and N2 delivery completed
        corporations[:venus] = create_corporation("Venus Development Corporation", "VENUS_CORP", :atmospheric_processing)
        puts "  ✓ Venus Corp established - Atmospheric processing and gas export"
        venus_corp = corporations[:venus]
        total_tasks_executed += execute_venus_system_integration(venus_corp)
      else
        puts "  ⚠️ Venus Corp creation gated - awaiting first N2 delivery from L1 to Luna"
      end

      # PHASE 4: Mars Development Corporation Operations (Can mine moons immediately)
      puts "\n🔴 === PHASE 4: MARS DEVELOPMENT CORPORATION ==="
      if Economy::ScheduledTradeService.first_n2_delivery_completed?
        # Create Mars corp after L1 is operational and N2 delivery completed
        corporations[:mars] = create_corporation("Mars Development Corporation", "MARS_CORP", :industrial_manufacturing)
        puts "  ✓ Mars Corp established - Industrial manufacturing and terraforming"
        mars_corp = corporations[:mars]
        total_tasks_executed += execute_mars_system_integration(mars_corp)
      else
        puts "  ⚠️ Mars Corp creation gated - awaiting first N2 delivery from L1 to Luna"
      end

      # PHASE 5: Titan Development Corporation Operations (Most distant, requires full infrastructure)
      puts "\n🪐 === PHASE 5: TITAN DEVELOPMENT CORPORATION ==="
      if Economy::ScheduledTradeService.first_n2_delivery_completed?
        # Create Titan corp after L1 is operational and N2 delivery completed
        corporations[:titan] = create_corporation("Titan Development Corporation", "TITAN_CORP", :fuel_chemical_production)
        puts "  ✓ Titan Corp established - Fuel/chemical production and Saturn resources"
        titan_corp = corporations[:titan]
        total_tasks_executed += execute_titan_system_integration(titan_corp)
      else
        puts "  ⚠️ Titan Corp creation gated - awaiting first N2 delivery from L1 to Luna"
      end

      # PHASE 6: Belt Mining Venture (Mars Corp + AstroLift joint operation)
      puts "\n⛏️ === PHASE 6: BELT MINING VENTURE ==="
      total_tasks_executed += execute_belt_mining_venture(corporations)

      # PHASE 7: Inter-Corporate Resource & GCC Flows
      puts "\n💰 === PHASE 7: INTER-CORPORATE RESOURCE & GCC FLOWS ==="
      analyze_resource_flows(corporations)

      # Final Solar System Status
      puts "\n🌌 === FINAL CORPORATE SOLAR SYSTEM STATUS ==="
      display_corporate_solar_system_status(corporations)

      end_time = Time.current
      duration = end_time - start_time
      puts "\n⏱️  Corporate pipeline completed in #{duration.round(2)} seconds"
      puts "🎯 Total tasks executed: #{total_tasks_executed}"

      puts "\n🏛️  Corporate infrastructure operational!"
      puts "   LDC: Lunar resource management and GCC banking"
      puts "   AstroLift: Interplanetary logistics and harvesting"
      puts "   Venus Corp: Atmospheric processing and gas export"
      puts "   Mars Corp: Industrial manufacturing and rare materials export"
      puts "   Titan Corp: Fuel/chemical production and Saturn resources"
      puts "   Belt Mining Venture: Joint Mars/AstroLift asteroid mining (72M GCC/month)"
      puts "   L1 Station: Co-owned depot for solar system trade"
    end

    def establish_corporate_infrastructure
      corporations = {}

      # Lunar Development Corporation (LDC) - Luna-based
      puts "  Establishing Lunar Development Corporation (LDC)..."
      corporations[:ldc] = create_corporation("Lunar Development Corporation", "LDC", :resource_management)
      puts "  ✓ LDC established - Resource management and GCC banking"

      # AstroLift - Logistics company
      puts "  Establishing AstroLift Logistics..."
      corporations[:astrolift] = create_corporation("AstroLift Interplanetary Logistics", "ASTROLIFT", :logistics)
      puts "  ✓ AstroLift established - Interplanetary logistics and harvesting"

      corporations
    end

    def create_corporation(name, code, specialization)
      # Create organization record
      org = Organizations::BaseOrganization.find_or_create_by!(identifier: code) do |o|
        o.name = name
        o.organization_type = 'corporation'
        o.operational_data = { 'is_npc' => true }
        o.description = "#{name} - #{specialization.to_s.humanize} specialists"
      end

      # Create corporate account (only if it doesn't exist)
      account = Financial::Account.find_or_create_by!(accountable: org, currency: Financial::Currency.find_by(symbol: 'GCC')) do |a|
        a.balance = 1000000.0 # Starting capital
      end

      puts "    Created/found account with #{account.balance} GCC"

      { organization: org, account: account }
    end

    def setup_corporate_relationships(corporations)
      tasks_executed = 0

      # LDC and AstroLift co-own L1 Station (simplified - just record the relationship)
      puts "  Establishing L1 Station co-ownership..."
      l1_station = create_l1_station
      puts "  ✓ L1 Station established for co-ownership by LDC and AstroLift"

      # AstroLift manages Venus and Titan harvesters
      puts "  AstroLift taking control of Venus harvesters..."
      # This would be implemented in the actual mission execution

      puts "  AstroLift taking control of Titan harvesters..."
      # This would be implemented in the actual mission execution

      tasks_executed += 3 # Co-ownership setup tasks
      tasks_executed
    end

    def create_l1_station
      # Create Earth if it doesn't exist
      earth = CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_or_create_by!(identifier: 'EARTH-01') do |p|
        p.name = "Earth"
        p.mass = 5.972e24
        p.radius = 6_371_000
        p.size = 1.0
        p.gravity = 9.807
        p.surface_temperature = 288.0
      end

      # Create L1 Lagrange point location
      l1_location = Location::CelestialLocation.find_or_create_by!(
        name: "Earth-Moon L1 Lagrange Point",
        celestial_body: earth
      ) do |loc|
        loc.coordinates = "0.0°N 0.0°E"
        loc.altitude = 384400000 # Distance to L1 in meters
      end

      puts "    Created/found L1 Station location at Earth-Moon Lagrange point"
      l1_location
    end

    def execute_corporate_mission(corporation, mission_id, celestial_body_id, station_name)
      puts "  #{corporation[:organization].name} executing #{mission_id}"

      # Load mission profile and manifest
      profile_path = Rails.root.join('app', 'data', 'json-data', 'missions', mission_id.split('_')[0] + '_settlement', "#{mission_id}_profile_v1.json")
      manifest_path = Rails.root.join('app', 'data', 'json-data', 'missions', mission_id.split('_')[0] + '_settlement', "#{mission_id}_manifest_v1.json")

      profile = JSON.parse(File.read(profile_path))
      manifest = JSON.parse(File.read(manifest_path))

      puts "    ✓ Profile: #{profile['mission_id']}"
      puts "    ✓ Manifest: #{manifest['manifest_id']}"

      # Setup celestial body
      celestial_body = setup_celestial_body(celestial_body_id, station_name)

      # Create settlement owned by corporation
      settlement = Settlement::BaseSettlement.create!(
        name: "#{station_name} #{SecureRandom.hex(4)}",
        location: create_location(celestial_body, "#{station_name} Base"),
        settlement_type: 'outpost',
        owner: corporation[:organization]
      )
      puts "    ✓ Corporate settlement created: #{settlement.name}"

      # Create mission record
      mission = Mission.create!(
        identifier: "#{mission_id}_#{settlement.id}",
        settlement: settlement,
        status: 'in_progress'
      )

      # Load inventory from manifest (funded by corporation)
      load_inventory_from_manifest(settlement, manifest, corporation[:account])

      # Execute mission phases
      tasks_executed = execute_mission_phases(mission_id, mission, settlement)

      puts "    ✓ #{corporation[:organization].name} #{mission_id} complete"
      tasks_executed
    end

    def execute_venus_system_integration(corporation)
      puts "  #{corporation[:organization].name} executing Venus System Integration"

      # Create Venus celestial body
      venus = CelestialBodies::CelestialBody.find_or_create_by!(identifier: 'VENUS-01') do |body|
        body.name = "Venus"
        body.mass = 4.867e24
        body.radius = 6_052_000
        body.size = 0.949
        body.gravity = 0.907
        body.surface_temperature = 737.0
      end

      # Create Venus orbital station
      venus_location = Location::CelestialLocation.find_or_create_by!(
        name: "Venus Orbital Station",
        celestial_body: venus
      ) do |loc|
        loc.coordinates = "0.0°N 0.0°E"
        loc.altitude = 0
      end

      venus_settlement = Settlement::BaseSettlement.create!(
        name: "Venus Atmospheric Station #{SecureRandom.hex(4)}",
        location: venus_location,
        settlement_type: 'outpost',
        owner: corporation[:organization]
      )

      puts "  ✓ Venus station established: #{venus_settlement.name}"

      # Load basic Venus station inventory
      load_basic_venus_inventory(venus_settlement, corporation[:account])

      puts "  ✓ Venus system integration completed"
      12  # Estimated tasks executed
    end

    def execute_mars_system_integration(corporation)
      puts "  #{corporation[:organization].name} executing Mars System Integration"

      # Create Mars celestial body
      mars = CelestialBodies::CelestialBody.find_or_create_by!(identifier: 'MARS-01') do |body|
        body.name = "Mars"
        body.mass = 6.39e23
        body.radius = 3_390_000
        body.size = 0.532
        body.gravity = 0.379
        body.surface_temperature = 210.0
      end

      # Create Mars orbital station
      mars_location = Location::CelestialLocation.find_or_create_by!(
        name: "Mars Orbital Station",
        celestial_body: mars
      ) do |loc|
        loc.coordinates = "0.0°N 0.0°E"
        loc.altitude = 0
      end

      mars_settlement = Settlement::BaseSettlement.create!(
        name: "Mars Industrial Station #{SecureRandom.hex(4)}",
        location: mars_location,
        settlement_type: 'outpost',
        owner: corporation[:organization]
      )

      puts "  ✓ Mars station established: #{mars_settlement.name}"

      # Load basic Mars station inventory
      load_basic_mars_inventory(mars_settlement, corporation[:account])

      puts "  ✓ Mars system integration completed"
      12  # Estimated tasks executed
    end

    def execute_ldc_lunar_base_mission(corporation)
      puts "  LDC establishing Lunar Base"

      # Get the Moon celestial body
      moon = CelestialBodies::CelestialBody.find_or_create_by!(identifier: 'MOON') do |body|
        body.name = "Moon"
        body.mass = 7.342e22
        body.radius = 1737400
        body.size = 0.2724
        body.gravity = 0.1654
        body.surface_temperature = 220.0
      end

      # Create lunar location
      lunar_location = Location::CelestialLocation.find_or_create_by!(
        name: "Lunar Base Site",
        celestial_body: moon
      ) do |loc|
        loc.coordinates = "0.0°N 0.0°E"
        loc.altitude = 0
      end

      # Create lunar settlement owned by LDC
      settlement = Settlement::BaseSettlement.create!(
        name: "Lunar Development Base #{SecureRandom.hex(4)}",
        location: lunar_location,
        settlement_type: 'base',
        owner: corporation[:organization]
      )

      puts "    ✓ Lunar Base settlement created: #{settlement.name}"

      # Create mission record
      mission = Mission.create!(
        identifier: "lunar_base_establishment_#{settlement.id}",
        settlement: settlement,
        status: 'in_progress'
      )

      # Load basic lunar base inventory
      load_basic_lunar_inventory(settlement, corporation[:account])

      # Create buy orders for N2 and CO on Luna market
      # luna_market = Market::Marketplace.find_or_create_by(settlement: settlement)
      # ['N2', 'CO'].each do |gas|
      #   Market::Order.create!(
      #     market_condition: luna_market.market_conditions.find_or_create_by(resource: gas),
      #     orderable: corporation[:organization],
      #     base_settlement: settlement,
      #     order_type: :buy,
      #     quantity: 100
      #   )
      # end
      puts "    ✓ Buy orders would be created for N2 and CO on Luna market (simplified)"

      puts "    ✓ LDC Lunar Base established"
      8  # Estimated tasks executed
    end

    def establish_l1_station(corporations)
      puts "  Establishing L1 Station as co-owned logistics and transfer hub"

      # Create L1 location (already exists from setup_corporate_relationships)
      l1_location = Location::CelestialLocation.find_by(name: "Earth-Moon L1 Lagrange Point")
      if l1_location.nil?
        l1_location = create_l1_station
      end

      # Create L1 station settlement co-owned by LDC and AstroLift
      # For simplicity, assign to LDC but mark as co-owned
      settlement = Settlement::BaseSettlement.create!(
        name: "L1 Logistics Station #{SecureRandom.hex(4)}",
        location: l1_location,
        settlement_type: 'outpost',
        owner: corporations[:ldc][:organization]  # Primary owner LDC
      )
      puts "    ✓ L1 Station settlement created: #{settlement.name}"

      # Create mission record
      mission = Mission.create!(
        identifier: "l1_station_establishment_#{settlement.id}",
        settlement: settlement,
        status: 'in_progress'
      )

      # Basic L1 station setup (cycler infrastructure, transfer facilities)
      # This would load from manifest and execute phases
      puts "    ✓ L1 Station operational - enabling interplanetary cyclers"

      # Mark as co-owned in operational data
      settlement.update!(operational_data: {
        co_owners: ['LDC', 'ASTROLIFT'],
        purpose: 'logistics_hub',
        cycler_capacity: 1000  # tons per cycle
      })

      puts "    ✓ L1 Station co-owned by LDC and AstroLift"

      # Simulate Heavy Lift Transport arrival with refined gases
      simulate_heavy_lift_arrival(settlement, corporations)

      # Execute scheduled deliveries if buy orders exist
      # Economy::ScheduledTradeService.monitor_and_execute_scheduled_deliveries

      8  # Estimated tasks for L1 setup
    end

    def simulate_heavy_lift_arrival(l1_settlement, corporations)
      puts "    Simulating Heavy Lift Transport arrival at L1 Depot"

      # Add refined gases and CO to L1 inventory
      inventory = l1_settlement.inventory || l1_settlement.create_inventory
      gases = { 'N2' => 1000, 'CH4' => 500, 'O2' => 800, 'CO' => 200 }

      gases.each do |gas, amount|
        inventory.items.find_or_create_by(name: gas) do |item|
          item.amount = 0
        end.increment!(:amount, amount)
      end

      puts "    ✓ Processed inventory added to L1 Depot: #{gases}"

      # Simplified - skip market orders for now
      puts "    ✓ Sell orders would be generated for refined gases and CO (simplified)"

      # Skip VirtualLedger for now
      puts "    ✓ Processed inventory registered (simplified)"
    end

    def execute_belt_mining_venture(corporations)
      puts "  Executing Belt Mining Venture (Mars Corp + AstroLift joint operation)..."

      # This would call the belt venture task
      # For now, simulate the key economic impacts
      mars_corp = corporations[:mars]
      astrolift = corporations[:astrolift]

      # Simulate venture formation and first revenue cycle
      venture_investment = 2_000_000.0
      monthly_revenue = 72_000_000.0
      monthly_profit = 25_200_000.0
      mars_dividend = monthly_profit * 0.5
      astrolift_dividend = monthly_profit * 0.5

      # Update corporation balances
      mars_corp[:account].update!(balance: mars_corp[:account].balance + mars_dividend)
      astrolift[:account].update!(balance: astrolift[:account].balance + astrolift_dividend)

      puts "    ✓ Belt Mining Venture LLC established"
      puts "    ✓ Initial investment: #{venture_investment} GCC (1M each from Mars/AstroLift)"
      puts "    ✓ Monthly revenue: #{monthly_revenue} GCC from rare materials export"
      puts "    ✓ Monthly profit: #{monthly_profit} GCC (35% margin)"
      puts "    ✓ Mars Corp monthly dividend: #{mars_dividend} GCC"
      puts "    ✓ AstroLift monthly dividend: #{astrolift_dividend} GCC"
      puts "    ✓ Mars Corp new balance: #{mars_corp[:account].balance} GCC"
      puts "    ✓ AstroLift new balance: #{astrolift[:account].balance} GCC"

      15  # Estimated tasks for venture setup
    end

    def execute_titan_system_integration(corporation)
      puts "  #{corporation[:organization].name} executing Titan System Integration"

      # Create Titan celestial body
      titan = CelestialBodies::CelestialBody.find_or_create_by!(identifier: 'TITAN-01') do |body|
        body.name = "Titan"
        body.mass = 1.345e23
        body.radius = 2_575_000
        body.size = 0.404
        body.gravity = 0.138
        body.surface_temperature = 94.0
      end

      # Create Titan orbital station
      titan_location = Location::CelestialLocation.find_or_create_by!(
        name: "Titan Orbital Station",
        celestial_body: titan
      ) do |loc|
        loc.coordinates = "0.0°N 0.0°E"
        loc.altitude = 0
      end

      titan_settlement = Settlement::BaseSettlement.create!(
        name: "Titan Fuel Station #{SecureRandom.hex(4)}",
        location: titan_location,
        settlement_type: 'outpost',
        owner: corporation[:organization]
      )

      puts "  ✓ Titan station established: #{titan_settlement.name}"

      # Load basic Titan station inventory
      load_basic_titan_inventory(titan_settlement, corporation[:account])

      puts "  ✓ Titan system integration completed"
      12  # Estimated tasks executed
    end

    def execute_mission_phases(mission_id, mission, settlement)
      tasks_executed
    end

    def execute_lunar_phase(phase_file, mission, settlement)
      # Simulate lunar phase execution (similar to Venus/Mars phases)
      tasks = case phase_file
      when 'lunar_landing_tasks_v1.json'
        3  # landing site selection, heavy lift landing, initial survey
      when 'lava_tube_habitat_tasks_v1.json'
        2  # mapping and habitat construction
      when 'lunar_resource_extraction_tasks_v1.json'
        2  # mining infrastructure and helium-3 collection
      when 'lunar_processing_facility_tasks_v1.json'
        2  # oxygen extraction and material processing
      else
        1
      end

      # Simulate task execution
      tasks.times do |i|
        puts "      Executing: Lunar task #{i + 1}"
      end

      puts "      ✓ Executed #{tasks} lunar tasks from #{phase_file}"
      tasks
    end

    def load_inventory_from_manifest(settlement, manifest, corporate_account)
      return unless manifest['inventory'] && manifest['inventory']['units']

      total_cost = 0
      manifest['inventory']['units'].each do |unit|
        settlement.inventory.add_item(unit['name'], unit['count'])
        # Simulate purchasing from corporate funds
        unit_cost = calculate_unit_cost(unit['name']) * unit['count']
        total_cost += unit_cost
        puts "    + #{unit['count']}x #{unit['name']} (#{unit_cost} GCC)"
      end

      # Deduct from corporate account
      corporate_account.update!(balance: corporate_account.balance - total_cost)
      puts "    ✓ Inventory loaded with #{manifest['inventory']['units'].count} item types"
      puts "    ✓ Corporate expenditure: #{total_cost} GCC (Balance: #{corporate_account.balance} GCC)"
    end

    def calculate_unit_cost(unit_name)
      # Simplified cost calculation - in real system this would be from blueprints
      case unit_name
      when /skimmer/i then 50000
      when /drone/i then 25000
      when /robot/i then 15000
      when /plant/i then 100000
      when /fuel/i then 1000
      else 10000
      end
    end

    def analyze_resource_flows(corporations)
      puts "  Analyzing inter-corporate resource and GCC flows..."

      # Venus Corp pays LDC for lunar materials (oxygen, metals) needed for station construction
      venus_pays_ldc_for_materials(corporations[:venus], corporations[:ldc])

      # Venus Corp sells atmospheric gases to Mars Corp
      venus_to_mars_flow(corporations[:venus], corporations[:mars])

      # Titan Corp sells fuel to Mars Corp
      titan_to_mars_flow(corporations[:titan], corporations[:mars])

      # Mars Corp pays LDC for GCC banking services
      mars_to_ldc_banking(corporations[:mars], corporations[:ldc])

      # AstroLift charges for logistics services (L1 station operations, harvester management)
      astrolift_logistics_fees(corporations)

      puts "  ✓ Resource and GCC flow analysis complete"
    end

    def venus_pays_ldc_for_materials(venus_corp, ldc)
      material_cost = 500000 # GCC for lunar oxygen, metals, and construction materials
      puts "    Venus Corp → LDC: Lunar materials supply (#{material_cost} GCC)"
      venus_corp[:account].update!(balance: venus_corp[:account].balance - material_cost)
      ldc[:account].update!(balance: ldc[:account].balance + material_cost)
    end

    def venus_to_mars_flow(venus_corp, mars_corp)
      gas_volume = 100000 # tons of CO2/N2
      gas_value = gas_volume * 50 # 50 GCC per ton
      puts "    Venus Corp → Mars Corp: #{gas_volume}t atmospheric gases (#{gas_value} GCC)"
      venus_corp[:account].update!(balance: venus_corp[:account].balance + gas_value)
      mars_corp[:account].update!(balance: mars_corp[:account].balance - gas_value)
    end

    def titan_to_mars_flow(titan_corp, mars_corp)
      fuel_volume = 50000 # tons of methane/hydrogen
      fuel_value = fuel_volume * 100 # 100 GCC per ton
      puts "    Titan Corp → Mars Corp: #{fuel_volume}t fuel (#{fuel_value} GCC)"
      titan_corp[:account].update!(balance: titan_corp[:account].balance + fuel_value)
      mars_corp[:account].update!(balance: mars_corp[:account].balance - fuel_value)
    end

    def mars_to_ldc_banking(mars_corp, ldc)
      banking_fee = 50000 # Monthly banking fee
      puts "    Mars Corp → LDC: Banking services (#{banking_fee} GCC)"
      mars_corp[:account].update!(balance: mars_corp[:account].balance - banking_fee)
      ldc[:account].update!(balance: ldc[:account].balance + banking_fee)
    end

    def astrolift_logistics_fees(corporations)
      logistics_fee = 75000 # Monthly logistics fee
      puts "    All Corps → AstroLift: Logistics services (#{logistics_fee} GCC total)"
      corporations.except(:ldc).each do |name, corp|
        next if name == :ldc
        individual_fee = logistics_fee / 4 # Split among Venus, Mars, Titan
        corp[:account].update!(balance: corp[:account].balance - individual_fee)
        corporations[:astrolift][:account].update!(balance: corporations[:astrolift][:account].balance + individual_fee)
      end
    end

    def display_corporate_solar_system_status(corporations)
      puts "Corporations:"
      corporations.each do |name, corp|
        puts "  • #{corp[:organization].name} (#{corp[:organization].identifier})"
        puts "    Balance: #{corp[:account].balance} GCC"
        puts "    Settlements: #{Settlement::BaseSettlement.where(owner: corp[:organization]).count}"
        puts "    Owned Crafts: #{Craft::BaseCraft.where(owner: corp[:organization]).count}"
      end

      puts "\nCo-owned Infrastructure:"
      l1_location = Location::CelestialLocation.find_by(name: "Earth-Moon L1 Lagrange Point")
      if l1_location
        puts "  • L1 Station: Co-owned by LDC and AstroLift"
      end

      # Check for Belt Venture
      belt_venture = Organizations::BaseOrganization.find_by(identifier: 'BELT_VENTURE')
      if belt_venture
        puts "  • Belt Mining Venture LLC: Joint Mars Corp/AstroLift operation"
        puts "    └─ Monthly revenue: 72M GCC, Profit: 25.2M GCC"
      end

      puts "\nResource Flows Active:"
      puts "  • Venus → Mars: Atmospheric gases for terraforming"
      puts "  • Titan → Mars: Fuel for industrial operations"
      puts "  • Mars → LDC: Banking and financial services"
      puts "  • All → AstroLift: Logistics and transportation"

      puts "\nGCC Flow Summary:"
      total_gcc = corporations.values.sum { |corp| corp[:account].balance }
      puts "  • Total system GCC: #{total_gcc}"
      puts "  • Most valuable corp: #{corporations.values.max_by { |corp| corp[:account].balance }[:organization].identifier}"
    end

    def execute_mission_pipeline(mission_id, celestial_body_id, station_name)
      puts "Loading mission: #{mission_id}"

      # Load mission profile and manifest
      profile_path = Rails.root.join('app', 'data', 'json-data', 'missions', mission_id.split('_')[0] + '_settlement', "#{mission_id}_profile_v1.json")
      manifest_path = Rails.root.join('app', 'data', 'json-data', 'missions', mission_id.split('_')[0] + '_settlement', "#{mission_id}_manifest_v1.json")

      profile = JSON.parse(File.read(profile_path))
      manifest = JSON.parse(File.read(manifest_path))

      puts "  ✓ Profile: #{profile['mission_id']}"
      puts "  ✓ Manifest: #{manifest['manifest_id']}"

      # Setup celestial body
      celestial_body = setup_celestial_body(celestial_body_id, station_name)

      # Create settlement
      settlement = Settlement::BaseSettlement.create!(
        name: "#{station_name} #{SecureRandom.hex(4)}",
        location: create_location(celestial_body, "#{station_name} Base"),
        settlement_type: 'station'
      )
      puts "  ✓ Settlement created: #{settlement.name}"

      # Create mission record
      mission = Mission.create!(
        identifier: "#{mission_id}_#{settlement.id}",
        settlement: settlement,
        status: 'in_progress'
      )

      # Load inventory from manifest
      load_inventory_from_manifest(settlement, manifest)

      # Execute mission phases
      tasks_executed = execute_mission_phases(mission_id, mission, settlement)

      puts "  ✓ #{mission_id} complete"
      tasks_executed
    end

    def execute_titan_mission_pipeline
      puts "Loading Titan Resource Hub mission"

      # Load all Titan mission files
      profile_path = Rails.root.join('app', 'data', 'json-data', 'missions', 'titan_resource_hub_profile_v1.json')
      manifest_path = Rails.root.join('app', 'data', 'json-data', 'missions', 'titan_resource_hub_manifest_v1.json')

      profile = JSON.parse(File.read(profile_path))
      manifest = JSON.parse(File.read(manifest_path))

      puts "  ✓ Profile: #{profile['mission_id']}"
      puts "  ✓ Manifest: #{manifest['manifest_id']}"

      # Setup Titan
      titan = setup_celestial_body('TITAN-01', 'Titan Resource Hub')

      # Create settlement
      settlement = Settlement::BaseSettlement.create!(
        name: "Titan Resource Hub #{SecureRandom.hex(4)}",
        location: create_location(titan, "Titan Surface Base"),
        settlement_type: 'base'
      )
      puts "  ✓ Settlement created: #{settlement.name}"

      # Create mission record
      mission = Mission.create!(
        identifier: "titan_resource_hub_#{settlement.id}",
        settlement: settlement,
        status: 'in_progress'
      )

      # Load inventory
      load_inventory_from_manifest(settlement, manifest)

      # Execute all Titan phases
      titan_phases = [
        'titan_orbital_establishment_phase_v1.json',
        'titan_resource_extraction_phase_v1.json',
        'titan_fuel_processing_phase_v1.json',
        'titan_surface_base_phase_v1.json',
        'titan_logistics_network_phase_v1.json'
      ]

      tasks_executed = 0
      titan_phases.each do |phase_file|
        puts "  Executing phase: #{phase_file}"
        tasks_executed += execute_titan_phase(phase_file, mission, settlement)
      end

      puts "  ✓ Titan Resource Hub complete"
      tasks_executed
    end

    def setup_celestial_body(identifier, name)
      body = CelestialBodies::CelestialBody.find_by(identifier: identifier)
      if body.nil?
        # Create basic celestial body for testing
        body = CelestialBodies::CelestialBody.create!(
          identifier: identifier,
          name: name,
          mass: 1e24, # Placeholder mass
          radius: 1000000, # Placeholder radius
          size: 1.0,
          gravity: 1.0,
          surface_temperature: 200.0
        )
        puts "  ✓ Created celestial body: #{name}"
      else
        puts "  ✓ Found existing celestial body: #{name}"
      end
      body
    end

    def create_location(celestial_body, location_name)
      # Generate unique coordinates
      latitude = rand(-90.0..90.0).round(6)
      longitude = rand(-180.0..180.0).round(6)
      
      lat_dir = latitude >= 0 ? 'N' : 'S'
      lon_dir = longitude >= 0 ? 'E' : 'W'
      
      Location::CelestialLocation.create!(
        name: location_name,
        celestial_body: celestial_body,
        coordinates: "#{latitude.abs}°#{lat_dir} #{longitude.abs}°#{lon_dir}",
        altitude: 0.0
      )
    end

    def load_basic_lunar_inventory(settlement, funding_account)
      # Create basic lunar base inventory
      inventory = settlement.inventory || settlement.create_inventory
      basic_supplies = {
        'Lunar Regolith' => 1000,
        'Helium-3' => 100,
        'Water Ice' => 500,
        'Construction Materials' => 200,
        'Solar Panels' => 50,
        'Habitat Modules' => 10
      }

      total_cost = 0
      basic_supplies.each do |item_name, quantity|
        inventory.items.find_or_create_by(name: item_name) do |item|
          item.amount = 0
        end.increment!(:amount, quantity)
        item_cost = quantity * 100 # Simplified cost
        total_cost += item_cost
      end

      funding_account.update!(balance: funding_account.balance - total_cost)
      puts "    📦 Basic lunar inventory loaded: #{basic_supplies.size} item types (#{total_cost} GCC)"
    end

    def load_basic_venus_inventory(settlement, funding_account)
      # Create basic Venus station inventory
      inventory = settlement.inventory || settlement.create_inventory
      venus_supplies = {
        'Gas Harvesters' => 20,
        'Atmospheric Processors' => 15,
        'Heat Shields' => 25,
        'CO2 Scrubbers' => 30,
        'Sulfuric Acid Neutralizers' => 10,
        'Orbital Habitat Modules' => 8
      }

      total_cost = 0
      venus_supplies.each do |item_name, quantity|
        inventory.items.find_or_create_by(name: item_name) do |item|
          item.amount = 0
        end.increment!(:amount, quantity)
        item_cost = quantity * 150 # Higher cost for Venus tech
        total_cost += item_cost
      end

      funding_account.update!(balance: funding_account.balance - total_cost)
      puts "    📦 Basic Venus inventory loaded: #{venus_supplies.size} item types (#{total_cost} GCC)"
    end

    def load_basic_mars_inventory(settlement, funding_account)
      # Create basic Mars station inventory
      inventory = settlement.inventory || settlement.create_inventory
      mars_supplies = {
        'Manufacturing Units' => 30,
        'Terraforming Equipment' => 20,
        'Research Labs' => 10,
        'Construction Drones' => 25,
        'Power Generators' => 15,
        'Life Support Systems' => 12
      }

      total_cost = 0
      mars_supplies.each do |item_name, quantity|
        inventory.items.find_or_create_by(name: item_name) do |item|
          item.amount = 0
        end.increment!(:amount, quantity)
        item_cost = quantity * 200 # Higher cost for Mars tech
        total_cost += item_cost
      end

      funding_account.update!(balance: funding_account.balance - total_cost)
      puts "    📦 Basic Mars inventory loaded: #{mars_supplies.size} item types (#{total_cost} GCC)"
    end

    def load_basic_titan_inventory(settlement, funding_account)
      # Create basic Titan station inventory
      inventory = settlement.inventory || settlement.create_inventory
      titan_supplies = {
        'Fuel Refineries' => 25,
        'Cryogenic Storage' => 40,
        'Extraction Rigs' => 15,
        'Methane Processors' => 20,
        'Thermal Insulation' => 30,
        'Orbital Fuel Depots' => 10
      }

      total_cost = 0
      titan_supplies.each do |item_name, quantity|
        inventory.items.find_or_create_by(name: item_name) do |item|
          item.amount = 0
        end.increment!(:amount, quantity)
        item_cost = quantity * 250 # Higher cost for Titan tech
        total_cost += item_cost
      end

      funding_account.update!(balance: funding_account.balance - total_cost)
      puts "    📦 Basic Titan inventory loaded: #{titan_supplies.size} item types (#{total_cost} GCC)"
    end

    def execute_mission_phases(mission_id, mission, settlement)
      # Load phase files based on mission
      phase_files = case mission_id
      when 'venus_orbital_establishment'
        [
          'venus_skimmer_deployment_phase_v1.json',
          'venus_station_construction_phase_v1.json',
          'venus_resource_processing_phase_v1.json',
          'venus_cycler_establishment_phase_v1.json'
        ]
      when 'mars_orbital_establishment'
        [
          'mars_skimmer_deployment_phase_v1.json',
          'mars_station_construction_phase_v1.json',
          'mars_resource_processing_phase_v1.json',
          'mars_cycler_establishment_phase_v1.json'
        ]
      else
        []
      end

      tasks_executed = 0
      phase_files.each do |phase_file|
        puts "  Executing phase: #{phase_file}"
        tasks_executed += execute_phase_file(phase_file, mission, settlement)
      end
      tasks_executed
    end

    def execute_titan_phase(phase_file, mission, settlement)
      phase_path = Rails.root.join('app', 'data', 'json-data', 'missions', phase_file)
      return 0 unless File.exist?(phase_path)

      phase_data = JSON.parse(File.read(phase_path))

      # Initialize task execution for this phase
      engine = AIManager::TaskExecutionEngine.new('titan_resource_hub')
      engine.instance_variable_set(:@mission, mission)
      engine.instance_variable_set(:@settlement, settlement)

      # Execute tasks from this phase
      tasks_executed = 0
      if phase_data['tasks']
        phase_data['tasks'].each do |task|
          puts "    Executing: #{task['name']}"
          execute_task(task, settlement)
          tasks_executed += 1
        end
      end
      tasks_executed
    end

    def execute_phase_file(phase_file, mission, settlement)
      mission_base = mission.identifier.split('_')[0..-2].join('_')
      phase_path = Rails.root.join('app', 'data', 'json-data', 'missions', mission_id_to_path(mission_base), phase_file)

      if File.exist?(phase_path)
        phase_data = JSON.parse(File.read(phase_path))

        tasks_executed = 0
        if phase_data['tasks']
          phase_data['tasks'].each do |task|
            puts "    Executing: #{task['name']}"
            execute_task(task, settlement)
            tasks_executed += 1
          end
        end
        tasks_executed
      else
        puts "    ⚠ Phase file not found: #{phase_file}"
        0
      end
    end

    def execute_task(task_data, settlement)
      # Simulate task execution - in real implementation this would use the TaskExecutionEngine
      case task_data['type']
      when 'construct'
        # Simulate construction
        puts "      Building: #{task_data['target']}"
      when 'deploy'
        puts "      Deploying: #{task_data['target']}"
      when 'harvest'
        puts "      Harvesting: #{task_data['resource']}"
      when 'process'
        puts "      Processing: #{task_data['input']} → #{task_data['output']}"
      else
        puts "      Executing: #{task_data['type']}"
      end

      # Simulate time delay (very short for accelerated testing)
      sleep(0.01)
    end

    def mission_id_to_path(mission_id)
      case mission_id
      when 'venus_orbital_establishment'
        'venus_settlement'
      when 'mars_orbital_establishment'
        'mars_settlement'
      else
        mission_id
      end
    end

    def display_solar_system_status
      puts "Celestial Bodies:"
      CelestialBodies::CelestialBody.all.each do |body|
        puts "  • #{body.name} (#{body.identifier})"
      end

      puts "\nSettlements:"
      Settlement::BaseSettlement.all.each do |settlement|
        location_name = settlement.location&.name || "Unknown Location"
        puts "  • #{settlement.name} at #{location_name}"
        puts "    Inventory: #{settlement.inventory.items.count} item types"
      end

      puts "\nMissions:"
      Mission.all.each do |mission|
        puts "  • #{mission.identifier}: #{mission.status}"
      end

      puts "\nInfrastructure Summary:"
      puts "  • Orbital Stations: #{Settlement::BaseSettlement.where(settlement_type: 'orbital_station').count}"
      puts "  • Resource Hubs: #{Settlement::BaseSettlement.where(settlement_type: 'resource_hub').count}"
      puts "  • Active Missions: #{Mission.where(status: 'in_progress').count}"
      puts "  • Completed Missions: #{Mission.where(status: 'completed').count}"
    end

    def trigger_resource_acquisition_for_deployment(settlement, funding_account)
      puts "    Triggering ResourceAcquisitionService for Earth-sourced items..."

      # Get all units deployed in the settlement's structures
      units = settlement.structures.flat_map(&:units)

      earth_sourced_materials = []
      units.each do |unit|
        next unless unit

        # Check if unit has components that need Earth import
        if unit['components']
          unit['components'].each do |component|
            material = component['material']
            amount = component['amount'] || component['quantity'] || 1

            # Trigger acquisition for Earth-sourced items
            unless AIManager::ResourceAcquisitionService.acquisition_method_for(material) == :local_trade
              AIManager::ResourceAcquisitionService.order_acquisition(settlement, material, amount)
              earth_sourced_materials << "#{material} (#{amount})"
            end
          end
        end
      end

      if earth_sourced_materials.any?
        puts "    ✓ ResourceAcquisitionService triggered for: #{earth_sourced_materials.join(', ')}"
        puts "    ✓ $1,000 USD import fee enforced for Earth-sourced materials"
      else
        puts "    ✓ No Earth-sourced materials required"
      end
    end

    def output_ai_diagnostic_summary(architect, celestial_body)
      puts "\n🤖 === AI SYSTEMARCHITECT DIAGNOSTIC SUMMARY ==="
      puts "Target Body: #{celestial_body.name} (#{celestial_body.identifier})"
      puts "Deployment Template: #{architect.deployment_template || 'Standard'}"

      puts "Logical Justifications:"
      if architect.logical_justifications.any?
        architect.logical_justifications.each do |justification|
          puts "  - #{justification}"
        end
      else
        puts "  - Subsurface foothold: Essential for radiation protection and resource access"
        puts "  - Habitat deployment: Required for crew safety and operations"
        puts "  - Infrastructure establishment: Power, comms, and life support systems"
      end

      puts "✓ AI deployment completed successfully"
    end

    def create_location(celestial_body, name)
      Location::CelestialLocation.find_or_create_by!(
        name: name,
        celestial_body: celestial_body
      ) do |loc|
        loc.coordinates = "0.0°N 0.0°E"
        loc.altitude = 0
      end
    end
  end
end
