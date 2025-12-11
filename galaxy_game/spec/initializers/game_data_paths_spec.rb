require 'rails_helper'

RSpec.describe 'GameDataPaths', type: :initializer do
  it 'sets the correct path based on environment' do
    # All environments now use the production data path
    expect(GalaxyGame::Paths::JSON_DATA).to eq(Rails.root.join('app', 'data'))
    
    # Verify the path exists
    expect(File.directory?(GalaxyGame::Paths::JSON_DATA)).to be true
  end
end