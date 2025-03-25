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
    end.new
  end

  let(:computer_unit) do 
    obj = Object.new
    def obj.type; 'Units::Computer'; end
    def obj.mining_power; 10; end
    def obj.mine(difficulty, efficiency); 50; end
    obj
  end

  let(:satellite_computer_unit) do
    obj = Object.new
    def obj.type; 'Units::Computer'; end
    def obj.mining_power; 5; end
    def obj.mine(difficulty, efficiency); 30; end
    obj
  end

  let(:owner) do
    Class.new do
      attr_accessor :funds, :account, :ground_computers, :satellite_computers
      
      def initialize(account)
        @funds = 100
        @account = account
        @ground_computers = []
        @satellite_computers = []
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
      owner.ground_computers = [computer_unit]
      owner.satellite_computers = [satellite_computer_unit]
    end
  end

  describe '#mine_gcc' do
    it 'correctly updates the account balance with mined GCC' do
      expect { owner.mine_gcc }.to change { owner.account.balance }.by(80)
    end

    it 'updates internal funds after mining' do
      expect { owner.mine_gcc }.to change { owner.funds }.by(80)
    end
  end
end




