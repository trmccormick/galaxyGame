require 'rails_helper'

RSpec.describe Financial::BondRepayment, type: :model do
  describe 'associations' do
    it { should belong_to(:bond) }
    it { should belong_to(:currency) }
  end
end
