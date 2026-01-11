# 🌑 Lunar Regolith ISRU Processing and Reuse Flow

## 🚁 Overview

This document outlines the regolith-based ISRU (In-Situ Resource Utilization) flow for the lunar base. It defines the daytime and nighttime processing steps, gas routing, cryogenic storage strategy, and reuse of regolith for construction.

---

## 🔁 Regolith ISRU Flow

### 1. Thermal Extraction Unit (TEU)

- **Input**: Raw lunar regolith
- **Timing**: Operates only during **lunar daytime**
- **Process**: Heats regolith to release volatile gases
- **Output**:
  - Mixed volatile gases → routed to **Inflatable Pressure Tank**
  - Heated, oxide-rich regolith → passed to **PVE**

---

### 2. Planetary Volatiles Extractor (PVE)

- **Input**: Pre-heated regolith from TEU
- **Timing**: Operates only during **lunar daytime**
- **Process**: Extracts oxygen and possibly other gases from metal oxides
- **Output**:
  - Oxygen and trace gases → routed to **Inflatable Pressure Tank**
  - Mineral-rich waste regolith → routed to 3D printing systems

---

### 3. Inflatable Pressure Tank (Buffer Storage)

- **Function**: Temporary gas buffer between daytime extraction and nighttime liquefaction
- **Timing**: Receives gases during **lunar day**, feeds separator during **lunar night**
- **Gases Stored**: O₂, trace CH₄, CO, CO₂, N₂ (if present)

---

### 4. Gas Separator

- **Timing**: Operates only during **lunar night**
- **Process**:
  - Separates gases
  - Uses natural cold to assist liquefaction
- **Output**:
  - CH₄, O₂, N₂, and other gases → sent to **Cryogenic Storage Tanks**
  - Compatible with both **inflatable cryo tanks** and **multi-purpose cryo tanks**

---

## 🧱 Waste Regolith Reuse

| Source             | Use Case                                   |
| ------------------ | ------------------------------------------ |
| PVE waste regolith | 3D Printed Shells (radiation shielding)    |
| PVE waste regolith | 3D Printed I-Beams (solar structures)      |
| TEU byproducts     | Dust mitigation, roads, radiation barriers |

---

## 🧪 Material Flow Diagram

```
      [ Raw Regolith ]
             ↓
         ┌────────┐
         │  TEU   │────┐
         └────────┘    │
             ↓         ▼
         ┌────────┐  [Inflatable Pressure Tank] ←────┐
         │  PVE   │────┘                             │
         └────────┘                                  ▼
             ↓                                ┌───────────────┐
      [Waste Regolith]                        │ Gas Separator │
             ↓                                └──────────────-┘
    [3D Printing Systems]                            ▼
                                           [Cryogenic Storage Tanks]
```

---

## 📊 6-Month Automated Harvesting Estimate

> **Assumptions**:
>
> - 1x TEU, 1x PVE, 1x Gas Separator
> - \~85% uptime per lunar cycle (12.5 Earth days operation every 27.3-day cycle)
> - \~50 kg regolith processed per cycle
> - Scaled over 6 lunar cycles (\~6 months Earth time)

| Output                  | Estimated Amount | Notes                                  |
| ----------------------- | ---------------- | -------------------------------------- |
| **Oxygen (O₂)**         | \~3,000 kg       | Stored as LOX after separation         |
| **Metallic Byproducts** | \~2,500 kg       | Aluminum, silicon, iron (construction) |
| **Water (H₂O)**         | \~30 kg          | From hydroxyls/volatiles (trace only)  |
| **Waste Regolith**      | \~90,000 kg      | Used for printing shells, beams, etc.  |
| **LOX Stored**          | \~2,500 kg       | Cryogenically liquefied                |
| **CH₄/N₂ (Trace)**      | Varies           | Depends on location or import presence |

