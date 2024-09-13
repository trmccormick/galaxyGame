require 'rails_helper'

RSpec.describe Star, type: :model do
  before do
    @star = Star.new(
      name: "Alpha Centauri",
      type_of_star: :red_dwarf,  # Use the symbol for the enum
      age: 5.0,
      mass: 1.0e30,
      radius: 1.0e8,
      temperature: 3000
    )
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
    expect(@star).to respond_to(:name, :type_of_star, :age, :mass, :radius, :temperature)
  end

  it "is not valid with a negative mass" do
    @star.mass = -1.0e30
    expect(@star).not_to be_valid
  end

  it "sets default luminosity based on type_of_star" do
    @star.type_of_star = :red_dwarf
    @star.save
    expect(@star.luminosity).to eq(0.01 * 3.828e26)
  end
end