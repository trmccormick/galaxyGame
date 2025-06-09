require 'rails_helper'

RSpec.describe 'GameDataPaths', type: :initializer do
  it 'sets the correct path based on environment' do
    # We're in test environment
    expect(GalaxyGame::Paths::GAME_DATA).to eq(Rails.root.join('spec', 'fixtures', 'data'))
    
    # Verify the path exists
    expect(File.directory?(GalaxyGame::Paths::GAME_DATA)).to be true
  end
end