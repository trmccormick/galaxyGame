RSpec.shared_examples "a gaseous planet" do
  let(:star) { create(:star, mass: 1.989e30, temperature: 5778, radius: 696_340_000) }
  let(:solar_system) { create(:solar_system, current_star: star) }
  
  let(:gaseous_planet) {
    FactoryBot.create(:gas_giant,
      name: "Shared Example Gas Planet",
      identifier: "GAS-TEST-1",
      mass: 1.898e27, # Jupiter mass (column supports large decimal)
      radius: 7.1492e7, # Jupiter radius (column supports up to 10^8)
      size: 1.0e7, # DB-safe value for size (max 10^8)
      density: 1.33,
      rotational_period: 35748, # ~10 hours in seconds, DB-safe
      orbital_period: 374371200, # Jupiter orbital period in seconds, DB-safe
      semi_major_axis: 5.2, # AU, DB-safe
      solar_system: solar_system
    )
  }
  
  # Validation tests
  it { is_expected.to validate_numericality_of(:density).is_less_than(2.0) }
  
  # Basic property tests
  it "has a low density" do
    expect(gaseous_planet.density).to be < 2.0
  end
  
  it "doesn't have a solid surface" do
    expect(gaseous_planet.has_solid_surface?).to eq(false)
  end
  
  # Advanced feature tests
  it "calculates cloud bands based on rotation" do
    expect(gaseous_planet.calculate_bands).to be_a(Integer)
  end
end