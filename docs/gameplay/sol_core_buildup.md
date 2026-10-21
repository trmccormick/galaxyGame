**Status:** Intent / tuning guide (not locked campaign script)  
**Last updated:** 2026-10-16  

This document records the **preferred early Sol dependency chain**, how **Mars becomes solvent as a trade hub**, and a **candidate player-entry window** after reconnection toward Eden. Test modes may use prescripted Sol, free AI build, or hybrid; the goal is an AI Manager that can run the game. Thresholds and exact timing remain in flux.

Related:
- Agent doc priority when older plans conflict: `docs/architecture/ai_manager/AGENT_READING_ORDER.md`
- Terraforming (downstream of this spine): `docs/gameplay/terraforming.md`
- Footholds / LDC: `docs/architecture/ai_manager/FOOTHOLD_PLANNER_ARCHITECTURE.md`
- Pre-player NPC markets: `docs/architecture/ai_manager/NPC_INITIAL_DEPLOYMENT_SEQUENCE.md`
- Snap intent: `docs/storyline/02_crisis_mechanics.md`
- Physics / AWS intent: `docs/storyline/05_physics_topology.md`

---

## 1. Core dependency chain (preferred order)

1. **Luna** — Footholds, industry, Earth-linked activity (LDC, science/facility customers).
2. **LEO / L1 depots** — Built primarily from **Luna bulk materials**; **custom electronics and specialty gear imported from Earth** (shipping cost is real; Earth trade often **USD**).
3. **L1 Station / Shipyard** — Critical bottleneck.
4. **Hard gate:** **No shipyard → no Mars / Venus expansion.** Large **cyclers** and **tugs** are built at shipyards.
5. **Tugs + cyclers** enter service.
6. **Phobos & Deimos** — Tug hollows and uses **slag propellant** to reposition; **cyclers** deliver equipment to finish **station / depot** conversion.
7. **Tug next mission:** asteroid belt — find **Phobos/Deimos-class** bodies and move them to **Venus** (same hollow → slag-move → cycler outfitting pattern).
8. **Three station/depot locations online** → **cyclers begin normal rotation** among the **core worlds**.
9. **After core loop is up:**
   - **Mars surface operations** start
   - **Venus atmospheric extraction** at scale
   - Optional **Venus high-altitude settlement**
10. **Further flexible legs** (examples): Mars→Saturn/Titan, Mars→Ceres (belt outpost), Psyche-style core-remnant mining — traffic **flows toward Mars**.

**Terraforming** (atmospheric programs, Seeds, brute-force packages) is **later still**: after cycler capacity and preferred feedstock paths exist, and under real Development Corp **GCC** budgets. See `docs/gameplay/terraforming.md`.

---

## 2. Why Mars does not stay "broke"

Branch and core volume move through **Mars** (orbit, then surface markets as they mature). Mars becomes a **large trade hub**: handling, storage, trade, services generate **revenue**. That revenue funds solvent demand so Venus and other suppliers keep exporting.

Without hub economics, Mars cannot pay, Venus throttles export, and resource flow stalls. **Mars-as-hub is the intended mechanism that keeps the chain alive.**

Early solvent demand before the hub matures comes mainly from **Earth → LDC (USD)** (research, facilities, housing, Earth supply purchases + freight), not from unpaid terraforming fantasy orders.

---

## 3. Money and goods (short)

| Mechanism | Role |
|-----------|------|
| **GCC** | Foothold / Development Corp budgets; LDC is early sponsor and mint |
| **USD** | Corps dealing with Earth; Earth freight/trade; corps may use USD between themselves when useful |
| **USD≈GCC peg at start** | Bootstrap familiar costs; peg removed later |
| **Virtual ledger** | NPC corps can transfer goods without a GCC market print; guides what the Manager can sustain — must **not** invent infinite unpaid demand |
| **NPC banks** | Possible Earth-like clearing/credit; detail out of scope for now |
| **Local currencies** (e.g. Martian dollar) | Possible later; out of scope now |

**Rule of thumb:** no solvent buyer → Venus does not export at scale. Ledger shows feasibility; **GCC/USD** makes commitments real.

### Logistics corps (AstroLift and others)

**AstroLift** is the primary early logistics corporation for **Earth ↔ Luna / Sol core freight** (and related depot traffic). Other logistics NPC corps may operate on the same rules.

- Earth-linked purchase/sell legs and shipping are generally **USD**; shipping cost is real.
- Core-world and later branch freight may be **GCC** or mixed once Sol markets mature.
- AI Manager posts demand and routes cargo via logistics corps and cyclers when players do not fill hauls.
- Players may compete on the same lanes (contracts, owned transports) without replacing the NPC backbone.
- Large cyclers and tugs still depend on the **shipyard gate**; AstroLift does not bypass "no shipyard → no Mars/Venus expansion."

Detailed corp charters and fleet lists are out of scope here; intent is a named logistics layer so agents do not invent anonymous free shipping.

---

## 4. Pre-player and AI Manager test modes

Pre-player: **only NPCs and automated/cycler logistics** fill orders. Purpose includes **tuning** — real markets, observable history, adjust AI Manager behavior.

Modes (all valid to try; none is the sole final path):

- **Prescripted Sol buildout** — training data / controlled spine  
- **Free build** — Manager builds Sol → Eden → faces Snap → continues  
- **Hybrid** — Sol scripted; Manager owns Eden and Snap response  

**Goal:** build an AI Manager that can **manage the game**, not freeze one campaign script.

---

## 5. Candidate player entry (not a fixed date)

There is **no locked calendar** for first player login. **Working intent:** players enter after **Sol core buildout** and the **reconnection effort toward Eden** is underway (AWS path), so the universe already has markets, routes, and a frontier.

