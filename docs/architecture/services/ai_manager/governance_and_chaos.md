# Architecture Intent: Governance, Population, and Uncertainty

## 1. The Governance Layer
When a settlement population exceeds 10,000, the AI Manager shifts to **Governance Mode**.
* **Primary Metric**: "Systemic Stability" (a weighted average of Life Support, Employment, and GCC Liquidity).
* **Labor Allocation**: The AI generates "Jobs" that fulfill DC Expansion goals (e.g., "Lunar-to-Mars Fuel Export").

## 2. Information Asymmetry (The "Snap" Protocol)
The AI is limited by its **Sensor Network**.
* **Local vs. Global**: The AI only "knows" what is connected via the `Planetary Umbilical Hub` or `Comms Spike`.
* **Random Events**: The engine may inject "Uncertainties" (Solar Flares, Hardware Failures, Micro-meteorites).
* **Reaction Time**: The AI's success is measured by its *recovery speed* after an unpredicted event, not its ability to prevent it perfectly.

## 3. The Population-Resource Feedback Loop
Large populations create exponential demand on the **Atmospheric harvesters** and **Sabatier Units**.
* **Failure State**: If demand > supply + 0.2 buffer, the AI must trigger a "Tier 1: Emergency" state, halting all expansion to fix the leak.
* **Success State**: If surplus is > 0.4, the AI uses the excess labor to "Crate" new expansion kits for the HLL inventory.

## 4. Implementation Guardrail
**No Omniscience**: The AI Manager service should only query the database for units it is "connected" to via the network. This simulates the real-world limitation of managing a million people across a lunar surface.