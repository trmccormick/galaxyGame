# Heavy Lift Transport — Solar Expansion Rig Updates

**Task Type:** Documentation & Sprite Backlog
**Status:** Backlog (LOW PRIORITY)
**Created:** March 4, 2026

---

## Task Summary

- **Solar Expansion Rig** is a multi-purpose deployable module on the Heavy Lift Transport, not a standalone ground structure.
- Blueprint JSON and sprite set need updating to reflect this.
- Image generation quota for new sprites is currently exhausted; sprites are queued for later.

## Details

- **Deployment:**
  - HLT docks to Cycler during deep space transit — Solar Expansion Rig is retracted while docked
  - Deep space power generation (rig extended in transit) belongs to the Cycler, not the HLT — Cycler requires its own sprite set with rig deployed state
  - HLT rig deploys on surface only — provides temporary colony power before grid is established
  - Robots physically detach and store the rig once the colony power grid comes online

- **Sprite Requirements:**
  - Heavy Lift Transport sprite states are now 5 not 6: Landed, Launching, In Orbit, Damaged, Landed + Rig Deployed
  - Reference existing sprite sheets in `docs/agent/image-generation/` for style and integration.

- **Blueprint JSON:**
  - `compatible_modules` should include Solar Expansion Rig as a deployable module.
  - Must support `deploy` and `retract` states for the module.

## Backlog Notes

- Sprite generation will resume when ChatGPT image quota resets (~24 hours).
- Documentation only; no code or asset changes until quota resets.

---

**References:**
- Sprite sheets: `docs/agent/image-generation/`
- Blueprint JSON: Update to support deployable modules

---

**Agent Assignment:** GPT-4.1 (Copilot) — documentation only, preserving premium requests.
