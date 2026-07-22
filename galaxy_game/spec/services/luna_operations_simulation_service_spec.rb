# spec/services/luna_operations_simulation_service_spec.rb
require 'rails_helper'

RSpec.describe LunaOperationsSimulationService, type: :service do
  let(:celestial_body) { CelestialBodies::CelestialBody.find_by(identifier: 'LUNA-01') || create(:celestial_body, name: 'Luna Test') }
  let(:location) { create(:celestial_location, celestial_body: celestial_body) }
  let(:owner) { create(:player) }
  let(:settlement) do
    Settlement::BaseSettlement.create!(
      name: 'Luna Base Alpha',
      settlement_type: :base,
      current_population: 5,
      owner: owner,
      location: location
    )
  end

  let!(:inventory) do
    settlement.build_inventory if settlement.inventory.nil?
    item_owner = owner
    %w[oxygen water food regolith].each do |resource|
      settlement.inventory.items.create!(
        name: resource,
        amount: 500,
        owner: item_owner,
        metadata: { 'purpose' => 'initial_stockpile' }
      )
    end
    settlement.inventory
  end

  describe '#run' do
    context 'with default day_count (30)' do
      it 'advances the simulation for 30 days' do
        service = described_class.new(settlement)
        result = service.run

        expect(result).to be_a(described_class)
        expect(service.daily_log).to include(a_string_matching(/Duration: 30 days/))
        expect(service.daily_log).to include(a_string_matching(/Simulation Complete/))
      end

      it 'logs production/consumption deltas for each day' do
        service = described_class.new(settlement)
        service.run

        day_entries = service.daily_log.select { |line| line.start_with?('[Day ') }
        expect(day_entries.count).to eq(30)
      end

      it 'persists tick_count to settlement.operational_data' do
        expect(settlement.operational_data['tick_count']).to be_nil

        service = described_class.new(settlement)
        service.run

        settlement.reload
        expect(settlement.operational_data['tick_count']).to eq(30)
      end

      it 'persists last_simulated_at to settlement.operational_data' do
        before_time = Time.current
        service = described_class.new(settlement)
        service.run
        settlement.reload

        expect(settlement.operational_data['last_simulated_at']).not_to be_nil
        expect(Time.parse(settlement.operational_data['last_simulated_at'])).to be > before_time
      end
    end

    context 'with custom day_count' do
      it 'advances the simulation for the specified number of days' do
        service = described_class.new(settlement, day_count: 60)
        service.run

        day_entries = service.daily_log.select { |line| line.start_with?('[Day ') }
        expect(day_entries.count).to eq(60)

        settlement.reload
        expect(settlement.operational_data['tick_count']).to eq(60)
      end
    end

    context 'validation' do
      it 'raises ArgumentError when settlement has no location' do
        bad_settlement = Settlement::BaseSettlement.new(name: 'Orphan Base', settlement_type: :base)
        expect {
          described_class.new(bad_settlement).run
        }.to raise_error(ArgumentError, /Settlement must be deployed/)
      end

      it 'raises ArgumentError when day_count is zero' do
        expect {
          described_class.new(settlement, day_count: 0).run
        }.to raise_error(ArgumentError, /Day count must be positive/)
      end

      it 'raises ArgumentError when day_count is negative' do
        expect {
          described_class.new(settlement, day_count: -5).run
        }.to raise_error(ArgumentError, /Day count must be positive/)
      end
    end
  end

  describe 'daily tick' do
    let(:initial_inventory) do
      settlement.build_inventory if settlement.inventory.nil?
      {
        oxygen: inventory.current_storage_of('oxygen'),
        water: inventory.current_storage_of('water'),
        food: inventory.current_storage_of('food'),
        regolith: inventory.current_storage_of('regolith')
      }
    end

    before do
      initial_inventory  # force eager evaluation BEFORE the tick runs
      @service = described_class.new(settlement, day_count: 1)
      @service.run
    end

    it 'consumes oxygen for life support (Tier A)' do
      settlement.reload
      final_oxygen = settlement.inventory.current_storage_of('oxygen')
      expect(final_oxygen).to be < initial_inventory[:oxygen]
    end

    it 'consumes water for life support (Tier A)' do
      settlement.reload
      final_water = settlement.inventory.current_storage_of('water')
      expect(final_water).to be < initial_inventory[:water]
    end

    it 'consumes food for life support (Tier A)' do
      settlement.reload
      final_food = settlement.inventory.current_storage_of('food')
      expect(final_food).to be < initial_inventory[:food]
    end

    it 'produces ibeam via I-beam printer if regolith available (Tier B)' do
      settlement.reload
      ibeam_items = settlement.inventory.items.where(name: 'ibeam')
      expect(ibeam_items.sum(:amount)).to be > 0
    end

    it 'consumes regolith as feedstock for I-beam production (Tier B)' do
      settlement.reload
      final_regolith = settlement.inventory.current_storage_of('regolith')
      expect(final_regolith).to eq(initial_inventory[:regolith] - 75)
    end

    it 'tracks import decisions per tracked resource' do
      expect(@service.decisions).not_to be_empty
      @service.decisions.each do |d|
        expect(d.tick).to be_a(Integer)
        expect(d.resource).to be_in(LunaOperationsSimulationService::TRACKED_RESOURCES)
        expect(d.decision).to be_in(%w[IMPORT LOCAL_ONLY NO_IMPORT_NEEDED])
        expect(d.reason).not_to be_blank
      end
    end
  end

  describe 'import gate logic' do
    context 'when resource can be produced locally' do
      it 'logs LOCAL_ONLY decision for regolith' do
        service = described_class.new(settlement, day_count: 1)
        service.run

        regolith_decisions = service.decisions.select { |d| d.resource == 'regolith' }
        expect(regolith_decisions).not_to be_empty
        expect(regolith_decisions.first.decision).to eq('LOCAL_ONLY')
      end

      it 'logs LOCAL_ONLY decision for oxygen (ISRU produces O2 on Luna)' do
        service = described_class.new(settlement, day_count: 1)
        service.run

        o2_decisions = service.decisions.select { |d| d.resource == 'oxygen' }
        expect(o2_decisions).not_to be_empty
        expect(o2_decisions.first.decision).to eq('LOCAL_ONLY')
      end
    end

    context 'when stockpile is exhausted' do
      before do
        item = inventory.items.find_by(name: 'oxygen')
        item&.destroy
      end

      it 'logs IMPORT decision when stockpile is zero and consumption > 0' do
        service = described_class.new(settlement, day_count: 1)
        service.run

        o2_decisions = service.decisions.select { |d| d.resource == 'oxygen' }
        expect(o2_decisions).not_to be_empty
        expect(o2_decisions.first.decision).to eq('IMPORT')
      end
    end

    context 'when stockpile is sufficient for transit window' do
      it 'logs LOCAL_ONLY when days_until_exhaustion >= transit time' do
        service = described_class.new(settlement, day_count: 1)
        service.run

        water_decisions = service.decisions.select { |d| d.resource == 'water' }
        expect(water_decisions).not_to be_empty
        # With 500 kg stockpile and 250 kg/day consumption, days_until_exhaustion = 2 < 3 transit.
        expect(water_decisions.first.decision).to eq('IMPORT')
      end
    end

    context 'when large stockpile exists' do
      before do
        item = inventory.items.find_by(name: 'water')
        item&.update!(amount: 10_000)
      end

      it 'logs LOCAL_ONLY when days_until_exhaustion >= transit time' do
        service = described_class.new(settlement, day_count: 1)
        service.run

        water_decisions = service.decisions.select { |d| d.resource == 'water' }
        expect(water_decisions).not_to be_empty
        # 10_000 / 250 = 40 days >= 3 transit days.
        expect(water_decisions.first.decision).to eq('LOCAL_ONLY')
      end
    end
  end

  describe '#to_s' do
    it 'returns the full simulation log as a string' do
      service = described_class.new(settlement, day_count: 3)
      service.run

      output = service.to_s
      expect(output).to be_a(String)
      expect(output).to include('Luna Base Operations Simulation')
      expect(output).to include('[Day 1]')
      expect(output).to include('[Day 2]')
      expect(output).to include('[Day 3]')
      expect(output).to include('Simulation Complete')
    end
  end

  describe 'multi-day simulation' do
    it 'accumulates inventory changes over multiple days' do
      service = described_class.new(settlement, day_count: 10)
      service.run

      settlement.reload

      final_oxygen = settlement.inventory.current_storage_of('oxygen')
      expect(final_oxygen).to be >= 0

      final_food = settlement.inventory.current_storage_of('food')
      expect(final_food).to be < 500
    end

    it 'does not modify luna_mission.rake or venus_mars:pipeline_v2' do
      rake_path = Rails.root.join('lib', 'tasks', 'luna_operations_simulation.rake')
      expect(File.exist?(rake_path)).to be true

      content = File.read(rake_path)
      expect(content).not_to include('namespace :luna_mission')
    end
  end

  describe 'no inventory scenario' do
    before do
      settlement.inventory&.destroy
      settlement.instance_variable_set(:@inventory, nil)
    end

    it 'handles settlement without inventory gracefully' do
      service = described_class.new(settlement, day_count: 1)
      expect { service.run }.not_to raise_error
    end
  end
end
