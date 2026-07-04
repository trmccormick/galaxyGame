# spec/services/ai_manager/escalation_service_spec.rb
require 'rails_helper'

RSpec.describe AIManager::EscalationService, type: :service do
  # pending "EscalationService requires ISRU-first redesign — see docs/agent/tasks/backlog/escalation_service_redesign.md"

  let(:settlement) { create(:base_settlement) }
  let(:celestial_body) { settlement.celestial_body }

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
          identifier: match(/^ROBOT-/),
          unit_type: "robot",
          owner: settlement.owner,
          attachable: settlement,
          operational_data: {
            'task_type' => 'atmospheric_harvesting',
            'target_material' => 'O2',
            'target_quantity' => 100,
            'extraction_rate' => 10,
            'mobility_type' => 'stationary'
          }
        )

        described_class.create_automated_harvester(settlement, 'oxygen', 100)
      end
    end

    context 'water harvesting' do
      xit 'creates harvester craft for water' do
        expect(Craft::Harvester).to receive(:create!).with(
          name: "Automated Water Extractor",
          craft_name: "water_extractor",
          craft_type: "harvester",
          owner: settlement.owner,
          docked_at: settlement,
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

    context 'with harvestable resources and ISRU equipment' do
        let(:mars_body) { CelestialBodies::CelestialBody.find_by!(identifier: 'MARS-01') }
        let(:mars_location) { create(:celestial_location, celestial_body: mars_body) }
        let(:settlement) { create(:base_settlement, location: mars_location) }
        let(:oxygen_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'oxygen') }
        let(:water_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'water') }

      before do
        atmosphere = celestial_body.atmosphere || create(:atmosphere, celestial_body: celestial_body)
        create(:gas, :o2, atmosphere: atmosphere, percentage: 21.0)
        celestial_body.reload  # force reload associations
        hydrosphere = celestial_body.hydrosphere
        hydrosphere ||= create(:hydrosphere, celestial_body: celestial_body)
        hydrosphere.update!(total_liquid_mass: 1.386e21)
        settlement.update!(current_population: 5) # ISRU requires human oversight
      end

      it 'returns :automated_harvesting for oxygen when locally available' do
        expect(described_class.send(:determine_escalation_strategy, oxygen_order))
          .to eq(:automated_harvesting)
      end

      it 'returns :automated_harvesting for water when locally available' do
        expect(described_class.send(:determine_escalation_strategy, water_order))
          .to eq(:automated_harvesting)
      end

      # End Mars context
      context 'with no local nitrogen (Luna)' do
        let(:settlement) { create(:base_settlement) } # default Luna
        let(:nitrogen_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'nitrogen') }

        it 'returns :scheduled_import for nitrogen when not locally available' do
          # Nitrogen has no local source on Luna — permanent planned import
          expect(described_class.send(:determine_escalation_strategy, nitrogen_order))
            .to eq(:scheduled_import)
        end
      end
    end

    context 'with non-critical locally available resources' do
      # advanced_electronics cannot be produced locally at any settlement phase
      # and represents a genuine scheduled import scenario.
      # Iron was removed — it's not imported, it's smelted from local regolith
      # once smelter infrastructure exists. See RESUPPLY_AND_ESCALATION_ARCHITECTURE.md
      let(:electronics_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'advanced_electronics') }

      it 'returns :scheduled_import for advanced_electronics (never locally producible)' do
        expect(described_class.send(:determine_escalation_strategy, electronics_order))
          .to eq(:scheduled_import)
      end
    end

    context 'with non-critical non-locally available resources' do
      let(:titanium_order) { create(:market_order, :buy, base_settlement: settlement, resource: 'oxygen') }

      before do
        settlement.celestial_body.atmosphere.gases.destroy_all
        allow(described_class).to receive(:hlt_mission_manifest).and_return(['O2'])
      end

      it 'returns :scheduled_import for unavailable materials' do
        expect(described_class.send(:determine_escalation_strategy, titanium_order)).to eq(:scheduled_import)
      end
    end
  end

  describe '.critical_import_required?' do
    it 'returns true for advanced_electronics' do
      expect(described_class.send(:critical_import_required?, 'advanced_electronics')).to be true
    end

    it 'returns false for oxygen' do
      expect(described_class.send(:critical_import_required?, 'oxygen')).to be false
    end
  end

  describe '.can_harvest_locally?' do
    context 'oxygen harvesting' do
      it 'returns true when atmosphere contains O2' do
        cb = create(:celestial_body)
        settlement = create(:base_settlement)
        settlement.location.celestial_body = cb
        settlement.location.save!
        atmosphere = cb.atmosphere
        atmosphere.gases.destroy_all
        create(:gas, :o2, atmosphere: atmosphere, percentage: 21.0)
        cb.reload
        settlement.reload
        settlement.location.reload
        expect(described_class.send(:can_harvest_locally?, settlement, 'oxygen')).to be true
      end

      it 'returns false when atmosphere lacks O2' do
        cb = create(:celestial_body)
        settlement = create(:base_settlement)
        settlement.location.celestial_body = cb
        settlement.location.save!
        atmosphere = cb.atmosphere
        atmosphere.gases.destroy_all
        create(:gas, :co2, atmosphere: atmosphere, percentage: 95.0)
        cb.reload
        settlement.reload
        settlement.location.reload
        expect(described_class.send(:can_harvest_locally?, settlement, 'oxygen')).to be false
      end
    end

    context 'water harvesting' do
      it 'returns true when hydrosphere has liquid water' do
        cb = create(:celestial_body)
        settlement = create(:base_settlement)
        settlement.location.celestial_body = cb
        settlement.location.save!
        hydrosphere = cb.hydrosphere
        hydrosphere.update!(total_liquid_mass: 1.386e21)
        cb.reload
        settlement.reload
        settlement.location.reload
        expect(described_class.send(:can_harvest_locally?, settlement, 'water')).to be true
      end

      it 'returns false when hydrosphere lacks liquid water' do
        cb = create(:celestial_body)
        settlement = create(:base_settlement)
        settlement.location.celestial_body = cb
        settlement.location.save!
        hydrosphere = cb.hydrosphere
        hydrosphere.update!(total_liquid_mass: 0.0)
        cb.reload
        settlement.reload
        settlement.location.reload
        expect(described_class.send(:can_harvest_locally?, settlement, 'water')).to be false
      end
    end

    context 'nitrogen harvesting' do
      it 'returns true when atmosphere contains N2' do
        cb = create(:celestial_body)
        settlement = create(:base_settlement)
        settlement.location.celestial_body = cb
        settlement.location.save!
        atmosphere = cb.atmosphere
        atmosphere.gases.destroy_all
        create(:gas, :n2, atmosphere: atmosphere, percentage: 78.0)
        cb.reload
        settlement.reload
        settlement.location.reload
        expect(described_class.send(:can_harvest_locally?, settlement, 'nitrogen')).to be true
      end

      it 'returns false when atmosphere lacks N2' do
        cb = create(:celestial_body)
        settlement = create(:base_settlement)
        settlement.location.celestial_body = cb
        settlement.location.save!
        atmosphere = cb.atmosphere
        atmosphere.gases.destroy_all
        create(:gas, :o2, atmosphere: atmosphere, percentage: 100.0)
        cb.reload
        settlement.reload
        settlement.location.reload
        expect(described_class.send(:can_harvest_locally?, settlement, 'nitrogen')).to be false
      end
    end

    context 'regolith materials' do
      it 'returns true when regolith contains the material' do
        cb = create(:celestial_body)
        settlement = create(:base_settlement)
        settlement.location.celestial_body = cb
        settlement.location.save!
        create(:material, name: 'iron', state: 'solid', location: 'geosphere', amount: 5.2, celestial_body: cb, layer: 'crust')
        cb.reload
        expect(described_class.send(:can_harvest_locally?, settlement, 'iron')).to be true
      end

      it 'returns false when regolith lacks the material' do
        cb = create(:celestial_body)
        settlement = create(:base_settlement)
        settlement.location.celestial_body = cb
        settlement.location.save!
        create(:material, name: 'titanium', state: 'solid', location: 'geosphere', amount: 1.5, celestial_body: cb, layer: 'crust')
        cb.reload
        expect(described_class.send(:can_harvest_locally?, settlement, 'iron')).to be false
      end
    end
  end

  describe '.find_best_import_source' do
    let(:other_settlement) { create(:settlement, location: create(:celestial_location, celestial_body: celestial_body)) }

    it 'prioritizes Earth as primary source' do
      source = described_class.send(:find_best_import_source, settlement, 'iron')
      expect(source[:type]).to eq(:earth)
      expect(source[:location]).to eq('Earth')
      expect(source[:cost_multiplier]).to eq(3.0)
    end

    it 'falls back to settlement sources when Earth cannot supply' do
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
      expect(harvester.location.celestial_body).to eq(celestial_body)
      expect(harvester.operational_data['deployment_site']).to eq('atmospheric_processor')
      expect(harvester.operational_data['coordinates']).to be_present
    end

    it 'deploys water harvester to hydrosphere site' do
      harvester = described_class.create_automated_harvester(settlement, 'water', 200)
      described_class.send(:deploy_harvester_to_site, harvester, celestial_body, 'water')

      harvester.reload
      expect(harvester.location.celestial_body).to eq(celestial_body)
      expect(harvester.operational_data['deployment_site']).to eq('ice_deposit')
      expect(harvester.operational_data['coordinates']).to be_present
    end

    it 'deploys regolith harvester to mining site' do
      harvester = described_class.create_automated_harvester(settlement, 'iron', 50)
      described_class.send(:deploy_harvester_to_site, harvester, celestial_body, 'iron')

      harvester.reload
      expect(harvester.location.celestial_body).to eq(celestial_body)
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
        .with(hash_including(wait_until: a_value_within(1.minute).of(expected_hours.hours.from_now)))
        .and_return(double(perform_later: true))

      described_class.send(:schedule_harvester_completion, harvester, oxygen_order)
    end
  end

  describe '.handle_resource_shortage' do
    let(:gcc_currency) { Financial::Currency.find_or_create_by(symbol: 'GCC') { |c| c.name = 'Galactic Credit Currency' } }
    let(:account) { Financial::Account.find_or_create_by(accountable_type: settlement.class.name, accountable_id: settlement.id, currency_id: gcc_currency.id) { |a| a.balance = 100_000 } }

    before do
      allow(Financial::Currency).to receive(:find_by).with(symbol: 'GCC').and_return(gcc_currency)
      allow(Financial::Account).to receive(:find_or_create_for_entity_and_currency)
        .with(accountable_entity: settlement, currency: gcc_currency).and_return(account)
    end

    context 'with sufficient funding' do
      before do
        allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'O2').and_return(500.0)
        allow(AIManager::EmergencyMissionService).to receive(:create_emergency_mission).with(settlement, :oxygen).and_return(id: 'emergency_oxygen_1')
      end

      it 'creates emergency mission when settlement can fund' do
        action_hash = { type: 'shortage', material: 'oxygen', deficit: 10, settlement: settlement }
        result = described_class.handle_resource_shortage(action_hash, settlement)

        expect(result).to eq(id: 'emergency_oxygen_1')
        expect(AIManager::EmergencyMissionService).to have_received(:create_emergency_mission).with(settlement, :oxygen)
      end

      it 'works with string keys in action_hash' do
        action_hash = { 'type' => 'shortage', 'material' => 'oxygen', 'deficit' => 10 }
        result = described_class.handle_resource_shortage(action_hash, settlement)

        expect(result).to eq(id: 'emergency_oxygen_1')
        expect(AIManager::EmergencyMissionService).to have_received(:create_emergency_mission).with(settlement, :oxygen)
      end

      it 'normalizes water to H2O and converts back to :water symbol' do
        allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'H2O').and_return(300.0)
        allow(AIManager::EmergencyMissionService).to receive(:create_emergency_mission).with(settlement, :water).and_return(id: 'emergency_water_1')

        action_hash = { type: 'shortage', material: 'water', deficit: 5 }
        result = described_class.handle_resource_shortage(action_hash, settlement)

        expect(result).to eq(id: 'emergency_water_1')
      end

      it 'normalizes methane to CH4 and converts back to :methane symbol' do
        allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'CH4').and_return(400.0)
        allow(AIManager::EmergencyMissionService).to receive(:create_emergency_mission).with(settlement, :methane).and_return(id: 'emergency_methane_1')

        action_hash = { type: 'shortage', material: 'methane', deficit: 3 }
        result = described_class.handle_resource_shortage(action_hash, settlement)

        expect(result).to eq(id: 'emergency_methane_1')
      end
    end

    context 'with insufficient funding' do
      before do
        allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'O2').and_return(500.0)
        account.update!(balance: 100) # too low to cover cost_estimate of 5000
        # Stub so RSpec can track calls — won't be invoked in this path
        allow(AIManager::EmergencyMissionService).to receive(:create_emergency_mission)
      end

      it 'adds to resupply manifest when settlement cannot fund' do
        action_hash = { type: 'shortage', material: 'oxygen', deficit: 10 }
        result = described_class.handle_resource_shortage(action_hash, settlement)

        expect(result).to be_nil
        expect(AIManager::EmergencyMissionService).not_to have_received(:create_emergency_mission)
      end
    end

    context 'with nil or blank input' do
      it 'returns nil when material is nil' do
        action_hash = { type: 'shortage', material: nil, deficit: 10 }
        result = described_class.handle_resource_shortage(action_hash, settlement)
        expect(result).to be_nil
      end

      it 'returns nil when material is blank string' do
        action_hash = { type: 'shortage', material: '', deficit: 10 }
        result = described_class.handle_resource_shortage(action_hash, settlement)
        expect(result).to be_nil
      end

      it 'returns nil when settlement is nil' do
        action_hash = { type: 'shortage', material: 'oxygen', deficit: 10 }
        result = described_class.handle_resource_shortage(action_hash, nil)
        expect(result).to be_nil
      end
    end

    context 'when mission creation fails' do
      before do
        allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(settlement, 'O2').and_return(500.0)
      end

      it 'returns nil and logs error when EmergencyMissionService returns nil' do
        allow(AIManager::EmergencyMissionService).to receive(:create_emergency_mission).with(settlement, :oxygen).and_return(nil)

        action_hash = { type: 'shortage', material: 'oxygen', deficit: 10 }
        result = described_class.handle_resource_shortage(action_hash, settlement)

        expect(result).to be_nil
      end

      it 'returns nil and logs error when EmergencyMissionService raises' do
        allow(AIManager::EmergencyMissionService).to receive(:create_emergency_mission).with(settlement, :oxygen).and_raise(StandardError.new('connection refused'))

        action_hash = { type: 'shortage', material: 'oxygen', deficit: 10 }
        result = described_class.handle_resource_shortage(action_hash, settlement)

        expect(result).to be_nil
      end
    end
  end
end