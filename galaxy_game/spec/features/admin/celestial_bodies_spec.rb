require 'rails_helper'

RSpec.describe 'Admin::CelestialBodies', type: :feature do
  let!(:celestial_body) do
    CelestialBodies::CelestialBody.create!(
      name: 'Test Planet',
      identifier: 'test-planet-001',
      mass: 5.972e24,
      radius: 6_371_000,
      gravity: 9.807,
      density: 5514,
      status: :active
    )
  end

  before do
    # If authentication is required, add login steps here
    visit "/admin/celestial_bodies/#{celestial_body.id}"
  end

  it "shows the celestial body profile" do
    expect(page).to have_content('Celestial Body')
    expect(page).to have_content('Test Planet')
    expect(page).to have_content('test-planet-001')
    expect(page).to have_content('Mass')
    expect(page).to have_content('Radius')
    expect(page).to have_content('Gravity')
    expect(page).to have_content('Density')
    expect(page).to have_content('Status')
  end
end
