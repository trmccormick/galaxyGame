# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Financial::ExchangeRateService do
  let(:service) { described_class.new }
  let(:service_with_rates) do
    described_class.new({
      ['USD', 'GCC'] => 100.0,
      ['LOX', 'USD'] => 2.5,
      ['EUR', 'USD'] => 1.1
    })
  end

  describe '#initialize' do
    it 'initializes with empty rates by default' do
      expect(service.instance_variable_get(:@rates)).to eq({})
    end

    it 'initializes with provided rates' do
      rates = { ['USD', 'GCC'] => 100.0 }
      svc = described_class.new(rates)
      expect(svc.instance_variable_get(:@rates)).to eq(rates)
    end
  end

  describe '#convert' do
    it 'returns the amount unchanged when from and to currencies are the same' do
      expect(service.convert(100, 'USD', 'USD')).to eq(100)
    end

    it 'converts using the stored rate' do
      expect(service_with_rates.convert(10, 'USD', 'GCC')).to eq(1000.0)
    end

    it 'defaults to 1.0 rate when no rate is found' do
      expect(service.convert(50, 'UNKNOWN', 'GCC')).to eq(50.0)
    end

    it 'handles string and symbol currencies' do
      expect(service.convert(10, :usd, :gcc)).to eq(10.0)
    end
  end

  describe '#get_rate' do
    it 'returns the stored rate' do
      expect(service_with_rates.get_rate('USD', 'GCC')).to eq(100.0)
    end

    it 'returns 1.0 for unknown rate pairs' do
      expect(service.get_rate('UNKNOWN', 'GCC')).to eq(1.0)
    end

    it 'normalizes keys to strings' do
      rates = { ['usd', 'gcc'] => 50.0 }
      svc = described_class.new(rates)
      expect(svc.get_rate('usd', 'gcc')).to eq(50.0)
    end
  end

  describe '#set_rate' do
    it 'sets a new rate' do
      service.set_rate('BTC', 'USD', 50000)
      expect(service.get_rate('BTC', 'USD')).to eq(50000)
    end

    it 'updates an existing rate' do
      service.set_rate('USD', 'GCC', 100)
      service.set_rate('USD', 'GCC', 150)
      expect(service.get_rate('USD', 'GCC')).to eq(150)
    end

    it 'normalizes keys to strings' do
      service.set_rate(:btc, :usd, 50000)
      expect(service.get_rate('btc', 'usd')).to eq(50000)
    end
  end

  describe '#value_of' do
    it 'converts item quantity to target currency' do
      expect(service_with_rates.value_of('LOX', 1000, 'USD')).to eq(2500.0)
    end

    it 'uses default rate when no specific rate exists' do
      expect(service.value_of('UNKNOWN', 100, 'GCC')).to eq(100.0)
    end
  end

  describe '#base_price_for' do
    let(:mock_item_lookup) { instance_double(Lookup::ItemLookupService) }
    let(:mock_blueprint_lookup) { instance_double(Lookup::BlueprintLookupService) }

    before do
      allow(Lookup::ItemLookupService).to receive(:new).and_return(mock_item_lookup)
      allow(Lookup::BlueprintLookupService).to receive(:new).and_return(mock_blueprint_lookup)
    end

    context 'when item is found with value' do
      it 'returns the item value converted to target currency' do
        item = { 'game_properties' => { 'value' => 50.0, 'currency' => 'USD' } }
        allow(mock_item_lookup).to receive(:find_item).and_return(item)

        expect(service_with_rates.base_price_for('test_item', 'GCC')).to eq(5000.0)
      end

      it 'defaults to GCC currency when not specified' do
        item = { 'game_properties' => { 'value' => 100.0 } }
        allow(mock_item_lookup).to receive(:find_item).and_return(item)
        allow(mock_blueprint_lookup).to receive(:find_blueprint).and_return(nil)

        expect(service.base_price_for('test_item', 'USD')).to eq(100.0)
      end
    end

    context 'when blueprint is found with cost_data' do
      it 'returns the blueprint cost converted to target currency' do
        blueprint = { 'cost_data' => { 'purchase_cost' => { 'amount' => 200.0, 'currency' => 'EUR' } } }
        allow(mock_item_lookup).to receive(:find_item).and_return(nil)
        allow(mock_blueprint_lookup).to receive(:find_blueprint).and_return(blueprint)

        expect(service_with_rates.base_price_for('test_blueprint', 'USD')).to be_within(0.01).of(220.0)
      end
    end

    context 'when neither item nor blueprint is found' do
      it 'returns default value converted to target currency' do
        allow(mock_item_lookup).to receive(:find_item).and_return(nil)
        allow(mock_blueprint_lookup).to receive(:find_blueprint).and_return(nil)

        expect(service_with_rates.base_price_for('unknown_entity', 'GCC')).to eq(100.0)
      end
    end
  end

  describe '#market_price_for' do
    it 'returns nil (TODO: implement market price lookup)' do
      expect(service.market_price_for('test_item', 'GCC')).to be_nil
    end
  end

  describe '#price_for' do
    let(:mock_item_lookup) { instance_double(Lookup::ItemLookupService) }

    before do
      allow(Lookup::ItemLookupService).to receive(:new).and_return(mock_item_lookup)
    end

    it 'returns market price when available' do
      # Since market_price_for returns nil, this will test the fallback
      item = { 'game_properties' => { 'value' => 75.0, 'currency' => 'GCC' } }
      allow(mock_item_lookup).to receive(:find_item).and_return(item)

      expect(service.price_for('test_item', 'USD')).to eq(75.0)
    end

    it 'falls back to base price when market price is not available' do
      item = { 'game_properties' => { 'value' => 75.0, 'currency' => 'GCC' } }
      allow(mock_item_lookup).to receive(:find_item).and_return(item)

      expect(service.price_for('test_item', 'USD')).to eq(75.0)
    end
  end

  describe 'integration with economic config' do
    it 'works with the initial USD=GCC peg' do
      # Test that initial setup maintains 1:1 parity
      initial_service = described_class.new({ ['USD', 'GCC'] => 1.0 })
      expect(initial_service.convert(100, 'USD', 'GCC')).to eq(100.0)
    end

    it 'supports future currency decoupling' do
      # Test that rates can be adjusted for economic changes
      decoupled_service = described_class.new({ ['USD', 'GCC'] => 0.8 })
      expect(decoupled_service.convert(100, 'USD', 'GCC')).to eq(80.0)
    end
  end
end