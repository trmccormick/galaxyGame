require 'rails_helper'


RSpec.describe CelestialBodies::Satellites::SmallMoon, type: :model do
  let(:small_moon) { build(:small_moon) }

  it 'is valid with valid attributes' do
    expect(small_moon).to be_valid
  end

  it 'is classified as a small moon' do
    expect(small_moon.radius).to be < 1000000
  end
end
