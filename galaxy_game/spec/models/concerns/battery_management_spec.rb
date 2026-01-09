require 'rails_helper'

# Create a test class that includes the concern
class TestBatteryEntity
  include ActiveModel::Model
  include BatteryManagement
  
  attr_accessor :operational_data
  
  def initialize(attrs = {})
    super
    @operational_data ||= {}
    initialize_battery_data
  end
  
  def save
    true # Mock saving behavior
  end
end

RSpec.describe BatteryManagement do
  let(:test_entity) { TestBatteryEntity.new }
  
  describe "initialization" do
    it "sets up default battery data" do
      expect(test_entity.operational_data).to have_key('battery')
      expect(test_entity.operational_data['battery']).to have_key('capacity')
      expect(test_entity.operational_data['battery']).to have_key('current_charge')
      expect(test_entity.operational_data['battery']).to have_key('drain_rate')
    end
    
    it "uses default capacity of 100.0" do
      expect(test_entity.battery_capacity).to eq(100.0)
    end
    
    it "initializes current charge to full capacity" do
      expect(test_entity.battery_level).to eq(100.0)
    end
  end
  
  describe "battery_percentage" do
    it "calculates percentage correctly" do
      test_entity.operational_data['battery']['current_charge'] = 75.0
      expect(test_entity.battery_percentage).to eq(75.0)
    end
    
    it "handles empty battery" do
      test_entity.operational_data['battery']['current_charge'] = 0.0
      expect(test_entity.battery_percentage).to eq(0.0)
    end
    
    it "handles zero capacity" do
      test_entity.operational_data['battery']['capacity'] = 0.0
      expect(test_entity.battery_percentage).to eq(0.0)
    end
  end
  
  describe "consume_battery" do
    before do
      test_entity.operational_data['battery']['current_charge'] = 100.0
    end
    
    it "reduces battery level by specified amount" do
      test_entity.consume_battery(25.0)
      expect(test_entity.battery_level).to eq(75.0)
    end
    
    it "doesn't allow battery to go below zero" do
      test_entity.consume_battery(150.0)
      expect(test_entity.battery_level).to eq(0.0)
    end
    
    it "ignores nil or negative values" do
      test_entity.consume_battery(nil)
      expect(test_entity.battery_level).to eq(100.0)
      
      test_entity.consume_battery(-10.0)
      expect(test_entity.battery_level).to eq(100.0)
    end
  end
  
  describe "recharge_battery" do
    before do
      test_entity.operational_data['battery']['current_charge'] = 50.0
    end
    
    it "increases battery level by specified amount" do
      test_entity.recharge_battery(25.0)
      expect(test_entity.battery_level).to eq(75.0)
    end
    
    it "doesn't allow battery to exceed capacity" do
      test_entity.recharge_battery(75.0)
      expect(test_entity.battery_level).to eq(100.0)
    end
    
    it "ignores nil or negative values" do
      test_entity.recharge_battery(nil)
      expect(test_entity.battery_level).to eq(50.0)
      
      test_entity.recharge_battery(-10.0)
      expect(test_entity.battery_level).to eq(50.0)
    end
  end
  
  describe "charge_battery alias" do
    it "works the same as recharge_battery" do
      test_entity.operational_data['battery']['current_charge'] = 50.0
      test_entity.charge_battery(25.0)
      expect(test_entity.battery_level).to eq(75.0)
    end
  end
  
  describe "battery_drain" do
    it "returns the configured drain rate" do
      test_entity.operational_data['battery']['drain_rate'] = 2.5
      expect(test_entity.battery_drain).to eq(2.5)
    end
    
    it "has a default value" do
      test_entity.operational_data['battery'].delete('drain_rate')
      expect(test_entity.battery_drain).to eq(1.0)
    end
  end
end