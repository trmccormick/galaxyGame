# RSpec for WormholeManager Shift Logic
require 'rails_helper'

RSpec.describe AIManager::WormholeManager, type: :service do
  let(:sol_anchor_id) { 'sol_wormhole_1' }
  let(:eden_wormhole_id) { 'eden_wormhole_1' }
  let(:wormholes) do
    [
      { id: sol_anchor_id, current_mass: 100_000, instability_threshold: 300_000, destination_id: 'eden', status: 'active' },
      { id: eden_wormhole_id, current_mass: 310_000, instability_threshold: 300_000, destination_id: 'sol', status: 'active' }
    ]
  end

  subject { described_class.new(wormholes, sol_anchor_id) }

  it 'marks Sol anchor as shift_resistant and does not shift' do
    subject.monitor_and_trigger_shift
    sol_wh = wormholes.find { |wh| wh[:id] == sol_anchor_id }
    expect(sol_wh[:shift_resistant]).to be true
    expect(sol_wh[:status]).to eq('active')
    expect(sol_wh[:destination_id]).to eq('eden')
  end

  it 'triggers shift discharge for Eden wormhole when mass exceeds threshold' do
    subject.monitor_and_trigger_shift
    eden_wh = wormholes.find { |wh| wh[:id] == eden_wormhole_id }
    expect(eden_wh[:status]).to eq('orphaned')
    expect(eden_wh[:destination_id]).not_to eq('sol')
    expect(eden_wh[:em_bloom_harvested]).to be true
    expect(eden_wh[:hot_start_resource_pool]).to be true
  end

  it 'generates lore log as mass approaches threshold' do
    wormholes[1][:current_mass] = 270_000
    subject.monitor_and_trigger_shift
    eden_wh = wormholes.find { |wh| wh[:id] == eden_wormhole_id }
    expect(eden_wh[:lore_log]).not_to be_nil
    expect(eden_wh[:lore_log].first).to match(/EM Bloom increasing/) 
  end
end
