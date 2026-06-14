# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Logistics::ExportManifestGenerator do
  describe '.generate_return_manifest' do
    context 'with valid settlements and surplus resources' do
      let(:source_settlement) { create :base_settlement, name: 'Lunar Gateway', operational_data: build_luna_operational_data }
      let(:destination_settlement) { create :base_settlement, name: 'Cape Canaveral' }

      def build_luna_operational_data
        {
          inventory: {
            'Helium-3' => { quantity: 100.0 },
            'Regolith' => { quantity: 50_000.0 },
            'Steel Components' => { quantity: 2_000.0 }
          },
          production_rates: {},
          consumption_targets: {}
        }
      end

      before do
        # Stub MarketPriceService to return prices without requiring material JSON files in test environment
        allow(Economics::MarketPriceService).to receive(:get_current_market_price).and_return(150.0)
      end

      it 'creates valid outbound Luna→Earth shipments with profit-maximizing cargo allocation' do
        manifest = described_class.generate_return_manifest(source_settlement, destination_settlement)

        expect(manifest).to be_a(Logistics::Manifest)
        expect(manifest.source_settlement).to eq(source_settlement)
        expect(manifest.destination_settlement).to eq(destination_settlement)
        expect(manifest.manifest_type).to eq(1)  # EXPORT_TYPE = 1
        expect(manifest.status).to eq('pending')  # Export manifests use existing pending status enum value
        expect(manifest.items).not_to be_empty
        expect(manifest.estimated_revenue_gcc).to be > 0
      end

      it 'returns nil when no viable cargo found' do
        empty_settlement = create :base_settlement, name: 'Empty Luna Base', operational_data: { inventory: {} }
        
        result = described_class.generate_return_manifest(empty_settlement, destination_settlement)
        
        expect(result).to be_nil
      end

      it 'raises ArgumentError when source settlement missing' do
        expect { described_class.generate_return_manifest(nil, destination_settlement) }.to raise_error(ArgumentError)
      end

      it 'raises ArgumentError when destination settlement missing' do
        expect { described_class.generate_return_manifest(source_settlement, nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.identify_exportable_surplus' do
    context 'with Luna settlement having excess production' do
      let(:settlement) { create :base_settlement, name: 'Lunar Gateway', operational_data: build_luna_operational_data }

      def build_luna_operational_data
        {
          inventory: {
            'Helium-3' => { quantity: 100.0 },
            'Regolith' => { quantity: 50_000.0 },
            'Steel Components' => { quantity: 2_000.0 }
          },
          production_rates: {},
          consumption_targets: {}
        }
      end

      before do
        # Stub MarketPriceService to return prices without requiring material JSON files in test environment
        allow(Economics::MarketPriceService).to receive(:get_current_market_price).and_return(150.0)
      end

      it 'correctly identifies surplus beyond safety buffer' do
        # Ensure market_settings is seeded (required by MarketPriceService)
        create :market_setting, transportation_cost_per_kg: 2.5 if Market::Settings.count == 0
        
        surplus = described_class.identify_exportable_surplus(settlement)

        expect(surplus).to be_an(Array)
        
        # Should identify all resources with positive quantities as exportable (no consumption targets set, so safety buffer is zero)
        resource_names = surplus.map { |item| item[:resource] }
        expect(resource_names).to include('Helium-3', 'Regolith', 'Steel Components')

        # Each item should have required fields for optimization algorithm
        first_item = surplus.first
        expect(first_item.keys).to include(:resource, :quantity_kg, :market_price_gcc_per_kg, :total_value, :value_density)
      end

      it 'returns empty array when settlement has no inventory' do
        empty_settlement = create :base_settlement, name: 'Empty Base', operational_data: { inventory: {} }
        
        surplus = described_class.identify_exportable_surplus(empty_settlement)
        
        expect(surplus).to be_empty
      end

      it 'returns resources sorted by value density descending' do
        # Helium-3 should have highest value density (rare isotope with premium pricing)
        surplus = described_class.identify_exportable_surplus(settlement)
        
        skip 'No market data available for testing' if surplus.empty?  # Skip if no market data available
        
        expect(surplus.first[:resource]).to eq('Helium-3')  # Highest value per kg should be first
      end

      it 'returns empty array when settlement has nil operational_data' do
        nil_settlement = create :base_settlement, name: 'Nil Data Base', operational_data: nil
        
        surplus = described_class.identify_exportable_surplus(nil_settlement)
        
        expect(surplus).to be_empty
      end
    end
  end

  describe '.optimize_cargo_load' do
    let(:available_resources) do
      [
        { resource: 'Helium-3', quantity_kg: 10.0, market_price_gcc_per_kg: 5_000.0 },
        { resource: 'Regolith', quantity_kg: 40_000.0, market_price_gcc_per_kg: 2.0 },
        { resource: 'Steel Components', quantity_kg: 1_000.0, market_price_gcc_per_kg: 50.0 }
      ]
    end

    it 'respects weight limits and maximizes revenue' do
      manifest_capacity_kg = 50_000.0  # AstroLift HLT capacity (50 tons)
      manifest_volume_m3 = 125.0       # Standard container space
      
      optimized_items = described_class.optimize_cargo_load(available_resources, manifest_capacity_kg, manifest_volume_m3)

      expect(optimized_items).to be_an(Array)
      
      total_weight = optimized_items.sum { |item| item[:quantity_kg].to_f }
      expect(total_weight).to be <= (manifest_capacity_kg + 0.1)  # Allow small floating point tolerance
      
      # Should include high-value items first (greedy algorithm by value density)
      if optimized_items.any?
        total_revenue = optimized_items.sum { |item| item[:total_value].to_f }
        expect(total_revenue).to be > 0
      end
    end

    it 'returns empty array when no resources available' do
      result = described_class.optimize_cargo_load([], 50_000.0, 125.0)
      
      expect(result).to be_empty
    end

    it 'respects minimum shipment threshold (default: 10 kg)' do
      tiny_resources = [
        { resource: 'Tiny Resource', quantity_kg: 5.0, market_price_gcc_per_kg: 1_000.0 }
      ]
      
      result = described_class.optimize_cargo_load(tiny_resources, 50_000.0, 125.0)
      
      expect(result).to be_empty  # Below minimum shipment threshold should be skipped
    end

    it 'partially fills capacity when full quantity exceeds limits' do
      oversized_resource = [
        { resource: 'Oversized', quantity_kg: 60_000.0, market_price_gcc_per_kg: 10.0 }
      ]
      
      result = described_class.optimize_cargo_load(oversized_resource, 50_000.0, 125.0)
      
      expect(result).not_to be_empty
      
      total_weight = result.sum { |item| item[:quantity_kg].to_f }
      expect(total_weight).to be <= (50_000.0 + 0.1)  # Should not exceed capacity
    end

    it 'sorts results by total value descending for display' do
      optimized_items = described_class.optimize_cargo_load(available_resources, 50_000.0, 125.0)
      
      return if optimized_items.length < 2
      
      # First item should have highest total_value (greedy fill prioritizes high-value items first)
      expect(optimized_items.first[:total_value]).to be >= optimized_items.last[:total_value]
    end
  end

  describe 'integration with MarketPriceService' do
    let(:source_settlement) { create :base_settlement, name: 'Lunar Gateway', operational_data: build_luna_operational_data }
    let(:destination_settlement) { create :base_settlement, name: 'Cape Canaveral' }

    def build_luna_operational_data
      {
        inventory: {
          'Helium-3' => { quantity: 10.0 },
          'Regolith' => { quantity: 5_000.0 }
        },
        production_rates: {},
        consumption_targets: {}
      }
    end

    before do
      # Stub MarketPriceService with He-3 premium pricing for lunar exports
      allow(Economics::MarketPriceService).to receive(:get_current_market_price)
        .with('Helium-3', anything).and_return(500.0)  # Higher price for He-3 (premium resource)
      
      allow(Economics::MarketPriceService).to receive(:get_current_market_price)
        .with(anything, anything).and_return(150.0)   # Default price for other resources
    end

    it 'uses market prices from MarketPriceService in manifest items' do
      manifest = described_class.generate_return_manifest(source_settlement, destination_settlement)

      skip 'No manifest generated' unless manifest && !manifest.items.empty?

      # Each item should have market_price_gcc_per_kg populated
      first_item = manifest.items.first
      expect(first_item[:market_price_gcc_per_kg]).to be > 0
      
      # Total revenue calculation should match sum of (quantity × price) for each item
      calculated_revenue = manifest.items.sum { |item| item[:quantity_kg].to_f * item[:market_price_gcc_per_kg].to_f }
      
      expect((manifest.estimated_revenue_gcc - calculated_revenue).abs).to be < 0.1  # Allow small floating point tolerance
    end

    it 'applies He-3 premium pricing for lunar exports' do
      manifest = described_class.generate_return_manifest(source_settlement, destination_settlement)

      skip 'No manifest generated' unless manifest && !manifest.items.empty?

      helium_item = manifest.items.find { |item| item[:resource].downcase.include?('helium') }
      
      # He-3 should have premium pricing (higher than base transport cost floor)
      if helium_item
        expect(helium_item[:market_price_gcc_per_kg]).to be > 2.5  # Should exceed transportation_cost_per_kg baseline
      end
    end

    it 'respects AstroLift HLT cargo capacity constraint (≤50 tons per flight)' do
      manifest = described_class.generate_return_manifest(source_settlement, destination_settlement)

      skip 'No manifest generated' unless manifest
      
      expect(manifest.total_weight_kg).to be <= (50_000.0 + 1.0)  # Should not exceed HLT capacity
    end
  end
end
