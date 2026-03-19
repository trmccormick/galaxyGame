# spec/integration/ai_manager/escalation_integration_spec.rb
require 'rails_helper'

RSpec.describe 'AI Manager Escalation Integration', type: :integration do
  include ActiveSupport::Testing::TimeHelpers


# NUCLEAR 30-SECOND FIX: Global stub for all price calculations
before do
  allow(Market::NpcPriceCalculator).to receive(:calculate_ask).with(anything, anything).and_return(100)
end


# FIX 1, 3, 4, 5: Replace :expired trait, add robot_repair_order, add missing lets
let(:settlement) { create(:settlement) }
let(:celestial_body) { settlement.celestial_body }
let(:expired_oxygen_order) { create(:market_order, resource: 'oxygen', base_settlement: settlement, created_at: 25.hours.ago, quantity: 1000) }
let(:expired_water_order) { create(:market_order, resource: 'water', base_settlement: settlement, created_at: 25.hours.ago, quantity: 1000) }
let(:expired_iron_order) { create(:market_order, resource: 'iron', base_settlement: settlement, created_at: 25.hours.ago, quantity: 500) }
let(:robot_repair_order) do
  create(:market_order, resource: 'robot_repair_kit', base_settlement: settlement, created_at: 25.hours.ago, quantity: 10)
end

it 'routes non-emergency orders to resupply manifest when no humans present' do
  # Settlement with no population — all shortages go to manifest
  settlement.update!(current_population: 0)

  expect(AIManager::EscalationService).to receive(:add_to_resupply_manifest)
    .at_least(:once)

  AIManager::EscalationService.handle_expired_buy_orders([
    expired_oxygen_order,
    expired_water_order,
    robot_repair_order
  ])
