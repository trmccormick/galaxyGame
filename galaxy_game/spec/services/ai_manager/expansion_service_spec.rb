# spec/services/ai_manager/expansion_service_spec.rb
require 'rails_helper'
require Rails.root.join('app/services/ai_manager/expansion_service')
require Rails.root.join('app/services/ai_manager/settlement_plan_generator')
require Rails.root.join('app/services/ai_manager/probe_deployment_service')

RSpec.describe AIManager::ExpansionService do
  describe '.expand_with_intelligence' do
    let(:target_system) do
      {
        identifier: 'SOL-001',
        stars: [{ type: 'G-type main-sequence' }],
        celestial_bodies: {
          terrestrial_planets: [
            {
              identifier: 'SOL-001-III',
              type: 'planet',
              resources: ['iron', 'nickel'],
              atmosphere: 'thin',
              surface_accessible: true
            }
          ],
          gas_giants: [
            {
              identifier: 'SOL-001-V',
              type: 'gas_giant',
              moons: [
                {
                  identifier: 'SOL-001-V-A',
                  type: 'moon',
                  size: 'large',
                  resources: ['water_ice', 'methane'],
                  composition: 'icy'
                }
              ]
            }
          ]
        }
      }
    end

    let(:settlement) { double('settlement', id: 1) }

    it 'successfully expands with probe deployment and asteroid tug integration' do
      result = described_class.expand_with_intelligence(target_system, settlement)

      expect(result[:status]).to eq(:success)
      expect(result[:plan]).to be_present
      expect(result[:probe_data]).to be_present
    end

    it 'generates settlement plan with appropriate mission type' do
      result = described_class.expand_with_intelligence(target_system)

      expect(result[:plan][:mission_type]).to be_present
      expect(result[:plan][:target_body]).to be_present
      expect(result[:plan][:strategy]).to be_present
    end

    it 'includes probe data in the result' do
      result = described_class.expand_with_intelligence(target_system)

      expect(result[:probe_data]).to include(:collection_period_days, :probes_deployed, :data_types, :findings)
      expect(result[:probe_data][:findings]).to include(:system_survey, :resource_assessment, :threat_assessment)
    end

    context 'with moon target' do
      let(:moon_target_system) do
        {
          identifier: 'NEP-001',
          stars: [{ type: 'M-type main-sequence' }],
          celestial_bodies: {
            ice_giants: [
              {
                identifier: 'NEP-001-VIII',
                type: 'ice_giant',
                moons: [
                  {
                    identifier: 'NEP-001-VIII-I',
                    type: 'moon',
                    size: 'large',
                    mass: 2.14e22, # Triton-like
                    resources: ['water_ice', 'nitrogen'],
                    composition: 'icy'
                  }
                ]
              }
            ]
          }
        }
      end

      it 'includes asteroid tug configuration for moon targets' do
        result = described_class.expand_with_intelligence(moon_target_system)

        expect(result[:plan][:specialized_craft]).to be_present
        expect(result[:plan][:specialized_craft].first[:type]).to eq('asteroid_relocation_tug')
        expect(result[:plan][:phases]).to include('asteroid_capture_and_conversion')
      end

      it 'selects appropriate tug mission based on moon size' do
        result = described_class.expand_with_intelligence(moon_target_system)

        tug_config = result[:plan][:specialized_craft].first
        expect(tug_config[:mission]).to eq('capture_and_hollow_for_depot')
      end
    end

    context 'with asteroid target' do
      let(:asteroid_target_system) do
        {
          identifier: 'BELT-001',
          stars: [{ type: 'G-type main-sequence' }],
          celestial_bodies: {
            asteroids: [
              {
                identifier: 'BELT-001-A001',
                type: 'asteroid',
                mass: 1e12, # Medium asteroid
                resources: ['nickel', 'iron', 'platinum'],
                composition: 'metallic'
              }
            ]
          }
        }
      end

      it 'includes asteroid tug for asteroid targets' do
        result = described_class.expand_with_intelligence(asteroid_target_system)

        expect(result[:plan][:specialized_craft]).to be_present
        expect(result[:plan][:specialized_craft].first[:type]).to eq('asteroid_relocation_tug')
      end
    end

    it 'links to appropriate mission profile based on system characteristics' do
      result = described_class.expand_with_intelligence(target_system)

      expect(result[:plan][:mission_profile]).to be_present
      expect(result[:plan][:cycler_config]).to be_present
    end

    it 'calculates success probability and ROI' do
      result = described_class.expand_with_intelligence(target_system)

      expect(result[:plan][:success_probability]).to be_a(Float)
      expect(result[:plan][:roi_years]).to be_a(Numeric)
      expect(result[:plan][:success_probability]).to be_between(0.0, 1.0)
    end
  end

  describe '.expand_with_pattern (legacy)' do
    let(:settlement) { double('settlement', id: 1) }
    let(:pattern) do
      {
        pattern_id: 'test_pattern',
        equipment_requirements: { total_unit_count: 5 },
        economic_model: { estimated_gcc_cost: 50000 },
        deployment_sequence: [
          { phase_name: 'initial_deployment' },
          { phase_name: 'resource_extraction' }
        ]
      }
    end

    before do
      allow(described_class).to receive(:settlement_funds).and_return(100000)
    end

    it 'expands settlement with pattern when suitable' do
      result = described_class.expand_with_pattern(settlement, pattern)

      expect(result[:status]).to eq(:success)
      expect(result[:pattern]).to eq('test_pattern')
    end

    it 'fails expansion when pattern is not suitable' do
      unsuitable_pattern = pattern.merge(equipment_requirements: { total_unit_count: 0 })

      result = described_class.expand_with_pattern(settlement, unsuitable_pattern)

      expect(result[:status]).to eq(:failed)
      expect(result[:reason]).to eq(:pattern_not_suitable)
    end
  end
end