# spec/models/financial/bond_spec.rb
require 'rails_helper'

RSpec.describe Financial::Bond, type: :model do
  describe 'associations' do
    it { should belong_to(:issuer) }
    it { should belong_to(:holder) }
    it { should belong_to(:currency) }
    it { should have_many(:repayments).class_name('Financial::BondRepayment').dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:issued_at) }
    it { should validate_presence_of(:status) }
  end

  describe 'methods' do
    let(:bond) { create(:financial_bond, amount: 1000) }
    
    it 'calculates total repaid' do
      expect(bond.total_repaid).to be_a(Numeric)
    end
    
    it 'checks if paid off' do
      expect([true, false]).to include(bond.paid_off?)
    end
  end
end
