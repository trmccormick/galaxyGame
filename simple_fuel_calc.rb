#!/usr/bin/env ruby

puts "=== Lunar Base Fuel Production Analysis ==="
puts

# Gas Separator Unit: 5kg/hr input, produces:
# - LOX: 1.0 kg/hr (20%)
# - Methane: 0.5 kg/hr (10%)
# - CO2: 0.625 kg/hr (12.5%)
# - H2: 0.25 kg/hr (5%)

# Gas Conversion Unit: Sabatier reaction CO2 + 4H2 → CH4 + 2H2O
# Rate: 2kg/hr CO2 input → 1kg/hr CH4 output

# Heavy Lift Transport:
# - Fuel consumption: 205 kg/hr LOX, 105 kg/hr Methane
# - Fuel capacity: 10,000 kg LOX, 350,000 kg Methane

def analyze_production(days)
  hours = days * 24.0
  
  # Gas Separator production
  lox_produced = 1.0 * hours
  methane_direct = 0.5 * hours
  co2_produced = 0.625 * hours
  h2_produced = 0.25 * hours
  
  # Gas Conversion (limited by H2 availability since CO2:H2 ratio is 1:4)
  # Available H2 limits conversion: 0.25 kg/hr H2 available
  # Sabatier needs 4:1 H2:CO2 ratio, so H2 limits at 0.25/4 = 0.0625 CO2 consumption rate
  # But max rate is 2kg/hr CO2, so H2 limits to 0.0625 * 2 = 0.125 kg/hr effective rate
  conversion_rate = [co2_produced / hours, h2_produced / hours / 4.0, 2.0].min
  methane_from_conversion = conversion_rate * hours
  
  total_methane = methane_direct + methane_from_conversion
  total_lox = lox_produced
  
  puts "#{days} Days (#{hours.to_i} hours) Production:"
  puts "  LOX: #{total_lox.round(1)} kg (#{ (total_lox/hours).round(2) } kg/hr)"
  puts "  Methane: #{total_methane.round(1)} kg (#{ (total_methane/hours).round(2) } kg/hr)"
  puts "    - Direct from separator: #{methane_direct.round(1)} kg"
  puts "    - From Sabatier conversion: #{methane_from_conversion.round(1)} kg"
  puts
  
  # Return trip analysis (4-day round trip)
  trip_hours = 4 * 24
  lox_needed = 205 * trip_hours      # 19,680 kg
  methane_needed = 105 * trip_hours  # 10,080 kg
  
  puts "Return Trip Fuel Requirements (4 days):"
  puts "  LOX needed: #{lox_needed} kg"
  puts "  Methane needed: #{methane_needed} kg"
  puts
  
  lox_percent = (total_lox / lox_needed * 100).round(1)
  methane_percent = (total_methane / methane_needed * 100).round(1)
  
  puts "Production vs Return Needs:"
  puts "  LOX: #{lox_percent}% of return requirement (#{total_lox.round(0)} / #{lox_needed})"
  puts "  Methane: #{methane_percent}% of return requirement (#{total_methane.round(0)} / #{methane_needed})"
  puts
  
  # Time to produce full return load
  lox_days_to_full = (10000 / (total_lox / days)).round(1)
  methane_days_to_full = (350000 / (total_methane / days)).round(1)
  
  puts "Time to fill Heavy Lift Transport tanks:"
  puts "  LOX (10,000 kg): #{lox_days_to_full} days"
  puts "  Methane (350,000 kg): #{methane_days_to_full} days"
  puts "-" * 60
end

[7, 30, 90, 180, 365].each { |days| analyze_production(days) }
