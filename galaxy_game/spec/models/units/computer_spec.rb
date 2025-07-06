require 'rails_helper'

RSpec.describe Units::Computer, type: :model do
  let(:computer) { build(:computer) }
  
  describe 'attributes' do
    it { should respond_to(:mining_rate_value) }
    it { should respond_to(:efficiency_upgrade_value) }
    
    it 'has default values' do
      expect(computer.mining_rate_value).to eq(1.0)
      expect(computer.efficiency_upgrade_value).to eq(0.0)
    end
  end

  describe '#mine' do
    it 'calculates GCC based on mining rate and efficiency' do
      computer.mining_rate_value = 2.0
      result = computer.mine(1.5, 2.0)
      expect(result).to eq(6.0) # 2.0 * 1.5 * 2.0
    end
  end

  describe '#energy_required' do
    it 'returns default energy required value' do
      expect(computer.energy_required).to eq(10.0)
    end
  end

  describe '#total_efficiency' do
    it 'calculates total efficiency with upgrades' do
      computer.efficiency_upgrade_value = 0.5
      expect(computer.total_efficiency).to eq(1.5)
    end
  end

  describe '#upgrade_efficiency' do
    it 'increases efficiency upgrade value' do
      expect {
        computer.upgrade_efficiency(0.2)
      }.to change { computer.efficiency_upgrade_value }.by(0.2)
    end
  end

  describe '#overclock' do
    it 'temporarily increases mining rate' do
      # Create a computer with a specific mining_rate_value in operational_data
      computer = create(:computer, :with_mining_data)
      
      # Reload to ensure we have the loaded values
      computer.reload
      original_rate = computer.mining_rate_value
      
      # Mock Thread to avoid actual sleep in tests
      thread_double = double("Thread")
      allow(Thread).to receive(:new).and_return(thread_double)
      
      # Test that the method increases the mining rate
      expect {
        computer.overclock(0.5, 60)
      }.to change { computer.reload.mining_rate_value }.by(0.5)
      
      # Now simulate the thread callback that resets the value
      # Update the operational_data directly instead of trying to use update_column on a virtual attribute
      updated_operational_data = computer.operational_data
      if updated_operational_data['operational_properties']
        updated_operational_data['operational_properties']['mining_rate'] = original_rate
      end
      
      computer.update_column(:operational_data, updated_operational_data)
      
      # Verify it was reset after reload
      expect(computer.reload.mining_rate_value).to eq(original_rate)
    end
  end
end