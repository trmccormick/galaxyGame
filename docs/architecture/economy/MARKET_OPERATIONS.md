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

## Contract Ceiling Limits (from GUARDRAILS.md §8)
- **Maximum Contract Value**: No single player contract may exceed 10% of current GCC money supply to prevent economic distortion
- **Daily Contract Limits**: Players limited to 5 active contracts per day to ensure market distribution
- **Contract Duration Caps**: Maximum 90 Earth days for any contract to prevent long-term economic commitments

## Market Dynamics and Resource Flow
- **Buy/Sell Order System:** All bases and stations maintain active buy and sell orders for essential materials, creating natural resource flow incentives
- **Player Logistics Role:** Players and logistics NPCs bridge resource gaps by transporting materials from production sites to consumption sites as the game expands
- **Multi-Modal Transport:** Cycler routes provide slow but reliable bulk transport, while players enable faster, more flexible logistics
- **Construction Buy Orders:** Orbital stations and depots create buy orders for construction materials (e.g., L1 station buying 1000 3D printed ibeams), allowing players to participate in infrastructure development
- **Player Supply Chain:** Players can build or purchase materials from locations like Luna and sell them at demand centers like L1 Station for profit
- **NPC Fallback System:** If players don't fill orders within timeout windows, NPCs like AstroLift automatically fill them to maintain game progression
- **Baseline Price Setting:** NPC order fulfillment establishes market prices and ensures economic activity continues even without player participation
- **Early Game Critical:** NPC fallbacks are especially important early in the game when player logistics infrastructure is limited
- **Economic Continuity:** System ensures construction and expansion never stall due to lack of material supply, whether through player participation or NPC automation
- **Adaptive Cycler Logistics:** AI Manager loads cyclers with materials for specific destinations, but if no buy orders exist at arrival, cyclers can unload and place sell orders locally, then continue to next destination to prevent wasted trips and create market opportunities
- **Pre-Destination Market Analysis:** AI Manager evaluates demand at upcoming cycler stops before arrival, deciding whether to deliver cargo, sell locally, or continue with current load
- **Ownership-Based Decision Making:** Cargo handling depends on ownership - AstroLift-owned materials can be sold opportunistically, while TDC cargo is delivered as contracted regardless of local market conditions
- **Mobile Production Platforms:** Cyclers function as moving space stations that can be configured for onboard production during transit, turning raw materials into processed goods to maximize value from long transit times
- **Docked Craft Processing:** Craft docked with cyclers can continue onboard processing if they have sufficient power, raw materials, and storage capacity, allowing Venus skimmers to crack CO2 into O2 and CO during transit
- **Cycler Gas Storage & Utilization:** Cyclers maintain their own gas storage capacity and have operational uses for various gases (propulsion, life support), enabling them to store and utilize processed gases from docked craft production
- **Ownership-Based Value Capture:** Processing value during transit belongs to the owning company - if AstroLift owns both cycler and docked craft, they capture all processing value; mixed ownership requires inter-company agreements for revenue sharing and material ownership
- **Station-Style Processing Services:** Docked craft extend cycler/base infrastructure with their processing systems, following station economics - owners can charge fees for others to use processing capabilities, allowing monetization of idle craft systems for GCC earnings
- **Player Infrastructure Contributions:** Players can add structures/units to NPC bases (if connections available) to expand storage or processing capabilities, earning GCC usage fees while paying rent to base owners for space utilization
- **DC Infrastructure Foundation:** Development Corporations provide basic infrastructure and expand as needed if players do not contribute, following the player-first model with NPCs as backup to ensure continuous expansion

## Earth-Luna Anchor & Import Parity
- **Earth-Luna Anchor**: All GCC pricing references the Earth-Luna Anchor as the absolute floor. No material can be sold below the cost of importing from Luna (including fuel, taxes, and 3.37% Sales Tax).
- **Import Parity Ceiling**: AI Manager sets Buy Orders at Earth Anchor + shipping costs + taxes. Players must beat this to compete with NPC imports.
