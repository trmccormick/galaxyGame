# spec/models/game_state_spec.rb
require 'rails_helper'

RSpec.describe GameState, type: :model do
  describe "attributes" do
    it "has accessible year, day, running, speed and last_updated_at attributes" do
      game_state = GameState.new(
        year: 5, 
        day: 125, 
        running: true, 
        speed: 4,
        last_updated_at: Time.current
      )
      
      expect(game_state.year).to eq(5)
      expect(game_state.day).to eq(125)
      expect(game_state.running).to eq(true)
      expect(game_state.speed).to eq(4)
      expect(game_state.last_updated_at).to be_within(1.second).of(Time.current)
    end
  end

  describe "#update_time!" do
    it "updates the game time based on elapsed time when running" do
      # Create a game state that's running
      game_state = GameState.create!(
        year: 0,
        day: 0,
        running: true,
        speed: 3,
        last_updated_at: 5.minutes.ago
      )
      
      # Call update_time!
      game_state.update_time!
      
      # Verify time was updated (approximately 5 days at normal speed)
      expect(game_state.day).to be > 0
    end
    
    it "doesn't update time when not running" do
      game_state = GameState.create!(
        year: 0,
        day: 0,
        running: false,
        speed: 3,
        last_updated_at: 5.minutes.ago
      )
      
      game_state.update_time!
      
      expect(game_state.day).to eq(0)
    end
  end
  
  describe "#toggle_running!" do
    it "toggles the running state" do
      # Added default values for year and day
      game_state = GameState.create!(
        running: false,
        year: 0,
        day: 0
      )
      
      game_state.toggle_running!
      expect(game_state.running).to eq(true)
      
      game_state.toggle_running!
      expect(game_state.running).to eq(false)
    end
    
    it "updates last_updated_at when turning on" do
      # Added default values for year and day
      game_state = GameState.create!(
        running: false, 
        last_updated_at: 1.day.ago,
        year: 0,
        day: 0
      )
      
      game_state.toggle_running!
      
      expect(game_state.last_updated_at).to be_within(1.second).of(Time.current)
    end
  end
end