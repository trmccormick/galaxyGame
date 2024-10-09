require 'rails_helper'

RSpec.describe Star, type: :model do
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
    @star.type_of_star = nil
    expect(@star).not_to be_valid
  end

  it "is not valid without an age" do
    @star.age = nil
    expect(@star).not_to be_valid
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
    @star.temperature = nil
    expect(@star).not_to be_valid
  end

  it "is not valid without life expectancy" do
    @star.life = nil
    expect(@star).not_to be_valid
  end

  it "is not valid without an r_ecosphere" do
    @star.r_ecosphere = nil
    expect(@star).not_to be_valid
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
    @star = Star.new(
      name: "Sol",
      type_of_star: 'red_dwarf',  # Example type_of_star
      age: 4.6e9,
      mass: 1.989e30,
      radius: 6.963e8,
      temperature: 5778,
      life: 10.0,
      r_ecosphere: 0.8
    )
    @star.save
    expected_luminosity = 0.01 * 3.828e26  # Correct luminosity for a red dwarf
    expect(@star.luminosity).to eq(expected_luminosity)
  end

  it "sets default luminosity for a sun-like star" do
    @star = Star.new(
      name: "Sol",
      type_of_star: 'sun',
      age: 4.6e9,
      mass: 1.989e30,
      radius: 6.963e8,
      temperature: 5778,
      life: 10.0,
      r_ecosphere: 0.8
    )
    @star.save
    expect(@star.luminosity).to eq(3.828e26)  # Luminosity for a sun-like star
  end
end