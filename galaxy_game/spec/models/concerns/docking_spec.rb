require 'rails_helper'

RSpec.describe Docking do
  let(:base) do
    klass = Class.new do
      include Docking
      attr_accessor :blueprint_ports
      def docked_crafts
        @docked_crafts ||= []
      end
      def docked_crafts=(val)
        @docked_crafts = val
      end
      def initialize(ports = nil)
        @blueprint_ports = ports || ["docking_port"]
        @docked_crafts = []
      end
    end
    klass.new
  end

  it 'returns at least one available docking port if no blueprint_ports' do
    base.blueprint_ports = nil
    expect(base.available_docking_ports).to eq(1)
  end

  it 'returns correct available docking ports from blueprint_ports' do
    base.blueprint_ports = ["docking_port", "external_module_port"]
    expect(base.available_docking_ports).to eq(2)
    base.docked_crafts << Object.new
    expect(base.available_docking_ports).to eq(1)
  end

  it 'never returns less than zero available docking ports' do
    base.blueprint_ports = ["docking_port"]
    base.docked_crafts << Object.new
    expect(base.available_docking_ports).to eq(0)
  end
end
