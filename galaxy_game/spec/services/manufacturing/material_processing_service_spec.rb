# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Manufacturing::MaterialProcessingService, type: :service do
  let!(:celestial_body) { create(:large_moon, :luna) }
  let(:location) do
    create(:celestial_location,
           name: "Test Location",
           coordinates: "0.00°N 0.00°E",
           celestial_body: celestial_body)
  end
  let(:settlement) { create(:base_settlement, :independent, location: location) }
  let(:service) { described_class.new(settlement) }

  describe '#process' do
    context 'with TEU unit and sufficient input' do
      let(:unit) { create(:base_unit, unit_type: 'thermal_extraction_unit_mk1', settlement: settlement) }
      before { allow(settlement.inventory).to receive(:has_item?).with('raw_regolith', 10).and_return(true) }

      it 'creates a job with correct processing_type :thermal_extraction' do
        job = service.process(unit, 'raw_regolith', 10)
        expect(job).to be_a(MaterialProcessingJob)
        expect(job.processing_type).to eq('thermal_extraction')
        expect(job.input_material).to eq('raw_regolith')
        expect(job.input_amount).to eq(10)
      end
    end

    context 'with insufficient input material' do
      let(:unit) { create(:base_unit, unit_type: 'thermal_extraction_unit_mk1', settlement: settlement) }
      before { allow(settlement.inventory).to receive(:has_item?).with('raw_regolith', 10).and_return(false) }

      it 'returns error hash' do
        result = service.process(unit, 'raw_regolith', 10)
        expect(result).to eq(error: 'Insufficient raw_regolith')
      end
    end
  end

  describe '#complete_job' do
    context 'TEU job: removes input, adds processed_regolith' do
      let(:unit) { create(:base_unit, unit_type: 'thermal_extraction_unit_mk1', settlement: settlement) }
      let(:job) do
        MaterialProcessingJob.create!(
          settlement: settlement,
          unit: unit,
          processing_type: :thermal_extraction,
          input_material: 'raw_regolith',
          input_amount: 10,
          status: :pending,
          production_time_hours: 1.0,
          operational_data: { 'unit_type' => unit.unit_type }
        )
      end
      before do
        allow(settlement.inventory).to receive(:remove_item).with('raw_regolith', 10, settlement, {}).and_return(true)
        allow(settlement.inventory).to receive(:add_item).with('processed_regolith', kind_of(Numeric), settlement, {})
      end
      it 'removes input and adds processed_regolith' do
        expect(settlement.inventory).to receive(:remove_item).with('raw_regolith', 10, settlement, {})
        expect(settlement.inventory).to receive(:add_item).with('processed_regolith', kind_of(Numeric), settlement, {})
        service.complete_job(job)
      end
    end

    context 'PVE job: calculates extracted_water from geosphere crust_composition' do
      let(:unit) { create(:base_unit, unit_type: 'planetary_volatiles_extractor_mk1', settlement: settlement) }
      let(:job) do
        MaterialProcessingJob.create!(
          settlement: settlement,
          unit: unit,
          processing_type: :volatiles_extraction,
          input_material: 'regolith',
          input_amount: 20,
          status: :pending,
          production_time_hours: 1.0,
          operational_data: { 'unit_type' => unit.unit_type }
        )
      end
      before do
        allow(settlement.inventory).to receive(:remove_item).with('regolith', 20, settlement, {}).and_return(true)
        allow(settlement.inventory).to receive(:add_item)
        allow(settlement.celestial_body.geosphere).to receive(:crust_composition).and_return({ 'volatiles' => { 'H2O' => 5.0 } })
      end
      it 'adds H2O based on geosphere H2O percent' do
        expect(settlement.inventory).to receive(:add_item).with('H2O', a_value_within(0.01).of(0.75), settlement, {})
        service.complete_job(job)
      end
    end

    context 'PVE job: calculates extracted_gases from non-H2O geosphere volatiles' do
      let(:unit) { create(:base_unit, unit_type: 'planetary_volatiles_extractor_mk1', settlement: settlement) }
      let(:job) do
        MaterialProcessingJob.create!(
          settlement: settlement,
          unit: unit,
          processing_type: :volatiles_extraction,
          input_material: 'regolith',
          input_amount: 20,
          status: :pending,
          production_time_hours: 1.0,
          operational_data: { 'unit_type' => unit.unit_type }
        )
      end
      before do
        allow(settlement.inventory).to receive(:remove_item).with('regolith', 20, settlement, {}).and_return(true)
        allow(settlement.inventory).to receive(:add_item)
        allow(settlement.celestial_body.geosphere).to receive(:crust_composition).and_return({ 'volatiles' => { 'CO2' => 3.0, 'N2' => 2.0 } })
      end
      it 'adds mixed_volatiles for each non-H2O volatile' do
        expect(settlement.inventory).to receive(:add_item).with('CO2', a_value_within(0.01).of(0.45), settlement, {})
        expect(settlement.inventory).to receive(:add_item).with('N2', a_value_within(0.01).of(0.30), settlement, {})
        service.complete_job(job)
      end
    end

    context 'PVE job: calculates depleted_regolith as remainder after extraction' do
      let(:unit) { create(:base_unit, unit_type: 'planetary_volatiles_extractor_mk1', settlement: settlement) }
      let(:job) do
        MaterialProcessingJob.create!(
          settlement: settlement,
          unit: unit,
          processing_type: :volatiles_extraction,
          input_material: 'regolith',
          input_amount: 20,
          status: :pending,
          production_time_hours: 1.0,
          operational_data: { 'unit_type' => unit.unit_type }
        )
      end
      before do
        allow(settlement.inventory).to receive(:remove_item).and_return(true)
        allow(settlement.inventory).to receive(:add_item)
        allow(settlement.celestial_body.geosphere).to receive(:crust_composition)
          .and_return({ 'volatiles' => { 'H2O' => 5.0, 'CO2' => 3.0 } })
      end
      it 'adds depleted_regolith as input minus extracted volatiles' do
        # 20kg input, H2O: 20*(5/100)*0.75=0.75, CO2: 20*(3/100)*0.75=0.45
        # total extracted = 1.2, depleted = 20 - 1.2 = 18.8
        expect(settlement.inventory).to receive(:add_item)
          .with('depleted_regolith', a_value_within(0.01).of(18.8), settlement, {})
        service.complete_job(job)
      end
    end

    context 'PVE job: returns gracefully if no crust_composition volatiles' do
      let(:unit) { create(:base_unit, unit_type: 'planetary_volatiles_extractor_mk1', settlement: settlement) }
      let(:job) do
        MaterialProcessingJob.create!(
          settlement: settlement,
          unit: unit,
          processing_type: :volatiles_extraction,
          input_material: 'regolith',
          input_amount: 20,
          status: :pending,
          production_time_hours: 1.0,
          operational_data: { 'unit_type' => unit.unit_type }
        )
      end
      before do
        allow(settlement.inventory).to receive(:remove_item).with('regolith', 20, settlement, {}).and_return(true)
        allow(settlement.inventory).to receive(:add_item)
        allow(settlement.celestial_body.geosphere).to receive(:crust_composition).and_return(nil)
      end
      it 'does not raise error if no volatiles' do
        expect { service.complete_job(job) }.not_to raise_error
      end
    end
  end
end