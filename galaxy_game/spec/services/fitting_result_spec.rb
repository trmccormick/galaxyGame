require 'rails_helper'

RSpec.describe FittingResult do
  subject(:result) { described_class.new }

  it "initializes with success true and empty arrays" do
    expect(result.success?).to be true
    expect(result.errors).to eq([])
    expect(result.installed_items).to eq([])
    expect(result.fitted).to eq([])
    expect(result.missing).to eq([])
  end

  it "marks success false and adds error when add_error is called" do
    result.add_error("Test error")
    expect(result.success?).to be false
    expect(result.errors).to include("Test error")
  end
end