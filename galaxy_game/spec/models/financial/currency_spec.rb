require 'rails_helper'

RSpec.describe Financial::Currency, type: :model do
  describe 'associations' do
    it { should have_many(:accounts) }
    it { should have_many(:transactions) }
    it { should belong_to(:issuer).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:symbol) }
    it { should validate_uniqueness_of(:symbol) }
    it { should allow_value(true, false).for(:is_system_currency) }
    it { should allow_value(2).for(:precision) }
  end
end
