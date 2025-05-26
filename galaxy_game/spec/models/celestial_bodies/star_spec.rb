require 'rails_helper'

RSpec.describe CelestialBodies::Star, type: :model do
  before do
    @star = create(:star)
  end

  it "is valid with all attributes" do
    expect(@star).to be_valid
  end

  it "is not valid without a name" do
    @star.name = nil
    expect(@star).not_to be_valid
  end

  it "is not valid without a type_of_star" do
    # Create a new instance without using factory to avoid callbacks
    star = CelestialBodies::Star.new(
      name: "Test Star",
      identifier: "TEST-1",
      age: 4.6e9,
      mass: 1.989e30,
      radius: 6.963e8,
      properties: {}
    )
    # Skip callbacks and validation
    star.type_of_star = nil
    # Force validation manually
    expect(star.valid?).to be false
    expect(star.errors[:type_of_star]).to include("can't be blank")
  end

  it "is not valid without an age" do
    star = CelestialBodies::Star.new(
      name: "Test Star",
      identifier: "TEST-2",
      type_of_star: "G",
      mass: 1.989e30,
      radius: 6.963e8,
      properties: {}
    )
    star.age = nil
    expect(star.valid?).to be false
    expect(star.errors[:age]).to include("can't be blank")
  end

  it "is not valid without a mass" do
    @star.mass = nil
    expect(@star).not_to be_valid
  end

  it "is not valid without a radius" do
    @star.radius = nil
    expect(@star).not_to be_valid
  end

  it "is not valid without a temperature" do
    star = CelestialBodies::Star.new(
      name: "Test Star",
      identifier: "TEST-3",
      type_of_star: "G",
      age: 4.6e9,
      mass: 1.989e30,
      radius: 6.963e8,
      life: 10.0,
      r_ecosphere: 0.8,
      properties: {}
    )
    star.temperature = nil
    expect(star.valid?).to be false
    expect(star.errors[:temperature]).to include("can't be blank")
  end

  it "is not valid without life expectancy" do
    star = CelestialBodies::Star.new(
      name: "Test Star",
      identifier: "TEST-4",
      type_of_star: "G",
      age: 4.6e9,
      mass: 1.989e30,
      radius: 6.963e8,
      temperature: 5778,
      r_ecosphere: 0.8,
      properties: {}
    )
    star.life = nil
    expect(star.valid?).to be false
    expect(star.errors[:life]).to include("can't be blank")
  end

  it "is not valid without an r_ecosphere" do
    star = CelestialBodies::Star.new(
      name: "Test Star",
      identifier: "TEST-5",
      type_of_star: "G",
      age: 4.6e9,
      mass: 1.989e30,
      radius: 6.963e8,
      temperature: 5778,
      life: 10.0,
      properties: {}
    )
    star.r_ecosphere = nil
    expect(star.valid?).to be false
    expect(star.errors[:r_ecosphere]).to include("can't be blank")
  end

  it "should have a positive mass" do
    expect(@star.mass).to be > 0
  end

  it "should have a positive radius" do
    expect(@star.radius).to be > 0
  end

  it "should have a positive temperature" do
    expect(@star.temperature).to be > 0
  end

  it "responds to attributes" do
    expect(@star).to respond_to(:name, :type_of_star, :age, :mass, :radius, :temperature, :life, :r_ecosphere)
  end

  it "sets default luminosity based on type_of_star" do
    @star = CelestialBodies::Star.new(
      name: "Sol",
      identifier: "SOL-RD-1", 
      type_of_star: 'M',  # Red dwarf type
      age: 4.6e9,
      mass: 1.989e30,
      radius: 6.963e8,
      temperature: 5778,
      life: 10.0,
      r_ecosphere: 0.8,
      properties: { 'spectral_class' => 'M5V', 'stellar_class' => 'Main Sequence' }
    )
    @star.luminosity = nil  # Force default calculation
    @star.save
    expect(@star.luminosity).to be_present
    expect(@star.luminosity).to be < 1.0  # M stars have lower luminosity
  end

  it "sets default luminosity for a sun-like star" do
    @star = CelestialBodies::Star.new(
      name: "Sol",
      identifier: "SOL-G-1", 
      type_of_star: 'G',
      age: 4.6e9,
      mass: 1.989e30,
      radius: 6.963e8,
      temperature: 5778,
      life: 10.0,
      r_ecosphere: 0.8,
      properties: { 'spectral_class' => 'G2V', 'stellar_class' => 'Main Sequence' }
    )
    @star.luminosity = nil  # Force default calculation
    @star.save
    expect(@star.luminosity).to be_present
    expect(@star.luminosity).to be_within(0.1).of(1.0)  # G stars have ~1.0 luminosity
  end

  it "correctly calculates habitable zone" do
    @star = CelestialBodies::Star.new(
      name: "Sol",
      identifier: "SOL-G-1", 
      type_of_star: "G",
      age: 4.6e9,
      mass: 1.989e30,
      radius: 6.963e8,
      luminosity: 1.0,  # Explicitly set this
      temperature: 5778,
      life: 10.0e9,
      r_ecosphere: 1.0,
      properties: { 'spectral_class' => 'G2V', 'stellar_class' => 'Main Sequence' }
    )
    @star.save
    
    expect(@star.habitable_zone_range.begin).to be_within(0.01).of(0.95)
    expect(@star.habitable_zone_range.end).to be_within(0.01).of(1.37)
  end
end