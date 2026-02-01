# spec/services/ai_manager/resource_flow_simulator_spec.rb
#
# Tests for ResourceFlowSimulator - Resource dependency modeling and timeline optimization

require 'rails_helper'

RSpec.describe AIManager::ResourceFlowSimulator do
  let(:settlement) { create(:settlement) }
  let(:simulator) { described_class.new(settlement) }

  describe '#simulate_plan' do
    let(:plan_phases) do
      [
        {
          start_day: 0,
          productions: [
            { type: 'teu_unit', quantity: 1 },
            { type: 'pve_unit', quantity: 1 }
          ],
          missions: [
            { type: 'titan_harvester', quantity: 1 }
          ]
        },
        {
          start_day: 14,
          productions: [
            { type: 'co2_splitter', quantity: 1 }
          ],
          missions: [
            { type: 'venus_harvester', quantity: 1 }
          ]
        }
      ]
    end

    it 'simulates resource flow over time' do
      result = simulator.simulate_plan(plan_phases, 60)

      expect(result).to include(
        :timeline,
        :final_inventory,
        :bottlenecks_identified,
        :completion_time_days
      )

      expect(result[:timeline]).to be_an(Array)
      expect(result[:completion_time_days]).to be >= 0
    end

    it 'tracks production completions' do
      result = simulator.simulate_plan(plan_phases, 30)

      completed_productions = result[:timeline].flat_map { |t| t[:productions_completed] }
      expect(completed_productions).to include('teu_unit', 'pve_unit')
    end

    it 'tracks mission completions' do
      result = simulator.simulate_plan(plan_phases, 120)

      completed_missions = result[:timeline].flat_map { |t| t[:missions_completed] }
      expect(completed_missions).to include('titan_harvester')
    end
  end

  describe '#optimize_flow' do
    let(:unoptimized_phases) do
      [
        {
          start_day: 0,
          productions: [{ type: 'lava_tube_base', quantity: 1 }],
          missions: []
        }
      ]
    end

    it 'reorders phases for dependency satisfaction' do
      optimized = simulator.optimize_flow(unoptimized_phases)

      expect(optimized).to be_an(Array)
      expect(optimized.length).to eq(unoptimized_phases.length)
    end

    it 'adjusts timing to prevent bottlenecks' do
      # This would test the timing adjustment logic
      optimized = simulator.optimize_flow(unoptimized_phases)

      # Should have adjusted start times
      expect(optimized.first[:start_day]).to be >= 0
    end
  end

  describe '#calculate_resource_availability' do
    it 'projects resource availability over time' do
      availability = simulator.calculate_resource_availability('titanium', 30)

      expect(availability).to be_an(Array)
      expect(availability.length).to eq(31) # 0 to 30 days

      availability.each do |point|
        expect(point).to include(:day, :available)
        expect(point[:available]).to be >= 0
      end
    end

    it 'includes production from active units' do
      # Add a production unit
      create(:unit, unit_type: 'processed_regolith_production', settlement: settlement, operational: true)

      availability = simulator.calculate_resource_availability('processed_regolith', 10)

      # Should show increasing availability over time
      expect(availability.last[:available]).to be > availability.first[:available]
    end
  end

  describe '#identify_bottlenecks' do
    context 'with resource shortages' do
      let(:inventory) { { 'titanium' => 10 } }
      let(:active_productions) { [{ type: 'lava_tube_base', inputs: { 'titanium' => 100 } }] }
      let(:active_missions) { [] }

      it 'identifies resource bottlenecks' do
        bottlenecks = simulator.identify_bottlenecks(inventory, active_productions, active_missions)

        expect(bottlenecks).to include(/Critical shortage of titanium/)
      end
    end

    context 'with power constraints' do
      let(:inventory) { { 'titanium' => 1000 } }
      let(:active_productions) do
        [
          { type: 'teu_unit', inputs: {} },
          { type: 'pve_unit', inputs: {} },
          { type: 'co2_splitter', inputs: {} }
        ]
      end
      let(:active_missions) { [] }

      it 'identifies power bottlenecks' do
        bottlenecks = simulator.identify_bottlenecks(inventory, active_productions, active_missions)

        expect(bottlenecks).to include(/Power constraint/)
      end
    end

    context 'with mission capacity limits' do
      let(:inventory) { { 'titanium' => 1000 } }
      let(:active_productions) { [] }
      let(:active_missions) do
        [
          { type: 'titan_harvester' },
          { type: 'venus_harvester' },
          { type: 'titan_harvester' },
          { type: 'venus_harvester' }
        ]
      end

      it 'identifies mission capacity bottlenecks' do
        bottlenecks = simulator.identify_bottlenecks(inventory, active_productions, active_missions)

        expect(bottlenecks).to include(/Mission capacity exceeded/)
      end
    end
  end

  describe 'private methods' do
    describe '#build_current_inventory' do
      before do
        settlement.inventory.add_item('titanium', 500)
        settlement.inventory.add_item('raw_regolith', 10000)
      end

      it 'builds inventory from settlement data' do
        inventory = simulator.send(:build_current_inventory)

        expect(inventory['titanium']).to eq(500)
        expect(inventory['raw_regolith']).to eq(10000)
      end
    end

    describe '#start_production' do
      let(:active_productions) { [] }

      it 'adds production to active list' do
        production = { type: 'teu_unit', quantity: 1 }

        simulator.send(:start_production, production, 0, active_productions)

        expect(active_productions.length).to eq(1)
        expect(active_productions.first[:type]).to eq('teu_unit')
        expect(active_productions.first[:completion_day]).to eq(10) # TEU build time
      end
    end

    describe '#start_mission' do
      let(:active_missions) { [] }

      it 'adds mission to active list' do
        mission = { type: 'titan_harvester', quantity: 1 }

        simulator.send(:start_mission, mission, 0, active_missions)

        expect(active_missions.length).to eq(1)
        expect(active_missions.first[:type]).to eq('titan_harvester')
        expect(active_missions.first[:completion_day]).to eq(90) # Titan mission duration
      end
    end

    describe '#complete_production' do
      let(:inventory) { { 'titanium' => 200, 'aluminum' => 100 } }
      let(:production) do
        {
          type: 'gcc_satellite',
          inputs: { 'titanium' => 50, 'aluminum' => 10 },
          outputs: { 'gcc_satellite' => 1 },
          quantity: 1
        }
      end

      it 'consumes inputs and produces outputs' do
        daily_events = { productions_completed: [], inventory_changes: {} }

        simulator.send(:complete_production, production, inventory, daily_events)

        expect(inventory['titanium']).to eq(150)
        expect(inventory['aluminum']).to eq(90)
        expect(inventory['gcc_satellite']).to eq(1)
        expect(daily_events[:productions_completed]).to include('gcc_satellite')
      end

      it 'handles insufficient inputs' do
        low_inventory = { 'titanium' => 10, 'aluminum' => 100 }
        daily_events = { productions_completed: [], inventory_changes: {}, bottlenecks: [] }

        simulator.send(:complete_production, production, low_inventory, daily_events)

        expect(low_inventory['titanium']).to eq(10) # Unchanged
        expect(daily_events[:bottlenecks]).to include(/Cannot complete gcc_satellite/)
      end
    end

    describe '#complete_mission' do
      let(:inventory) { { 'methane' => 300 } }
      let(:mission) do
        {
          type: 'titan_harvester',
          fuel_required: 200,
          resources: { 'titanium' => 500, 'nitrogen' => 100 }
        }
      end

      it 'consumes fuel and adds mission resources' do
        daily_events = { missions_completed: [], inventory_changes: {} }

        simulator.send(:complete_mission, mission, inventory, daily_events)

        expect(inventory['methane']).to eq(100)
        expect(inventory['titanium']).to eq(500)
        expect(inventory['nitrogen']).to eq(100)
        expect(daily_events[:missions_completed]).to include('titan_harvester')
      end

      it 'handles insufficient fuel' do
        low_fuel_inventory = { 'methane' => 100 }
        daily_events = { missions_completed: [], inventory_changes: {}, bottlenecks: [] }

        simulator.send(:complete_mission, mission, low_fuel_inventory, daily_events)

        expect(low_fuel_inventory['methane']).to eq(100) # Unchanged
        expect(daily_events[:bottlenecks]).to include(/Cannot complete titan_harvester mission/)
      end
    end

    describe '#identify_critical_path' do
      let(:phases) do
        [
          { productions: [{ type: 'lava_tube_base' }] },
          { productions: [{ type: 'venus_harvester' }] }
        ]
      end

      it 'identifies prerequisite productions' do
        critical_path = simulator.send(:identify_critical_path, phases)

        expect(critical_path).to include('lava_tube_base')
      end
    end

    describe '#calculate_completion_time' do
      let(:phases) do
        [
          { start_day: 0, productions: [{ type: 'teu_unit' }] },
          { start_day: 10, productions: [{ type: 'pve_unit' }] }
        ]
      end
      let(:timeline) { [] }

      it 'calculates total completion time' do
        completion_time = simulator.send(:calculate_completion_time, phases, timeline)

        expect(completion_time).to eq(22) # TEU (10) + PVE (12) = 22
      end
    end
  end
end