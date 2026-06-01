# frozen_string_literal: true

require 'rails_helper'

describe Settlements::CostAnalyzer do
  let(:settlement) { instance_double('Settlement::BaseSettlement') }
  let(:marketplace) { instance_double('Market::Marketplace') }

  before do
    allow(settlement).to receive(:marketplace).and_return(marketplace); allow(marketplace).to receive(:current_market_condition).and_return(nil)
  end

  describe '.compare_costs' do
    context 'happy path: known resource with market data' do
      it 'returns correct cost comparison and recommendation' do
        allow(Settlements::CostAnalyzer).to receive(:local_production_cost).and_return(100.0)
        allow(Settlements::CostAnalyzer).to receive(:current_import_price).and_return(120.0)
        result = described_class.compare_costs('Steel', settlement)
        expect(result[:local_cost]).to eq(100.0)
        expect(result[:import_cost]).to eq(120.0)
        expect(result[:recommendation]).to eq(:produce_locally)
        expect(result[:local_cheaper]).to be true
        expect(result[:cost_delta]).to eq(20.0)
        expect(result[:confidence]).to eq(:high)
      end
    end

    context 'no market data' do
      it 'handles missing market data gracefully' do
        allow(Settlements::CostAnalyzer).to receive(:local_production_cost).and_return(100.0)
        allow(Settlements::CostAnalyzer).to receive(:current_import_price).and_return(nil)
        result = described_class.compare_costs('Steel', settlement)
        expect(result[:import_cost]).to be_nil
        expect(result[:confidence]).to eq(:low)
        expect(result[:recommendation]).to eq(:produce_locally)
      end
    end

    context 'import cheaper' do
      it 'recommends import when import is cheaper' do
        allow(Settlements::CostAnalyzer).to receive(:local_production_cost).and_return(150.0)
        allow(Settlements::CostAnalyzer).to receive(:current_import_price).and_return(100.0)
        result = described_class.compare_costs('Steel', settlement)
        expect(result[:recommendation]).to eq(:import)
        expect(result[:local_cheaper]).to be false
      end
    end

    context 'local cheaper' do
      it 'recommends local production when local is cheaper' do
        allow(Settlements::CostAnalyzer).to receive(:local_production_cost).and_return(80.0)
        allow(Settlements::CostAnalyzer).to receive(:current_import_price).and_return(120.0)
        result = described_class.compare_costs('Steel', settlement)
        expect(result[:recommendation]).to eq(:produce_locally)
        expect(result[:local_cheaper]).to be true
      end
    end

    context 'unknown resource' do
      it 'handles missing blueprint gracefully' do
        allow(Settlements::CostAnalyzer).to receive(:local_production_cost).and_return(nil)
        result = described_class.compare_costs('Unobtainium', settlement)
        expect(result[:recommendation]).to eq(:error)
        expect(result[:confidence]).to eq(:low)
        expect(result[:error]).to match(/No blueprint/)
      end
    end
  end
end
