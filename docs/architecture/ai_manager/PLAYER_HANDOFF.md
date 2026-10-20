# AI Manager → Player Handoff Protocol

## Documentation status (2026-10-19)

This file describes an **exploratory** "AI becomes advisory when a player arrives in a system" protocol. It is **not** current default player-entry intent.

Current intent (`docs/gameplay/sol_core_buildup.md`):
- Players spawn at a chosen **Development Corp foothold** and learn basics (harvest → process → craft/sell).
- The AI Manager **continues** to run NPC corps, markets, logistics, and background programs; players plug into that economy.
- Candidate universe phase for entry is **reconnection-underway** (or other DB snapshots), not "player takes strategic control of AWS/consortium on arrival."

Treat sections below as optional advanced/cooperative modes unless explicitly adopted later. Prefer sol_core_buildup and AI_MANAGER_ROLE for default player vs AI Manager split.

## TRANSITION TRIGGER
- **Event:** Player arrives in system
- **Action:** `AI_MANAGER.autonomy = :advisory`
- **Result:** AI shifts from full control to strategic advisor and execution assistant

---

## ADVISORY MODE (AI Suggests → Player Decides)

### Example Event: Natural WH Detected (Barnard's Star)
- **AI Analysis:**
  - BFS: Sol→Barnard (3 hops via Brown Dwarf L3)
  - EM Yield: 2.3x vs AWS cost
  - Consortium Vote: 72% quorum (LDC: +0.28, AstroLift: +0.22)
  - **Recommendation:** Prioritize natural (EM fountain)
- **Player Input:** "Focus on Alpha Centauri instead"
- **AI Response:** Recalculate ROI, suggest counter-proposal

---

## EXECUTION ASSISTANT (Player-Approved Actions)
- **Player:** "Execute stabilization"
- **AI:** Deploy AWS L3 + EM satellites, monitor physics compliance
- **Player:** "Show EM buffer status"
- **AI:** Report current EM buffer, suggest next optimal action

---

*This protocol ensures seamless transition from AI autonomy to player-driven strategy, maximizing synergy and compliance with game physics. The AI Manager remains a flawless executor and advisor throughout the galactic empire.*
