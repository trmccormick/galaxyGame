# ECONOMIC_ENGINE_SURFACE_VS_ORBITAL.md

## Overview
This document outlines the core economic hierarchy and industrial trade engine of Galaxy Game. It details the asymmetric relationship between planetary surface bases (infinite resource generators) and orbiting nodes/cyclers (vacuum-suspended resource consumers). Reference this document when designing resource supply chains, balancing Mass Driver launch costs, structuring GCC market buy orders, and configuring automated trade AI.

## Source Basis
This architecture is derived from orbital mechanics constraints, space logistics studies, and in-game economic balancing decisions. The model relies on gravity well delta-v asymmetry and life support maintenance sinks to maintain open-ended market velocity.

## Structural Hierarchy & Asymmetric Architecture

```
                  SURFACE SETTLEMENT (Luna / Mars / Ceres)
                [Extractable Resources: Regolith, O2, Ice, Ore]
                                      │
                                      │ Bulk Extraction
                                      ▼
                           SURFACE MASS DRIVERS / LAUNCHERS
                                      │
                                      │ (Cheap Raw Mass Export)
                                      ▼
                        ORBITAL DEPOTS / STATIONS (EML-1)
                     [Refining, Assembly, Market Hubs]
                                      │
                                      │ Refueling & Resupply
                                      ▼
                             CYCLER CRAFT / SHIPS
                      [Transit Habitats & Gas Haulers]
```

### 1. Surface Settlements: The Extraction Engine
- **Economic Role:** Primary resource producer.
- **Physical Advantage:** Taps into planetary crusts and polar traps for raw materials (Regolith, Water Ice, Metal Ores, Volatiles).
- **Operational Edge:** Uses local planetary mass for free radiation shielding (burial under regolith) and deep crust thermal sinking.

### 2. Orbital Stations & Cyclers: The Consumption Engine
- **Economic Role:** Transit hubs, refining complexes, and market liquidity centers.
- **Physical Vulnerability:** Zero native raw matter generation. Every gram of structural mass or volatile liquid must be imported from surface mass drivers or atmospheric skimmers.
- **Operational Edge:** Minimal gravity wells allow friction-free ship arrivals, zero-g construction, and low-energy orbital transfers.

## Resource Logistics Matrix

To ensure realistic dynamic flows across nodes, commodities are categorized by their extraction points, transit methods, and primary economic sinks:

| Resource / Commodity | Surface Source | Orbital / Space Source | Primary Consumption / Sink |
|---|---|---|---|
| Oxygen (O2) | Regolith reduction, Polar ice | Sabatier/Plant loop recovery | ECLSS breathing, Rocket Propellant |
| Water (H2O) | Polar crater/glacier mining | Atmospheric Skimmer imports | ECLSS intake, Agriculture, Radiation Shielding |
| Nitrogen (N2) | Rare on Luna/Mars | Venus/Titan Atmospheric Skimmers | Habitat pressure buffers, Leak replenishment |
| Structural Mass | Local Foundries (Fe/Al/Anorthite) | Orbital 3D Printing Yards | Station frame expansion, Panel maintenance |
| Methane (CH4) | Sabatier synthesis from surface ice | Gas Giant Skimmers | Ship propellant, Station RCS thrusters |

## Market Dynamics & The "Build vs. Buy" Loop

### 1. Inelastic Life Support Demand
Orbital depots and cyclers suffer continuous, non-negotiable material losses due to 2% water recycling inefficiencies and passive atmospheric micro-leaks. When internal reserves breach safety limits, nodes issue automated high-priority buy orders on the Galactic Credit Exchange (GCC) regardless of current pricing.

### 2. Mass Driver Economics
Surface settlements on low-gravity bodies (Luna, Ceres) utilize electromagnetic Mass Drivers to launch bulk payloads (O2, Ice, Refined Metals) directly to Lagrange Depots (e.g., EML-1) at near-zero fuel cost. This creates a severe cost advantage over Earth-surface imports, establishing localized regional monopolies.

### 3. Trader Arbitrage Mechanics
Because atmospheric gases (especially Nitrogen) are unevenly distributed across the solar system, traders profit from inter-planetary supply imbalances. For instance, Venusian nitrogen harvested by skimmers can be transported to Mars cyclers to undercut local scarcity prices.

## Rails Implementation Notes

System nodes share a common base representation, using type discriminators to control local resource generation capabilities.

- **Affected Models:** `HabitationNode`, `ResourceBuffer`, `MarketOrder`, `TradeRoute`.

```ruby
class HabitationNode < ApplicationRecord
  has_many :installed_modules
  has_one  :resource_buffer
  has_many :market_orders

  def surface_node?
    node_type == 'surface_settlement'
  end

  def process_eclss_tick!
    resource_buffer.consume_metabolic_supplies!
    resource_buffer.apply_micro_leaks!(hull_wear)

    if surface_node?
      # Extract raw surface deposits (Regolith, Polar Ice)
      extract_local_deposits!
    else
      # Process inbound freight and evaluate automated buy triggers
      process_docked_transfers!
      check_critical_eclss_deficits!
    end
  end

  private

  def check_critical_eclss_deficits!
    [:purified_water, :nitrogen, :oxygen].each do |commodity|
      days_left = resource_buffer.days_of_supply_remaining(commodity)
      next unless days_left < GameConstants::CRITICAL_BUFFER_THRESHOLD_DAYS

      MarketOrder.create_automated_buy_order!(
        node: self,
        commodity: commodity,
        quantity: resource_buffer.target_resupply_quantity(commodity),
        max_price: market_price_scaler(days_left)
      )
    end
  end
end
```

## JSON Data Schema Example (Orbital Depot Buffer State)

```json
{
  "node_id": "eml1_depot_alpha",
  "node_type": "orbital_depot",
  "local_extraction_capable": false,
  "eclss_status": {
    "water_reserve_days": 14,
    "nitrogen_reserve_days": 8,
    "structural_panels_in_stock": 12
  },
  "market_dependencies": [
    {
      "commodity": "nitrogen",
      "status": "critical_buy_order_active",
      "target_source": "venus_skimmer_imports"
    },
    {
      "commodity": "purified_water",
      "status": "stable",
      "target_source": "luna_mass_driver_exports"
    }
  ]
}
```

## Open Design Questions

- **Mass Driver Trajectory Interception:** Should players be able to intercept or alter the destination of unguided mass driver payloads in transit?
- **GCC Market Currency Uncoupling:** At what threshold of orbital trade volume should the GCC (Galactic Credit Coupon) permanently uncouple its 1:1 conversion peg from the USD base?

## Related Files

- `ECLSS_PARAMETERS.md` — Defines loss rate formulas driving market demand.
- `LUNA_SETTLEMENT_LIFECYCLE.md` — Details the Luna-to-L1 export lifecycle.
- `HABITATION_NODE_ARCHITECTURE.md` — Object model for surface and orbital nodes.
