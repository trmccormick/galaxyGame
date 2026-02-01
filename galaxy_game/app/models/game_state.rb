class GameState < ApplicationRecord
  # Fields: year:integer day:float running:boolean last_updated_at:datetime speed:integer

  # Validations
  validates :year, numericality: { greater_than_or_equal_to: 0 }
  validates :day, numericality: { greater_than_or_equal_to: 0 }
  validates :speed, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
  
  # Set defaults before validation
  before_validation :set_defaults
  
  def set_defaults
    today = Date.today
    self.year ||= today.year
    self.day ||= today.yday
    self.speed ||= 3
    self.running = false if running.nil?
    self.last_updated_at ||= Time.current
  end

  # Toggle running status
  def toggle_running!
    self.running = !self.running
    self.last_updated_at = Time.current if self.running
    save!
  end

  # Update game time based on elapsed real time
  def update_time!
    return unless running
    
    return if last_updated_at.nil?
    
    time_elapsed_seconds = Time.current - last_updated_at
    days_elapsed = time_elapsed_seconds / seconds_per_game_day
    
    self.day += days_elapsed
    
    while self.day >= 365
      self.year += 1
      self.day -= 365
    end
    
    self.last_updated_at = Time.current
    save!
  end

  # How many real seconds per game day, based on speed
  def seconds_per_game_day
    case speed
    when 1 then 300  # 5 min = 1 day
    when 2 then 120  # 2 min = 1 day
    when 3 then 60   # 1 min = 1 day
    when 4 then 30   # 30 sec = 1 day
    when 5 then 10   # 10 sec = 1 day
    else 60
    end
  end

  # Get current game time as a Time object
  def current_time
    # Create a time object for the current game year and day
    Time.new(year, 1, 1) + (day - 1).days
  end
end