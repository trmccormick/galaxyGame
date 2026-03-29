# MARKET OPERATIONS

## Earth Anchor Price (EAP)
- **Definition:** The maximum price for any resource at any destination. If a resource costs more than EAP, NPCs import from Earth instead.
- **Formula:**

  EAP = (Earth spot price × refining factor) + transport cost to destination

- **Implementation:**
  - Earth spot prices from economic parameters
  - Transport rates by category (bulk, manufactured, high_tech)
  - Route modifiers via Logistics::TransportCostService

## Market vs. Build Decision Logic
- **AI Manager Resource Acquisition:**
  - If local production cost < EAP: source locally (ISRU or local market)
  - Else if NPC market price < EAP: buy from NPC market (Virtual Ledger if GCC scarce)
  - Else: import from Earth (requires USD)
- **Price Ceiling Enforcement:**
  - NPC buy orders posted at EAP ceiling
  - NPC sell orders posted slightly below EAP
  - Player sell orders above EAP are rejected; imports are scheduled instead

## Virtual Ledger Protocols (NPC-to-NPC)
- **Purpose:** Enables NPC-to-NPC economic interactions without depleting player-accessible GCC pools.
- **Mechanics:**
  - Virtual Ledger accounts track obligations between NPCs when GCC is scarce
  - Obligations are settled with real GCC when available
  - Used for supply chain, construction contracts, and crisis procurement
- **Example Flows:**
  - NPC supply chain deliveries
  - Construction contracts with milestone payments
  - Emergency resource procurement

---
