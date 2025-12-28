# spec/services/manufacturing/component_production_service_spec.rb
require 'rails_helper'

RSpec.describe Manufacturing::ComponentProductionService do
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
        'component_production' => {
          'categories' => ['structural'],
          'production_rate_multiplier' => 1.0
        }
      }
    )
  end

  let(:service) { described_class.new(settlement) }

  before do
    # Stub blueprint lookup
    allow_any_instance_of(Lookup::BlueprintLookupService)
      .to receive(:find_blueprint)
      .with('3d_printed_ibeam')
      .and_return({
        'id' => '3d_printed_ibeam',
        'name' => '3D-Printed I-Beam',
        'category' => 'structural',
        'blueprint_data' => {
          'material_requirements' => [
            {
              'material' => 'inert_waste',
              'quantity' => 90,
              'unit' => 'kg'
            },
            {
              'material' => 'binding_agent',
              'quantity' => 10,
              'unit' => 'kg'
            }
          ],
          'construction_time_hours' => 2.0,
          'waste_products' => [
            {
              'material' => 'manufacturing_dust',
              'quantity' => 5,
              'recyclable' => true
            }
          ]
        }
      })

    # Stub item lookup for materials
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
      .with('binding_agent')
      .and_return({
        'id' => 'binding_agent',
        'name' => 'Binding Agent',
        'type' => 'processed_material'
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('3D-Printed I-Beam')
      .and_return({
        'id' => '3d_printed_ibeam',
        'name' => '3D-Printed I-Beam',
        'type' => 'component'
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('manufacturing_dust')
      .and_return({
        'id' => 'manufacturing_dust',
        'name' => 'Manufacturing Dust',
        'type' => 'waste_material'
      })
  end

  describe '#produce_component' do
    context 'with sufficient materials' do
      before do
        # Add materials to inventory
        settlement.inventory.add_item('inert_waste', 200, player, {
          'composition' => { 'SiO2' => 43.0, 'Al2O3' => 24.0 }
        })
        settlement.inventory.add_item('binding_agent', 50, player)
      end

      it 'creates a component production job' do
        expect {
          service.produce_component('3d_printed_ibeam', 2, printer_unit)
        }.to change { ComponentProductionJob.count }.by(1)

        job = ComponentProductionJob.last
        expect(job.component_blueprint_id).to eq('3d_printed_ibeam')
        expect(job.component_name).to eq('3D-Printed I-Beam')
        expect(job.quantity).to eq(2)
        expect(job.production_time_hours).to eq(4.0) # 2 hours * 2 quantity
        expect(job.status).to eq('pending')
      end

      it 'consumes materials from inventory' do
        service.produce_component('3d_printed_ibeam', 2, printer_unit)
        
        inert_waste = settlement.inventory.items.find_by(name: 'inert_waste')
        binding_agent = settlement.inventory.items.find_by(name: 'binding_agent')
        
        expect(inert_waste.amount).to eq(20) # 200 - (90 * 2)
        expect(binding_agent.amount).to eq(30) # 50 - (10 * 2)
      end

      it 'stores material composition in job metadata' do
        service.produce_component('3d_printed_ibeam', 1, printer_unit)
        
        job = ComponentProductionJob.last
        expect(job.materials_consumed['inert_waste']).to include(
          'amount' => 90,
          'composition' => { 'SiO2' => 43.0, 'Al2O3' => 24.0 }
        )
      end
    end

    context 'with insufficient materials' do
      before do
        settlement.inventory.add_item('inert_waste', 50, player) # Not enough
      end

      it 'raises an error' do
        expect {
          service.produce_component('3d_printed_ibeam', 1, printer_unit)
        }.to raise_error(/Insufficient materials/)
      end
    end

    context 'with incompatible printer' do
      let(:wrong_printer) do
        create(:base_unit,
          owner: settlement,
          attachable: settlement,
          operational_data: {
            'component_production' => {
              'categories' => ['electronics'], # Can't make structural
              'production_rate_multiplier' => 1.0
            }
          }
        )
      end

      before do
        settlement.inventory.add_item('inert_waste', 200, player)
        settlement.inventory.add_item('binding_agent', 50, player)
      end

      it 'raises an error' do
        expect {
          service.produce_component('3d_printed_ibeam', 1, wrong_printer)
        }.to raise_error(/cannot produce structural components/)
      end
    end
  end

  describe '#complete_job' do
    let!(:job) do
      create(:component_production_job,
        settlement: settlement,
        printer_unit: printer_unit,
        component_blueprint_id: '3d_printed_ibeam',
        component_name: '3D-Printed I-Beam',
        quantity: 2,
        status: 'in_progress',
        materials_consumed: {
          'inert_waste' => {
            'amount' => 180,
            'composition' => { 'SiO2' => 43.0, 'Al2O3' => 24.0 }
          },
          'binding_agent' => {
            'amount' => 20,
            'composition' => {}
          }
        }
      )
    end

    it 'adds components to inventory' do
      expect {
        service.complete_job(job)
      }.to change { settlement.inventory.items.count }.by(2) # component + waste

      component = settlement.inventory.items.find_by(name: '3D-Printed I-Beam')
      expect(component.amount).to eq(2)
    end

    it 'stores source material composition in component metadata' do
      service.complete_job(job)
      
      component = settlement.inventory.items.find_by(name: '3D-Printed I-Beam')
      expect(component.metadata['source_materials']).to be_present
      expect(component.metadata['source_materials'].first).to include(
        'material' => 'inert_waste',
        'amount' => 180
      )
    end

    it 'adds waste products to inventory' do
      service.complete_job(job)
      
      waste = settlement.inventory.items.find_by(name: 'manufacturing_dust')
      expect(waste).to be_present
      expect(waste.amount).to eq(10) # 5 * 2 quantity
      expect(waste.metadata['recyclable']).to be true
    end

    it 'marks job as completed' do
      service.complete_job(job)
      
      expect(job.reload.status).to eq('completed')
      expect(job.completed_at).to be_present
    end
  end
end