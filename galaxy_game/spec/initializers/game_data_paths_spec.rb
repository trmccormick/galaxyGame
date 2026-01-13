require 'rails_helper'

RSpec.describe 'GameDataPaths', type: :initializer do
  it 'sets the correct path based on environment' do
    expected_path = if ENV['GALAXY_JSON_DATA_PATH']
      Pathname.new(ENV['GALAXY_JSON_DATA_PATH'])
    else
      Rails.root.join('app', 'data')
    end
    
    expect(GalaxyGame::Paths::JSON_DATA).to eq(expected_path)
    
    # Verify the path exists
    expect(File.directory?(GalaxyGame::Paths::JSON_DATA)).to be true
  end
  
  it 'TEMPLATE_PATH is correctly derived from JSON_DATA' do
    expect(GalaxyGame::Paths::TEMPLATE_PATH).to eq(GalaxyGame::Paths::JSON_DATA.join('templates'))
  end
end