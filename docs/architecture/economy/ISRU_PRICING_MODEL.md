# ISRU Pricing Model

## Overview
This document describes the pricing logic for materials in the Galaxy Game economy, focusing on the distinction between local ISRU (In-Situ Resource Utilization) production and interplanetary import costs. It is intended to clarify how NpcPriceCalculator and related services determine market prices for settlements and manufacturing.

## Pricing Logic

### NpcPriceCalculator.calculate_ask(settlement, material)
- **If the settlement has a local ISRU source:**
  - The market price is set to **95% of the current import cost (EAP)**, regardless of actual production cost. This ensures local production is always competitive, helps offset high import costs, and allows the settlement to balance its books over time—not to maximize profit or gouge buyers.
- **Otherwise (no local ISRU):**
  - `import_cost = Luna_baseline + transport_cost(settlement ↔ Luna)`

### Example Scenarios
- **Luna N2:** import_cost = $40k+/m² (lunar colony reference)
- **Titan N2:** production_cost ≈ 0 (98.4% atmosphere harvest)
- **Mars H2O:** ISRU electrolysis enables low local cost

## ManufacturingService Flow
1. **Blueprint BOM:** Each blueprint defines `required_materials` (JSON Bill of Materials).
2. **Material Pricing:** For each material, call `NpcPriceCalculator.ask(settlement, material)` to get the market price.
3. **Total BOM Cost:** `bom_cost = sum(all material prices × required amounts)`
4. **Final Charge:** `final_charge = bom_cost × settlement.construction_cost_percentage`

### Example Calculation
If a Methane Engine requires 1600kg of materials, and each kg costs 100 GCC:

    1600 kg × 100 GCC = 160,000 GCC (BOM cost)
    160,000 × 0.004 (0.4%) = 640 GCC (final charge)

## Test Harness Example
```ruby
before do
  create(:blueprint, name: 'Methane Engine', player: player, licensed_runs_remaining: 999)
  settlement.inventory.items.create!(name: 'titanium_alloy', amount: 1000, ...) # ×4 for all required materials
  allow(NpcPriceCalculator).to receive(:calculate_ask).and_return(100.0)
  player.credit(500_000)
end
# Methane Engine: 1600kg BOM × 100 = 160k → 640 GCC (0.4%)
```

---
This document should be updated as the pricing model evolves and as new ISRU or import logic is introduced.