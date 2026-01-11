## Equipment Transfer System

### Transferable Equipment (Goes to Infrastructure):
**Purpose:** Permanent capabilities for local operations

Venus Pattern:
├─ Atmospheric processors → Station (5 units)
├─ CNT fabricators → Station (3 units)
├─ Gas separators → Depot (4 units)
└─ Solar arrays → Depot (6 units)

Lunar Pattern:
├─ ISRU processors → Base (6 units)
├─ Regolith processors → Base (4 units)
├─ CNT fabricators → Base (3 units)
└─ Solar arrays → Depot (5 units)

Mars Pattern:
├─ Mining drones → Depot (6 units)
├─ Refining equipment → Depot (4 units)
├─ Hollowing equipment → Depot (3 units)
└─ Solar arrays → Station (5 units)

### Permanent Cycler Equipment (Never Transfers):
**Purpose:** Essential for crew and cycler operations

All Patterns:
├─ Cycler habitat modules (4 units) - crew quarters
├─ Life support systems - crew survival
├─ Navigation systems - cycler-specific
├─ Ion drives - cycler propulsion
└─ Cryogenic storage - cargo capacity

### Reusable Equipment (Returns to Sol):
**Purpose:** Next mission deployment

All Patterns:
├─ Construction drone bays (2-3 units)
├─ Assembly systems (where applicable)
├─ Deployment bays (skimmer, mining)
└─ Survey equipment

### Transfer Trigger:
- **Milestone:** Infrastructure completion status
- **Venus:** station_completion
- **Lunar:** base_completion  
- **Mars:** depot_completion
- **Timing:** After construction phase, before departure