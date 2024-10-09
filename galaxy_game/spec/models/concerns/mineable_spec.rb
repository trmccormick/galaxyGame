# spec/models/concerns/mineable_spec.rb
require 'rails_helper'

# Dummy class to include the Mineable module for testing
class TestModel
  include Mineable

  attr_accessor :account, :available_power

  def initialize
    @account = double('Account', update: true) # Mocking the account
    @available_power = 1000
  end
end

RSpec.describe Mineable do
  let(:test_model) { TestModel.new }

  describe '#mine_gcc' do
    let(:computer) { double('Computer', mining_power: 200, mine: 50) }
    let(:satellite) { double('Satellite', mining_power: 300, mine: 30) }

    before do
      allow(test_model).to receive(:computers).and_return([computer])
      allow(test_model).to receive(:satellites).and_return([satellite])
      allow(test_model).to receive(:available_power).and_return(1000)
    end

    it 'mines from satellites and computers' do
      expect(test_model.account).to receive(:update).with(balance: 80) # 30 (satellite) + 50 (computer)
      test_model.mine_gcc
    end

    it 'does not exceed available power' do
      allow(computer).to receive(:mining_power).and_return(1200) # Simulate high power usage
      expect(test_model.account).to receive(:update).with(balance: 30) # Only satellite can mine
      test_model.mine_gcc
    end
  end
end