### 5.1 Reconnection sequence (intent)

1. **AWS built on the Sol side** — opens an artificial link toward Eden.  
2. **Stabilization sats deployed on the Eden side** — first presence; **unknown** what they find.  
3. **Scout ships** — survey the system; classify condition (see Eden bands below).  
4. **Tug** — targets the **original Wormhole Station (WS)** in Eden space.  
5. **WS must be moved** to the **new artificial wormhole opening** and **reconfigured to serve as the AWS** that maintains the link.  
6. **System B** (and further exploration) — plenty for players: survey, salvage, logistics, claims, support tug/AWS work, parallel frontiers.

One-sided open + sats-only exit remains **fragile** until the far-side AWS (reconfigured WS) is online; mass limits, counterbalance, and **EM** still apply.

### 5.2 Eden condition bands (from pre-Snap settlement)

Post-survey state depends on **how far Eden was settled and how closed its loops were** under pre-player AI/NPCs before the Snap (thresholds in flux):

| Band | Character |
|------|-----------|
| **Ghost** | Import-reliant / broken loops — stalled or dead infrastructure |
| **Remnant** | Survival-focused, limited growth |
| **Expanding** | Closed loops, local industry, still developing |

Reconnection **reveals** that history; it does not auto-repair it.

### 5.3 Tutorial mode and first player loop (intent)

There is no locked onboarding script, but the working first steps are:

1. **Spawn** at a player-chosen open **Development Corporation foothold** base (tutorial mode teaches basics at that location).
2. Receive **basic harvest equipment** appropriate to what that body/base supports.
3. **Harvest** local resources.
4. **Process** those resources.
5. **Build basic items** — upgrade personal equipment and/or **sell** on the local market.
6. After that ladder, normal play opens: haul, contracts, wider Sol routes, and (if the snapshot is reconnection-underway) optional Eden/System B support work.

**Valid tutorial spawn bases (intent):** Any **open Development Corporation foothold** present in the snapshot. For reconnection-underway class dumps, expect at least:

- **Luna** DC foothold(s) — default-safe tutorial; bulk industry and Earth-linked market legs
- **Mars** orbital and/or surface footholds once the core loop has opened them — denser trade-hub jobs
- **Venus** station / high-altitude footholds once extraction-era presence exists — gas/industrial flavor

Do not require every dump to offer every base. Tutorial gear and recipes are **local** to the chosen foothold. If only Luna is open, that is enough for first-player testing. Players are not offered a spawn at undeveloped bodies or at pure NPC logistics hubs with no foothold services.

The AI Manager and NPCs already run the economy. The tutorial teaches the player how to **plug in** (extract → process → craft/sell), not how to found Sol or control terraforming. Starter kit and available recipes depend on the foothold's local resources and what that snapshot has unlocked.

**Starter kit (intent):** minimal **basic harvest equipment** suited to the spawn body, plus access to **local processing** needed for the tutorial ladder. Not a free ship, shipyard, or full industrial suite. Haul capacity and owned transports are earned or bought after the basics, not granted at spawn.

---

## 6. What this document is not

- Not a substitute for detailed cycler/tug/shipyard implementation specs  
- Not locked Snap tonnage or EM corona rules  
- Not full player UX  
- Not a requirement that every test run use the same script  

When agents rank early AI Manager priorities, **prefer this spine over early terraforming buy spam or early EM-farm expansion.**

## Universe snapshots (DB dumps) for test and play

Long automated buildouts are expensive to re-run after every AI Manager change. **Database dumps (universe snapshots)** capture Sol/Eden (and related) state at chosen points so a run can start mid-spine.

**Purpose**
- Test AI Manager adaptations from a known state without simulating everything up to that point each time
- Support prescripted, free, and hybrid modes by *producing* dumps from long runs and *consuming* them in short tests
- Optionally seed playable servers (e.g. reconnection-underway as a candidate player-entry class dump)

**Example snapshot classes** (names illustrative, not locked filenames)
- Early Luna / pre-shipyard
- Shipyard online, pre-Mars–Venus expansion
- Core cycler loop + Mars hub forming
- Pre-Snap Eden at varying maturity
- Post-Snap Sol, pre-AWS reconnection
- Reconnection underway (Sol AWS, Eden sats/scouts/tug/WS move)
- Eden surveyed as Ghost / Remnant / Expanding

**Practice**
1. Run automated (NPC-only) buildout or load a prior dump
2. Export DB snapshot at the stage under test
3. After code changes, import that dump and observe AI Manager behavior
4. Promote useful dumps as named seeds for regression or play

Exact dump format, storage path, and tooling are implementation details. Intent: **snapshots are first-class** for AI Manager tuning and for optional player-start states.

## EM harvesting and network economy (later, not early Sol)

Exotic Matter (EM) from natural wormholes (and related AWS/stabilization infrastructure) is important for **interstellar links, portals, and high-end network ops**. It is **not** an early Sol priority.

- Preferred early ordering remains Luna → shipyard → core cyclers → Mars hub (see Core dependency chain above).
- EM harvest, containment, and stabilizing a natural throat with artificial counterbalance are **mid/late** systems after the core industrial spine exists.
- Natural links remain subject to mass limits, counterbalance, and Snap risk (storyline docs; thresholds in flux).
- Artificial management (AWS) improves stability; it does not remove EM cost or mass limits.
- Detailed harvest corona/surge rules and pricing are **open**; do not treat speculative frameworks as locked game facts.

Operational physics/topology intent: `docs/storyline/05_physics_topology.md`  
Snap / reconnection: `docs/storyline/02_crisis_mechanics.md`
