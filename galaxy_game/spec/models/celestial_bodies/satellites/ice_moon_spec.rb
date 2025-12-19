require 'rails_helper'


RSpec.describe CelestialBodies::Satellites::IceMoon, type: :model do
  let(:ice_moon) { build(:ice_moon) }

  it 'is valid with valid attributes' do
    expect(ice_moon).to be_valid
  end

  it 'has ice composition' do
    expect(ice_moon.hydrosphere.composition['water']).to be >= 90
    expect(ice_moon.hydrosphere.composition).to include('water')
  end
end
