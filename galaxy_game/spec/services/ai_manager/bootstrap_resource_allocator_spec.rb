# spec/services/ai_manager/bootstrap_resource_allocator_spec.rb
require "./app/services/ai_manager/bootstrap_resource_allocator"
require 'rails_helper'

RSpec.describe AIManager::BootstrapResourceAllocator do
  let(:shared_context) { double('SharedContext') }
  let(:allocator) { described_class.new(shared_context) }

  let(:settlement_plan) do
    {
      mission_type: 'mining_outpost',
      target_body: 'Luna-1',
      requirements: {
        personnel: 12,
        duration_months: 24
      }
    }
  end

  let(:target_system) do
    {
      identifier: 'SOL-LUNA',
      resource_profile: {
        water_ice: 150,
        regolith: 600,
        minerals: ['iron', 'aluminum'],
        energy_potential: { solar: 0.9, geothermal: 0.3 }
      },
      environmental_data: {
        atmosphere_composition: { 'CO2' => 0.95 },
        atmospheric_density: 0.01,
        radiation_levels: 'moderate'
      }
    }
  end

  describe '#calculate_bootstrap_requirements' do
    it 'calculates comprehensive bootstrap requirements' do
      result = allocator.calculate_bootstrap_requirements(settlement_plan, target_system)

      expect(result).to include(
        :base_requirements,
        :isru_adjustments,
        :logistics_requirements,
        :startup_budget,
        :timeline,
        :risk_factors
      )
    end

    it 'adjusts requirements based on mission type' do
      mining_plan = settlement_plan.merge(mission_type: 'mining_outpost')
      result = allocator.calculate_bootstrap_requirements(mining_plan, target_system)

      expect(result[:base_requirements]['mining_equipment']).to be > 0
      expect(result[:base_requirements]['personnel']).to eq(12)
    end

    it 'calculates ISRU adjustments for resource-rich systems' do
      result = allocator.calculate_bootstrap_requirements(settlement_plan, target_system)

      expect(result[:isru_adjustments][:reduced_imports]).to include('life_support_supplies')
      expect(result[:isru_adjustments][:timeline_acceleration]).to be > 0
    end

    it 'estimates realistic startup budget' do
      result = allocator.calculate_bootstrap_requirements(settlement_plan, target_system)

      expect(result[:startup_budget][:total_budget]).to be > 0
      expect(result[:startup_budget][:capital_expenditure]).to be > 0
      expect(result[:startup_budget][:operational_expenditure]).to be > 0
      expect(result[:startup_budget][:payback_period]).to be > 0
    end

    it 'assesses bootstrap risks appropriately' do
      result = allocator.calculate_bootstrap_requirements(settlement_plan, target_system)

      expect(result[:risk_factors]).to include(:technical_risks, :logistical_risks, :environmental_risks)
      expect(result[:risk_factors][:overall_risk_level]).to be_in([:low, :medium, :high])
    end
  end

  describe '#allocate_initial_resources' do
    let(:settlement) { double('Settlement', id: 1) }
    let(:bootstrap_requirements) do
      {
        base_requirements: {
          'life_support_supplies' => 500,
          'power_systems' => 200,
          'structural_materials' => 1000,
          'scientific_instruments' => 100
        }
      }
    end

    it 'allocates resources with proper priorities' do
      allocations = allocator.allocate_initial_resources(settlement, bootstrap_requirements)

      expect(allocations).to all(include(:settlement, :resource, :quantity, :priority, :allocation_type))

      critical_allocations = allocations.select { |a| a[:priority] == :critical }
      expect(critical_allocations.size).to be >= 2 # life support and power
    end

    it 'prioritizes critical resources first' do
      allocations = allocator.allocate_initial_resources(settlement, bootstrap_requirements)

      critical_resources = allocations.select { |a| a[:priority] == :critical }
      expect(critical_resources).to include(
        hash_including(resource: 'life_support_supplies', priority: :critical),
        hash_including(resource: 'power_systems', priority: :critical)
      )
    end

    it 'includes infrastructure and operational resources' do
      allocations = allocator.allocate_initial_resources(settlement, bootstrap_requirements)

      high_priority = allocations.select { |a| a[:priority] == :high }
      medium_priority = allocations.select { |a| a[:priority] == :medium }

      expect(high_priority.size).to be >= 1
      expect(medium_priority.size).to be >= 1
    end
  end

  describe 'private methods' do
    describe '#calculate_base_requirements' do
      it 'scales requirements based on mission type' do
        mining_requirements = allocator.send(:calculate_base_requirements, settlement_plan)
        research_plan = settlement_plan.merge(mission_type: 'research_station')
        research_requirements = allocator.send(:calculate_base_requirements, research_plan)

        expect(mining_requirements['mining_equipment']).to be > 0
        expect(research_requirements['laboratory_equipment']).to be > 0
        expect(mining_requirements['personnel']).to be > research_requirements['personnel']
      end
    end

    describe '#calculate_isru_adjustments' do
      it 'reduces import requirements for resource-rich systems' do
        adjustments = allocator.send(:calculate_isru_adjustments, target_system, settlement_plan)

        expect(adjustments[:reduced_imports]['life_support_supplies']).to be > 0
        expect(adjustments[:reduced_imports]['structural_materials']).to be > 0
        expect(adjustments[:timeline_acceleration]).to be > 0
      end

      it 'handles systems with limited resources' do
        poor_system = target_system.merge(
          resource_profile: { water_ice: 10, regolith: 50 },
          environmental_data: {}
        )
        adjustments = allocator.send(:calculate_isru_adjustments, poor_system, settlement_plan)

        expect(adjustments[:reduced_imports]).to be_empty.or have_attributes(size: 0)
        expect(adjustments[:timeline_acceleration]).to eq(0)
      end
    end

    describe '#calculate_startup_budget' do
      let(:base_requirements) { { 'structural_materials' => 1000, 'personnel' => 12 } }
      let(:isru_adjustments) { { reduced_imports: { 'structural_materials' => 300 }, timeline_acceleration: 45 } }
      let(:logistics_requirements) { { fuel_requirements: 500 } }

      it 'calculates comprehensive budget with ISRU savings' do
        budget = allocator.send(:calculate_startup_budget, base_requirements, isru_adjustments, logistics_requirements)

        expect(budget[:capital_expenditure]).to be > 0
        expect(budget[:operational_expenditure]).to be > 0
        expect(budget[:total_budget]).to eq(budget[:capital_expenditure] + budget[:operational_expenditure])
        expect(budget[:payback_period]).to be > 0
      end
    end

    describe '#estimate_bootstrap_timeline' do
      it 'provides accelerated timeline with ISRU benefits' do
        isru_adjustments = { timeline_acceleration: 45 }
        timeline = allocator.send(:estimate_bootstrap_timeline, settlement_plan, isru_adjustments)

        expect(timeline[:base_timeline]).to include(:planning_phase, :procurement_phase)
        expect(timeline[:accelerated_timeline]).to include(:planning_phase, :procurement_phase)
        expect(timeline[:total_duration]).to be > 0
        expect(timeline[:critical_path]).to be_an(Array)
      end
    end

    describe '#assess_bootstrap_risks' do
      it 'evaluates risks based on system characteristics' do
        risks = allocator.send(:assess_bootstrap_risks, settlement_plan, target_system)

        expect(risks[:technical_risks]).to be_an(Array)
        expect(risks[:logistical_risks]).to be_an(Array)
        expect(risks[:environmental_risks]).to be_an(Array)
        expect(risks[:overall_risk_level]).to be_in([:low, :medium, :high])
        expect(risks[:mitigation_strategies]).to be_an(Array)
      end

      it 'adjusts risk level based on risk count' do
        high_risk_system = target_system.merge(
          environmental_data: target_system[:environmental_data].merge(radiation_levels: 'high')
        )
        risks = allocator.send(:assess_bootstrap_risks, settlement_plan, high_risk_system)

        expect(risks[:environmental_risks]).to include('radiation_exposure')
        expect(risks[:mitigation_strategies]).to include('shielded_habitats')
      end
    end
  end

  describe 'economic calculations' do
    it 'calculates realistic capital costs' do
      requirements = { 'structural_materials' => 1000, 'power_systems' => 200 }
      costs = allocator.send(:calculate_capital_costs, requirements)

      expect(costs).to be > 0
      expect(costs).to eq(1000 * 100 + 200 * 1000) # material cost + power cost
    end

    it 'estimates operational costs' do
      requirements = { 'personnel' => 12 }
      logistics = { fuel_requirements: 500 }
      costs = allocator.send(:calculate_operational_costs, requirements, logistics)

      expect(costs).to be > 0
      expect(costs).to eq(12 * 50000 + 500 * 50 + 12 * 200 * 0.1) # personnel + fuel + maintenance
    end

    it 'calculates ISRU savings impact' do
      isru_adjustments = { reduced_imports: { 'structural_materials' => 300, 'life_support_supplies' => 200 } }
      savings = allocator.send(:calculate_isru_savings, isru_adjustments)

      expect(savings[:capital_reduction]).to be > 0
      expect(savings[:operational_reduction]).to be > 0
      expect(savings[:capital_reduction]).to be <= 0.3 # Max 30%
      expect(savings[:operational_reduction]).to be <= 0.4 # Max 40%
    end
  end
end