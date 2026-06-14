# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Economics::MarketPriceService do
  describe '.get_current_market_price' do
    context 'with valid resource type and seeded market_settings' do
      let(:market_setting) { create :market_setting, transportation_cost_per_kg: 2.5 }

      before do
        market_setting
        allow(described_class).to receive(:calculate_eap_price).and_return(100.0)
        allow(described_class).to receive(:calculate_transport_floored_price).and_return(50.0)
      end

      it 'returns a Float price when both EAP and transport floor are available' do
        price = described_class.get_current_market_price('Steel', settlement_context: {})
        expect(price).to be_a(Float)
        expect(price).to be > 0
      end

      it 'returns midpoint between floor and ceiling' do
        price = described_class.get_current_market_price('Steel', settlement_context: {})
        expect(price).to eq(75.0) # (100 + 50) / 2
      end

      it 'returns nil for blank resource type' do
        price = described_class.get_current_market_price('', settlement_context: {})
        expect(price).to be_nil
      end

      it 'returns nil for nil resource type' do
        price = described_class.get_current_market_price(nil, settlement_context: {})
        expect(price).to be_nil
      end

      it 'works with string context parameter for backward compatibility' do
        price = described_class.get_current_market_price('Steel', settlement_context: 'export')
        expect(price).to be_a(Float)
        expect(price).to be > 0
      end
    end

    context 'when only EAP ceiling is available' do
      before do
        allow(described_class).to receive(:calculate_eap_price).and_return(100.0)
        allow(described_class).to receive(:calculate_transport_floored_price).and_return(nil)
      end

      it 'returns EAP price when transport floor unavailable' do
        price = described_class.get_current_market_price('Steel', settlement_context: {})
        expect(price).to eq(100.0)
      end
    end

    context 'when only transport floor is available' do
      before do
        allow(described_class).to receive(:calculate_eap_price).and_return(nil)
        allow(described_class).to receive(:calculate_transport_floored_price).and_return(50.0)
      end

      it 'returns transport floor price when EAP unavailable' do
        price = described_class.get_current_market_price('Steel', settlement_context: {})
        expect(price).to eq(50.0)
      end
    end

    context 'when neither price source is available' do
      before do
        allow(described_class).to receive(:calculate_eap_price).and_return(nil)
        allow(described_class).to receive(:calculate_transport_floored_price).and_return(nil)
      end

      it 'returns nil for unknown resource types with no material data' do
        price = described_class.get_current_market_price('NonExistentResource12345', settlement_context: {})
        expect(price).to be_nil
      end
    end

    context 'without seeded market_settings' do
      before do
        Market::Settings.destroy_all
        allow(described_class).to receive(:calculate_eap_price).and_return(nil)
        allow(described_class).to receive(:calculate_transport_floored_price).and_return(nil)
      end

      it 'returns nil when no pricing sources available' do
        price = described_class.get_current_market_price('Steel', settlement_context: {})
        expect(price).to be_nil
      end
    end
  end

  describe '.calculate_trade_balance' do
    context 'with import and export manifests' do
      let(:import_manifests) { [create(:manifest, total_cost: 10_000.0)] }
      let(:export_manifests) { [create(:manifest, :luna_export, estimated_revenue_gcc: 52_500.0)] }

      it 'correctly calculates net GCC flow direction and magnitude' do
        balance = described_class.calculate_trade_balance(import_manifests, export_manifests)

        expect(balance[:total_import_costs_gcc]).to eq(10_000.0)
        expect(balance[:total_export_revenues_gcc]).to eq(52_500.0)
        expect(balance[:net_trade_balance_gcc]).to eq(42_500.0)
        expect(balance[:flow_direction]).to eq('surplus')
      end

      it 'returns deficit when imports exceed exports' do
        expensive_imports = [create(:manifest, total_cost: 60_000.0)]
        small_exports = [create(:manifest, :export_manifest, estimated_revenue_gcc: 10_000.0)]

        balance = described_class.calculate_trade_balance(expensive_imports, small_exports)

        expect(balance[:flow_direction]).to eq('deficit')
        expect(balance[:net_trade_balance_gcc]).to be < 0
      end

      it 'returns correct trade ratio' do
        balance = described_class.calculate_trade_balance(import_manifests, export_manifests)
        expect(balance[:trade_ratio]).to be_a(Float)
        expect(balance[:trade_ratio]).to be > 0
      end

      it 'generates trade recommendations based on balance analysis' do
        expensive_imports = [create(:manifest, total_cost: 10_000.0)]

        balance = described_class.calculate_trade_balance(expensive_imports, [])

        expect(balance[:recommendations]).to be_an(Array)
        expect(balance[:recommendations].length).to be > 0
        recommendation_text = balance[:recommendations].join(' ')
        expect(recommendation_text.downcase).to include('export').or include('import')
      end

      it 'returns healthy trade message when no issues detected' do
        balanced_imports = [create(:manifest, total_cost: 10_000.0)]
        balanced_exports = [create(:manifest, :export_manifest, estimated_revenue_gcc: 12_000.0)]

        balance = described_class.calculate_trade_balance(balanced_imports, balanced_exports)

        expect(balance[:recommendations]).to include('Trade balance appears healthy')
      end
    end

    context 'with empty manifests' do
      it 'returns zero balance with empty arrays' do
        balance = described_class.calculate_trade_balance([], [])

        expect(balance[:total_import_costs_gcc]).to eq(0.0)
        expect(balance[:total_export_revenues_gcc]).to eq(0.0)
        expect(balance[:net_trade_balance_gcc]).to eq(0.0)
      end

      it 'returns infinity trade ratio when no imports' do
        export_manifests = [create(:manifest, :export_manifest, estimated_revenue_gcc: 10_000.0)]
        balance = described_class.calculate_trade_balance([], export_manifests)

        expect(balance[:trade_ratio]).to eq(Float::INFINITY)
      end
    end
  end

  describe 'market infrastructure integration' do
    context 'with existing market services and models' do
      let(:market_setting) { create :market_setting, transportation_cost_per_kg: 2.5 }

      before { market_setting }

      it 'does NOT raise errors without live simulation data' do
        expect {
          described_class.get_current_market_price('Steel', settlement_context: {})
        }.not_to raise_error
      end

      it 'uses Tier1PriceModeler for EAP ceiling calculation when material data available' do
        allow(described_class).to receive(:load_material_data).and_return({
          'pricing' => { 'earth_usd' => { 'base_price_per_kg' => 10.0 } }
        })
        allow(Tier1PriceModeler).to receive(:new).and_return(
          double('modeler', calculate_eap: 150.0)
        )

        price = described_class.get_current_market_price('Iron', settlement_context: {})

        expect(price).to be_a(Float)
      end
    end
  end
end
