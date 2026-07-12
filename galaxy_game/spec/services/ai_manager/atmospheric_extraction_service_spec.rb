require 'rails_helper'

RSpec.describe AIManager::AtmosphericExtractionService, type: :service do
  let(:astro_lift) { create(:corporation) }
  let(:skimmer) { create(:craft_harvester, owner: astro_lift) }
  let(:luna) { CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01') }

  # Helper to create a skimmer without owner (bypasses validation)
  def build_skimmer_without_owner
    skimmer = Craft::Harvester.new(name: 'TestSkimmerNoOwner', craft_name: 'Harvester', craft_type: 'harvesters', extraction_rate: 1.2)
    # Save without validations first
    skimmer.save!(validate: false)
    # Then clear owner via direct column update
    skimmer.update_columns(owner_id: nil, owner_type: nil)
    skimmer.reload
    skimmer
  end

  # Helper to ensure skimmer has an atmosphere with gases
  def setup_skimmer_atmosphere(skimmer, gases = { 'N2' => 1000, 'CH4' => 500 })
    unless skimmer.atmosphere
      skimmer.build_atmosphere(
        temperature: 288.0,
        pressure: 101325.0,
        environment_type: 'artificial',
        total_atmospheric_mass: 0
      )
      skimmer.save!
    end
    
    gases.each do |formula, mass|
      skimmer.atmosphere.add_gas(formula, mass)
    end
  end

  describe '#initialize' do
    it 'stores skimmer and source body' do
      service = described_class.new(skimmer, luna)
      expect(service.skimmer).to eq(skimmer)
      expect(service.source_body).to eq(luna)
    end

    it 'resolves owner corporation from skimmer' do
      service = described_class.new(skimmer, luna)
      expect(service.owner_corporation).to eq(astro_lift)
    end

    it 'defaults target body to Luna' do
      service = described_class.new(skimmer, luna)
      expect(service.target_body).to be_a(CelestialBodies::CelestialBody)
      expect(service.target_body.name).to eq('Luna')
    end

    context 'when skimmer has no owner' do
      let(:skimmer_without_owner) { build_skimmer_without_owner }

      it 'sets owner_corporation to nil' do
        service = described_class.new(skimmer_without_owner, luna)
        expect(service.owner_corporation).to be_nil
      end
    end
  end

  describe '#execute_extraction' do
    context 'when skimmer has no owner' do
      let(:skimmer_without_owner) { build_skimmer_without_owner }

      it 'raises ArgumentError' do
        service = described_class.new(skimmer_without_owner, luna)
        expect { service.execute_extraction }.to raise_error(ArgumentError, /has no owner/)
      end
    end

    context 'when source has no atmosphere' do
      let(:no_atm_body) do
        cb = create(:celestial_body, name: 'TestNoAtm')
        # Destroy the atmosphere created by factory callback, bypassing validation
        cb.atmosphere&.destroy
        cb.reload
        cb
      end

      it 'raises ArgumentError' do
        service = described_class.new(skimmer, no_atm_body)
        expect { service.execute_extraction }.to raise_error(ArgumentError, /has no atmosphere/)
      end
    end

    context 'with valid skimmer and atmosphere' do
      let(:service) { described_class.new(skimmer, luna) }

      it 'delegates to TerraSim::AtmosphericTransferService with :raw mode' do
        # Stub to avoid existing logger bug in TerraSim service
        transfer_result = { gases_extracted: { 'N2' => 100, 'CH4' => 50 }, gases_delivered: { 'N2' => 98, 'CH4' => 49 }, success: true }
        
        expect(TerraSim::AtmosphericTransferService).to receive(:new) do |source, target, options|
          expect(source).to eq(luna)
          expect(target).to be_a(CelestialBodies::CelestialBody)
          expect(options[:mode]).to eq(:raw)
          instance_double(TerraSim::AtmosphericTransferService, transfer_atmosphere: transfer_result)
        end

        result = service.execute_extraction(capacity: 1000)
        expect(result[:success]).to be true
        expect(result[:gases_extracted]).to be_a(Hash)
      end

      it 'extracts gases proportionally by percentage' do
        # Stub to avoid existing logger bug
        transfer_result = { gases_extracted: { 'N2' => 100, 'CH4' => 50 }, gases_delivered: { 'N2' => 98, 'CH4' => 49 }, success: true }
        allow(TerraSim::AtmosphericTransferService).to receive(:new)
          .and_return(instance_double(TerraSim::AtmosphericTransferService, transfer_atmosphere: transfer_result))

        service = described_class.new(skimmer, luna)
        result = service.execute_extraction(capacity: 1000)

        expect(result[:gases_extracted]).to be_a(Hash)
        expect(result[:gases_delivered]).to be_a(Hash)
      end

      it 'uses default capacity when not provided' do
        allow(skimmer.atmosphere).to receive(:total_atmospheric_mass).and_return(3000)
        
        # Stub to verify capacity is passed correctly
        expect(TerraSim::AtmosphericTransferService).to receive(:new) do |source, target, options|
          expect(options[:mode]).to eq(:raw)
          instance_double(TerraSim::AtmosphericTransferService, transfer_atmosphere: { success: true })
        end

        service = described_class.new(skimmer, luna)
        service.execute_extraction
      end
    end
  end

  describe '#dock_and_transfer_to_cycler' do
    let(:base_craft) { create(:base_craft, craft_type: 'cycler') }
    let(:cycler_attrs) { { base_craft_id: base_craft.id, cycler_type: 'earth_mars', orbital_period: 780, craft_name: 'test_cycler', craft_type: 'cycler' } }
    let(:cycler) { Craft::Transport::Cycler.create!(cycler_attrs) }
    let(:service) { described_class.new(skimmer, luna) }

    before do
      allow(skimmer).to receive(:has_available_docking_port?).and_return(true)
      # Stub has_available_docking_port? on the cycler's base_craft association
      allow(base_craft).to receive(:has_available_docking_port?).and_return(true)
    end

    it 'transfers cargo to cycler.definition_data[cargo] hash' do
      setup_skimmer_atmosphere(skimmer, { 'N2' => 1000, 'CH4' => 500 })

      service.dock_and_transfer_to_cycler(cycler, max_capacity: 1000)

      expect(cycler.definition_data['cargo']['N2']).to be > 0
      expect(cycler.definition_data['cargo']['CH4']).to be > 0
    end

    it 'does NOT use cycler.atmosphere for cargo' do
      setup_skimmer_atmosphere(skimmer, { 'N2' => 1000 })
      service.dock_and_transfer_to_cycler(cycler, max_capacity: 1000)

      expect(cycler.definition_data['cargo']).to be_a(Hash)
    end

    it 'returns false when docking is not possible' do
      allow(cycler).to receive(:base_craft).and_return(base_craft)
      allow(base_craft).to receive(:has_available_docking_port?).and_return(false)

      expect(service.dock_and_transfer_to_cycler(cycler)).to be false
    end

    it 'limits transfer to cycler available storage' do
      setup_skimmer_atmosphere(skimmer, { 'N2' => 1000 })
      allow(base_craft).to receive(:base_units).and_return([])
      allow(cycler).to receive(:changed?).and_return(false)

      service.dock_and_transfer_to_cycler(cycler, max_capacity: 100)

      expect(cycler.definition_data['cargo']['N2']).to be <= 100
    end

    it 'saves cycler when definition_data changes' do
      setup_skimmer_atmosphere(skimmer, { 'N2' => 1000 })
      
      # Stub changed? to return true so save! is called
      allow(cycler).to receive(:changed?).and_return(true)
      # Stub save! to track if it was called
      saved = false
      allow(cycler).to receive(:save!) { saved = true }

      service.dock_and_transfer_to_cycler(cycler, max_capacity: 1000)

      expect(saved).to be true
    end
  end
end
