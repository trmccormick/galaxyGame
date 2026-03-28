# Architecture Intent: Sol Validation & NPC Ascension

## 1. The Sol Trial (Phase 1)
The AI Manager is restricted to the Sol system until specific "Stability Milestones" are met. This is the "Training Phase" where JSON Mission Profiles are tested for viability.

### Milestone: Self-Sustenance
A settlement is considered "Proven" when:
* **Stability Score** remains > 0.8 for 100 consecutive ticks.
* **Resource Buffer** (O2, Power, Food) is > 0.5 capacity.
* **Economic Loop** generates a net-positive GCC flow without player intervention.

## 2. Testing Hypotheses (JSON Profiles)
The mission JSONs in `data/json-data/missions/` are not "Fixed Truths."
* The AI should attempt different profiles (e.g., "Solar Heavy" vs "Nuclear Heavy") on the same celestial body.
* The `PerformanceTracker` will rank these profiles. The "Winning" profile becomes the default for future NPC-managed systems.

## 3. Ascension to NPC Manager (Phase 2)
Upon successful validation in Sol, the AI Manager "Ascends" to manage the **Eden Wormhole Network**.
* **Global Oversight**: The AI takes control of the Galaxy Game Market (Build vs. Market logic).
* **Mission Generation**: The AI begins generating its own missions for Players based on the shortages it predicts in the industrial loop.

## 4. Implementation Guardrail
**No Hardcoded Success**: The AI must fail if the JSON profile is physically impossible. If a profile lacks a `Power Unit`, the AI should not be "helped." This ensures the `AI_LEARNING_SYSTEM` captures the failure and adjusts the confidence of that specific mission profile.