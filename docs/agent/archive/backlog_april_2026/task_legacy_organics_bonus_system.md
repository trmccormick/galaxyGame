# Legacy Organics Bonus System Implementation

## 🎯 **Task Overview**
Implement the +20% biomass production bonus for Worldhouses constructed in organic-rich regions, leveraging existing biosphere `soil_organic_content` fields and bonus multiplier systems.

## 📋 **Requirements**

### **Bonus Calculation Logic**
```ruby
def calculate_organic_biomass_bonus(soil_organic_content, site_characteristics)
  base_bonus = 0.0

  # +20% for high organic content sites
  if soil_organic_content > 0.8
    base_bonus += 0.20
  elsif soil_organic_content > 0.5
    base_bonus += 0.15
  elsif soil_organic_content > 0.2
    base_bonus += 0.10
  end

  # Additional bonuses for sedimentary basin sites
  if site_characteristics[:sedimentary_basin]
    base_bonus += 0.05
  end

  # Radiation shielding bonus
  if site_characteristics[:radiation_shielded]
    base_bonus += 0.03
  end

  [base_bonus, 0.25].min # Cap at 25%
end
```

### **Integration Points**
- **Biosphere Model**: Use existing `soil_organic_content` field
- **Worldhouse Construction**: Apply bonus during initial setup
- **Biomass Production**: Modify production calculations
- **Mission Rewards**: Include organic bonuses in mission objectives

### **Data Flow**
1. Organic assessment phase collects data
2. Data stored in biosphere `soil_organic_content`
3. Worldhouse construction queries organic levels
4. Bonus applied to biomass production rates
5. AI prioritizes high-organic sites

## ✅ **Success Criteria**
- +20% biomass bonus applied correctly in organic-rich sites
- Bonus calculation is consistent and predictable
- Integration with existing biosphere simulation
- AI correctly prioritizes organic-rich construction sites

## 📅 **Timeline**: 2-3 weeks
## 🎯 **Priority**: High
## 👥 **Owner**: Biosphere Simulation Team