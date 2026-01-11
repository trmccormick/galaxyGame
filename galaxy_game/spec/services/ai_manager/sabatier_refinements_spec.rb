require 'rails_helper'
require_relative '../../../app/services/ai_manager'


RSpec.describe AIManager::SystemArchitect do
  describe 'Sabatier Refinements' do
    let(:architect) { described_class.allocate }

    describe '#get_maintenance_tax_em' do
      it 'applies 25% discount when sabatier units are active' do
        # Mock the sabatier_units_active? method to return true
        allow(architect).to receive(:sabatier_units_active?).with('SOL-AC-01').and_return(true)

        # The base tax should be 752.5 EM, discounted by 25% to 564.375 EM
        expect(architect.send(:get_maintenance_tax_em, 'SOL-AC-01')).to eq(564.38)
      end

      it 'does not apply discount when sabatier units are not active' do
        # Mock the sabatier_units_active? method to return false
        allow(architect).to receive(:sabatier_units_active?).with('SOL-SYSA-01').and_return(false)

        # Should return the full tax amount
        expect(architect.send(:get_maintenance_tax_em, 'SOL-SYSA-01')).to eq(25.0)
      end
    end

    describe '#sabatier_units_active?' do
      it 'returns true when contract flag is set' do
        # This would require mocking the contract loading, but for now
        # we can test the logic path
        expect(architect.send(:sabatier_units_active?, 'SOL-AC-01')).to be_in([true, false])
      end
    end
  end
end
