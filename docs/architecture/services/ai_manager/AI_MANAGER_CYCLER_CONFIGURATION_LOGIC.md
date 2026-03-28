## AI Manager Cycler Configuration Logic

When deploying to new system:

### Step 1: Pattern Matching
```
ScoutLogic analyzes system:
├─ Dense atmosphere, no surface → Venus Pattern
├─ Large moon, lava tubes → Lunar Pattern
├─ Small moons, asteroid belt → Mars Pattern
├─ Volatile-rich outer moon → Titan Pattern
└─ Asteroid belt only → Belt Pattern
```

### Step 2: Select Operational Configuration
```
AI loads appropriate operational data:
├─ cycler_venus_harvester_data.json → Venus Pattern
├─ cycler_lunar_support_data.json → Lunar Pattern
├─ cycler_mars_constructor_data.json → Mars Pattern
├─ cycler_titan_harvester_data.json → Titan Pattern
└─ cycler_belt_operations_data.json → Belt Pattern
```

### Step 3: Fit Cycler
```
Install units from recommended_fit:
├─ Mission-specific processors
├─ Construction equipment
├─ Deployment systems
├─ Storage capacity
└─ Power generation

Calculate total mass:
├─ Cycler empty: 600K kg
├─ Equipment: varies by mission
├─ Supplies: varies by duration
└─ Total departure mass: ~1-2M kg
```

### Step 4: Execute Mission
```
Follow mission_phases timeline:
├─ Arrival: Deploy equipment, begin operations
├─ Construction: Build infrastructure from local resources
├─ Transfer: Move equipment to permanent infrastructure
└─ Departure: Load resources, prepare kinetic hammer
```

### Step 5: Return Configuration
```
Switch to kinetic_hammer configuration:
├─ Remove all transferable equipment
├─ Maximize cargo capacity
├─ Load: Resources + Satellites
├─ Total mass: 18M+ kg
└─ Trigger: Controlled Snap
```

### Step 6: Refit for Next Mission
```
Back at Sol:
├─ Unload extracted resources
├─ Remove remaining mission equipment
├─ Analyze next target system
├─ Install new mission fit
└─ Depart through natural WH
```
```

---

## ✅ What's Ready to Add to Plan

### You Have Complete Specifications For:

1. **Cycler base platform** (base_cycler_bp.json) ✅
2. **All operational configurations** (6 mission types) ✅
3. **Equipment transfer logic** (transferable flags) ✅
4. **Mission timelines** (phase durations) ✅
5. **Transfer destinations** (station/depot/keep) ✅

### What the Plan Still Needs:

**Clarifications:**
1. How does "Controlled Snap Expansion" work with these timelines?
2. What's the relationship between mission duration and natural WH stability?
3. How does AI balance "quick extraction" (Harvest systems) vs "full deployment" (Prize systems)?

**Example Questions:**

**Q: If Venus mission takes 255 days, and Jupiter-stabilized WH lasts ~18 months, is that enough time?**
```
Jupiter-stabilized WH: ~540 days stable window
Venus mission: 255 days
Margin: 285 days (9.5 months)

Answer: YES - plenty of time
Even Mars mission (305 days) leaves 235 days margin
```

**Q: What if system is Harvest-tier, not Prize?**
```
Harvest Strategy:
├─ Don't build full infrastructure
├─ Deploy extractors only
├─ Quick operations (3-6 months instead of 8-10)
├─ Skip construction/transfer phases
├─ Immediate departure when depleted
└─ Trigger Snap early (don't wait for full window)
```

**Q: How does this affect the "Saturation Phase" description?**
```
Current plan says: "12-18 months"
Actual data shows: "7-10 months for Prize, 3-6 months for Harvest"

Update: Saturation Phase = Mission-dependent
├─ Prize systems: 7-10 months (full deployment)
├─ Harvest systems: 3-6 months (extractors only)
├─ Skip systems: 1-2 weeks (survey only)
└─ Natural WH stability determines urgency