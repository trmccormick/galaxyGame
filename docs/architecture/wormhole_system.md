# Wormhole Contract v1.2: Intergalactic Aperture & Stability Protocols

This document establishes the official operational standards for the Galaxy Game's expansion logic, governing the physical and economic requirements for maintaining stable links between Sol and external systems.

## 1. Natural Wormhole (NWH) Mechanics

- **Fixed Sol Anchor:** The origin point within the Sol system remains static, acting as the primary hub for the Galaxy Game market due to solar mass.
- **Stochastic Exit (The Snap):** The exit-side aperture is naturally unstable; upon reaching its Mass Displacement Threshold ($M_{max}$), the link collapses and "snaps" to new coordinates.
- **Mass Fatigue:** Every kilogram of transit mass reduces the limit of the wormhole.
- **Residual EM Bloom:** A collapsed natural wormhole (Shift Discharge) releases a massive amount of Exotic Matter (EM) at the Anchor and the new destination.
- **Hot Starts:** Reconnecting to sites with recent EM blooms allows Stabilization Satellites to harvest that energy to "re-knit" space-time and reset mass counters.

## 2. Artificial Wormhole (AWH) Mechanics

- **Targeted Deployment:** Utilizing known data from the system_seeding directory (e.g., alpha_centauri.json), the AI Manager can force an aperture at specific coordinates like AC-01.
- **Cold Start Classification:** Targeted openings in systems with no natural history (e.g., Alpha Centauri) are classified as "Cold Starts".
- **Fuel Bridge Requirement:** Cold Starts possess zero residual EM and require a permanent supply chain of processed EM from the Sol Anchor to prevent link pinch-off.
- **Stabilization Satellites:**
  - **Harvest Mode:** Deployed in "Hot" systems to siphon residual EM and offset maintenance costs.
  - **Logistics Mode:** Deployed in "Cold" systems to receive and distribute EM shipped from Sol.

## 3. Operational Logistics & The EM Economy

- **Variable Hold Duration (ROI Logic):** The AI Manager maintains a link only as long as the resource extraction rate exceeds the Maintenance Tax, which is 5x higher for inter-galactic links.
- **Strategic Discard:** If a system yield is low, the AI may execute a Mass Dump Maneuver to intentionally exceed $M_{max}$, forcing a "Snap" to gamble on a new destination.
- **Asset Retrieval Protocol:** Before any planned shift or release, all mobile drones and stabilization satellites must return to the Sol-side Anchor to prevent them from becoming "Orphaned".

## 4. System Seeding & Discovery

- **Hybrid Generation:** For known systems in the Local Group, the generator locks in real-world star data (Mass, Luminosity, $R_{ecosphere}$) while using Alien World Logic to fill empty orbital slots.
- **Immutable Ground Truth:** Real-world planetary data, such as Proxima Centauri b and its recorded atmosphere (90% $N_2$, 10% $CO_2$), is treated as fixed and unchangeable by the generator.
- **Market Tagging:** Any purely procedural system discovered without a seed is tagged for the Galaxy Game market for competitive bidding and exploitation.

## Implementation Note for system_architect.rb

The SystemArchitect must reference the Environment Classification to determine deployment priority. In Cold Start systems like Alpha Centauri, the AI must prioritize EM Storage Vaults and Sabatier Units (leveraging the 10% $CO_2$ on Proxima b) for local fuel production to sustain the link.

## Versioning

- **Version:** 1.2
- **Status:** Approved for AIManager::SystemArchitect
- **Compatibility:** galaxy.rb, system_architect.rb