# spec/services/ai_manager/network_optimizer_spec.rb
require 'rails_helper'
require './app/services/ai_manager/network_optimizer'

RSpec.describe AIManager::NetworkOptimizer do
  let(:shared_context) { double('SharedContext') }
  let(:optimizer) { described_class.new(shared_context) }

  let(:current_network) do
    {
      nodes: {
        'SOL' => { connected_systems: ['ALPHA_CENTAURI'] },
        'ALPHA_CENTAURI' => { connected_systems: ['SOL'] }
      },
      edges: [
        {
          from: 'SOL',
          to: 'ALPHA_CENTAURI',
          wormhole: double('Wormhole', id: 1, stability: 'stable'),
          capacity: 100000,
          traversable: true
        }
      ]
    }
  end

  let(:expansion_targets) do
    [
      {
        id: 2,
        identifier: 'PROXIMA_B',
        economic_value: 150000,
        strategic_value: 1.2,
        time_sensitive: false
      },
      {
        id: 3,
        identifier: 'BARNARDS_STAR',
        economic_value: 180000,
        strategic_value: 1.8,
        time_sensitive: true
      }
    ]
  end

  let(:economic_constraints) do
    {
      available_budget: 100000000,
      max_annual_investment: 20000000,
      planning_horizon: 5
    }
  end

  describe '#identify_network_priorities' do
    it 'analyzes network gaps and development priorities' do
      result = optimizer.identify_network_priorities(current_network, expansion_targets, economic_constraints)

      expect(result).to have_key(:network_gaps)
      expect(result).to have_key(:development_priorities)
      expect(result).to have_key(:optimized_sequence)
      expect(result).to have_key(:economic_impact)
      expect(result).to have_key(:implementation_roadmap)
    end

    it 'identifies network gaps for inaccessible targets' do
      result = optimizer.identify_network_priorities(current_network, expansion_targets, economic_constraints)

      gaps = result[:network_gaps]
      expect(gaps).to be_an(Array)
      expect(gaps.length).to eq(2)

      gaps.each do |gap|
        expect(gap).to have_key(:target_system)
        expect(gap).to have_key(:gap_type)
        expect(gap).to have_key(:economic_impact)
        expect(gap).to have_key(:development_cost)
        expect(gap).to have_key(:priority_score)
      end
    end

    it 'prioritizes gaps by economic impact and feasibility' do
      result = optimizer.identify_network_priorities(current_network, expansion_targets, economic_constraints)

      priorities = result[:development_priorities]
      expect(priorities).to be_an(Array)
      expect(priorities.length).to eq(2)

      # Should be sorted by priority (higher first)
      expect(priorities.first[:priority_score]).to be >= priorities.last[:priority_score]
    end

    it 'generates optimized development sequence' do
      result = optimizer.identify_network_priorities(current_network, expansion_targets, economic_constraints)

      sequence = result[:optimized_sequence]
      expect(sequence).to be_an(Array)
      expect(sequence.length).to be <= 2 # Limited by budget and time

      sequence.each do |item|
        expect(item).to have_key(:project)
        expect(item).to have_key(:phase)
        expect(item).to have_key(:scheduled_year)
        expect(item).to have_key(:funding_allocated)
      end
    end

    it 'calculates economic impact of development plan' do
      result = optimizer.identify_network_priorities(current_network, expansion_targets, economic_constraints)

      impact = result[:economic_impact]
      expect(impact).to have_key(:total_investment)
      expect(impact).to have_key(:net_present_value)
      expect(impact).to have_key(:benefit_cost_ratio)
      expect(impact).to have_key(:payback_period_years)
    end

    it 'provides implementation roadmap' do
      result = optimizer.identify_network_priorities(current_network, expansion_targets, economic_constraints)

      roadmap = result[:implementation_roadmap]
      expect(roadmap).to have_key(:phases)
      expect(roadmap).to have_key(:milestones)
      expect(roadmap).to have_key(:risks)
    end
  end

  describe '#optimize_network_economics' do
    let(:settlement_projects) do
      [
        {
          completion_year: 1,
          annual_economic_output: 50000,
          network_upgrade_year: 0
        },
        {
          completion_year: 2,
          annual_economic_output: 75000,
          network_upgrade_year: 1
        }
      ]
    end

    it 'models network evolution over time' do
      result = optimizer.optimize_network_economics(current_network, settlement_projects, 3)

      evolution = result[:network_evolution]
      expect(evolution).to be_an(Array)
      expect(evolution.length).to eq(4) # 0 to 3 years

      evolution.each do |year_state|
        expect(year_state).to have_key(:year)
        expect(year_state).to have_key(:active_wormholes)
        expect(year_state).to have_key(:connected_systems)
        expect(year_state).to have_key(:operational_settlements)
        expect(year_state).to have_key(:economic_output)
      end
    end

    it 'calculates economic scenarios' do
      result = optimizer.optimize_network_economics(current_network, settlement_projects, 3)

      scenarios = result[:economic_scenarios]
      expect(scenarios).to have_key(:baseline)
      expect(scenarios).to have_key(:optimistic)
      expect(scenarios).to have_key(:pessimistic)

      scenarios.each do |scenario, metrics|
        expect(metrics).to have_key(:total_economic_output)
        expect(metrics).to have_key(:peak_network_capacity)
        expect(metrics).to have_key(:average_annual_output)
      end
    end

    it 'finds optimal development path' do
      result = optimizer.optimize_network_economics(current_network, settlement_projects, 3)

      optimal_path = result[:optimal_path]
      expect(optimal_path).to have_key(:recommended_approach)
      expect(optimal_path).to have_key(:expected_npv)
      expect(optimal_path).to have_key(:confidence_interval)
    end

    it 'generates investment recommendations' do
      result = optimizer.optimize_network_economics(current_network, settlement_projects, 3)

      recommendations = result[:investment_recommendations]
      expect(recommendations).to be_an(Array)
      expect(recommendations.length).to be > 0

      recommendations.each do |rec|
        expect(rec).to have_key(:type)
        expect(rec).to have_key(:priority)
        expect(rec).to have_key(:description)
        expect(rec).to have_key(:investment_increase)
        expect(rec).to have_key(:expected_roi)
      end
    end

    it 'analyzes network risks' do
      # Create a network with potential issues
      risky_network = {
        nodes: { 'SOL' => { connected_systems: [] } },
        edges: [
          {
            wormhole: double('Wormhole', stability: 'unstable'),
            capacity: 50000
          }
        ]
      }

      result = optimizer.optimize_network_economics(risky_network, settlement_projects, 3)

      risks = result[:risk_analysis]
      expect(risks).to be_an(Array)
      expect(risks.length).to be > 0

      risks.each do |risk|
        expect(risk).to have_key(:type)
        expect(risk).to have_key(:severity)
        expect(risk).to have_key(:description)
        expect(risk).to have_key(:mitigation_cost)
        expect(risk).to have_key(:impact_probability)
      end
    end
  end

  describe 'private methods' do
    describe '#analyze_network_gaps' do
      it 'identifies gaps for each expansion target' do
        gaps = optimizer.send(:analyze_network_gaps, current_network, expansion_targets)

        expect(gaps).to be_an(Array)
        expect(gaps.length).to eq(2)

        gaps.each do |gap|
          expect(gap).to have_key(:target_system)
          expect(gap).to have_key(:gap_type)
          expect(gap).to have_key(:economic_impact)
          expect(gap).to have_key(:development_cost)
          expect(gap).to have_key(:priority_score)
        end
      end

      it 'calculates economic impact of network gaps' do
        gaps = optimizer.send(:analyze_network_gaps, current_network, expansion_targets)

        gap = gaps.first
        impact = gap[:economic_impact]

        expect(impact).to have_key(:potential_value)
        expect(impact).to have_key(:accessible_value)
        expect(impact).to have_key(:value_loss)
        expect(impact).to have_key(:annual_impact)
      end

      it 'estimates development costs' do
        gaps = optimizer.send(:analyze_network_gaps, current_network, expansion_targets)

        gap = gaps.first
        cost = gap[:development_cost]

        expect(cost).to have_key(:base_cost)
        expect(cost).to have_key(:complexity_multiplier)
        expect(cost).to have_key(:total_cost)
        expect(cost).to have_key(:annual_maintenance)
      end
    end

    describe '#calculate_development_priorities' do
      let(:gaps) do
        [
          {
            target_system: expansion_targets.first,
            economic_impact: { annual_impact: 30000 },
            development_cost: { total_cost: 50000000, annual_maintenance: 5000000 },
            gap_type: :complete_isolation
          }
        ]
      end

      it 'calculates ROI and feasibility metrics' do
        priorities = optimizer.send(:calculate_development_priorities, gaps, economic_constraints)

        expect(priorities).to be_an(Array)
        expect(priorities.length).to eq(1)

        priority = priorities.first
        expect(priority).to have_key(:payback_years)
        expect(priority).to have_key(:roi_percentage)
        expect(priority).to have_key(:budget_feasible)
        expect(priority).to have_key(:overall_feasibility)
      end

      it 'sorts priorities by feasibility and ROI' do
        multiple_gaps = gaps + [
          {
            target_system: expansion_targets.second,
            economic_impact: { annual_impact: 45000 },
            development_cost: { total_cost: 30000000, annual_maintenance: 3000000 },
            gap_type: :missing_intermediate_connections
          }
        ]

        priorities = optimizer.send(:calculate_development_priorities, multiple_gaps, economic_constraints)

        expect(priorities.first[:roi_percentage]).to be >= priorities.last[:roi_percentage]
      end
    end

    describe '#optimize_development_sequence' do
      let(:priorities) do
        [
          {
            target_system: expansion_targets.first,
            overall_feasibility: true,
            payback_years: 3,
            development_cost: { total_cost: 30000000 },
            budget_feasible: true
          },
          {
            target_system: expansion_targets.second,
            overall_feasibility: false,
            payback_years: 5,
            development_cost: { total_cost: 80000000 },
            budget_feasible: false
          }
        ]
      end

      it 'sequences projects by phase and feasibility' do
        sequence = optimizer.send(:optimize_development_sequence, priorities, economic_constraints)

        expect(sequence).to be_an(Array)
        expect(sequence.length).to eq(2)

        # First project should be feasible
        expect(sequence.first[:project][:overall_feasibility]).to be true
        expect(sequence.first[:phase]).to eq(1)
      end

      it 'respects budget constraints' do
        limited_budget = { available_budget: 20000000, max_annual_investment: 20000000, planning_horizon: 5 }

        sequence = optimizer.send(:optimize_development_sequence, priorities, limited_budget)

        total_allocated = sequence.sum { |item| item[:funding_allocated] }
        expect(total_allocated).to be <= limited_budget[:available_budget]
      end
    end

    describe '#calculate_economic_impact' do
      let(:sequence) do
        [
          {
            project: {
              net_annual_benefit: 10000000
            },
            funding_allocated: 50000000
          }
        ]
      end

      it 'calculates NPV and ROI metrics' do
        impact = optimizer.send(:calculate_economic_impact, sequence, current_network)

        expect(impact).to have_key(:total_investment)
        expect(impact).to have_key(:net_present_value)
        expect(impact).to have_key(:benefit_cost_ratio)
        expect(impact).to have_key(:payback_period_years)
      end

      it 'accounts for multiple projects' do
        multi_sequence = sequence + [
          {
            project: {
              net_annual_benefit: 8000000
            },
            funding_allocated: 40000000
          }
        ]

        impact = optimizer.send(:calculate_economic_impact, multi_sequence, current_network)

        expect(impact[:total_investment]).to eq(90000000)
        expect(impact[:net_present_value]).to be > 0
      end
    end

    describe '#generate_implementation_roadmap' do
      let(:sequence) do
        [
          {
            project: { target_system: { name: 'Test System' } },
            phase: 1,
            scheduled_year: 0,
            funding_allocated: 50000000
          }
        ]
      end

      it 'organizes projects by phases' do
        roadmap = optimizer.send(:generate_implementation_roadmap, sequence)

        expect(roadmap).to have_key(:phases)
        expect(roadmap[:phases]).to have_key(1)

        phase_info = roadmap[:phases][1]
        expect(phase_info).to have_key(:name)
        expect(phase_info).to have_key(:duration_years)
        expect(phase_info).to have_key(:projects)
        expect(phase_info).to have_key(:total_investment)
      end

      it 'generates milestone timeline' do
        roadmap = optimizer.send(:generate_implementation_roadmap, sequence)

        expect(roadmap).to have_key(:milestones)
        expect(roadmap[:milestones]).to be_an(Array)
        expect(roadmap[:milestones].length).to eq(1)

        milestone = roadmap[:milestones].first
        expect(milestone).to have_key(:year)
        expect(milestone).to have_key(:project)
        expect(milestone).to have_key(:investment)
      end

      it 'identifies implementation risks' do
        roadmap = optimizer.send(:generate_implementation_roadmap, sequence)

        expect(roadmap).to have_key(:risks)
        expect(roadmap[:risks]).to be_an(Array)
      end
    end

    describe '#analyze_network_gaps sub-methods' do
      let(:target) { expansion_targets.first }

      describe '#check_network_accessibility' do
        it 'returns accessible for connected systems' do
          # Add target to current network
          accessible_network = current_network.merge(
            nodes: current_network[:nodes].merge(
              'PROXIMA_B' => { connected_systems: ['SOL'] }
            )
          )

          result = optimizer.send(:check_network_accessibility, accessible_network, target)

          expect(result[:accessible]).to be true
          expect(result[:path_length]).to eq(0)
        end

        it 'identifies indirect connections' do
          result = optimizer.send(:check_network_accessibility, current_network, target)

          expect(result[:accessible]).to be false
          expect(result[:connection_type]).to eq(:indirect)
        end
      end

      describe '#analyze_accessibility_gap' do
        let(:accessibility) do
          {
            connection_type: :indirect,
            required_hops: [{ from: 'SOL', to: 'PROXIMA_B' }]
          }
        end

        it 'analyzes gap characteristics' do
          gap = optimizer.send(:analyze_accessibility_gap, current_network, target, accessibility)

          expect(gap).to have_key(:gap_type)
          expect(gap).to have_key(:missing_connections)
          expect(gap).to have_key(:development_approach)
          expect(gap).to have_key(:complexity)
        end
      end

      describe '#calculate_gap_economic_impact' do
        let(:gap_analysis) do
          {
            gap_type: :complete_isolation,
            complexity: :high
          }
        end

        it 'quantifies economic impact of gaps' do
          impact = optimizer.send(:calculate_gap_economic_impact, target, gap_analysis)

          expect(impact).to have_key(:potential_value)
          expect(impact).to have_key(:accessible_value)
          expect(impact).to have_key(:value_loss)
          expect(impact).to have_key(:annual_impact)

          expect(impact[:value_loss]).to be > 0
          expect(impact[:annual_impact]).to be > 0
        end
      end

      describe '#estimate_development_cost' do
        let(:gap_analysis) do
          {
            missing_connections: [1, 2], # Two connections needed
            complexity: :medium
          }
        end

        it 'estimates development and maintenance costs' do
          cost = optimizer.send(:estimate_development_cost, gap_analysis)

          expect(cost).to have_key(:base_cost)
          expect(cost).to have_key(:complexity_multiplier)
          expect(cost).to have_key(:connection_multiplier)
          expect(cost).to have_key(:total_cost)
          expect(cost).to have_key(:annual_maintenance)

          expect(cost[:total_cost]).to be > cost[:base_cost]
        end
      end
    end
  end
end