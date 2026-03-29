# Asteroid Conversion Physics & Logistics Spec

## 1. Overview
This document defines the physical constraints for converting celestial bodies into stations (specifically the Eden AWS Anchor). It replaces static timelines with dynamic, property-based calculations.

## 2. Asteroid Qualification (The Disqualifiers)
The AI Manager must perform a "Discovery & Qualification" phase. An asteroid is disqualified for conversion if it meets any of the following criteria:

### 2.1 Cohesion Check (The "Rubble Pile")
* **Criteria:** Density < 1.5 g/cm³.
* **Physics:** These are loosely bound aggregates. Applying Tug thrust causes structural dissipation rather than movement.
* **Result:** Disqualified. Cannot mount I-Beam frames.

### 2.2 Thermal Check (The "Ice" Rule)
* **Criteria:** Volatile/Ice composition > 20%.
* **Physics:** High-output station equipment (Quantum Arrays, Power Cores) generates heat that sublimates the ice core.
* **Result:** Requires "Thermal Shielding" sub-phase (consuming extra Panels) or disqualification if heat output is :EXTREME.

### 2.3 Mass-to-Void Ratio (The "Hollow" Rule)
* **Criteria:** `is_hollow: true` (Internal Void > 40%).
* **Physics:** Risk of structural buckling/collapse under Tug thrust.
* **Requirement:** Mandatory "Internal Bracing" phase (consuming I-Beams) must be completed before the Towing Phase begins.

## 3. Dynamic Towing Logistics
The 9-month placeholder is replaced by a variable timeline:
* **Stress Tolerance:** * Metallic (M-Type): 1.0 (High Thrust allowed)
    * Stony (S-Type): 0.7 (Moderate Thrust)
    * Carbonaceous (C-Type): 0.4 (Low Thrust/Slow Transit)
* **Tug Multiplier:** Additional Tug units allow for better force distribution, increasing the safe acceleration cap ($a = Thrust / Mass$).