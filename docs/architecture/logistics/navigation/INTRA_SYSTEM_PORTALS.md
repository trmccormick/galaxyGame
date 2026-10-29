# INTRA_SYSTEM_PORTALS.md

## Micro-Portal 'Airport Gate' Architecture

### EM Maintenance Cost
- Each portal pair requires a continuous supply of Exotic Matter (EM) to maintain resonance and stability.
- **Rule:** The EM cost to operate a portal pair for a given mass must always exceed the cost of running a Cycler for bulk goods transport. This ensures that portals are reserved for high-priority, low-mass, or time-sensitive cargo and personnel.
- **Implication:** Bulk goods and heavy freight are routed via Cyclers, not portals, due to cost efficiency.

### Mass Limit
- Each portal has a strict maximum mass limit (PORTAL_MAX_MASS). Any ship or cargo exceeding this limit cannot transit.

### Paired Constraint
- Portals must be deployed in pairs. Each portal has a `partner_id` or `destination_portal_id` linking it to its fixed exit.
- Single, unpaired portals are non-functional and cannot be used for transit.

---

**See also:** WORMHOLE_NETWORK.md for interstellar portal logic and mass constraints.
