# spec/services/manufacturing/shell_printing_service_spec.rb
require 'rails_helper'

RSpec.describe Manufacturing::ShellPrintingService do
  let!(:celestial_body) { create(:large_moon, :luna) }
  let(:location) do
    create(:celestial_location,
      name: "Shackleton Crater Base",
      celestial_body: celestial_body
    )
  end
  let(:player) { create(:player, active_location: "Shackleton Crater Base") }
  let(:settlement) do
    create(:base_settlement,
      owner: player,
      location: location
    )
  end
  
  let(:printer_unit) do
    create(:base_unit,
      owner: settlement,
      attachable: settlement,
      operational_data: {
        'processing_capabilities' => {
          'geosphere_processing' => {
            'enabled' => true,
            'types' => ['regolith'],
            'efficiency' => 0.85
          }
        },
        'component_production' => {
          'production_rate_multiplier' => 1.0
        }
      }
    )
  end

  let(:inflatable_tank) do
    create(:base_unit,
      owner: settlement,
      attachable: settlement,
      unit_type: 'inflatable_cryo_tank',
      operational_data: {
        'capacity' => 5000,
        'current_level' => 0,
        'deployed' => true,
        'operational' => true
      }
    )
  end

  let(:service) { described_class.new(settlement) }

  before do
    # Stub blueprint lookup for inflatable tank
    allow_any_instance_of(Lookup::BlueprintLookupService)
      .to receive(:find_blueprint)
      .with('inflatable_cryo_tank')
      .and_return({
        'id' => 'inflatable_cryo_tank',
        'name' => 'Inflatable Cryogenic Tank',
        'shell_requirements' => {
          'material_requirements' => [
            {
              'material' => 'inert_waste',
              'quantity' => 1400,
              'unit' => 'kg'
            },
            {
              'material' => '3D-Printed I-Beam Mk1',
              'quantity' => 5,
              'unit' => 'units'
            }
          ],
          'printing_time_hours' => 10.0
        }
      })

    # Stub item lookups
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('inert_waste')
      .and_return({
        'id' => 'inert_waste',
        'name' => 'Inert Waste',
        'type' => 'processed_material'
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('3D-Printed I-Beam Mk1')
      .and_return({
        'id' => '3d_printed_ibeam_mk1',
        'name' => '3D-Printed I-Beam Mk1',
        'type' => 'component'
      })
  end

  describe '#enclose_inflatable' do
    context 'with sufficient materials' do
      before do
        # Add required materials to inventory
        settlement.inventory.add_item('inert_waste', 2000, player, {
          'composition' => { 'SiO2' => 43.0, 'Al2O3' => 24.0 }
        })
        settlement.inventory.add_item('3D-Printed I-Beam Mk1', 10, player)
      end

      it 'creates a shell printing job' do
        expect {
          service.enclose_inflatable(inflatable_tank, printer_unit)
        }.to change { ShellPrintingJob.count }.by(1)

        job = ShellPrintingJob.last
        expect(job.inflatable_tank).to eq(inflatable_tank)
        expect(job.printer_unit).to eq(printer_unit)
        expect(job.production_time_hours).to eq(10.0)
        expect(job.status).to eq('pending')
      end

      it 'consumes materials from inventory' do
        service.enclose_inflatable(inflatable_tank, printer_unit)
        
        inert_waste = settlement.inventory.items.find_by(name: 'inert_waste')
        ibeams = settlement.inventory.items.find_by(name: '3D-Printed I-Beam Mk1')
        
        expect(inert_waste.amount).to eq(600) # 2000 - 1400
        expect(ibeams.amount).to eq(5) # 10 - 5
      end

      it 'stores material composition in job metadata' do
        service.enclose_inflatable(inflatable_tank, printer_unit)
        
        job = ShellPrintingJob.last
        expect(job.materials_consumed['inert_waste']).to include(
          'amount' => 1400,
          'composition' => { 'SiO2' => 43.0, 'Al2O3' => 24.0 }
        )
      end
    end

    context 'with insufficient materials' do
      before do
        settlement.inventory.add_item('inert_waste', 500, player) # Not enough
      end

      it 'raises an error' do
        expect {
          service.enclose_inflatable(inflatable_tank, printer_unit)
        }.to raise_error(/Insufficient materials/)
      end
    end

    context 'with tank not ready' do
      it 'raises error if tank not deployed' do
        inflatable_tank.update!(operational_data: inflatable_tank.operational_data.merge('deployed' => false))
        
        expect {
          service.enclose_inflatable(inflatable_tank, printer_unit)
        }.to raise_error(/Tank must be deployed/)
      end

      it 'raises error if tank already has shell' do
        inflatable_tank.update!(operational_data: inflatable_tank.operational_data.merge('deployed' => true, 'operational' => true, 'enclosed' => true))
        
        expect {
          service.enclose_inflatable(inflatable_tank, printer_unit)
        }.to raise_error(/Tank already has shell/)
      end
    end

    context 'with incompatible printer' do
      let(:wrong_printer) do
        create(:base_unit,
          owner: settlement,
          attachable: settlement,
          operational_data: {
            'processing_capabilities' => {
              'geosphere_processing' => {
                'enabled' => false,
                'types' => [],
                'efficiency' => 0.0
              }
            }
          }
        )
      end

      before do
        settlement.inventory.add_item('inert_waste', 2000, player)
        settlement.inventory.add_item('3D-Printed I-Beam Mk1', 10, player)
      end

      it 'raises an error' do
        expect {
          service.enclose_inflatable(inflatable_tank, wrong_printer)
        }.to raise_error(/cannot process regolith/)
      end
    end
  end

  describe '#complete_job' do
    let!(:job) do
      create(:shell_printing_job,
        settlement: settlement,
        printer_unit: printer_unit,
        inflatable_tank: inflatable_tank,
        status: 'in_progress',
        materials_consumed: {
          'inert_waste' => {
            'amount' => 1400,
            'composition' => { 'SiO2' => 43.0, 'Al2O3' => 24.0 }
          },
          '3D-Printed I-Beam Mk1' => {
            'amount' => 5,
            'composition' => {}
          }
        }
      )
    end

    it 'marks tank as enclosed' do
      service.complete_job(job)
      
      inflatable_tank.reload
      expect(inflatable_tank.operational_data['enclosed']).to be true
      expect(inflatable_tank.operational_data['shell_printed_at']).to be_present
    end

    it 'stores shell materials in tank metadata' do
      service.complete_job(job)
      
      inflatable_tank.reload
      expect(inflatable_tank.operational_data['shell_materials']).to be_present
      expect(inflatable_tank.operational_data['shell_materials']['inert_waste']).to include(
        'amount' => 1400
      )
    end

    it 'marks job as completed' do
      service.complete_job(job)
      
      expect(job.reload.status).to eq('completed')
      expect(job.completed_at).to be_present
    end
  end
end