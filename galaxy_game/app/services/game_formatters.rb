module GameFormatters
  module AtmosphericData
    def self.format_pressure(pressure_atm)
      if pressure_atm >= 0.1
        # Use atm for Earth and Venus
        "#{pressure_atm.round(3)} atm"
      elsif pressure_atm >= 0.0001
        # Use millibars for Mars and thin atmospheres
        mbar = pressure_atm * 1013.25
        "#{mbar.round(2)} mbar"
      elsif pressure_atm >= 0.00000001
        # Use microbars for very thin atmospheres (1 µbar = 0.001 mbar)
        ubar = pressure_atm * 1013250
        "#{ubar.round(2)} µbar"
      else
        # Use pascals for extremely thin atmospheres
        pascals = pressure_atm * 101325
        "#{pascals.round(2)} Pa"
      end
    end
    
    def self.format_mass(mass)
      if mass >= 1.0e18
        "#{(mass / 1.0e18).round(2)} Exatons"
      elsif mass >= 1.0e15
        "#{(mass / 1.0e15).round(2)} Pt"
      elsif mass >= 1.0e12
        "#{(mass / 1.0e12).round(2)} Tt"
      elsif mass >= 1.0e9
        "#{(mass / 1.0e9).round(2)} Gt"
      elsif mass >= 1.0e6
        "#{(mass / 1.0e6).round(2)} Mt"
      elsif mass >= 1.0e3
        "#{(mass / 1.0e3).round(2)} kt"
      else
        "#{mass.round(2)} kg"
      end
    end
    
    def self.format_ratio(ratio)
      # For ratios close to 1, show percentage change
      if (ratio > 0.9 && ratio < 1.1)
        change = ((ratio - 1) * 100).round(2)
        sign = change >= 0 ? "+" : ""
        "#{sign}#{change}%"
      else
        # For bigger changes, show a simple multiplier
        "×#{ratio.round(2)}"
      end
    end
  end
end