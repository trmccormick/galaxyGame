# filepath: /Users/tam0013/Documents/git/galaxyGame/galaxy_game/spec/services/pressurization/habitat_pressurization_service_spec.rb
require 'rails_helper'

RSpec.describe Pressurization::HabitatPressurizationService do
  let(:crater_dome) do
    dome = build(:crater_dome)
    dome.operational_data['dimensions'] = { 'diameter' => 50.0, 'depth' => 20.0 }
    dome
  end
  let(:available_gases) do
    {
      oxygen: 100.0,
      nitrogen: 300.0,
      argon: 10.0
    }
  end
  
  describe "#calculate_habitat_volume" do
    it "calculates correct volume for crater dome" do
      service = described_class.new(crater_dome, available_gases)
      expected_volume = Math::PI * ((50 / 2.0) ** 2) * 20 / 2.0
      
      expect(service.calculate_habitat_volume).to be_within(0.1).of(expected_volume)
    end
  end
  
  # Add more specs for other methods
end