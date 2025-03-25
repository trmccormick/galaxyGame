require 'rails_helper'

RSpec.describe Units::Computer, type: :model do
  let(:computer) { build(:computer) }
  
  describe 'attributes' do
    it { should respond_to(:mining_rate) }
    it { should respond_to(:efficiency_upgrade) }
    
    it 'has default values' do
      expect(computer.mining_rate).to eq(1.0)
      expect(computer.efficiency_upgrade).to eq(0.0)
    end
  end

  describe '#mine' do
    it 'calculates GCC based on mining rate and efficiency' do
      computer.mining_rate = 2.0
      result = computer.mine(1.5, 2.0)
      expect(result).to eq(6.0) # 2.0 * 1.5 * 2.0
    end
  end

  describe '#mining_power' do
    it 'returns default mining power' do
      expect(computer.mining_power).to eq(10)
    end
  end

  describe '#total_efficiency' do
    it 'calculates total efficiency with upgrades' do
      computer.efficiency_upgrade = 0.5
      expect(computer.total_efficiency).to eq(1.5)
    end
  end

  describe '#upgrade_efficiency' do
    it 'increases efficiency upgrade value' do
      expect {
        computer.upgrade_efficiency(0.2)
      }.to change { computer.efficiency_upgrade }.by(0.2)
    end

    it 'persists the change' do
      expect(computer).to receive(:save)
      computer.upgrade_efficiency(0.2)
    end
  end
end