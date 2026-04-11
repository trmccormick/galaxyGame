**COMPLETED TASK: docs/agent/tasks/completed/2026-04-06-HIGH-DOCUMENTATION-MARKET-ISRU-PRICING.md**

**HIGH DOCUMENTATION: Dynamic World + ISRU Pricing Model**

**ECONOMY INTENT:**
NpcPriceCalculator.calculate_ask(settlement, material) =

IF LOCAL ISRU SOURCE:
production_cost (energy + facility depreciation)

ELSE:
import_cost = Luna_baseline + transport(settlement ↔ Luna)

EXAMPLES:

Luna N2: import_cost = $40k+/m² [lunar colony ref]

Titan N2: production_cost ≈ 0 (98.4% atmosphere harvest)

Mars H2O: ISRU electrolysis → low local cost

text

**ManufacturingService Flow:**
blueprint['required_materials'] (JSON BOM)

× NpcPriceCalculator.ask(settlement, material) → market_price

SUM = bom_cost

× settlement.construction_cost_percentage → final_charge

text

**TEST HARNESS:**
before do
create(:blueprint, name: 'Methane Engine', player: player, licensed_runs_remaining: 999)
settlement.inventory.items.create!(name: 'titanium_alloy', amount: 1000, ...) ×4
allow(NpcPriceCalculator).to receive(:calculate_ask).and_return(100.0)
player.credit(500_000)
end
→ Methane Engine: 1600kg BOM × 100 = 160k → 640 GCC (0.4%)