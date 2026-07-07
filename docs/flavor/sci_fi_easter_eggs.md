# Sci-Fi Easter Eggs (Love Letter to the Genre)
**Location:** `docs/flavor/sci_fi_easter_eggs.md`  
**Source:** Extracted from `docs/GUARDRAILS.md` Section 11 (lines 396-442) during GUARDRAILS consolidation, 2026-07-03

---

## Core Philosophy
- **Subtle Nods:** References should be easter eggs, not core mechanics. Casual players see them as flavor; fans recognize them as homages.
- **No Copyright Infringement:** Use generic names, indirect references, or public-domain elements. Avoid direct quotes, logos, or protected trademarks.
- **Immersion First:** Easter eggs enhance the universe without breaking gameplay or requiring knowledge to enjoy.

## Integration Points
- **Celestial Body Names & Descriptions:** Unnamed moons or asteroid clusters can bear names of famous fictional star systems (e.g., "Arrakis Cluster" for a desert world, "Terminus Belt" for a trade hub, or "The Belt" for asteroid fields). Descriptions include subtle flavor text.
- **Mission Manifests:** `manifest_v1.1.json` files include "Legacy Cargo" or "Historic Logs" referencing famous ships/captains (e.g., "Cargo from the Nostromo" or "Logs from the Serenity's maiden voyage").
- **AI Manager Quips:** Occasional dialogue or "Error Codes" reference famous sentient computers (e.g., "HAL 9000 protocol engaged" for navigation errors, "GlaDOS testing sequence" for experimental phases, or "Holly override" for AI decisions).
- **Item Metadata:** Standard items like `slag_propellant` have flavor text referencing sci-fi fuel types (e.g., "Propellant reminiscent of the fuel used in the Rocinante's Epstein drives").

## Alpha Centauri Connection
- **Wormhole Hub:** Use Alpha Centauri as the primary hub for Easter Eggs. "Natural wormholes" can open to systems in the Milky Way, acting as "guest appearances" for iconic sci-fi locations.
- **Proxima Centauri References:** Generated JSON files for Proxima systems include nods to *The Three-Body Problem* (e.g., "Trisolarian signals detected") or *Avatar* (e.g., "Pandora-like bioluminescent flora").
- **Milky Way Access:** Wormholes enable "visits" to sci-fi-inspired systems without developing FTL travel.

## Technical Implementation
- **GUARDRAILS.md Rules:** Naming conventions ensure easter eggs stay within "nod" category—e.g., no direct character names, focus on locations/ships/concepts.
- **JSON Schema:** Every generated system JSON includes `flavor_text` or `easter_egg_id` fields for references, kept separate from core game logic.
- **System-Level Easter Eggs:** For special systems (e.g., wormhole hubs), use `AIManager::WorldKnowledgeService#generate_system_easter_egg(has_wormhole: true)` to apply sci-fi references like the "Celestial Anomaly" from Star Trek DS9.
- **Location-Based Triggers:** `location` is now an optional parameter in `find_matching_easter_egg`. `ancient_world` is a reserved location tag triggered by worlds with a `geological_age > 1.0` or the `pre_collapse_ruins` trait. System-level tags (e.g., `deep_space`) are validated against `system.sector_type`.
- **Documentation Sync:** Any new easter egg must be documented in `docs/` with its source inspiration and guardrail compliance.
- **Testing:** Easter eggs must not affect gameplay balance or cause immersion breaks. Specs include checks for flavor text presence without requiring sci-fi knowledge.

## Examples & Compliance
- **Compliant:** "A barren world echoing the harsh deserts of ancient tales" (nods to Dune without naming).
- **Non-Compliant:** "Welcome to Arrakis, home of the Fremen" (direct reference, potential infringement).
- **Implementation Check:** Before adding, verify against public-domain status or generic nature.

## Easter Egg Categories & Sub-Categories
- **World Naming:** System/planet name references (e.g., Celestial Anomaly)
- **Found Footage:** Discovery logs and signals (e.g., Monolith, Ghost Ship)
- **AI Personality:** Sentient computer behaviors (e.g., HAL protocol)
- **Vessel Logs:** Ship sightings and encounters (e.g., Serenity-class)
- **Improbable Events:** Reality-bending anomalies (e.g., Infinite Improbability Drive)
- **Industrial Horror:** Corporate exploitation themes (e.g., Nostromo incident)
- **Military/Refugee Fleet:** Fleet sightings and refugee encounters (e.g., Lost Fleet)
- **Smuggler/Outlaw:** Rogue vessel and outlaw activities (e.g., Kessel Run)
- **Xeno-Biological Anomaly:** Alien life and biological threats (e.g., Protomolecule)

This strategy ensures the game honors sci-fi's legacy while maintaining focus on realistic space colonization.
