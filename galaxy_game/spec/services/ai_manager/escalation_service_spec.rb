# spec/services/ai_manager/escalation_service_spec.rb
require 'rails_helper'

RSpec.describe AIManager::EscalationService, type: :service do
  let(:settlement) { create(:settlement) }
  let(:expired_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'oxygen', quantity: 1000) }

  describe '.handle_expired_buy_orders' do
    context 'with expired orders' do
      let(:expired_orders) { [expired_order] }

      it 'processes each expired order' do
        expect(described_class).to receive(:determine_escalation_strategy).with(expired_order).and_return(:special_mission)
        expect(described_class).to receive(:create_special_mission_for_order).with(expired_order)

        described_class.handle_expired_buy_orders(expired_orders)
      end

      it 'handles multiple escalation strategies' do
        order1 = create(:market_order, :buy, base_settlement: settlement, resource: 'oxygen')
        order2 = create(:market_order, :buy, base_settlement: settlement, resource: 'water')
        orders = [order1, order2]

        expect(described_class).to receive(:determine_escalation_strategy).with(order1).and_return(:special_mission)
        expect(described_class).to receive(:determine_escalation_strategy).with(order2).and_return(:automated_harvesting)
        expect(described_class).to receive(:create_special_mission_for_order).with(order1)
        expect(described_class).to receive(:deploy_automated_harvesters).with(order2)

        described_class.handle_expired_buy_orders(orders)
      end
    end

    context 'with empty orders array' do
      it 'handles empty array gracefully' do
        expect { described_class.handle_expired_buy_orders([]) }.not_to raise_error
      end
    end
  end

  describe '.create_special_mission_for_order' do
    let(:order) { expired_order }

    it 'calls EmergencyMissionService with correct parameters' do
      expect(AIManager::EmergencyMissionService).to receive(:create_emergency_mission)
        .with(settlement, :oxygen)

      described_class.create_special_mission_for_order(order)
    end

    it 'converts resource string to symbol' do
      order_with_string_resource = create(:market_order, :buy, base_settlement: settlement, resource: 'water')
      expect(AIManager::EmergencyMissionService).to receive(:create_emergency_mission)
        .with(settlement, :water)

      described_class.create_special_mission_for_order(order_with_string_resource)
    end
  end

  describe '.deploy_automated_harvesters' do
    let(:order) { create(:market_order, :buy, base_settlement: settlement, resource: 'oxygen', quantity: 100) }

    it 'creates automated harvester unit' do
      expect(described_class).to receive(:create_automated_harvester)
        .with(settlement, 'oxygen', 100)
        .and_return(double('harvester'))

      expect(described_class).to receive(:deploy_harvester_to_site)
      expect(described_class).to receive(:schedule_harvester_completion)

      described_class.deploy_automated_harvesters(order)
    end
  end

  describe '.create_automated_harvester' do
    context 'oxygen harvesting' do
      it 'creates robot unit for oxygen' do
        expect(Units::Robot).to receive(:create!).with(
          name: "Automated Oxygen Harvester",
          settlement: settlement,
          operational_data: {
            'task_type' => 'atmospheric_harvesting',
            'target_material' => 'oxygen',
            'target_quantity' => 100,
            'extraction_rate' => 10,
            'mobility_type' => 'stationary'
          }
        )

        described_class.create_automated_harvester(settlement, 'oxygen', 100)
      end
    end

    context 'water harvesting' do
      it 'creates harvester craft for water' do
        expect(Craft::Harvester).to receive(:create!).with(
          name: "Automated Water Extractor",
          settlement: settlement,
          operational_data: {
            'extraction_rate' => 50,
            'target_body' => settlement.celestial_body
          }
        )

        described_class.create_automated_harvester(settlement, 'water', 200)
      end
    end
  end

  describe '.schedule_cycler_import' do
    let(:order) { create(:market_order, :buy, base_settlement: settlement, resource: 'iron', quantity: 500) }

    it 'creates a scheduled import record' do
      import_source = { type: :earth, location: 'Earth', cost_multiplier: 3.0 }
      transport_cost = 1500.0
      delivery_eta = 30.days.from_now

      expect(described_class).to receive(:find_best_import_source).and_return(import_source)
      expect(described_class).to receive(:calculate_transport_cost).and_return(transport_cost)
      expect(described_class).to receive(:calculate_delivery_time).and_return(delivery_eta)
      expect(described_class).to receive(:schedule_import_delivery).with(
        material: 'iron',
        quantity: 500,
        source: import_source,
        destination: settlement,
        transport_cost: transport_cost,
        delivery_eta: delivery_eta
      )

      described_class.schedule_cycler_import(order)
    end
  end

  describe '.schedule_import_delivery' do
    let(:source) { { type: :earth, location: 'Earth' } }
    let(:destination) { settlement }
    let(:delivery_eta) { 30.days.from_now }

    it 'creates a ScheduledImport record' do
      expect {
        described_class.schedule_import_delivery(
          material: 'iron',
          quantity: 500,
          source: source,
          destination: destination,
          transport_cost: 1500.0,
          delivery_eta: delivery_eta
        )
      }.to change(ScheduledImport, :count).by(1)

      import = ScheduledImport.last
      expect(import.material).to eq('iron')
      expect(import.quantity).to eq(500)
      expect(import.source).to eq('Earth')
      expect(import.destination_settlement_id).to eq(settlement.id)
      expect(import.transport_cost).to eq(1500.0)
      expect(import.delivery_eta).to be_within(1.second).of(delivery_eta)
      expect(import.status).to eq('scheduled')
    end
  end

  describe '.determine_escalation_strategy' do
    let(:celestial_body) { settlement.celestial_body }

    context 'with critical resources' do
      let(:oxygen_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'oxygen') }
      let(:water_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'water') }
      let(:nitrogen_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'nitrogen') }

      before do
        create(:atmosphere, celestial_body: celestial_body)
      end

      it 'returns :special_mission for oxygen' do
        expect(described_class.send(:determine_escalation_strategy, oxygen_order)).to eq(:special_mission)
      end

      it 'returns :special_mission for water' do
        expect(described_class.send(:determine_escalation_strategy, water_order)).to eq(:special_mission)
      end

      it 'returns :special_mission for nitrogen' do
        expect(described_class.send(:determine_escalation_strategy, nitrogen_order)).to eq(:special_mission)
      end
    end

    context 'with non-critical locally available resources' do
      let(:iron_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'iron') }

      it 'returns :automated_harvesting for locally available materials' do
        celestial_body.update!(composition: { 'regolith' => { 'iron' => 3.5 } })
        expect(described_class.send(:determine_escalation_strategy, iron_order)).to eq(:automated_harvesting)
      end
    end

    context 'with non-critical non-locally available resources' do
      let(:titanium_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'titanium') }

      it 'returns :scheduled_import for unavailable materials' do
        expect(described_class.send(:determine_escalation_strategy, titanium_order)).to eq(:scheduled_import)
      end
    end
  end

  describe '.critical_resource?' do
    it 'returns true for oxygen' do
      expect(described_class.send(:critical_resource?, 'oxygen')).to be true
    end

    it 'returns true for water' do
      expect(described_class.send(:critical_resource?, 'water')).to be true
    end

    it 'returns true for nitrogen' do
      expect(described_class.send(:critical_resource?, 'nitrogen')).to be true
    end

    it 'returns true for hydrogen' do
      expect(described_class.send(:critical_resource?, 'hydrogen')).to be true
    end

    it 'returns false for non-critical resources' do
      expect(described_class.send(:critical_resource?, 'iron')).to be false
      expect(described_class.send(:critical_resource?, 'titanium')).to be false
      expect(described_class.send(:critical_resource?, 'copper')).to be false
    end

    it 'is case insensitive' do
      expect(described_class.send(:critical_resource?, 'OXYGEN')).to be true
      expect(described_class.send(:critical_resource?, 'Water')).to be true
    end
  end

  describe '.can_harvest_locally?' do
    let(:celestial_body) { settlement.celestial_body }

    context 'oxygen harvesting' do
      it 'returns true when atmosphere contains O2' do
        atmosphere = create(:atmosphere, celestial_body: celestial_body)
        create(:gas, atmosphere: atmosphere, name: 'O2', percentage: 21.0)

        expect(described_class.send(:can_harvest_locally?, settlement, 'oxygen')).to be true
      end

      it 'returns false when atmosphere lacks O2' do
        atmosphere = create(:atmosphere, celestial_body: celestial_body)
        create(:gas, atmosphere: atmosphere, name: 'CO2', percentage: 95.0)

        expect(described_class.send(:can_harvest_locally?, settlement, 'oxygen')).to be false
      end
    end

    context 'water harvesting' do
      it 'returns true when hydrosphere has liquid water' do
        create(:hydrosphere, celestial_body: celestial_body, total_liquid_mass: 1000000.0)

        expect(described_class.send(:can_harvest_locally?, settlement, 'water')).to be true
      end

      it 'returns false when hydrosphere lacks liquid water' do
        create(:hydrosphere, celestial_body: celestial_body, total_liquid_mass: 0.0)

        expect(described_class.send(:can_harvest_locally?, settlement, 'water')).to be false
      end
    end

    context 'nitrogen harvesting' do
      it 'returns true when atmosphere contains N2' do
        atmosphere = create(:atmosphere, celestial_body: celestial_body)
        create(:gas, atmosphere: atmosphere, name: 'N2', percentage: 78.0)

        expect(described_class.send(:can_harvest_locally?, settlement, 'nitrogen')).to be true
      end

      it 'returns false when atmosphere lacks N2' do
        atmosphere = create(:atmosphere, celestial_body: celestial_body)
        create(:gas, atmosphere: atmosphere, name: 'O2', percentage: 100.0)

        expect(described_class.send(:can_harvest_locally?, settlement, 'nitrogen')).to be false
      end
    end

    context 'regolith materials' do
      it 'returns true when regolith contains the material' do
        celestial_body.update!(composition: { 'regolith' => { 'iron' => 5.2 } })

        expect(described_class.send(:can_harvest_locally?, settlement, 'iron')).to be true
      end

      it 'returns false when regolith lacks the material' do
        celestial_body.update!(composition: { 'regolith' => { 'titanium' => 1.5 } })

        expect(described_class.send(:can_harvest_locally?, settlement, 'iron')).to be false
      end
    end
  end

  describe '.find_best_import_source' do
    it 'prioritizes Earth as primary source' do
      source = described_class.send(:find_best_import_source, settlement, 'iron')
      expect(source[:type]).to eq(:earth)
      expect(source[:location]).to eq('Earth')
      expect(source[:cost_multiplier]).to eq(3.0)
    end

    it 'falls back to settlement sources when Earth cannot supply' do
      allow(described_class).to receive(:can_supply?).with(anything, 'helium').and_return(false)
      allow(described_class).to receive(:find_nearby_settlements).and_return([double('settlement')])

      source = described_class.send(:find_best_import_source, settlement, 'helium')
      expect(source[:type]).to eq(:settlement)
    end
  end

  describe '.calculate_transport_cost' do
    let(:earth_source) { { type: :earth, location: 'Earth', cost_multiplier: 3.0 } }
    let(:settlement_source) { { type: :settlement, location: 'Nearby Settlement', cost_multiplier: 1.5 } }

    it 'calculates correct cost for Earth imports' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_ask).and_return(100.0)

      cost = described_class.send(:calculate_transport_cost, earth_source, settlement, 'iron', 100)
      expected_cost = 100.0 * 100 * 5.0 * 2.0 # base_price * quantity * distance_factor * urgency_factor

      expect(cost).to eq(expected_cost)
    end

    it 'calculates correct cost for settlement imports' do
      allow(Market::NpcPriceCalculator).to receive(:calculate_ask).and_return(100.0)

      cost = described_class.send(:calculate_transport_cost, settlement_source, settlement, 'iron', 100)
      expected_cost = 100.0 * 100 * 2.0 * 2.0 # base_price * quantity * distance_factor * urgency_factor

      expect(cost).to eq(expected_cost)
    end
  end

  describe '.calculate_delivery_time' do
    it 'returns 6 months for Earth imports' do
      earth_source = { type: :earth, location: 'Earth' }
      eta = described_class.send(:calculate_delivery_time, earth_source, settlement)

      expect(eta).to be_within(1.day).of(180.days.from_now)
    end

    it 'returns 1 month for settlement imports' do
      settlement_source = { type: :settlement, location: 'Nearby Settlement' }
      eta = described_class.send(:calculate_delivery_time, settlement_source, settlement)

      expect(eta).to be_within(1.day).of(30.days.from_now)
    end

    it 'returns 1 week for depot imports' do
      depot_source = { type: :depot, location: 'Orbital Depot' }
      eta = described_class.send(:calculate_delivery_time, depot_source, settlement)

      expect(eta).to be_within(1.day).of(7.days.from_now)
    end
  end

  describe '.can_supply?' do
    it 'Earth can supply most materials except rare space resources' do
      expect(described_class.send(:can_supply?, { type: :earth }, 'iron')).to be true
      expect(described_class.send(:can_supply?, { type: :earth }, 'helium')).to be false
      expect(described_class.send(:can_supply?, { type: :earth }, 'deuterium')).to be false
    end

    it 'settlements can supply local resources' do
      expect(described_class.send(:can_supply?, { type: :settlement }, 'iron')).to be true
      expect(described_class.send(:can_supply?, { type: :settlement }, 'water')).to be true
    end

    it 'depots can supply processed materials' do
      expect(described_class.send(:can_supply?, { type: :depot }, 'iron')).to be true
      expect(described_class.send(:can_supply?, { type: :depot }, 'titanium')).to be true
    end
  end

  describe '.deploy_harvester_to_site' do
    let(:oxygen_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'oxygen', quantity: 100) }
    let(:water_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'water', quantity: 200) }
    let(:iron_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'iron', quantity: 50) }

    it 'deploys oxygen harvester to atmospheric site' do
      harvester = described_class.create_automated_harvester(settlement, 'oxygen', 100)
      described_class.send(:deploy_harvester_to_site, harvester, celestial_body, 'oxygen')

      harvester.reload
      expect(harvester.location).to eq(celestial_body)
      expect(harvester.operational_data['deployment_site']).to eq('atmospheric_processor')
      expect(harvester.operational_data['coordinates']).to be_present
    end

    it 'deploys water harvester to hydrosphere site' do
      harvester = described_class.create_automated_harvester(settlement, 'water', 200)
      described_class.send(:deploy_harvester_to_site, harvester, celestial_body, 'water')

      harvester.reload
      expect(harvester.location).to eq(celestial_body)
      expect(harvester.operational_data['deployment_site']).to eq('ice_deposit')
      expect(harvester.operational_data['coordinates']).to be_present
    end

    it 'deploys regolith harvester to mining site' do
      harvester = described_class.create_automated_harvester(settlement, 'iron', 50)
      described_class.send(:deploy_harvester_to_site, harvester, celestial_body, 'iron')

      harvester.reload
      expect(harvester.location).to eq(celestial_body)
      expect(harvester.operational_data['deployment_site']).to eq('regolith_field')
      expect(harvester.operational_data['coordinates']).to be_present
    end
  end

  describe '.schedule_harvester_completion' do
    let(:oxygen_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'oxygen', quantity: 100) }

    it 'schedules completion job with correct timing' do
      harvester = described_class.create_automated_harvester(settlement, 'oxygen', 100)
      extraction_rate = 10 # kg/hour
      expected_hours = (100 / extraction_rate.to_f).ceil # 10 hours

      expect(HarvesterCompletionJob).to receive(:set)
        .with(wait_until: a_value_within(1.minute).of(expected_hours.hours.from_now))
        .and_return(double(perform_later: true))

      described_class.send(:schedule_harvester_completion, harvester, oxygen_order)
    end
  end
end