# Hycean Planet System

## Overview
Hycean planets are a specialized type of ocean planet characterized by hydrogen-rich atmospheres and extreme pressure conditions. These planets represent potential habitable worlds with unique environmental challenges and opportunities.

## Characteristics

### Atmospheric Composition
- **Primary Gas**: Hydrogen (H2) ≥ 10% of atmosphere
- **Supporting Gases**: Helium (He), Methane (CH4), Ammonia (NH3)
- **Pressure Range**: > 1 atm, often 10-100 atm optimal
- **Temperature**: Wide habitable range due to hydrogen greenhouse effect

### Ocean Chemistry
- Hydrogen-saturated oceans under extreme pressure
- Potential for methane-rich or ammonia-based liquids
- Unique biochemistry adapted to high-pressure environments

### Habitability Factors
- **Pressure Zones**: 
  - Optimal: 10-100 atm (Level 3)
  - Moderate: 1-10 atm or 100-1000 atm (Level 2)
  - Extreme: <1 atm or >1000 atm (Level 1)
- **Temperature Range**: Expanded due to greenhouse effects
- **Surface Features**: Storm systems at high pressures, hydrogen-specific atmospheric phenomena

## Model Implementation

### Validations
- Requires atmosphere presence
- Minimum 10% hydrogen content
- Atmospheric pressure > 1 atm
- Inherits ocean planet water coverage requirements

### Key Methods
- `#habitability_factors`: Calculates environmental suitability
- `#surface_features`: Determines visible planetary characteristics
- `#ocean_chemistry`: Analyzes liquid composition
- `#habitable_layer_depth`: Pressure-based depth calculations
- `#hydrogen_percentage`: Atmospheric hydrogen quantification

## Factory Configuration
The test factory creates planets with:
- 60% H2, 30% He, 7% CH4, 3% NH3 atmospheric composition
- 15 atm pressure baseline
- Associated molar masses for gas validation

## Scientific Basis
Hycean planets are theoretical worlds where liquid water oceans exist beneath hydrogen-rich atmospheres. The high pressure prevents the hydrogen from escaping, creating a greenhouse effect that maintains habitable temperatures despite distance from the star.

## Recent Fixes
**Issue**: Gas molar mass validation failures in test environment
**Root Cause**: Material lookup service failing in test context, preventing automatic molar_mass assignment
**Solution**: Direct molar_mass specification in factory for required gases (H2: 2.016, He: 4.0026, CH4: 16.04, NH3: 17.03)