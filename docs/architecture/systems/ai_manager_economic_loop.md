# AI Manager Economic Loop — Unified Economic Loop Design Intent

## 1. AI Manager as Sovereign NPC Government
- **Role:** The AI Manager acts as a sovereign NPC government, not just a planetary governor.
- **Mega-Projects:** Manages projects too large/slow for individual players (e.g., worldhouses, terraforming, wormhole stations, AWS).
- **NPC Corporations & Factions:** Runs NPC corporations and factions, maintaining baseline market stability as buyer/seller of last resort.
- **Market Orders:** Generates buy orders and special missions that players can fulfill.
- **Player Autonomy:** Player corporations operate alongside the AI, not under it. Players can build their own settlements, stations, and corporations. The AI fills gaps players do not address.
- **Inspirations:** Think Eve Online NPC empires + Civ4 city-state AI.

## 2. World Strategy Options per Body Type
- **Terraformable Worlds:** Atmospheric modification contracts (e.g., Mars, Venus).
- **Non-Terraformable Worlds:** Worldhouse/dome/extraction station contracts.
- **Luna Pattern:** Lava tube seal → dome → network node.

## 3. Buy Orders & Special Missions Generation
- **Planetary State Driven:** Buy orders and missions are generated based on planetary deficits, surpluses, and strategic needs (e.g., oxygen shortage, infrastructure gap).
- **Mission Planner:** Uses a three-tier sourcing hierarchy (ISRU, system trade, network import) to determine how needs are met. If all tiers fail, project is blocked.
- **Special Missions:** Triggered by critical events (e.g., orphaned system, life support crisis) or strategic expansion (e.g., wormhole stabilization, asteroid conversion).

## 4. Player/Corp Role as Contractors
- **Contractor Model:** Players and player corporations act as contractors, filling AI-generated orders via the market.
- **Autonomy:** Players are not subordinate to the AI; they compete and cooperate as independent actors.
- **Order Fulfillment:** Resource delivery and mission completion by players update planetary state and can unlock further contracts.

## 5. Resource Delivery & Planetary State
- **Slow Background Update:** Resource deliveries update planetary state over time, not instantly. This simulates logistics, processing, and construction delays.
- **Feedback Loop:** Successful deliveries reduce deficits, trigger new missions, or close fulfilled orders. Persistent shortages escalate to higher-priority missions.

## 6. FinancialTransaction as Economic Backbone
- **GCC Routing:** All economic activity (AI, player, NPC) is routed through the FinancialTransaction system, using GCC (Galactic Crypto Currency) as the universal medium.
- **Market Integration:** Buy/sell orders, mission rewards, and contract payments are all processed via FinancialTransaction, ensuring traceability and economic balance.

## 7. Market Price & Planetary Deficit/Surplus
- **Dynamic Pricing:** Market prices are directly influenced by planetary deficits (higher prices) and surpluses (lower prices).
- **AI as Stabilizer:** The AI acts as buyer/seller of last resort, smoothing out extreme price swings and ensuring minimum market liquidity.

## 8. Four-Game Inspiration Model
- **SimEarth:** Background planetary simulation and biosphere evolution.
- **Civ4:** Expansion, city-state AI, and strategic contracts.
- **SimCity:** Settlement growth, infrastructure, and resource management.
- **Eve Online:** Player-driven economy, NPC empires, and market contracts.

---

## Implementation Gaps (as of 2026)
- **AI Manager Scope:** Current implementation may not fully support mega-projects or NPC corporations at the described scale.
- **Market Integration:** Buy order and mission generation may not yet be fully responsive to planetary state.
- **FinancialTransaction:** Ensure all economic flows (including NPC/AI) are routed through the unified system.
- **Dynamic Pricing:** Market price linkage to deficit/surplus may be incomplete or indirect.
- **Player Autonomy:** Confirm that player corporations are not subordinate to AI and can operate independently.

---

*This document is a design reference. For implementation details, see:*
- `docs/architecture/services/ai_manager/planner.md`
- `docs/architecture/services/ai_manager/priority_mapping.md`
- `docs/architecture/systems/asteroid_conversion_physics.md`
- `docs/wormhole_expansion/00_executive_summary.md`
- `galaxy_game/config/initializers/game_constants.rb`
