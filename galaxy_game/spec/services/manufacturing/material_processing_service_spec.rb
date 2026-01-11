# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Manufacturing::MaterialProcessingService, type: :service do
  # Isolate this spec completely
  around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback # Force rollback
    end
  end

  let(:celestial_body) { create(:celestial_body) }
  let(:location) { create(:celestial_location, celestial_body: celestial_body) }
  let(:settlement) { create(:base_settlement, location: location) }
  let(:teu_unit) { create(:base_unit, unit_type: 'thermal_extraction_unit') }
  let(:pve_unit) { create(:base_unit, unit_type: 'volatiles_extraction_unit') }
  let(:service) { described_class.new(settlement) }

  describe '#thermal_extraction' do
    context 'with valid inputs' do
      before do
        # Set up surface storage with raw regolith
        settlement.create_inventory! unless settlement.inventory
        unless settlement.inventory.surface_storage
          Storage::SurfaceStorage.create!(
            inventory: settlement.inventory,
            settlement: settlement,
            celestial_body: celestial_body,
            item_type: 'Solid'
          )
        end
        storage = settlement.inventory.surface_storage
        storage.add_pile(material_name: "raw_regolith", amount: 50.0, source_unit: "test")
        Item.create!(
          inventory: settlement.inventory,
          name: "raw_regolith",
          amount: 50.0,
          owner: settlement,
          storage_method: 'bulk_storage',
          metadata: { "storage_location" => "surface_pile" }
        )
      end

      it 'creates a material processing job record' do
        job = service.thermal_extraction(10.0, teu_unit)

        expect(job).to be_a(MaterialProcessingJob)
        expect(job.processing_type).to eq('thermal_extraction')
        expect(job.input_material).to eq('raw_regolith')
        expect(job.input_amount).to eq(10.0)
        expect(job.status).to eq('pending')

        # Complete the job to test processing
        job.start!
        job.process_tick(24.0) # Complete immediately
        job.reload
        expect(job.status).to eq('completed')
      end

      it 'updates inventory correctly after job completion' do
        job = service.thermal_extraction(10.0, teu_unit)
        job.start!
        job.process_tick(24.0)

        expect(settlement.inventory.items.find_by(name: "raw_regolith").amount).to eq(40.0)
        expect(settlement.inventory.items.find_by(name: "processed_regolith").amount).to eq(9.95)
      end
    end

    context 'with insufficient raw regolith' do
      it 'returns an error' do
        result = service.thermal_extraction(100.0, teu_unit)
        expect(result[:error]).to include("Insufficient raw regolith")
      end
    end
  end

  describe '#volatiles_extraction' do
    context 'with valid inputs' do
      before do
        # Set up inventory with processed regolith
        settlement.create_inventory! unless settlement.inventory
        Item.create!(
          inventory: settlement.inventory,
          name: "processed_regolith",
          amount: 10.0,
          owner: settlement,
          storage_method: 'bulk_storage'
        )
      end

      it 'creates a material processing job record' do
        job = service.volatiles_extraction(5.0, pve_unit)

        expect(job).to be_a(MaterialProcessingJob)
        expect(job.processing_type).to eq('volatiles_extraction')
        expect(job.input_material).to eq('processed_regolith')
        expect(job.input_amount).to eq(5.0)
        expect(job.status).to eq('pending')

        # Complete the job to test processing
        job.start!
        job.process_tick(24.0)
        job.reload
        expect(job.status).to eq('completed')
      end

      it 'produces gases with correct composition after job completion' do
        job = service.volatiles_extraction(5.0, pve_unit)
        job.start!
        job.process_tick(24.0)

        gas_items = settlement.inventory.items.where(name: ['hydrogen', 'carbon_monoxide', 'helium', 'neon'])
        expect(gas_items.sum(:amount)).to eq(0.06) # Total gases produced

        # Check individual gas ratios
        hydrogen = settlement.inventory.items.find_by(name: 'hydrogen')
        expect(hydrogen.amount).to eq(0.03) # 0.06 * 0.50
      end
    end

    context 'with insufficient processed regolith' do
      it 'returns an error' do
        result = service.volatiles_extraction(50.0, pve_unit)
        expect(result[:error]).to include("Insufficient processed regolith")
      end
    end
  end
end