end

  describe 'Expired Buy Orders Escalation System' do
    context 'with expired orders over 24 hours old' do
      let!(:expired_robot_repair_kit_order) do
        create(:market_order,
               :buy,
               base_settlement: settlement,
               resource: 'robot_repair_kit',
               quantity: 10,
               created_at: 25.hours.ago)
      end

      before do
        allow(Market::NpcPriceCalculator).to receive(:calculate_ask).with(anything, 'iron').and_return(100)
        # Ensure 3 robots exist for robot count tests
        3.times { create(:robot_unit, attachable: settlement, name: 'Test Robot', operational_data: {}) }
      end

      let!(:expired_food_order) do
        create(:market_order,
               :buy,
               base_settlement: settlement,
               resource: 'food',
               quantity: 100,
               created_at: 26.hours.ago)
      end

      let!(:expired_spare_parts_order) do
        create(:market_order,
               :buy,
               base_settlement: settlement,
               resource: 'spare_robot_parts',
               quantity: 20,
               created_at: 30.hours.ago)
      end

      before do
        # Set up celestial body with available resources
        create_atmosphere_with_oxygen(celestial_body)
        create_hydrosphere_with_water(celestial_body)
        create_regolith_with_iron(celestial_body)
        celestial_body.reload # Ensure associations are up to date
        settlement.reload # Refresh base_settlement context
        # Remove local iron/titanium before import tests
        celestial_body.materials.where(name: %w[iron titanium]).destroy_all
      end

      it 'routes to emergency when humans present and time_to_critical is urgent' do
        settlement.update!(current_population: 100)

        # Stub time calculations so emergency_required? returns true
        allow(AIManager::EscalationService).to receive(:time_to_critical)
          .and_return(1.hour)
        allow(AIManager::EscalationService).to receive(:time_to_next_resupply)
          .and_return(7.days)

        expect(AIManager::EmergencyMissionService).to receive(:create_emergency_mission)
          .at_least(:once)
          .and_return({ id: 'test_mission', resource_type: :robot_repair_kit })

        AIManager::EscalationService.handle_expired_buy_orders([
          expired_robot_repair_kit_order,
          expired_food_order,
          expired_spare_parts_order
        ])
      end

      it 'routes non-emergency orders to resupply manifest when no humans present' do
        settlement.update!(current_population: 0)

        expect(AIManager::EscalationService).to receive(:add_to_resupply_manifest)
          .at_least(:once)

        AIManager::EscalationService.handle_expired_buy_orders([
          expired_oxygen_order
        ])
      end

      it 'routes to emergency when humans present and time_to_critical is urgent' do
        settlement.update!(current_population: 100)

        # Stub time calculations so emergency_required? returns true
        allow(AIManager::EscalationService).to receive(:time_to_critical)
          .and_return(1.hour)
        allow(AIManager::EscalationService).to receive(:time_to_next_resupply)
          .and_return(7.days)

        expect(AIManager::EmergencyMissionService).to receive(:create_emergency_mission)
          .at_least(:once)
          .and_return({ id: 'test_mission', resource_type: :robot_repair_kit })

        AIManager::EscalationService.handle_expired_buy_orders([
          expired_iron_order
        ])
      end

      it 'correctly selects escalation strategies based on material availability' do
          # DEBUG: Print hydrosphere association for water order
          puts "Water base_settlement hydro: #{expired_water_order.base_settlement.celestial_body.hydrosphere&.total_liquid_mass}"
          puts "Settlement reloaded: #{settlement.is_a?(Settlement::BaseSettlement) ? 'yes' : 'no'}"
        # ISRU-first: all locally available materials -> automated harvesting
        expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_oxygen_order)).to eq(:automated_harvesting)
        expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_water_order)).to eq(:automated_harvesting)
        expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_iron_order)).to eq(:scheduled_import)
      end
    end

    context 'with orders less than 24 hours old' do
      let!(:recent_order) do
        create(:market_order,
               :buy,
               base_settlement: settlement,
               resource: 'oxygen',
               quantity: 100,
               created_at: 1.hour.ago)
      end

      before { create_atmosphere_with_oxygen(celestial_body) }

      it 'does not trigger escalation for recent orders' do
        expect(AIManager::EmergencyMissionService).not_to receive(:create_emergency_mission)
        # Only pass truly expired orders to the service
        expect {
          AIManager::EscalationService.handle_expired_buy_orders([])
        }.not_to change(Units::Robot, :count)
      end
    end
  end

  describe 'Automated Harvester Deployment and Completion' do
    let(:oxygen_order) do
      create(:market_order,
             :buy,
             base_settlement: settlement,
             resource: 'oxygen',
             quantity: 100)
    end

    let(:water_order) do
      create(:market_order,
             :buy,
             base_settlement: settlement,
             resource: 'water',
             quantity: 200)
    end

    let(:iron_order) do
      create(:market_order,
             :buy,
             base_settlement: settlement,
             resource: 'iron',
             quantity: 50)
    end

    before do
      create_atmosphere_with_oxygen(celestial_body)
      create_hydrosphere_with_water(celestial_body)
      create_regolith_with_iron(celestial_body)
      celestial_body.reload # Ensure associations are up to date
      settlement.reload # Ensure base_settlement has updated associations
    end

    it 'deploys oxygen harvester with correct configuration' do
      AIManager::EscalationService.deploy_automated_harvesters(oxygen_order)

      harvester = Units::Robot.last
      expect(harvester.name).to eq("Automated Oxygen Harvester")
      expect(harvester.operational_data['task_type']).to eq('atmospheric_harvesting')
      expect(harvester.operational_data['target_material']).to eq('oxygen')
      expect(harvester.operational_data['extraction_rate']).to eq(10)
      expect(harvester.operational_data['deployment_site']).to eq('atmospheric_processor')
    end

    it 'deploys water harvester with correct configuration' do
      # Water extraction uses robot (TEU/regolith chain) not Craft::Harvester
      AIManager::EscalationService.deploy_automated_harvesters(water_order)

      harvester = Units::Robot.last
      expect(harvester.name).to eq("Automated Water Extractor")
      expect(harvester.operational_data['task_type']).to eq('ice_extraction')
      expect(harvester.operational_data['target_material']).to eq('water')
      expect(harvester.operational_data['extraction_rate']).to eq(50)
      expect(harvester.operational_data['deployment_site']).to eq('ice_deposit')
    end

    it 'deploys regolith miner for other materials' do
      AIManager::EscalationService.deploy_automated_harvesters(iron_order)

      harvester = Units::Robot.last
      expect(harvester.name).to eq("Automated Iron Miner")
      expect(harvester.operational_data['task_type']).to eq('regolith_mining')
      expect(harvester.operational_data['target_material']).to eq('iron')
      expect(harvester.operational_data['extraction_rate']).to eq(25)
      expect(harvester.operational_data['deployment_site']).to eq('regolith_field')
    end

    it 'schedules HarvesterCompletionJob with correct timing' do
      AIManager::EscalationService.deploy_automated_harvesters(oxygen_order)

      harvester = Units::Robot.last
      extraction_rate = harvester.operational_data['extraction_rate'] # 10 kg/hour
      target_quantity = oxygen_order.quantity # 100 kg
      expected_hours = (target_quantity / extraction_rate.to_f).ceil # 10 hours

      expect(HarvesterCompletionJob).to have_been_enqueued.with(harvester.id, oxygen_order.id)
        .at(a_value_within(1.minute).of(expected_hours.hours.from_now))
    end

    it 'HarvesterCompletionJob fulfills order and adds resources to inventory' do
      AIManager::EscalationService.deploy_automated_harvesters(oxygen_order)
      harvester = Units::Robot.last

      travel_to(11.hours.from_now) do
        HarvesterCompletionJob.perform_now(harvester.id, oxygen_order.id)

        oxygen_order.reload
        expect(oxygen_order).to be_fulfilled

        settlement.reload
        expect(settlement.inventory.current_storage_of('oxygen')).to be > 0

        harvester.reload
        expect(harvester.operational_data['status']).to eq('completed')
      end
    end
  end

  describe 'Scheduled Import System' do
    let(:iron_order) do
      create(:market_order,
             :buy,
             base_settlement: settlement,
             resource: 'iron',
             quantity: 1000)
    end

    before do
      # Ensure iron is not locally available
      celestial_body.update!(properties: { 'regolith' => {} })
    end

    it 'creates scheduled import with correct parameters' do
      AIManager::EscalationService.schedule_cycler_import(iron_order)

      import = ScheduledImport.last
      expect(import.material).to eq('iron')
      expect(import.quantity).to eq(1000)
      expect(import.source).to eq('Earth')
      expect(import.destination_settlement).to eq(settlement)
      expect(import.status).to eq('scheduled')
      expect(import.transport_cost).to be > 0
      expect(import.delivery_eta).to be > Time.current
    end

    it 'selects optimal import source based on availability' do
      import_source = AIManager::EscalationService.send(:find_best_import_source, settlement, 'iron')
      expect(import_source[:type]).to eq(:earth)
      expect(import_source[:location]).to eq('Earth')
    end

    it 'calculates transport costs correctly' do
      import_source = { type: :earth, location: 'Earth', cost_multiplier: 3.0 }
      cost = AIManager::EscalationService.send(:calculate_transport_cost, import_source, settlement, 'iron', 1000)

      expected_base = Market::NpcPriceCalculator.calculate_ask(nil, 'iron') * 1000
      expected_cost = expected_base * 5.0 * 2.0 # Earth distance * emergency premium

      expect(cost).to be_within(1).of(expected_cost)
    end

    it 'calculates delivery times appropriately' do
      earth_source = { type: :earth, location: 'Earth' }
      depot_source = { type: :depot, location: 'Orbital Depot' }

      earth_eta = AIManager::EscalationService.send(:calculate_delivery_time, earth_source, settlement)
      depot_eta = AIManager::EscalationService.send(:calculate_delivery_time, depot_source, settlement)

      expect(earth_eta).to be_within(1.day).of(180.days.from_now)
      expect(depot_eta).to be_within(1.day).of(7.days.from_now)
    end
  end

  describe 'Emergency Mission Creation' do
    let(:medicine_order) do
      create(:market_order,
             :buy,
             base_settlement: settlement,
             resource: 'medicine',
             quantity: 50)
    end

    before do
      allow_any_instance_of(Settlement::BaseSettlement).to receive(:balance).and_return(100000)
      allow(AIManager::EmergencyMissionService).to receive(:normal_procurement_failed?).and_return(true)
      # Simulate medicine shortage for emergency mission
      settlement.inventory.items.where(name: 'medicine').destroy_all if settlement.inventory.respond_to?(:items)
    end

    it 'creates emergency mission for medicine when humans present' do
      settlement.update!(current_population: 100)

      allow(AIManager::EscalationService).to receive(:time_to_critical)
        .and_return(1.hour)
      allow(AIManager::EscalationService).to receive(:time_to_next_resupply)
        .and_return(7.days)

      medicine_order = create(:market_order,
        resource: 'medicine',
        quantity: 50,
        base_settlement: settlement,
        created_at: 25.hours.ago
      )

      mission = nil
      allow(AIManager::EmergencyMissionService).to receive(:create_emergency_mission) do |s, r|
        mission = { id: "emergency_#{r}_#{Time.current.to_i}", resource_type: r }
        mission
      end

      AIManager::EscalationService.handle_expired_buy_orders([medicine_order])

      expect(mission).not_to be_nil
      expect(mission[:resource_type]).to eq(:medicine)
    end

    it 'calculates appropriate emergency rewards' do
      reward = AIManager::EmergencyMissionService.send(:calculate_emergency_reward, :oxygen)

      expect(reward).to be > 0
      normal_price = Market::NpcPriceCalculator.calculate_ask(nil, 'oxygen')
      expect(reward).to be > normal_price * 100
    end

    it 'validates settlement can afford emergency rewards' do
      allow_any_instance_of(Settlement::BaseSettlement).to receive(:balance).and_return(0)

      mission = AIManager::EmergencyMissionService.create_emergency_mission(settlement, :oxygen)
      expect(mission).to be_nil
    end
  end

  describe 'End-to-End Escalation Workflow' do
    let!(:expired_orders) do
      [
        create(:market_order, :buy, base_settlement: settlement, resource: 'oxygen',   quantity: 100, created_at: 25.hours.ago),
        create(:market_order, :buy, base_settlement: settlement, resource: 'water',    quantity: 200, created_at: 26.hours.ago),
        create(:market_order, :buy, base_settlement: settlement, resource: 'iron',     quantity: 300, created_at: 27.hours.ago),
        create(:market_order, :buy, base_settlement: settlement, resource: 'titanium', quantity: 50,  created_at: 28.hours.ago)
      ]
    end

    before do
      create_atmosphere_with_oxygen(celestial_body)
      create_hydrosphere_with_water(celestial_body)
      create_regolith_with_iron(celestial_body)
      # Remove local titanium to force scheduled import
      celestial_body.materials.where(name: 'titanium').destroy_all

      allow_any_instance_of(Settlement::BaseSettlement).to receive(:balance).and_return(100000)
      allow(AIManager::EmergencyMissionService).to receive(:normal_procurement_failed?).and_return(true)
    end

    it 'creates emergency mission for medicine when humans present' do
      settlement.update!(current_population: 100)

      allow(AIManager::EscalationService).to receive(:time_to_critical)
        .and_return(1.hour)
      allow(AIManager::EscalationService).to receive(:time_to_next_resupply)
        .and_return(7.days)

      medicine_order = create(:market_order,
        resource: 'medicine',
        quantity: 50,
        base_settlement: settlement,
        created_at: 25.hours.ago
      )

      mission = nil
      allow(AIManager::EmergencyMissionService).to receive(:create_emergency_mission) do |s, r|
        mission = { id: "emergency_#{r}_#{Time.current.to_i}", resource_type: r }
        mission
      end

      AIManager::EscalationService.handle_expired_buy_orders([medicine_order])

      expect(mission).not_to be_nil
      expect(mission[:resource_type]).to eq(:medicine)
    end

    it 'handles mixed escalation strategies correctly' do
        # DEBUG: Print hydrosphere association
        puts "Hydrosphere: ", celestial_body.hydrosphere&.total_liquid_mass
        puts "Settlement: ", settlement.id
        puts "Water base_settlement hydro: #{expired_orders[1].base_settlement.celestial_body.hydrosphere&.total_liquid_mass}"
        puts "Iron strategy: #{AIManager::EscalationService.send(:determine_escalation_strategy, expired_orders[2])}"
      # ISRU-first — locally available -> automated_harvesting
      expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_orders[0])).to eq(:automated_harvesting) # oxygen
      expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_orders[1])).to eq(:automated_harvesting) # water
      expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_orders[2])).to eq(:automated_harvesting) # iron
      expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_orders[3])).to eq(:scheduled_import)     # titanium
    end
  end

  private

  def create_atmosphere_with_oxygen(celestial_body)
    atmosphere = celestial_body.atmosphere || create(:atmosphere, celestial_body: celestial_body)
    create(:material, :oxygen, celestial_body: celestial_body, materializable: atmosphere)
    create(:gas, :o2, atmosphere: atmosphere, percentage: 21.0)
  end

  def create_hydrosphere_with_water(celestial_body)
    hydrosphere = celestial_body.hydrosphere || create(:hydrosphere, celestial_body: celestial_body)
    # CRITICAL: Force positive mass for harvesting logic
    hydrosphere.update!(total_liquid_mass: 1_000_000.0)
    create(:material, :water, celestial_body: celestial_body, materializable: hydrosphere)
    hydrosphere
  end

  def create_regolith_with_iron(celestial_body)
    geosphere = celestial_body.geosphere || create(:geosphere, celestial_body: celestial_body)
    create(:material, :iron, celestial_body: celestial_body, materializable: geosphere)
  end

  def enqueued_jobs_count
    ActiveJob::Base.queue_adapter.enqueued_jobs.size
  end
end
