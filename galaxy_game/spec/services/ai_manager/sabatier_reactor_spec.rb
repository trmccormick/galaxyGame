# spec/services/ai_manager/sabatier_reactor_spec.rb
#
# Tests for Sabatier Reactor — CH4 production chain.
# Resource identifiers use chemical formulas (CH4, CO2, H2, H2O).

require 'rails_helper'

RSpec.describe 'Sabatier Reactor — CH4 Production Chain', type: :service do
  # Note: Blueprint structure, operational data, and deployment task file
  # format are tested by BlueprintLookupService and UnitLookupService specs.
  # This spec tests only service-level behavior unique to the Sabatier reactor.

  describe 'methane material data' do
    let(:material_id) { 'methane' }
    let(:material_data) { MaterialGeneratorService.generate_material(material_id) }

    it 'loads methane material data' do
      expect(material_data).not_to be_nil
      expect(material_data['id']).to eq('methane')
    end

    describe 'pricing.lunar_production' do
      it 'has available set to true' do
        lunar_prod = material_data.dig('pricing', 'lunar_production')
        expect(lunar_prod['available']).to be true
      end

      it 'requires sabatier_reactor facility' do
        lunar_prod = material_data.dig('pricing', 'lunar_production')
        expect(lunar_prod['facility_required']).to eq('sabatier_reactor')
      end

      it 'has cost_per_kg set' do
        lunar_prod = material_data.dig('pricing', 'lunar_production')
        expect(lunar_prod['cost_per_kg']).to be > 0
      end
    end
  end

  describe 'NpcPriceCalculator.can_produce_locally?' do
    let(:celestial_body) { create(:celestial_body, name: 'TestBody') }
    let(:location) { create(:celestial_location, celestial_body: celestial_body) }
    let(:settlement_no_facility) { create(:base_settlement, location: location) }

    it 'returns false for nil settlement' do
      result = Market::NpcPriceCalculator.send(:can_produce_locally?, nil, 'methane')
      expect(result).to be false
    end
  end
end
