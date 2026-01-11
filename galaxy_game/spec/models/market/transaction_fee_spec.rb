require 'rails_helper'

RSpec.describe Market::TransactionFee, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:fee_type) }
    it { should validate_inclusion_of(:fee_type).in_array(%w[percentage fixed]) }
    it { should validate_numericality_of(:percentage).is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_numericality_of(:fixed_amount).is_greater_than_or_equal_to(0).allow_nil }
  end

  describe '#calculate' do
    it 'calculates percentage fee' do
      fee = build(:transaction_fee, fee_type: 'percentage', percentage: 5, fixed_amount: nil)
      expect(fee.calculate(100)).to eq(5.0)
    end

    it 'calculates fixed fee' do
      fee = build(:transaction_fee, fee_type: 'fixed', percentage: nil, fixed_amount: 10)
      expect(fee.calculate(100)).to eq(10.0)
    end

    it 'returns 0 for unknown fee_type' do
      fee = build(:transaction_fee, fee_type: 'other', percentage: nil, fixed_amount: nil)
      expect(fee.calculate(100)).to eq(0)
    end
  end
end