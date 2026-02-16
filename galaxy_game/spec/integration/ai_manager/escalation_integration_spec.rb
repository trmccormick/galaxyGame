# spec/integration/ai_manager/escalation_integration_spec.rb
require 'rails_helper'

RSpec.describe 'AI Manager Escalation Integration', type: :integration do
  let(:settlement) { create(:base_settlement) }
  let(:celestial_body) { settlement.celestial_body }

  describe 'Expired Buy Orders Escalation System' do
    context 'with expired orders over 24 hours old' do
      let!(:expired_oxygen_order) do
        create(:market_order,
               :buy,
               base_settlement: settlement,
               resource: 'oxygen',
               quantity: 1000,
               created_at: 25.hours.ago)
      end

      let!(:expired_water_order) do
        create(:market_order,
               :buy,
               base_settlement: settlement,
               resource: 'water',
               quantity: 2000,
               created_at: 26.hours.ago)
      end

      let!(:expired_iron_order) do
        create(:market_order,
               :buy,
               base_settlement: settlement,
               resource: 'iron',
               quantity: 500,
               created_at: 30.hours.ago)
      end

      before do
        # Set up celestial body with available resources
        create_atmosphere_with_oxygen(celestial_body)
        create_hydrosphere_with_water(celestial_body)
        create_regolith_with_iron(celestial_body)
      end

      it 'triggers escalation for all expired orders' do
        expect {
          AIManager::EscalationService.handle_expired_buy_orders([expired_oxygen_order, expired_water_order, expired_iron_order])
        }.to change { enqueued_jobs_count }.by_at_least(3) # At least 3 jobs: 2 harvesters + 1 import
      end

      it 'creates special missions for critical resources (oxygen, water)' do
        expect(AIManager::EmergencyMissionService).to receive(:create_emergency_mission)
          .with(settlement, :oxygen)
        expect(AIManager::EmergencyMissionService).to receive(:create_emergency_mission)
          .with(settlement, :water)

        AIManager::EscalationService.handle_expired_buy_orders([expired_oxygen_order, expired_water_order])
      end

      it 'deploys automated harvesters for locally available materials' do
        expect {
          AIManager::EscalationService.handle_expired_buy_orders([expired_oxygen_order])
        }.to change(Units::Robot, :count).by(1)

        harvester = Units::Robot.last
        expect(harvester.name).to eq("Automated Oxygen Harvester")
        expect(harvester.settlement).to eq(settlement)
        expect(harvester.operational_data['target_material']).to eq('oxygen')
        expect(harvester.operational_data['target_quantity']).to eq(1000)
      end

      it 'schedules imports for non-critical, non-locally-available materials' do
        # Remove iron from regolith to force import
        celestial_body.update!(composition: { 'regolith' => {} })

        expect {
          AIManager::EscalationService.handle_expired_buy_orders([expired_iron_order])
        }.to change(ScheduledImport, :count).by(1)

        import = ScheduledImport.last
        expect(import.material).to eq('iron')
        expect(import.quantity).to eq(500)
        expect(import.destination_settlement).to eq(settlement)
        expect(import.status).to eq('scheduled')
      end

      it 'correctly selects escalation strategies based on material availability and criticality' do
        # Test oxygen (critical + locally available) -> special mission
        expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_oxygen_order)).to eq(:special_mission)

        # Test water (critical + locally available) -> special mission
        expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_water_order)).to eq(:special_mission)

        # Test iron (non-critical + locally available) -> automated harvesting
        expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_iron_order)).to eq(:automated_harvesting)
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

      it 'does not trigger escalation for recent orders' do
        expect(AIManager::EmergencyMissionService).not_to receive(:create_emergency_mission)
        expect {
          AIManager::EscalationService.handle_expired_buy_orders([recent_order])
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
      AIManager::EscalationService.deploy_automated_harvesters(water_order)

      harvester = Craft::Harvester.last
      expect(harvester.name).to eq("Automated Water Extractor")
      expect(harvester.operational_data['extraction_rate']).to eq(50)
      expect(harvester.operational_data['target_body']).to eq(celestial_body)
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
      # Deploy harvester
      AIManager::EscalationService.deploy_automated_harvesters(oxygen_order)
      harvester = Units::Robot.last

      # Fast-forward time to simulate completion
      travel_to(11.hours.from_now) do
        # Run the completion job
        HarvesterCompletionJob.perform_now(harvester.id, oxygen_order.id)

        # Check order fulfillment
        oxygen_order.reload
        expect(oxygen_order.status).to eq('fulfilled')

        # Check inventory addition
        settlement.reload
        expect(settlement.inventory.quantity_of('oxygen')).to eq(100)

        # Check harvester deactivation
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
      celestial_body.update!(composition: { 'regolith' => {} })
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
      # Test Earth as primary source
      import_source = AIManager::EscalationService.send(:find_best_import_source, settlement, 'iron')
      expect(import_source[:type]).to eq(:earth)
      expect(import_source[:location]).to eq('Earth')
    end

    it 'calculates transport costs correctly' do
      import_source = { type: :earth, location: 'Earth', cost_multiplier: 3.0 }
      cost = AIManager::EscalationService.send(:calculate_transport_cost, import_source, settlement, 'iron', 1000)

      # Cost should be: base_price * quantity * distance_factor * urgency_factor
      expected_base = Market::NpcPriceCalculator.calculate_ask(nil, 'iron') * 1000
      expected_cost = expected_base * 5.0 * 2.0 # Earth distance * emergency premium

      expect(cost).to be_within(1).of(expected_cost)
    end

    it 'calculates delivery times appropriately' do
      earth_source = { type: :earth, location: 'Earth' }
      depot_source = { type: :depot, location: 'Orbital Depot' }

      earth_eta = AIManager::EscalationService.send(:calculate_delivery_time, earth_source, settlement)
      depot_eta = AIManager::EscalationService.send(:calculate_delivery_time, depot_source, settlement)

      expect(earth_eta).to be_within(1.day).of(180.days.from_now) # 6 months
      expect(depot_eta).to be_within(1.day).of(7.days.from_now) # 1 week
    end
  end

  describe 'Emergency Mission Creation' do
    let(:oxygen_order) do
      create(:market_order,
             :buy,
             base_settlement: settlement,
             resource: 'oxygen',
             quantity: 500)
    end

    before do
      # Set up settlement with sufficient funds
      allow_any_instance_of(Settlement::BaseSettlement).to receive(:settlement_funds).and_return(100000)
      allow(AIManager::EmergencyMissionService).to receive(:normal_procurement_failed?).and_return(true)
    end

    it 'creates emergency missions for critical resources' do
      mission = AIManager::EscalationService.create_special_mission_for_order(oxygen_order)

      expect(mission).not_to be_nil
      expect(mission[:resource_type]).to eq(:oxygen)
      expect(mission[:settlement_id]).to eq(settlement.id)
    end

    it 'calculates appropriate emergency rewards' do
      # Test reward calculation logic
      reward = AIManager::EmergencyMissionService.send(:calculate_emergency_reward, :oxygen)

      expect(reward).to be > 0
      # Reward should be higher than normal procurement
      normal_price = Market::NpcPriceCalculator.calculate_ask(nil, 'oxygen')
      expect(reward).to be > normal_price * 100 # Assuming emergency quantity
    end

    it 'validates settlement can afford emergency rewards' do
      # Test with insufficient funds
      allow_any_instance_of(Settlement::BaseSettlement).to receive(:settlement_funds).and_return(0)

      mission = AIManager::EmergencyMissionService.create_emergency_mission(settlement, :oxygen)
      expect(mission).to be_nil
    end
  end

  describe 'End-to-End Escalation Workflow' do
    let!(:expired_orders) do
      [
        create(:market_order, :buy, base_settlement: settlement, resource: 'oxygen', quantity: 100, created_at: 25.hours.ago),
        create(:market_order, :buy, base_settlement: settlement, resource: 'water', quantity: 200, created_at: 26.hours.ago),
        create(:market_order, :buy, base_settlement: settlement, resource: 'iron', quantity: 300, created_at: 27.hours.ago),
        create(:market_order, :buy, base_settlement: settlement, resource: 'titanium', quantity: 50, created_at: 28.hours.ago)
      ]
    end

    before do
      # Set up celestial body resources
      create_atmosphere_with_oxygen(celestial_body)
      create_hydrosphere_with_water(celestial_body)
      create_regolith_with_iron(celestial_body)
      # Leave titanium unavailable to force import

      # Mock settlement funds for emergency missions
      allow_any_instance_of(Settlement::BaseSettlement).to receive(:settlement_funds).and_return(100000)
      allow(AIManager::EmergencyMissionService).to receive(:normal_procurement_failed?).and_return(true)
    end

    it 'executes complete escalation workflow' do
      expect {
        AIManager::EscalationService.handle_expired_buy_orders(expired_orders)
      }.to change(Units::Robot, :count).by(2) # oxygen + iron harvesters
        .and change(Craft::Harvester, :count).by(1) # water harvester
        .and change(ScheduledImport, :count).by(1) # titanium import

      # Verify emergency missions created for critical resources
      expect(AIManager::EmergencyMissionService).to have_received(:create_emergency_mission).with(settlement, :oxygen)
      expect(AIManager::EmergencyMissionService).to have_received(:create_emergency_mission).with(settlement, :water)

      # Verify harvesters are properly configured
      oxygen_harvester = Units::Robot.find_by(name: "Automated Oxygen Harvester")
      water_harvester = Craft::Harvester.find_by(name: "Automated Water Extractor")
      iron_harvester = Units::Robot.find_by(name: "Automated Iron Miner")

      expect(oxygen_harvester).to be_present
      expect(water_harvester).to be_present
      expect(iron_harvester).to be_present

      # Verify import scheduled for unavailable material
      titanium_import = ScheduledImport.find_by(material: 'titanium')
      expect(titanium_import).to be_present
      expect(titanium_import.quantity).to eq(50)
      expect(titanium_import.destination_settlement).to eq(settlement)
    end

    it 'handles mixed escalation strategies correctly' do
      # Verify strategy selection
      expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_orders[0])).to eq(:special_mission) # oxygen
      expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_orders[1])).to eq(:special_mission) # water
      expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_orders[2])).to eq(:automated_harvesting) # iron
      expect(AIManager::EscalationService.send(:determine_escalation_strategy, expired_orders[3])).to eq(:scheduled_import) # titanium
    end
  end

  private

  def create_atmosphere_with_oxygen(celestial_body)
    atmosphere = create(:atmosphere, celestial_body: celestial_body)
    create(:gas, atmosphere: atmosphere, name: 'O2', percentage: 21.0)
  end

  def create_hydrosphere_with_water(celestial_body)
    create(:hydrosphere, celestial_body: celestial_body, total_liquid_mass: 1000000.0)
  end

  def create_regolith_with_iron(celestial_body)
    celestial_body.update!(composition: { 'regolith' => { 'iron' => 5.2 } })
  end

  def enqueued_jobs_count
    ActiveJob::Base.queue_adapter.enqueued_jobs.size
  end
end