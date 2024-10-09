# spec/models/concerns/financial_management_spec.rb
require 'rails_helper'

RSpec.describe FinancialManagement do
  let(:dummy_class) { Class.new { include FinancialManagement }.new }

  describe '#manage_expenses' do
    it 'correctly manages expenses and funds' do
      dummy_class.funds = 100
      dummy_class.expenses = 50
      dummy_class.manage_expenses(20)
      expect(dummy_class.funds).to eq(80)
      expect(dummy_class.expenses).to eq(70)
    end
  end

  describe '#can_afford?' do
    it 'returns true if funds are sufficient' do
      dummy_class.funds = 100
      expect(dummy_class.can_afford?(50)).to be_truthy
    end

    it 'returns false if funds are insufficient' do
      dummy_class.funds = 30
      expect(dummy_class.can_afford?(50)).to be_falsey
    end
  end
end
