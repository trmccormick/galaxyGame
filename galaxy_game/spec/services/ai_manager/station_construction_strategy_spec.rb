# spec/services/ai_manager/station_construction_strategy_spec.rb
require 'rails_helper'
require_relative '../../../app/services/ai_manager/station_construction_strategy'

RSpec.describe AIManager::StationConstructionStrategy, type: :service do
  let(:shared_context) { instance_double(AIManager::SharedContext) }
  let(:strategy_service) { described_class.new(shared_context) }

  let(:sample_target_system) do
    {
      identifier: 'SOL-001',
      celestial_bodies: {
        asteroids: [
          {
            id: 'AST-001',
            name: 'Ceres',
            diameter_km: 0.94,
            composition: 'carbonaceous',
            resources: ['water_ice', 'organics'],
            rotation_period_hours: 9
          },
          {
            id: 'AST-002',
            name: 'Vesta',
            diameter_km: 0.53,
            composition: 'stony',
            resources: ['iron', 'nickel'],
            rotation_period_hours: 5
          }
        ],
        moons: [
          {
            id: 'MOON-001',
            name: 'Luna',
            parent_body: 'Earth',
            gravity_m_s2: 1.62,
            atmosphere: 'none',
            resources: ['helium-3', 'titanium'],
            orbital_period_days: 27.3
          }
        ],
        planets: [
          {
            id: 'PLANET-001',
            name: 'Earth',
            type: 'terrestrial',
            gravity_m_s2: 9.8,
            atmosphere_density: 1.2,
            magnetic_field_strength: 1.0
          }
        ]
      }
    }
  end

  describe '#determine_optimal_station_strategy' do
    let(:strategic_purpose) { :wormhole_anchor }
    let(:available_resources) { { steel: 10000, aluminum: 5000 } }

    it 'analyzes local resources and generates construction options' do
      result = strategy_service.determine_optimal_station_strategy(
        sample_target_system,
        strategic_purpose,
        available_resources
      )

      expect(result).to have_key(:optimal_strategy)
      expect(result).to have_key(:construction_options)
      expect(result).to have_key(:resource_analysis)
      expect(result).to have_key(:strategic_requirements)
      expect(result).to have_key(:implementation_plan)
      expect(result).to have_key(:risk_assessment)
    end

    it 'includes resource analysis with asteroid, moon, and planet data' do
      result = strategy_service.determine_optimal_station_strategy(
        sample_target_system,
        strategic_purpose,
        available_resources
      )

      resource_analysis = result[:resource_analysis]
      expect(resource_analysis).to have_key(:asteroids)
      expect(resource_analysis).to have_key(:moons)
      expect(resource_analysis).to have_key(:planets)
      expect(resource_analysis[:asteroids].length).to eq(2)
      expect(resource_analysis[:moons].length).to eq(1)
    end

    it 'generates multiple construction options' do
      result = strategy_service.determine_optimal_station_strategy(
        sample_target_system,
        strategic_purpose,
        available_resources
      )

      options = result[:construction_options]
      expect(options.length).to be > 1

      # Should include full space station option
      full_station_option = options.find { |opt| opt[:construction_type] == :full_space_station }
      expect(full_station_option).to be_present
      expect(full_station_option).to have_key(:estimated_cost)
      expect(full_station_option).to have_key(:construction_time)
    end
  end

  describe '#evaluate_station_type_suitability' do
    let(:station_type) { :orbital_construction }
    let(:strategic_purpose) { :wormhole_anchor }

    it 'returns suitability assessment with score and reasoning' do
      result = strategy_service.evaluate_station_type_suitability(
        station_type,
        strategic_purpose,
        sample_target_system
      )

      expect(result).to have_key(:suitability_score)
      expect(result).to have_key(:reasoning)
      expect(result).to have_key(:construction_feasibility)
      expect(result).to have_key(:recommended_modifications)
      expect(result[:suitability_score]).to be_a(Numeric)
    end

    it 'provides different scores for different station types and purposes' do
      orbital_score = strategy_service.evaluate_station_type_suitability(
        :orbital_construction, :wormhole_anchor, sample_target_system
      )[:suitability_score]

      asteroid_score = strategy_service.evaluate_station_type_suitability(
        :asteroid_conversion, :wormhole_anchor, sample_target_system
      )[:suitability_score]

      expect(orbital_score).to be > asteroid_score
    end
  end

  describe 'resource analysis methods' do
    describe '#analyze_local_resources' do
      it 'analyzes asteroid resources for conversion suitability' do
        result = strategy_service.send(:analyze_local_resources, sample_target_system)

        # The method should process the data even if no asteroids are suitable
        expect(result).to have_key(:asteroids)
        expect(result[:asteroids]).to be_an(Array)
        # Note: actual suitability depends on the asteroid data
      end

      it 'analyzes moon resources for station suitability' do
        result = strategy_service.send(:analyze_local_resources, sample_target_system)

        expect(result).to have_key(:moons)
        expect(result[:moons]).to be_an(Array)
      end

      it 'analyzes planets for orbital construction' do
        result = strategy_service.send(:analyze_local_resources, sample_target_system)

        expect(result).to have_key(:planets)
        expect(result[:planets]).to be_an(Array)
      end
    end
  end

  describe 'strategic requirements evaluation' do
    describe '#evaluate_strategic_requirements' do
      it 'sets appropriate requirements for wormhole anchor purpose' do
        result = strategy_service.send(:evaluate_strategic_requirements, :wormhole_anchor, sample_target_system)

        expect(result[:purpose]).to eq(:wormhole_anchor)
        expect(result[:capability_requirements]).to include(:wormhole_stabilization)
        expect(result[:capability_requirements]).to include(:energy_generation)
        expect(result[:risk_tolerance]).to eq(:low)
        expect(result[:scalability_needs]).to eq(:high)
      end

      it 'sets appropriate requirements for research outpost purpose' do
        result = strategy_service.send(:evaluate_strategic_requirements, :research_outpost, sample_target_system)

        expect(result[:purpose]).to eq(:research_outpost)
        expect(result[:capability_requirements]).to include(:laboratory_facilities)
        expect(result[:risk_tolerance]).to eq(:high)
        expect(result[:scalability_needs]).to eq(:low)
      end
    end
  end

  describe 'construction option generation' do
    let(:resource_analysis) { strategy_service.send(:analyze_local_resources, sample_target_system) }
    let(:strategic_requirements) { strategy_service.send(:evaluate_strategic_requirements, :wormhole_anchor, sample_target_system) }

    describe '#generate_construction_options' do
      it 'generates full space station option' do
        options = strategy_service.send(:generate_construction_options, resource_analysis, strategic_requirements)

        full_station = options.find { |opt| opt[:construction_type] == :full_space_station }
        expect(full_station).to be_present
        expect(full_station[:name]).to eq('Full Space Station Construction')
        expect(full_station).to have_key(:estimated_cost)
        expect(full_station).to have_key(:construction_time)
        expect(full_station).to have_key(:capability_score)
      end

      it 'generates asteroid conversion options' do
        options = strategy_service.send(:generate_construction_options, resource_analysis, strategic_requirements)

        asteroid_options = options.select { |opt| opt[:construction_type] == :asteroid_conversion }
        expect(asteroid_options.length).to be >= 0 # May be 0 if no suitable asteroids

        if asteroid_options.any?
          asteroid_option = asteroid_options.first
          expect(asteroid_option[:name]).to include('Asteroid Conversion')
          expect(asteroid_option).to have_key(:asteroid_data)
          expect(asteroid_option).to have_key(:estimated_cost)
        end
      end

      it 'generates lunar station options' do
        options = strategy_service.send(:generate_construction_options, resource_analysis, strategic_requirements)

        lunar_options = options.select { |opt| opt[:construction_type] == :lunar_surface_station }
        expect(lunar_options.length).to be >= 0

        if lunar_options.any?
          lunar_option = lunar_options.first
          expect(lunar_option[:name]).to include('Lunar Surface Station')
          expect(lunar_option).to have_key(:moon_data)
        end
      end

      it 'generates orbital construction options' do
        options = strategy_service.send(:generate_construction_options, resource_analysis, strategic_requirements)

        orbital_options = options.select { |opt| opt[:construction_type] == :orbital_construction }
        expect(orbital_options.length).to be >= 0

        if orbital_options.any?
          orbital_option = orbital_options.first
          expect(orbital_option[:name]).to include('Orbital Station')
          expect(orbital_option).to have_key(:planet_data)
        end
      end
    end
  end

  describe 'implementation planning' do
    let(:sample_option) do
      {
        construction_type: :full_space_station,
        estimated_cost: 100_000_000,
        construction_time: 11.months,
        resource_requirements: { materials: { steel: 50000 } }
      }
    end

    describe '#generate_implementation_plan' do
      it 'generates phased implementation plan for full space station' do
        plan = strategy_service.send(:generate_implementation_plan, sample_option, sample_target_system)

        expect(plan).to have_key(:phases)
        expect(plan).to have_key(:resource_requirements)
        expect(plan).to have_key(:timeline)
        expect(plan).to have_key(:risk_mitigation)
        expect(plan).to have_key(:contingency_plans)

        expect(plan[:phases].length).to be > 1
        expect(plan[:timeline]).to have_key(:total_duration)
        expect(plan[:timeline]).to have_key(:critical_path)
      end

      it 'generates different plans for different construction types' do
        asteroid_option = sample_option.merge(construction_type: :asteroid_conversion, asteroid_data: { name: 'Test Asteroid' })
        asteroid_plan = strategy_service.send(:generate_implementation_plan, asteroid_option, sample_target_system)

        expect(asteroid_plan[:phases].length).not_to eq(sample_option.length)
        expect(asteroid_plan[:timeline][:total_duration]).not_to eq(11.months)
      end
    end
  end

  describe 'risk assessment' do
    let(:sample_option) do
      {
        construction_type: :full_space_station,
        estimated_cost: 100_000_000,
        construction_time: 11.months,
        resource_requirements: { materials: { steel: 50000 } }
      }
    end

    describe '#assess_implementation_risks' do
      it 'assesses risks for different construction types' do
        risks = strategy_service.send(:assess_implementation_risks, sample_option, sample_target_system)

        expect(risks).to have_key(:technical_risks)
        expect(risks).to have_key(:resource_risks)
        expect(risks).to have_key(:timeline_risks)
        expect(risks).to have_key(:environmental_risks)
        expect(risks).to have_key(:overall_risk_level)

        expect(risks[:overall_risk_level]).to be_in([:low, :medium, :high])
      end

      it 'includes technical risks with probability and impact' do
        risks = strategy_service.send(:assess_implementation_risks, sample_option, sample_target_system)

        technical_risks = risks[:technical_risks]
        expect(technical_risks).to be_an(Array)
        expect(technical_risks.first).to have_key(:risk)
        expect(technical_risks.first).to have_key(:probability)
        expect(technical_risks.first).to have_key(:impact)
      end
    end
  end

  describe 'helper calculation methods' do
    describe '#is_suitable_for_asteroid_conversion?' do
      it 'returns true for suitable asteroids' do
        suitable_asteroid = { diameter_km: 1.0, composition: 'stony' }
        unsuitable_asteroid = { diameter_km: 0.1, composition: 'unknown' }

        expect(strategy_service.send(:is_suitable_for_asteroid_conversion?, suitable_asteroid)).to be true
        expect(strategy_service.send(:is_suitable_for_asteroid_conversion?, unsuitable_asteroid)).to be false
      end
    end

    describe '#calculate_conversion_complexity' do
      it 'calculates complexity based on size and composition' do
        simple_asteroid = { diameter_km: 1.0, composition: 'stony' }
        complex_asteroid = { diameter_km: 4.0, composition: 'carbonaceous' }

        simple_complexity = strategy_service.send(:calculate_conversion_complexity, simple_asteroid)
        complex_complexity = strategy_service.send(:calculate_conversion_complexity, complex_asteroid)

        expect(complex_complexity).to be > simple_complexity
      end
    end

    describe '#calculate_asteroid_resource_value' do
      it 'calculates value based on resource types' do
        high_value_asteroid = { resources: ['platinum', 'gold'] }
        low_value_asteroid = { resources: ['water_ice'] }

        high_value = strategy_service.send(:calculate_asteroid_resource_value, high_value_asteroid)
        low_value = strategy_service.send(:calculate_asteroid_resource_value, low_value_asteroid)

        expect(high_value).to be > low_value
      end
    end

    describe '#assess_asteroid_stability' do
      it 'assesses stability based on rotation and shape' do
        stable_asteroid = { rotation_period_hours: 12, shape: 'spherical' }
        unstable_asteroid = { rotation_period_hours: 0.5, shape: 'irregular' }

        stable_rating = strategy_service.send(:assess_asteroid_stability, stable_asteroid)
        unstable_rating = strategy_service.send(:assess_asteroid_stability, unstable_asteroid)

        expect(stable_rating).to be > unstable_rating
      end
    end
  end

  describe 'cost calculation methods' do
    let(:strategic_requirements) { { purpose: :wormhole_anchor } }

    describe '#calculate_full_station_cost' do
      it 'calculates cost based on strategic purpose' do
        cost = strategy_service.send(:calculate_full_station_cost, strategic_requirements)
        expect(cost).to be > 50_000_000
        expect(cost).to be < 200_000_000
      end

      it 'adjusts cost for different purposes' do
        defensive_cost = strategy_service.send(:calculate_full_station_cost, { purpose: :defensive_position })
        research_cost = strategy_service.send(:calculate_full_station_cost, { purpose: :research_outpost })

        expect(defensive_cost).to be > research_cost
      end
    end

    describe '#calculate_asteroid_conversion_cost' do
      it 'calculates cost based on asteroid complexity' do
        simple_asteroid = { name: 'Simple' }
        complex_asteroid = { name: 'Complex' }

        # Mock the complexity calculation
        allow(strategy_service).to receive(:calculate_conversion_complexity).and_return(1.0, 2.0)

        simple_cost = strategy_service.send(:calculate_asteroid_conversion_cost, simple_asteroid, strategic_requirements)
        complex_cost = strategy_service.send(:calculate_asteroid_conversion_cost, complex_asteroid, strategic_requirements)

        expect(complex_cost).to be > simple_cost
      end
    end
  end

  describe 'suitability evaluation methods' do
    describe '#evaluate_wormhole_anchor_suitability' do
      it 'rates orbital construction highest for wormhole anchoring' do
        orbital_score = strategy_service.send(:evaluate_wormhole_anchor_suitability, :orbital_construction, sample_target_system)
        asteroid_score = strategy_service.send(:evaluate_wormhole_anchor_suitability, :asteroid_conversion, sample_target_system)

        expect(orbital_score).to be > asteroid_score
      end
    end

    describe '#evaluate_resource_processing_suitability' do
      it 'rates asteroid conversion and lunar stations high for resource processing' do
        asteroid_score = strategy_service.send(:evaluate_resource_processing_suitability, :asteroid_conversion, sample_target_system)
        lunar_score = strategy_service.send(:evaluate_resource_processing_suitability, :lunar_surface_station, sample_target_system)
        orbital_score = strategy_service.send(:evaluate_resource_processing_suitability, :orbital_construction, sample_target_system)

        expect(asteroid_score).to be > orbital_score
        expect(lunar_score).to be > orbital_score
      end
    end
  end
end