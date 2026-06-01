# frozen_string_literal: true

require 'rails_helper'


describe Logistics::ManifestGenerator do
  let!(:source_settlement) { FactoryBot.create(:base_settlement) }
  let!(:destination_settlement) { FactoryBot.create(:base_settlement) }
  let!(:inventory) { FactoryBot.create(:inventory, inventoryable: source_settlement) }

  before do
    # Patch inventory for both settlements
    allow(source_settlement).to receive(:inventory).and_return(inventory)
    allow(destination_settlement).to receive(:inventory).and_return(inventory)
    allow(Settlements::CostAnalyzer).to receive(:current_import_price).and_return(10.0)
  end

  describe '.create_manifest' do
    context 'happy path: mixed items' do
      it 'creates manifest with correct items and categories' do
        allow(inventory).to receive(:has_item?).and_return(true)
        items = [
          { resource: 'Steel', quantity: 100 },
          { resource: 'Water', quantity: 500 },
          { resource: 'Component A', quantity: 10 }
        ]
        manifest = described_class.create_manifest(source_settlement, destination_settlement, items)
        expect(manifest).to be_persisted
        expect(manifest.items.size).to eq(3)
        expect(manifest.items.map { |i| i[:category] }).to include(:raw_material, :component)
        expect(manifest.manifest_id).to be_present
      end
    end

    context 'single item' do
      it 'creates manifest with one item' do
        allow(inventory).to receive(:has_item?).and_return(true)
        items = [ { resource: 'Water', quantity: 50 } ]
        manifest = described_class.create_manifest(source_settlement, destination_settlement, items)
        expect(manifest.items.size).to eq(1)
        expect(manifest.items.first[:quantity]).to eq(50)
      end
    end

    context 'missing item in inventory' do
      it 'raises error if item not present' do
        allow(inventory).to receive(:has_item?).and_return(false)
        items = [ { resource: 'Unobtainium', quantity: 1 } ]
        expect {
          described_class.create_manifest(source_settlement, destination_settlement, items)
        }.to raise_error(Logistics::ManifestGenerator::ManifestError, /does not have enough/)
      end
    end

    context 'empty items' do
      it 'raises error for empty list' do
        expect {
          described_class.create_manifest(source_settlement, destination_settlement, [])
        }.to raise_error(Logistics::ManifestGenerator::ManifestError, /cannot be empty/)
      end
    end

    context 'cross-settlement' do
      it 'sets correct destination_settlement_id' do
        allow(inventory).to receive(:has_item?).and_return(true)
        items = [ { resource: 'Steel', quantity: 10 } ]
        manifest = described_class.create_manifest(source_settlement, destination_settlement, items)
        expect(manifest.destination_settlement_id).to eq(destination_settlement.id)
        expect(manifest.source_settlement_id).to eq(source_settlement.id)
      end
    end
  end
end
