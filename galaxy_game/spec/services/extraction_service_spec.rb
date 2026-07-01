require 'rails_helper'

RSpec.describe ExtractionService, type: :service do

  let(:settlement) { double('Settlement') }
  let(:location) { double('Location') }
  let(:account) { double('Account', balance: 200_000) }
  let(:celestial_body) { double('CelestialBody') }
  let(:priority_heuristic) { double('PriorityHeuristic') }
  let(:structure1) { double('Structure', operational_data: nil) }
  let(:structure2) { double('Structure', operational_data: nil) }
  let(:structures) { [structure1, structure2] }


  before do
    allow(settlement).to receive(:location).and_return(location)
    allow(location).to receive(:celestial_body).and_return(celestial_body)
    allow(settlement).to receive(:gcc_account).and_return(account)
    allow(settlement).to receive(:id).and_return(1)
    allow(Structures::BaseStructure).to receive(:where).with(settlement_id: 1).and_return(structures)
    allow(AIManager::PriorityHeuristic).to receive(:new).with(settlement).and_return(priority_heuristic)
    allow(account).to receive(:update!)
    allow(structure1).to receive(:save!)
    allow(structure2).to receive(:save!)
  end

  describe '.extract_argon_on_mars' do
    let(:amount_needed) { 10.0 }

    context 'when celestial body is nil' do
      before { allow(settlement).to receive(:location).and_return(nil) }
      it 'returns false' do
        expect(described_class.extract_argon_on_mars(settlement, amount_needed)).to eq(false)
      end
    end

    context 'when atmosphere_composition is nil' do
      before { allow(celestial_body).to receive(:atmosphere_composition).and_return(nil) }
      it 'returns false' do
        expect(described_class.extract_argon_on_mars(settlement, amount_needed)).to eq(false)
      end
    end

    context 'when Ar is not present or too low' do
      before { allow(celestial_body).to receive(:atmosphere_composition).and_return({ 'Ar' => 0.005 }) }
      it 'returns false' do
        expect(described_class.extract_argon_on_mars(settlement, amount_needed)).to eq(false)
      end
    end

    context 'when nitrogen is not critical' do
      before do
        allow(celestial_body).to receive(:atmosphere_composition).and_return({ 'Ar' => 0.02 })
        allow(priority_heuristic).to receive(:nitrogen_critical?).and_return(false)
      end
      it 'returns false' do
        expect(described_class.extract_argon_on_mars(settlement, amount_needed)).to eq(false)
      end
    end

    context 'when not enough energy' do
      before do
        allow(celestial_body).to receive(:atmosphere_composition).and_return({ 'Ar' => 0.02 })
        allow(priority_heuristic).to receive(:nitrogen_critical?).and_return(true)
        allow(account).to receive(:balance).and_return(5)
      end
      it 'returns false' do
        expect(described_class.extract_argon_on_mars(settlement, amount_needed)).to eq(false)
      end
    end

    context 'happy path' do
      before do
        allow(celestial_body).to receive(:atmosphere_composition).and_return({ 'Ar' => 0.02 })
        allow(priority_heuristic).to receive(:nitrogen_critical?).and_return(true)
        allow(account).to receive(:balance).and_return(200_000)
        allow(structure1).to receive(:operational_data).and_return({})
        allow(structure2).to receive(:operational_data).and_return({})
        allow(structure1).to receive(:operational_data=)
        allow(structure2).to receive(:operational_data=)
        allow(structure1).to receive(:save!)
        allow(structure2).to receive(:save!)
      end
      it 'deducts energy, updates gas_storage, and returns true' do
        amount_needed = 10
        expect(account).to receive(:update!).with(balance: 190_000)
        expect(structure1).to receive(:save!)
        expect(structure2).to receive(:save!)
        expect(described_class.extract_argon_on_mars(settlement, amount_needed)).to eq(true)
      end
    end
  end
end
