# Create a settings model (Marketplace::Settings)
module Market
    class Settings < ApplicationRecord
      # Add attributes for the settings you want to be adjustable
      # For example:
      attribute :transportation_cost_per_kg, :decimal # Use attribute for type casting
  
      # You can add other settings here as needed
      self.table_name = 'market_settings'
    end
end