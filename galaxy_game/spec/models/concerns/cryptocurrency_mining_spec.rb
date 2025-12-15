require 'rails_helper'
require 'ostruct'

RSpec.describe CryptocurrencyMining do
  # Create a proper ActiveRecord test model to avoid polymorphic association issues
  let(:test_model_class) do
    Class.new(ApplicationRecord) do
      self.table_name = 'players' # Use an existing table
      
      attr_accessor :base_units, :funds, :account
      
      def available_power; 1000; end
      def mining_difficulty; 1.0; end
      def unit_efficiency; 1.0; end
      
      def update!(attrs)
        @funds = attrs[:funds] if attrs[:funds]
        true
      end
    end
  end

  let(:account) do 
    Class.new do
      attr_accessor :balance
      def initialize(balance = 100)
        @balance = balance
      end
      
      def update(attrs)
        @balance = attrs[:balance] if attrs[:balance]
        true
      end

      def deposit(amount, description)
        update(balance: balance + amount)
        true
      end
    end.new
  end

  let(:computer_unit) do 
    obj = Object.new
    def obj.is_a?(klass); klass == Units::Computer; end
    def obj.mining_rate_value; 50; end
    obj
  end

  let(:owner) do
    test_model_class.new(name: 'Test Miner', active_location: 'Test Location').tap do |owner|
      owner.funds = 100
      owner.account = account
      owner.extend(CryptocurrencyMining)
      owner.base_units = [computer_unit]
      owner.save!(validate: false) # Save without validation to get an ID for polymorphic association
    end
  end

  describe '#mine_gcc' do
    it 'correctly updates the account balance with mined GCC' do
      expect { owner.mine_gcc }.to change { owner.account.balance }.by(50)
    end

    it 'updates internal funds after mining' do
      expect { owner.mine_gcc }.to change { owner.funds }.by(50)
    end
  end
end