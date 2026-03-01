# RSpec for ConsortiumManager AWS reconnection logic
require 'rails_helper'

RSpec.describe 'Consortium AWS Reconnection', type: :service do
  let(:system) do
    {
      system_id: 'eden',
      orphaned: true,
      prize: true,
      bodies: [
        { id: 'eden_gas_giant', mass: 1.2e27, position: 45 },
        { id: 'eden_moon', mass: 7.3e22, position: 120 }
      ],
      founding_corporations: ['CorpA', 'CorpB']
    }
  end
  let(:wormhole_manager) do
    double('WormholeManager', get_hot_start_resource_pool: 'hot_start_em_eden')
  end
  let(:station_placement_service) { AIManager::StationPlacementService.new }
  let(:transit_fee_service) { AIManager::TransitFeeService.new }
  let(:manager) { AIManager::ConsortiumManager.new(wormhole_manager, station_placement_service, transit_fee_service) }

  it 'uses Hot Start EM for AWS construction' do
    mission = manager.handle_orphaned_prize_system(system)
    expect(mission[:em_resource]).to eq('hot_start_em_eden')
  end

  it 'clears orphaned status upon AWS activation' do
    manager.handle_orphaned_prize_system(system)
    expect(system[:orphaned]).to be false
    expect(system[:aws_active]).to be true
  end

  it 'places AWS 180° opposite the gas giant' do
    manager.handle_orphaned_prize_system(system)
    expect(system[:aws_location][:anchor_body_id]).to eq('eden_gas_giant')
    expect(system[:aws_location][:position]).to eq(225)
  end

  it 'enables transit fees and logs charges' do
    manager.handle_orphaned_prize_system(system)
    fee = transit_fee_service.charge_fee(system, 5, 'CorpA')
    expect(system[:transit_fees_enabled]).to be true
    expect(system[:fee_log].last[:fee]).to eq(50)
    expect(system[:dividends]['CorpA']).to eq(25)
    expect(system[:dividends]['CorpB']).to eq(25)
  end
end
