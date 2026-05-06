# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Manufacturing::MaterialProcessingService, type: :service do
  # Use a generic celestial body with controlled volatile data.
  # Do NOT use Luna or any world constant — specs must be independent of real-world data.
  let!(:celestial_body) do
    body = create(:celestial_body)
    body.create_geosphere!(
      geological_activity: 5,
      tectonic_activity: false,
      crust_composition: { 'regolith' => 100.0 },
      stored_volatiles: { 'H2O' => { 'polar_ice' => 5.0 }, 'He3' => { 'regolith' => 95.0 } }
    ) unless body.geosphere
    body.geosphere.update_columns(
      stored_volatiles: { 'H2O' => { 'polar_ice' => 5.0 }, 'He3' => { 'regolith' => 95.0 } }.to_json
    )
    body
  end
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
        od = job.operational_data.is_a?(String) ? JSON.parse(job.operational_data) : job.operational_data
        expect(job).to be_a(Job)
        expect(job.job_type).to eq('material_processing')
        expect(od['processing_type']).to eq('thermal_extraction')
        expect(od['input_material']).to eq('raw_regolith')
        expect(od['input_amount']).to eq(10)
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
        Job.create!(
          job_type: :material_processing,
          settlement: settlement,
          owner: settlement.owner,
          output_type: 'processed_regolith',
          start_date: 1.hour.ago,
          completes_at: 1.hour.from_now,
          status: :pending,
          operational_data: {
            'unit_type' => unit.unit_type,
            'processing_type' => 'thermal_extraction',
            'input_material' => 'raw_regolith',
            'input_amount' => 10,
            'production_time_hours' => 1.0
          }
        )
      end
      before do
        allow(settlement.inventory).to receive(:remove_item).with('raw_regolith', 10, settlement, {}).and_return(true)
        # Allow all add_item calls — TEU produces processed_regolith (primary) plus
        # per-compound volatile byproducts from geosphere crust composition.
        # Volatile byproducts are world-driven and vary by location.
        allow(settlement.inventory).to receive(:add_item)
      end
      it 'removes input and adds processed_regolith' do
        expect(settlement.inventory).to receive(:remove_item).with('raw_regolith', 10, settlement, {})
        expect(settlement.inventory).to receive(:add_item).with('processed_regolith', kind_of(Numeric), settlement, {})
        # Allow volatile byproduct adds — world-driven, not asserted here
        allow(settlement.inventory).to receive(:add_item)
        service.complete_job(job)
      end
    end

    context 'PVE job: calculates extracted_water from geosphere stored_volatiles' do
      # Outer let! body has H2O: 5.0, He3: 95.0 → total mass = 100.0
      # H2O% = 5%, He3% = 95%
      # H2O produced = 20 * (5/100) * 0.75 = 0.75
      let(:unit) { create(:base_unit, unit_type: 'planetary_volatiles_extractor_mk1', settlement: settlement) }
      let(:job) do
        Job.create!(
          job_type: :material_processing,
          settlement: settlement,
          owner: settlement.owner,
          output_type: 'H2O',
          start_date: 1.hour.ago,
          completes_at: 1.hour.from_now,
          status: :pending,
          operational_data: {
            'unit_type' => unit.unit_type,
            'processing_type' => 'volatiles_extraction',
            'input_material' => 'regolith',
            'input_amount' => 20,
            'production_time_hours' => 1.0
          }
        )
      end
      before do
        allow(settlement.inventory).to receive(:remove_item).with('regolith', 20, settlement, {}).and_return(true)
        allow(settlement.inventory).to receive(:add_item)
      end
      it 'adds H2O based on geosphere stored_volatiles H2O mass fraction' do
        expect(settlement.inventory).to receive(:add_item).with('H2O', a_value_within(0.01).of(0.75), settlement, {})
        allow(settlement.inventory).to receive(:add_item)
        service.complete_job(job)
      end
    end

    context 'PVE job: calculates extracted_gases from non-H2O geosphere stored_volatiles' do
      # Set body geosphere to CO2: 3.0, N2: 2.0 → total mass = 5.0
      # CO2% = 60%, N2% = 40%
      # CO2 produced = 20 * (3/5) * 0.75 = 9.0
      # N2 produced  = 20 * (2/5) * 0.75 = 6.0
      let(:unit) { create(:base_unit, unit_type: 'planetary_volatiles_extractor_mk1', settlement: settlement) }
      let(:job) do
        Job.create!(
          job_type: :material_processing,
          settlement: settlement,
          owner: settlement.owner,
          output_type: 'CO2',
          start_date: 1.hour.ago,
          completes_at: 1.hour.from_now,
          status: :pending,
          operational_data: {
            'unit_type' => unit.unit_type,
            'processing_type' => 'volatiles_extraction',
            'input_material' => 'regolith',
            'input_amount' => 20,
            'production_time_hours' => 1.0
          }
        )
      end
      before do
        celestial_body.geosphere.update_columns(
          stored_volatiles: { 'CO2' => { 'deposits' => 3.0 }, 'N2' => { 'deposits' => 2.0 } }.to_json
        )
        allow(settlement.inventory).to receive(:remove_item).with('regolith', 20, settlement, {}).and_return(true)
        allow(settlement.inventory).to receive(:add_item)
      end
      it 'adds extracted compounds for each volatile in stored_volatiles' do
        expect(settlement.inventory).to receive(:add_item).with('CO2', a_value_within(0.01).of(9.0), settlement, {})
        expect(settlement.inventory).to receive(:add_item).with('N2', a_value_within(0.01).of(6.0), settlement, {})
        allow(settlement.inventory).to receive(:add_item)
        service.complete_job(job)
      end
    end

    context 'PVE job: calculates depleted_regolith as remainder after extraction' do
      # Set body geosphere to H2O: 5.0, CO2: 3.0 → total mass = 8.0
      # H2O% = 62.5%, CO2% = 37.5%
      # H2O produced  = 20 * 0.625 * 0.75 = 9.375
      # CO2 produced  = 20 * 0.375 * 0.75 = 5.625
      # total extracted = 15.0
      # depleted_regolith = 20 - 15.0 = 5.0
      let(:unit) { create(:base_unit, unit_type: 'planetary_volatiles_extractor_mk1', settlement: settlement) }
      let(:job) do
        Job.create!(
          job_type: :material_processing,
          settlement: settlement,
          owner: settlement.owner,
          output_type: 'depleted_regolith',
          start_date: 1.hour.ago,
          completes_at: 1.hour.from_now,
          status: :pending,
          operational_data: {
            'unit_type' => unit.unit_type,
            'processing_type' => 'volatiles_extraction',
            'input_material' => 'regolith',
            'input_amount' => 20,
            'production_time_hours' => 1.0
          }
        )
      end
      before do
        celestial_body.geosphere.update_columns(
          stored_volatiles: { 'H2O' => { 'deposits' => 5.0 }, 'CO2' => { 'deposits' => 3.0 } }.to_json
        )
        allow(settlement.inventory).to receive(:remove_item).and_return(true)
        allow(settlement.inventory).to receive(:add_item)
      end
      it 'adds depleted_regolith as input minus all extracted volatiles' do
        expect(settlement.inventory).to receive(:add_item)
          .with('depleted_regolith', a_value_within(0.01).of(5.0), settlement, {})
        allow(settlement.inventory).to receive(:add_item)
        service.complete_job(job)
      end
    end

    context 'PVE job: returns gracefully if no stored_volatiles' do
      let(:unit) { create(:base_unit, unit_type: 'planetary_volatiles_extractor_mk1', settlement: settlement) }
      let(:job) do
        Job.create!(
          job_type: :material_processing,
          settlement: settlement,
          owner: settlement.owner,
          output_type: 'processed_regolith',
          start_date: 1.hour.ago,
          completes_at: 1.hour.from_now,
          status: :pending,
          operational_data: {
            'unit_type' => unit.unit_type,
            'processing_type' => 'volatiles_extraction',
            'input_material' => 'regolith',
            'input_amount' => 20,
            'production_time_hours' => 1.0
          }
        )
      end
      before do
        celestial_body.geosphere.update_columns(stored_volatiles: {}.to_json)
        allow(settlement.inventory).to receive(:remove_item).with('regolith', 20, settlement, {}).and_return(true)
        allow(settlement.inventory).to receive(:add_item)
      end
      it 'does not raise error if no volatiles' do
        expect { service.complete_job(job) }.not_to raise_error
      end
    end
  end
end
