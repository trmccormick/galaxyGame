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
end