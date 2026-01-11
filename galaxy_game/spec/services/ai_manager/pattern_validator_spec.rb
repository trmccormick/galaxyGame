# spec/services/ai_manager/pattern_validator_spec.rb
require_relative '../../../app/services/ai_manager'

require 'rails_helper'

RSpec.describe AIManager::PatternValidator do
  let(:earth_data) do
    {
      'name' => 'Earth',
      'type' => 'terrestrial',
      'surface_temperature' => 288,
      'known_pressure' => 1.0,
      'gravity' => 1.0,
      'atmosphere_attributes' => {
        'nitrogen' => { 'percentage' => 78.0 },
        'oxygen' => { 'percentage' => 21.0 },
        'argon' => { 'percentage' => 0.9 }
      },
      'materials' => [
        { 'name' => 'regolith', 'abundance' => 1.0 },
        { 'name' => 'water', 'abundance' => 0.7 }
      ],
      'geological_features' => ['volcanic', 'impact craters']
    }
  end

  let(:validator) { described_class.new(earth_data) }

  describe '#validate_pattern' do
    context 'with a valid pattern' do
      let(:valid_pattern) do
        {
          equipment_requirements: {
            craft_fit: {
              modules: ['compact_nuclear_reactor (4)', 'oxygen_generator (2)', 'water_extractor (1)'], # More power + ISRU
              units: ['modular_habitat_unit (2)']
            },
            inventory: {
              deployable_units: ['mrr_200_maintenance_repair_eva_mk1 (1)'],
              supplies: ['enriched_uranium_fuel (1000 kilogram)'],
              consumables: ['oxygen (4000 kilogram)', 'water (14000 kilogram)', 'food (10000 day)'],
              total_mass: '1500 kg'
            }
          },
          phase_structure: {
            estimated_total_duration: 720 # 30 days
          },
          economic_model: {
            estimated_cost: 1000000,
            import_ratio: 0.3
          }
        }
      end

      it 'returns valid status for well-formed pattern' do
        result = validator.validate_pattern(valid_pattern)

        # With world knowledge, patterns may need review even if well-formed
        expect(result[:valid]).to be true
        expect(result[:confidence]).to be > 0.5 # Lowered expectation due to world-aware validation
      end
    end

    context 'with insufficient life support' do
      let(:insufficient_resources_pattern) do
        {
          equipment_requirements: {
            craft_fit: {
              units: ['modular_habitat_unit (1)'] # 1 habitat = ~3 crew
            },
            inventory: {
              consumables: ['oxygen (10 kilogram)', 'water (20 kilogram)'], # Not enough for 30 days
              total_mass: '500 kg'
            }
          },
          phase_structure: {
            estimated_total_duration: 720 # 30 days
          },
          economic_model: {
            estimated_cost: 500000
          }
        }
      end

      it 'flags insufficient resources' do
        result = validator.validate_pattern(insufficient_resources_pattern)

        expect(result[:valid]).to be false # Now invalid due to world-aware validation
        expect(result[:errors]).to include(
          a_hash_including(
            rule: :resource_sufficiency,
            message: /insufficient/i
          )
        )
      end
    end

    context 'with invalid equipment IDs' do
      let(:invalid_equipment_pattern) do
        {
          equipment_requirements: {
            craft_fit: {
              modules: ['a (1)'] # Very short invalid ID
            }
          },
          phase_structure: {
            estimated_total_duration: 24
          }
        }
      end

      it 'flags invalid equipment' do
        result = validator.validate_pattern(invalid_equipment_pattern)

        expect(result[:valid]).to be false
        expect(result[:status]).to eq(:invalid)
        expect(result[:errors]).to include(
          a_hash_including(
            rule: :equipment_feasibility,
            message: /not found/i
          )
        )
      end
    end

    context 'with unrealistic cost' do
      let(:expensive_pattern) do
        {
          equipment_requirements: {
            inventory: {
              consumables: ['oxygen (100 kilogram)', 'water (100 kilogram)', 'food (100 day)']
            }
          },
          economic_model: {
            estimated_cost: 100_000_000 # 100 million GCC
          },
          phase_structure: {
            estimated_total_duration: 24
          }
        }
      end

      it 'flags suspicious costs' do
        result = validator.validate_pattern(expensive_pattern)

        expect(result[:valid]).to be true # Valid but with warnings
        expect(result[:warnings]).to include(
          a_hash_including(
            rule: :economic_viability,
            message: /extremely high/i
          )
        )
      end
    end

    context 'with aggressive timeline' do
      let(:aggressive_timeline_pattern) do
        {
          equipment_requirements: {
            inventory: {
              consumables: ['oxygen (100 kilogram)', 'water (100 kilogram)', 'food (100 day)']
            }
          },
          phase_structure: {
            estimated_total_duration: 10 # 10 hours for 3 phases
          },
          deployment_sequence: [
            { phase_id: 'phase1' },
            { phase_id: 'phase2' },
            { phase_id: 'phase3' }
          ]
        }
      end

      it 'flags unrealistic timelines' do
        result = validator.validate_pattern(aggressive_timeline_pattern)

        expect(result[:valid]).to be true # Valid but with warnings
        expect(result[:warnings]).to include(
          a_hash_including(
            rule: :timeline_realistic,
            message: /too aggressive/i
          )
        )
      end
    end
  end

  describe 'helper methods' do
    describe '#extract_id' do
      it 'extracts ID from formatted strings' do
        expect(validator.send(:extract_id, 'Robotic Unit (5)')).to eq('Robotic Unit')
        expect(validator.send(:extract_id, 'simple_id')).to eq('simple_id')
      end
    end

    describe '#estimate_crew_size' do
      it 'estimates crew based on habitat units' do
        pattern = {
          equipment_requirements: {
            craft_fit: {
              units: ['modular_habitat_unit (2)'] # 2 habitats
            }
          }
        }

        crew = validator.send(:estimate_crew_size, pattern)
        expect(crew).to eq(6) # 2 * 3 people per habitat
      end

      it 'reduces crew estimate with robots' do
        pattern = {
          equipment_requirements: {
            craft_fit: {
              units: ['modular_habitat_unit (2)', 'construction_robot (4)']
            }
          }
        }

        crew = validator.send(:estimate_crew_size, pattern)
        expect(crew).to eq(4) # 6 - (4 * 0.5) automation bonus
      end
    end

    describe '#find_consumable_amount' do
      it 'extracts amounts from consumable strings' do
        consumables = ['oxygen (100 kilogram)', 'water (50 liter)']

        oxygen = validator.send(:find_consumable_amount, consumables, 'oxygen')
        water = validator.send(:find_consumable_amount, consumables, 'water')

        expect(oxygen).to eq(100)
        expect(water).to eq(50)
      end
    end
  end
end