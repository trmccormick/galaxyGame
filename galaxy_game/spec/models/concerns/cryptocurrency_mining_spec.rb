require 'rails_helper'
require 'ostruct'

RSpec.describe CryptocurrencyMining do
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
    def obj.mine(difficulty, efficiency); 50; end
    obj
  end

  let(:owner) do
    Class.new do
      attr_accessor :funds, :account, :base_units
      
      def initialize(account)
        @funds = 100
        @account = account
        @base_units = []
      end

      def update!(attrs)
        @funds = attrs[:funds] if attrs[:funds]
        true
      end

      def available_power; 1000; end
      def mining_difficulty; 1.0; end
      def unit_efficiency; 1.0; end
    end.new(account).tap do |owner|
      owner.extend(CryptocurrencyMining)
      owner.base_units = [computer_unit]
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