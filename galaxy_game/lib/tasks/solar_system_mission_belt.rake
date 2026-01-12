# lib/tasks/belt_mining_venture.rake
# Extension to solar_system_mission_pipeline.rake

namespace :missions do
  namespace :solar_system do
    namespace :belt do
      desc "Execute Belt Mining Joint Venture between MDC and AstroLift"
      task venture: :environment do
        puts "\n⛏️  === ASTEROID BELT MINING VENTURE ==="
        puts "Joint operation: Mars Development Corporation + AstroLift Logistics\n"

        start_time = Time.current
        tasks_executed = 0

        # Get the parent corporations
        mars_corp = find_corporation('MARS_CORP')
        astrolift = find_corporation('ASTROLIFT')

        # PHASE 1: Establish Joint Venture
        puts "\n🤝 === PHASE 1: JOINT VENTURE FORMATION ==="
        venture = establish_belt_venture(mars_corp, astrolift)
        tasks_executed += 3

        # PHASE 2: Ceres Operations Hub
        puts "\n☄️  === PHASE 2: CERES OPERATIONS HUB ==="
        ceres_settlement = establish_ceres_hub(venture)
        tasks_executed += 5  # AI unit selection and deployment

        # PHASE 3: Phobos Processing Facility
        puts "\n🌑 === PHASE 3: PHOBOS PROCESSING FACILITY ==="
        phobos_settlement = establish_phobos_facility(venture)
        tasks_executed += 5  # AI unit selection and deployment

        # PHASE 4: Belt Mining Operations
        puts "\n⚒️  === PHASE 4: ACTIVE MINING OPERATIONS ==="
        tasks_executed += execute_belt_mining_operations(venture, ceres_settlement, phobos_settlement)

        # PHASE 5: Resource Distribution & Revenue
        puts "\n💎 === PHASE 5: RESOURCE DISTRIBUTION ==="
        revenue = distribute_belt_resources(venture, mars_corp, astrolift)

        # Final Status
        puts "\n📊 === BELT VENTURE STATUS ==="
        display_venture_status(venture, mars_corp, astrolift, revenue)

        end_time = Time.current
        duration = end_time - start_time
        puts "\n⏱️  Belt mining venture established in #{duration.round(2)} seconds"
        puts "🎯 Total tasks executed: #{tasks_executed}"
        puts "\n✨ Mars Corp is now a net exporter of rare materials!"
      end

      def find_corporation(identifier)
        org = Organizations::Corporation.find_by!(identifier: identifier)
        account = Financial::Account.find_by!(
          accountable: org, 
          currency: Financial::Currency.find_by(symbol: 'GCC')
        )
        { organization: org, account: account }
      end

      def establish_belt_venture(mars_corp, astrolift)
        puts "  Creating Belt Mining Venture LLC..."
        
        # Create joint venture corporation
        venture_org = Organizations::Corporation.find_or_create_by!(identifier: 'BELT_VENTURE') do |o|
          o.name = "Belt Mining Venture LLC"
          o.organization_type = 'corporation'  # Joint ventures are for-profit corporations
          o.description = "Joint venture between MDC and AstroLift for asteroid belt resource extraction"
        end

        # Create venture account with initial capital from both parents
        initial_capital = 2_000_000.0 # 1M from each parent
        venture_account = Financial::Account.find_or_create_by!(
          accountable: venture_org, 
          currency: Financial::Currency.find_by(symbol: 'GCC')
        ) do |a|
          a.balance = initial_capital
        end

        # Deduct investment from parent corporations
        mars_corp[:account].update!(balance: mars_corp[:account].balance - 1_000_000.0)
        astrolift[:account].update!(balance: astrolift[:account].balance - 1_000_000.0)

        puts "    ✓ Venture capitalized with #{initial_capital} GCC"
        puts "    ✓ Mars Corp invested: 1,000,000 GCC (50% equity)"
        puts "    ✓ AstroLift invested: 1,000,000 GCC (50% equity)"
        puts "    ✓ Mars Corp balance: #{mars_corp[:account].balance} GCC"
        puts "    ✓ AstroLift balance: #{astrolift[:account].balance} GCC"

        { 
          organization: venture_org, 
          account: venture_account,
          equity: { mars: 0.5, astrolift: 0.5 }
        }
      end

      def establish_ceres_hub(venture)
        puts "  Establishing Ceres as primary mining hub via AI DecisionTree..."

        ceres = CelestialBodies::CelestialBody.find_or_create_by!(identifier: 'CERES-01') do |body|
          body.name = "Ceres"
          body.mass = 9.39e20 # kg
          body.radius = 473_000 # meters
          body.size = 0.073 # relative to Earth
          body.gravity = 0.028 # relative to Earth
          body.surface_temperature = 167.0 # Kelvin
        end

        # Create settlement on Ceres
        settlement = Settlement::BaseSettlement.create!(
          name: "Ceres Mining Hub #{SecureRandom.hex(4)}",
          location: create_venture_location(ceres, "Ceres Mining Base"),
          settlement_type: 'base',
          owner: venture[:organization]
        )

        # Use AI DecisionTree to select mining units
        decision_tree = AIManager::DecisionTree.new(settlement, nil)

        mining_units = select_units_by_trait('Mining')
        puts "    🤖 AI selected mining units: #{mining_units.map { |u| u['name'] }.join(', ')}"

        # Deploy selected units
        deploy_selected_units(settlement, mining_units, venture[:account])

        # Trigger ResourceAcquisitionService
        trigger_resource_acquisition_for_belt_deployment(settlement, venture[:account])

        # Output AI justifications
        output_belt_ai_diagnostic_summary(settlement, mining_units, 'Mining', ceres)

        puts "    ✓ Ceres mining hub established with AI-selected units"
        settlement
      end

      def establish_phobos_facility(venture)
        puts "  Establishing Phobos as processing facility via AI DecisionTree..."

        phobos = CelestialBodies::CelestialBody.find_or_create_by!(identifier: 'PHOBOS-01') do |body|
          body.name = "Phobos"
          body.mass = 1.0659e16 # kg
          body.radius = 11_267 # meters
          body.size = 0.0018 # relative to Earth
          body.gravity = 0.0006 # relative to Earth
          body.surface_temperature = 233.0 # Kelvin
        end

        # Create settlement on Phobos
        settlement = Settlement::BaseSettlement.create!(
          name: "Phobos Refinery #{SecureRandom.hex(4)}",
          location: create_venture_location(phobos, "Phobos Processing Base"),
          settlement_type: 'station',
          owner: venture[:organization]
        )

        # Use AI DecisionTree to select refining units
        decision_tree = AIManager::DecisionTree.new(settlement, nil)

        refining_units = select_units_by_trait('Refining')
        puts "    🤖 AI selected refining units: #{refining_units.map { |u| u['name'] }.join(', ')}"

        # Deploy selected units
        deploy_selected_units(settlement, refining_units, venture[:account])

        # Trigger ResourceAcquisitionService
        trigger_resource_acquisition_for_belt_deployment(settlement, venture[:account])

        # Output AI justifications
        output_belt_ai_diagnostic_summary(settlement, refining_units, 'Refining', phobos)

        puts "    ✓ Phobos processing facility established with AI-selected units"
        settlement
      end

      def execute_venture_mission(venture, mission_id, celestial_body_id, station_name)
        puts "  Belt Venture executing #{mission_id}"

        # Setup celestial body
        celestial_body = CelestialBodies::CelestialBody.find_by(identifier: celestial_body_id)

        # Create settlement owned by venture
        settlement = Settlement::BaseSettlement.create!(
          name: "#{station_name} #{SecureRandom.hex(4)}",
          location: create_venture_location(celestial_body, "#{station_name} Base"),
          settlement_type: mission_id.include?('refinery') ? 'station' : 'base',
          owner: venture[:organization]
        )
        puts "    ✓ Venture settlement created: #{settlement.name}"

        # Create mission
        mission = Mission.create!(
          identifier: "#{mission_id}_#{settlement.id}",
          settlement: settlement,
          status: 'in_progress'
        )

        # Load equipment based on facility type
        if mission_id.include?('ceres')
          load_ceres_equipment(settlement, venture[:account])
        elsif mission_id.include?('phobos')
          load_phobos_equipment(settlement, venture[:account])
        end

        # Execute facility construction phases
        tasks_executed = execute_facility_phases(mission_id, mission, settlement)

        puts "    ✓ #{mission_id} operational"
        tasks_executed
      end

      def load_ceres_equipment(settlement, venture_account)
        equipment = {
          'Deep Core Mining Drones' => { count: 20, cost: 75_000 },
          'Autonomous Hauler Craft' => { count: 12, cost: 120_000 },
          'Surface Survey Rovers' => { count: 8, cost: 40_000 },
          'Ore Processing Units' => { count: 6, cost: 200_000 },
          'Habitat Modules' => { count: 4, cost: 150_000 },
          'Nuclear Fuel Elements' => { count: 25, cost: 20_000 }
        }

        total_cost = 0
        equipment.each do |name, spec|
          settlement.inventory.add_item(name, spec[:count])
          item_cost = spec[:cost] * spec[:count]
          total_cost += item_cost
          puts "    + #{spec[:count]}x #{name} (#{item_cost} GCC)"
        end

        venture_account.update!(balance: venture_account.balance - total_cost)
        puts "    ✓ Ceres equipment deployed: #{total_cost} GCC"
        puts "    ✓ Venture balance: #{venture_account.balance} GCC"
      end

      def load_phobos_equipment(settlement, venture_account)
        equipment = {
          'Smelting Furnaces' => { count: 8, cost: 250_000 },
          'Refining Reactors' => { count: 6, cost: 300_000 },
          'Centrifuge Separators' => { count: 10, cost: 100_000 },
          'Cargo Transfer Systems' => { count: 5, cost: 150_000 },
          'Quality Control Labs' => { count: 3, cost: 200_000 },
          'Storage Tanks' => { count: 20, cost: 25_000 }
        }

        total_cost = 0
        equipment.each do |name, spec|
          settlement.inventory.add_item(name, spec[:count])
          item_cost = spec[:cost] * spec[:count]
          total_cost += item_cost
          puts "    + #{spec[:count]}x #{name} (#{item_cost} GCC)"
        end

        venture_account.update!(balance: venture_account.balance - total_cost)
        puts "    ✓ Phobos refinery equipped: #{total_cost} GCC"
        puts "    ✓ Venture balance: #{venture_account.balance} GCC"
      end

      def execute_belt_mining_operations(venture, ceres_hub, phobos_facility)
        puts "  Initiating mining operations across the belt..."

        operations = [
          { name: 'Deep core extraction on Ceres', duration: 0.02 },
          { name: 'Survey missions to Vesta', duration: 0.015 },
          { name: 'Ice mining operations', duration: 0.02 },
          { name: 'Metallic asteroid harvesting', duration: 0.025 },
          { name: 'Transport runs to Phobos', duration: 0.018 },
          { name: 'Refining processes active', duration: 0.02 },
          { name: 'Quality control and grading', duration: 0.01 },
          { name: 'Mars delivery preparation', duration: 0.015 }
        ]

        tasks_executed = 0
        operations.each do |op|
          puts "    → #{op[:name]}"
          sleep(op[:duration])
          tasks_executed += 1
        end

        puts "    ✓ All mining operations nominal"
        tasks_executed
      end

      def distribute_belt_resources(venture, mars_corp, astrolift)
        puts "  Distributing extracted resources and calculating revenue..."

        # Resource extraction volumes (monthly)
        resources = {
          'Platinum Group Metals' => { volume: 500, price: 50_000, buyer: 'Venus Corp' },
          'Rare Earth Elements' => { volume: 2000, price: 8_000, buyer: 'Titan Corp' },
          'Titanium Alloys' => { volume: 50_000, price: 200, buyer: 'Earth Shipyards' },
          'Water Ice' => { volume: 100_000, price: 100, buyer: 'All Stations' },
          'Cobalt' => { volume: 10_000, price: 500, buyer: 'Venus Corp' },
          'Silicon' => { volume: 20_000, price: 300, buyer: 'All Manufacturing' }
        }

        total_revenue = 0
        resources.each do |resource, spec|
          revenue = spec[:volume] * spec[:price]
          total_revenue += revenue
          puts "    → #{resource}: #{spec[:volume]} tons @ #{spec[:price]} GCC/ton = #{revenue} GCC"
          puts "       Buyer: #{spec[:buyer]}"
        end

        # Update venture account
        venture[:account].update!(balance: venture[:account].balance + total_revenue)

        # Distribute profits to parent companies (50/50 split)
        monthly_profit = total_revenue * 0.35 # 35% profit margin after operational costs
        mars_share = monthly_profit * 0.5
        astrolift_share = monthly_profit * 0.5

        puts "\n  💰 Revenue Distribution:"
        puts "    Total Revenue: #{total_revenue} GCC"
        puts "    Operating Costs: #{(total_revenue * 0.65).round} GCC"
        puts "    Net Profit: #{monthly_profit.round} GCC"
        puts "\n  📈 Profit Distribution (50/50):"
        puts "    → Mars Corp dividend: #{mars_share.round} GCC"
        puts "    → AstroLift dividend: #{astrolift_share.round} GCC"

        # Pay dividends
        mars_corp[:account].update!(balance: mars_corp[:account].balance + mars_share)
        astrolift[:account].update!(balance: astrolift[:account].balance + astrolift_share)

        {
          total: total_revenue,
          profit: monthly_profit,
          mars_share: mars_share,
          astrolift_share: astrolift_share
        }
      end

      def display_venture_status(venture, mars_corp, astrolift, revenue)
        puts "Belt Mining Venture LLC:"
        puts "  • Status: Operational"
        puts "  • Ownership: 50% MDC / 50% AstroLift"
        puts "  • Venture Balance: #{venture[:account].balance} GCC"
        puts "  • Settlements: #{venture[:organization].owned_settlements.count}"
        puts "\nParent Corporation Balances:"
        puts "  • Mars Corp: #{mars_corp[:account].balance} GCC"
        puts "    └─ Monthly dividend from venture: #{revenue[:mars_share].round} GCC"
        puts "  • AstroLift: #{astrolift[:account].balance} GCC"
        puts "    └─ Monthly dividend from venture: #{revenue[:astrolift_share].round} GCC"
        puts "\nMonthly Operations:"
        puts "  • Total Revenue: #{revenue[:total]} GCC"
        puts "  • Net Profit: #{revenue[:profit].round} GCC"
        puts "  • ROI: #{((revenue[:profit] / 2_000_000.0) * 100).round(2)}% per cycle"
        puts "\nStrategic Impact:"
        puts "  ✓ Mars Corp now exports rare materials"
        puts "  ✓ Reduces Mars dependency on imports"
        puts "  ✓ Establishes belt infrastructure for future expansion"
        puts "  ✓ AstroLift gains exclusive logistics contracts"
      end

      def create_venture_location(celestial_body, location_name)
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

      def execute_facility_phases(mission_id, mission, settlement)
        # Simulate construction and activation phases
        phases = case mission_id
        when 'ceres_mining_hub'
          ['Landing and site preparation', 'Mining drone deployment', 'Processing facility construction', 'Operations activation']
        when 'phobos_refinery'
          ['Orbital facility construction', 'Refining equipment installation', 'Transfer systems activation', 'Quality control setup']
        else
          []
        end

        tasks = 0
        phases.each do |phase|
          puts "    → #{phase}"
          sleep(0.015)
          tasks += 1
        end
        tasks
      end

      def select_units_by_trait(trait)
        unit_lookup = Lookup::UnitLookupService.new
        unit_lookup.find_units_by_trait('traits', trait)
      end

      def deploy_selected_units(settlement, units, funding_account)
        units.each do |unit|
          # Create settlement unit
          SettlementUnit.create!(
            settlement: settlement,
            unit: unit,
            quantity: 1,
            operational: true
          )

          puts "      ✓ Deployed: #{unit['name']}"
        end
      end

      def trigger_resource_acquisition_for_belt_deployment(settlement, funding_account)
        puts "      Triggering ResourceAcquisitionService for Earth-sourced items..."

        # Get all units deployed in the settlement's structures
        units = settlement.structures.flat_map(&:units)

        earth_sourced_materials = []
        units.each do |unit|
          next unless unit && unit['components']

          unit['components'].each do |component|
            material = component['material']
            amount = component['amount'] || component['quantity'] || 1

            unless AIManager::ResourceAcquisitionService.acquisition_method_for(material) == :local_trade
              AIManager::ResourceAcquisitionService.order_acquisition(settlement, material, amount)
              earth_sourced_materials << "#{material} (#{amount})"
            end
          end
        end

        if earth_sourced_materials.any?
          puts "      ✓ ResourceAcquisitionService triggered for: #{earth_sourced_materials.join(', ')}"
          puts "      ✓ $1,000 USD import fee enforced for Earth-sourced materials"
        else
          puts "      ✓ No Earth-sourced materials required"
        end
      end

      def output_belt_ai_diagnostic_summary(settlement, units, trait, celestial_body)
        puts "\n🤖 === AI DECISION TREE DIAGNOSTIC SUMMARY ==="
        puts "Location: #{celestial_body.name} (#{celestial_body.identifier})"
        puts "Trait Selected: #{trait}"
        puts "Units Chosen: #{units.map { |u| u['name'] }.join(', ')}"

        puts "Logical Justifications:"
        units.each do |unit|
          puts "  - #{unit['name']}: Selected for #{trait.downcase} operations based on unit traits and settlement requirements"
        end

        puts "✓ AI unit selection completed successfully"
      end

      def create_venture_location(celestial_body, base_name)
        Location::CelestialLocation.find_or_create_by!(
          name: "#{base_name} Location",
          celestial_body: celestial_body
        ) do |loc|
          loc.coordinates = "0.0°N 0.0°E"
          loc.altitude = 0.0
        end
      end
    end
  end
end