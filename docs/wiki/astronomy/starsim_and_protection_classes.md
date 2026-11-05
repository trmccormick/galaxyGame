# Stellar Radiation, Orbital Mechanics & Planetary Protection Classes

> **Code Alignment Status:** `DESIGN INTENT`
> *Last Audited:* 2026-11-04
> *Audit Summary:* Expanded specification covering stellar radiation pressure curves, flare flux dynamics, solar wind erosion models per star class, orbital degradation vectors, magnetic shielding attenuation equations, radiation exposure dosage calculations, and planetary protection containment protocols Classes I through V. Code implementation pending or unverified as of audit baseline.

## Status: DESIGN INTENT — Backend Simulation Specification

This document defines the backend astrophysics subsystems governing stellar environment effects, orbital dynamics under prolonged radiation pressure, magnetic shielding physics, and the Planetary Protection Class (PPC) framework for biological contamination risk management across all procedurally generated solar systems. All content is target design intent; no runtime enforcement currently exists in code.

**Cross-link:** For StarSim procedural system generation and CelestialBody model contracts, see **[StarSim Procedural Generation](../design/starsim_and_protection_classes.md)**.
**Cross-link:** For ISRU fabrication chain feedstock qualification and CNT composite production, see **[ISRU Fabrication Chain](../technical/isru_fabrication_chain.md)**.
**Cross-link:** For atmospheric harvesting of CO₂ and N₂ from Venus/Titan analog bodies, see **[Atmospheric Harvesting](../infrastructure/atmospheric_harvesting.md)**.
**Cross-link:** For pre-player-era logistics pipeline governing transit decay, delta-v expenditure equations, and depot warehousing, see **[Pre-Player Era Logistics Pipeline](../infrastructure/pre_player_era_logistics_pipeline.md)**.
**Cross-link:** For Planetary Protection & Environmental Governance governance hierarchy, see **[Planetary Protection & Environmental Governance](../infrastructure/planetary_protection_environmental_governance.md)**.
**Cross-link:** For Terraforming Economic Integration and the Sol Tri-System Volatile Loop, see **[Terraforming Economic Integration](../logistics/terraforming_economic_integration.md)**.

---

## 1. Stellar Radiation Environment per Star Class

Galaxy Game assigns each generated star one of the Morgan-Keenan spectral classes (O, B, A, F, G, K, M) with sub-class subdivisions (0–9). Each class defines a deterministic radiation profile that feeds into downstream orbital mechanics and biological protection calculations.

### 1.1 Stellar Classification Constants

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from standard stellar astrophysics references (Morgan-Keenan classification, Kopparapu HZ model). They have not been validated against `config/initializers/game_constants.rb` or StarSim operational data. Validate against architecture specs before treating as authoritative.

| Class | Surface Temp (K) | Luminosity (L⊙) | Mass (M⊙) | UV Photon Flux at 1 AU (W/m²) | Typical Lifespan (Myr) | Grounding |
|-------|------------------|--------------------|-------------|-------------------------------|----------------------|-----------|
| O5    | ~42,000          | ~90,000            | ~40         | 2,850                         | ~3.1                 | **[PROPOSED / PLACEHOLDER]** — standard MK classification data, not from game constants |
| B0    | ~30,000          | ~20,000            | ~17.5       | 980                           | ~10                  | **[PROPOSED / PLACEHOLDER]** — standard MK classification data, not from game constants |
| A0    | ~9,600           | ~80                | ~2.9        | 48                            | ~400                 | **[PROPOSED / PLACEHOLDER]** — standard MK classification data, not from game constants |
| F5    | ~6,500           | ~3.2               | ~1.3        | 11                            | ~15,000              | **[PROPOSED / PLACEHOLDER]** — standard MK classification data, not from game constants |
| G2    | ~5,772           | 1.0                | 1.0         | 4.6                           | ~10,000              | **[PROPOSED / PLACEHOLDER]** — standard MK classification data, not from game constants |
| K5    | ~4,400           | 0.15               | 0.68        | 1.2                           | ~57,000              | **[PROPOSED / PLACEHOLDER]** — standard MK classification data, not from game constants |
| M5    | ~3,200           | 0.008              | 0.21        | 0.15                          | ~2,000               | **[PROPOSED / PLACEHOLDER]** — standard MK classification data, not from game constants |

**Effective Habitable Zone (HZ) Bounds:**

```ruby
# Pseudo-code derived from Kopparapu et al. (2013) runaway-greenhouse / maximum-greenhouse limits
def habitable_zone_boundaries(star_luminosity_Lsun)
  inner_edge = Math.sqrt(star_luminosity_Lsun / 1.05)    # Runaway greenhouse threshold
  outer_edge = Math.sqrt(star_luminosity_Lsun / 0.35)     # Maximum greenhouse threshold
  [inner_edge, outer_edge]
end
```

Planets within the HZ receive sufficient flux for liquid water; planets outside the HZ receive either excessive or insufficient insolation, driving surface temperature determinations used by `CelestialBody::Spheres::Geosphere`.

### 1.2 Stellar Radiation Pressure Curves

Radiation pressure exerts an outward force on orbiting bodies and dust particles, modifying effective gravitational potential. The radiation pressure ratio β determines whether a particle is bound or ejected:

**Radiation Pressure Ratio:**
```
β = F_rad / F_grav = (L * Q_pr * A) / (4πcGMm)

where:
  L   = stellar luminosity (W)
  Q_pr = radiation pressure efficiency (~1 for absorbing particles)
  A   = cross-sectional area of particle (m²)
  c   = speed of light (299,792,458 m/s)
  G   = gravitational constant
  M   = stellar mass (kg)
  m   = particle mass (kg)
```

**Per-Body Flux Integration:**

For a planet at semi-major axis `a` (in AU), the integrated spectral irradiance is:

```
I(a, star_class) = L_star / (4π * (a * 1.496e11)²)

Radiation pressure on hull: P_rad = I(a, star_class) / c
```

**Flux Decay with Stellar Evolution:**

Stellar luminosity increases over the main-sequence lifetime at a class-dependent rate.

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from standard stellar evolution models (e.g., Pinsonneault et al.). They have not been validated against game constants or StarSim operational data.

| Class | Luminosity Growth Rate (per Gyr) | ΔL/L₀ at Tₘₐₓ | Grounding |
|-------|----------------------------------|-----------------|-----------|
| O     | ~+180% / Gyr                     | +540%           | **[PROPOSED / PLACEHOLDER]** — stellar evolution model estimate; not from game constants |
| B     | ~+95% / Gyr                      | +285%           | **[PROPOSED / PLACEHOLDER]** — stellar evolution model estimate; not from game constants |
| A     | ~+35% / Gyr                      | +70%            | **[PROPOSED / PLACEHOLDER]** — stellar evolution model estimate; not from game constants |
| F     | ~+18% / Gyr                      | +36%            | **[PROPOSED / PLACEHOLDER]** — stellar evolution model estimate; not from game constants |
| G     | ~+6.5% / Gyr                     | +13%            | **[PROPOSED / PLACEHOLDER]** — solar analog extrapolation; not from game constants |
| K     | ~+2.1% / Gyr                     | +4.2%           | **[PROPOSED / PLACEHOLDER]** — stellar evolution model estimate; not from game constants |
| M     | ~+0.08% / Gyr                    | +0.16%          | **[PROPOSED / PLACEHOLDER]** — M-dwarf models are less constrained; not from game constants |

### 1.3 Stellar Flare Flux Dynamics

Stellar flares are sudden, localized energy releases driven by magnetic reconnection events on the stellar photosphere. Flare frequency and intensity scale inversely with stellar class — lower-mass stars flare more frequently but with shorter total durations.

**Flare Frequency Distribution (Power Law):**
```
dN/dE = k * E^(-α)

where:
  dN/dE   = differential flare rate per unit energy
  E       = flare energy (J)
  α       = power-law index (~1.8–2.4 for solar-type stars)
  k       = normalization constant (class-dependent)
```

**Per-Class Flare Parameters:**

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from solar physics extrapolation models. They have not been validated against game constants or StarSim operational data.

| Class | Flare Rate (per day, E > 10²⁴ J) | Peak X-ray Flux at 1 AU (W/m²) | Characteristic Duration (min) | Reoccurrence Interval (Gyr) | Grounding |
|-------|-----------------------------------|-------------------------------|------------------------------|----------------------------|-----------|
| O     | ~0.001                            | < 0.01                        | 2–5                          | > stellar lifetime         | **[PROPOSED / PLACEHOLDER]** — massive star flare data is extremely limited; extrapolated from solar data |
| B     | ~0.01                             | ~0.1                          | 5–15                         | > stellar lifetime         | **[PROPOSED / PLACEHOLDER]** — massive star flare data is extremely limited; extrapolated from solar data |
| A     | ~0.1                              | ~1                            | 10–30                        | 500+                       | **[PROPOSED / PLACEHOLDER]** — A-star flare rates are not well-constrained observationally |
| F5    | ~1                                | ~10                           | 20–60                        | 100+                       | **[PROPOSED / PLACEHOLDER]** — F-star flare data extrapolated from solar and T-Tauri stars |
| G2    | ~3 (Carrington-level >10²⁵ J)     | ~45 (X-class event)           | 30–120                       | 50–100                     | **[PROPOSED / PLACEHOLDER]** — solar data extrapolated; not from game constants |
| K5    | ~15 (superflares common)          | ~200                          | 60–300                       | 5–20                       | **[PROPOSED / PLACEHOLDER]** — K-dwarf superflare rates from Kepler/TESS surveys; not game-validated |
| M5    | ~800 (continuous microflare activity) | ~1,500                   | 10–600                       | 1–5                        | **[PROPOSED / PLACEHOLDER]** — M-dwarf flare rates from TESS survey data; not game-validated |

**Flare Impact on Unshielded Hulls:**

A flare event delivers an instantaneous radiation dose to exposed surfaces. Dose calculations are **[PROPOSED / PLACEHOLDER]** estimates for modeling purposes only.

> **Note:** The formulas below represent a model framework. Actual parameter values (e.g., `ρ_material`, `(dE/dx)_interaction`) require validation against game hull material definitions.

```
Dose_rate (Gy/hr) = X_ray_flux / ρ_material * (dE/dx)_interaction

Cumulative flare dose over mission duration T:
  D_flare = Σ_i [Flare_i_Xray_Flux * Duration_i] / (4π * distance²)
```

**Coronal Mass Ejection (CME) Coupling:**

Each major flare (>10²⁶ J) carries an associated CME with kinetic energy E_CME and bulk velocity v_CME:
```
E_CME ≈ 0.5 * M_ejecta * v_CME²
v_CME_range = [200–3,200 km/s] (class-dependent distribution)

Arrival time at planet distance d:
  t_arrival = d / v_CME
```

CME-driven particle fluence adds to the total radiation exposure and can trigger secondary ionization cascades in planetary atmospheres.

### 1.4 Solar Wind Erosion Models per Star Class

The stellar wind — a continuous outflow of charged particles — strips planetary atmospheres through ion pick-up, sputtering, and gravitational escape. The erosion rate depends on stellar mass-loss rate, wind velocity, and planetary magnetic shielding.

**Stellar Mass-Loss Rate:**
```
dM/dt_star = dM/dt_Sun * (R_star / R_Sun)² * (v_wind / v_wind_Sun)^(-1) * (T_eff / T_eff_Sun)^0.5

where:
  dM/dt_Sun ≈ 2e-14 M⊙/yr (solar baseline)
```

**Per-Class Wind Parameters:**

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from stellar wind models (e.g., Wood et al. mass-loss relations). They have not been validated against game constants or StarSim operational data.

| Class | Mass-Loss Rate (× 10⁻¹⁴ M⊙/yr) | Wind Velocity (km/s) | Dynamic Pressure at 1 AU (pPa) | Grounding |
|-------|---------------------------------|----------------------|-------------------------------|-----------|
| O     | ~50                             | 2,500                | ~800                          | **[PROPOSED / PLACEHOLDER]** — O-star wind parameters are high-uncertainty; not game-validated |
| B     | ~30                             | 2,000                | ~400                          | **[PROPOSED / PLACEHOLDER]** — B-star wind parameters extrapolated from O-star models |
| A     | ~5                              | 1,500                | ~25                           | **[PROPOSED / PLACEHOLDER]** — A-star winds are weak and poorly constrained; not game-validated |
| F     | ~3                              | 700                  | ~8                            | **[PROPOSED / PLACEHOLDER]** — F-star wind data extrapolated from solar analogs |
| G2    | 2.0 (baseline)                  | 400–800              | ~2                            | **[PROPOSED / PLACEHOLDER]** — solar baseline scaled; not game-validated |
| K     | ~1                              | 450                  | ~1                            | **[PROPOSED / PLACEHOLDER]** — K-dwarf wind parameters from model extrapolation |
| M     | ~50+ (intense low-mass wind)   | 300–500              | ~60                           | **[PROPOSED / PLACEHOLDER]** — M-dwarf wind is poorly understood; highly uncertain estimates |

**Atmospheric Escape Flux:**

The atmospheric mass loss rate from a planet at orbital distance `a`. Parameters below are **[PROPOSED / PLACEHOLDER]** model framework values, not game constants.

**Magnetic Shielding Attenuation:**

A planet with a magnetosphere reduces the effective wind impact by the magnetopause standoff ratio:
```
R_mp = R_p * (B_surface² / (2μ₀ * P_dyn))^(1/6)

Atmospheric protection factor:
  f_protection = (R_mp / R_p)^(-2) = (2μ₀ * P_dyn / B_surface²)^(1/3)
```

Planets without intrinsic magnetic fields (Mars-analog, Class-1 bodies without magnetosphere) receive the full unattenuated stellar wind erosion.

---

## 2. Orbital Mechanics & Degradation Vectors

### 2.1 Orbital Decay Due to Radiation Pressure

Radiation pressure reduces the effective gravitational parameter μ:
```
μ_eff = G * M_star * (1 - β)

Orbital decay rate for eccentric orbit:
  da/dt = -2 * a * β * (n / sqrt(1 - e²))

where n is mean motion and e is orbital eccentricity.
```

For macro-simulation (StarSim), this produces secular shifts in semi-major axis that accumulate over the body's lifetime. Small bodies (μm–mm sized) achieve β > 1 and are ejected from the system entirely within the Poynting-Robertson timescale:
```
t_PR = (4π * ρ * r * c² * a²) / (3 * L_star * Q_pr)
```

### 2.2 Tidal Forces & Roche Limit Dynamics

Tidal stress induces orbital decay for bodies within the tidal radius:
```
a_Roche = R_p * (2 * ρ_body / ρ_primary)^(1/3)

Tidal acceleration at surface:
  a_tidal = (2 * G * M_primary * R_body) / d³

where d is the center-to-center distance.
```

Bodies crossing the Roche limit disintegrate into ring systems or feed debris disks that seed asteroid populations via the accretion simulation service.

### 2.3 Poynting-Robertson Drag on Minor Bodies

Minor bodies experience PR drag causing inward orbital migration:
```
dr/dt = - (β * c) / (4π * ρ * r_particle) * (L_star / (4π * c * a²))

Time to spiral into star from distance a₀:
  t_infall ≈ (c² * ρ² * r_p² * a₀²) / (β * L_star)
```

This mechanism clears dust from inner system regions and creates the radial gradient of volatile/rocky composition observed in procedural generation outputs.

---

## 3. Magnetic Shielding Physics

### 3.1 Magnetosphere Generation Model

Planetary magnetic field strength is derived from dynamo activity in the liquid core:
```
B_surface = B_earth * (ρ_core / ρ_earth)^(1/2) * (R_core / R_earth)^(-1) * (Ω / Ω_earth)^(0.5)

where Ω is planetary rotation rate.

Dynamo threshold: minimum core convection velocity v_crit required to sustain field
  Ra_critical ≈ 10⁹ (Rayleigh number for onset)
```

Planets with core temperatures below the solidus threshold, or rotation rates below v_crit / R_core, fail to generate a dynamo and produce no magnetosphere.

### 3.2 Shielding Attenuation Equations

The magnetopause standoff distance determines the effective shield cross-section:
```
R_mp = [B_surface² * R_p⁶ / (2 * μ₀ * P_dyn)]^(1/6)

Where dynamic pressure P_dyn includes both stellar wind ram pressure and thermal pressure components.
```

**Shielding effectiveness by class:**

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from magnetospheric physics models. They have not been validated against game constants or StarSim operational data.

| B-surface (Gauss) | R_mp / R_p Ratio | Atmospheric Retention Efficiency | Protection Rating | Grounding |
|-------------------|-------------------|---------------------------------|-------------------|-----------|
| 0 (none)          | 1.0               | 0%                              | none              | **[PROPOSED / PLACEHOLDER]** — no shielding; baseline case |
| < 1               | 1.5–2.0           | ~20%                            | weak              | **[PROPOSED / PLACEHOLDER]** — low-field magnetosphere model; not game-validated |
| 1–3               | 2.5–4.0           | ~55%                            | moderate          | **[PROPOSED / PLACEHOLDER]** — derived from Mars-analog magnetosphere models |
| 3–6 (Earth-like)  | 5.0–8.5           | ~85%                            | strong            | **[PROPOSED / PLACEHOLDER]** — Earth-analog; not game-validated |
| > 6 (super-Earth) | > 9.0             | ~98%                            | extreme           | **[PROPOSED / PLACEHOLDER]** — super-Earth magnetosphere model extrapolation |

### 3.3 Magnetic Reconnection Events

Magnetospheric substorms release stored magnetic energy during reconnection events:
```
E_substorm ≈ (4π/3) * R_mp³ * B² / (2μ₀)

Energy flux to upper atmosphere:
  Φ_substorm = E_substorm / (4π * R_p² * Δt)
```

These events produce auroral precipitation that ionizes atmospheric constituents and drives local heating transients relevant to `CelestialBodies::Spheres::Atmosphere` temperature profiles.

---

## 4. Radiation Exposure Dosage for Unshielded Hulls

### 4.1 Background Radiation Environment

The ambient radiation environment around a celestial body combines multiple sources:
```
Φ_total = Φ_solar_wind + Φ_cosmic_rays + Φ_solar_particle_events + Φ_stellar_flare

Background galactic cosmic ray (GCR) flux at 1 AU:
  Φ_GCR ≈ 4.0 particles/(cm²·s·sr)
  Dose_GCR ≈ 0.3–0.5 mSv/day in deep space (unshielded)
```

**Per-Orbital-Distance Flux Scaling:**

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from standard solar system flux models. They have not been validated against game constants or StarSim operational data.

| Quantity | Solar Wind | GCR | Flare Events | CME Events | Grounding |
|----------|-----------|-----|-------------|------------|-----------|
| At HZ inner edge | ×3.0        | ×1.0 | ×4.5       | ×6.0      | **[PROPOSED / PLACEHOLDER]** — flux scaling from standard solar models; not game-validated |
| At HZ (G2)       | 1.0         | 1.0  | 1.0        | 1.0       | Baseline reference point for G2 stars |
| At HZ outer edge | ×0.3        | ×1.0 | ×0.2       | ×0.3      | **[PROPOSED / PLACEHOLDER]** — flux scaling from standard solar models; not game-validated |
| Beyond snow line | ×0.05       | ×1.0 | ×0.01      | ×0.05     | **[PROPOSED / PLACEHOLDER]** — outer system flux estimates; not game-validated |

### 4.2 Hull Material Dose Attenuation

Different hull materials attenuate radiation according to their areal density and atomic number. All attenuation values below are **[PROPOSED / PLACEHOLDER]** estimates derived from nuclear physics reference data, not validated against game material definitions.

```
Dose_after = Dose_before * exp(-ρ * t / λ)

where:
  ρ   = material density (kg/m³)
  t   = thickness (m)
  λ   = attenuation length (depends on radiation type and material composition)
```

**Attenuation Reference Table:**

| Hull Material    | Areal Density (g/cm²) | γ-ray Attenuation (%) | Proton Attenuation (%) | Neutron Shielding (%) | Grounding |
|------------------|----------------------|-----------------------|----------------------|---------------------|-----------|
| Aluminum alloy   | 25                   | ~30%                  | ~60%                 | ~15%                | **[PROPOSED / PLACEHOLDER]** — derived from NIST XCOM attenuation tables; not game-validated |
| Steel composite  | 60                   | ~55%                  | ~85%                 | ~40%                | **[PROPOSED / PLACEHOLDER]** — derived from NIST XCOM attenuation tables; not game-validated |
| Regolith-packed  | 100                  | ~70%                  | ~92%                 | ~75%                | **[PROPOSED / PLACEHOLDER]** — regolith equivalent density estimate; not game-validated |
| Water shielded   | 40 (H₂O)             | ~40%                  | ~80%                 | ~85%                | **[PROPOSED / PLACEHOLDER]** — water shielding data from reactor design references |
| Multi-layer CNT  | 15                   | ~15%                  | ~30%                 | ~10%                | **[PROPOSED / PLACEHOLDER]** — theoretical estimate for layered carbon structures; not game-validated |

### 4.3 Crew & Biological Dose Accumulation

For units with biological components (settlement populations, scientific expeditions). All dose thresholds below are **[PROPOSED / PLACEHOLDER]** values derived from NASA/ICRP radiation protection standards, not game constants.

where W_R is the radiation weighting factor:
  γ-rays:  W_R = 1
  protons: W_R = 2–5 (energy-dependent)
  heavy ions: W_R = 10–20
```

**Career limit thresholds (design baseline):**

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from NASA/ICRP radiation protection standards extrapolated to the game's career timeline. They have not been validated against game constants or any official Galaxy Game design docs.

| Threshold | Value | Grounding |
|-----------|-------|-----------|
| Low orbit  : 600 mSv (3-year career) | **[PROPOSED / PLACEHOLDER]** — NASA LEO career limits; not game-validated |
| Deep space : 1,000 mSv (career) | **[PROPOSED / PLACEHOLDER]** — NASA deep-space career limits; not game-validated |
| Acute onset: > 1,000 mSv → radiation sickness | **[PROPOSED / PLACEHOLDER]** — acute radiation syndrome threshold from medical literature |
| > 4,000 mSv: LD50/60 — lethal without medical intervention | **[PROPOSED / PLACEHOLDER]** — LD50/60 estimate from radiobiology studies |

### 4.4 Electronic Hardening Thresholds

Circuitry and electronic systems degrade under cumulative ionizing dose (TID). All thresholds below are **[PROPOSED / PLACEHOLDER]** figures from electronics radiation tolerance literature, not game constants.

---

## 5. Planetary Protection Containment Protocols (Classes I–V)

### 5.1 Protection Class Framework

The Planetary Protection Class (PPC) framework governs biological contamination risk management across all celestial bodies. Classification is driven by biosphere detection triggers and environmental state assessment — not player preference.

**Classification Authority:** The `PlanetaryProtectionService` (target design intent) evaluates each CelestialBody's Biosphere sphere state post-generation and assigns a class. No current code implements this service.

### 5.2 Class I — Sterile World

**Trigger Criteria:**
- `biosphere.biodiversity_index == 0` AND `biosphere.habitable_ratio < 0.01`
- Or: Biosphere sphere not generated during procedural creation
- No detectable organic molecules, no atmospheric biosignature gases beyond abiotic equilibrium

**Containment Rules:**
- Full extraction permitted without biological restrictions
- Settlement construction allowed on any surface with adequate geosphere features
- No quarantine requirements; bodies classified Class I require NO contamination monitoring
- Atmospheric processing and ISRU operations face no PPC constraints

**Quarantine Enforcement:** None — this is the default state for most procedurally generated terrestrial planets in outer system regions.

### 5.3 Class II — Dormant World

**Trigger Criteria:**
- `biosphere.biodiversity_index > 0` AND `biodiversity_index < 0.05` (trace organics only)
- Abiotic organic synthesis detected (tholins, amino acid precursors, prebiotic chemistry)
- No self-replicating biological activity; biochemical state is purely abiotic

**Containment Rules:**
- Limited surface sampling permitted without sterilization protocols
- Settlement construction allowed but must maintain 1 km minimum distance from organic concentration hotspots
- Atmospheric extraction capped at 2% of atmospheric mass per operational year to prevent disrupting prebiotic equilibrium
- ISRU feedstock qualification requires abiotic contamination screening

**Quarantine Enforcement:** Passive monitoring only — Class II bodies are cataloged in the planetary registry and trigger periodic biosphere re-evaluation on each simulation tick. Contamination from external biological introduction triggers a Class IIA downgrade.

### 5.4 Class III — Regulated World (Microbial Presence)

**Trigger Criteria:**
- `biosphere.has_microbial_life == true` OR `biodiversity_index >= 0.05 AND biodiversity_index < 0.3`
- Self-replicating microbial or single-cell biological activity confirmed
- Atmospheric biosignature gases detected beyond abiotic production (e.g., O₂/CH₄ disequilibrium)

**Containment Rules:**
- All incoming material must pass sterilization verification at ≥121°C for 30 min OR equivalent chemical sterilization
- Extraction capped at 5% of atmospheric/surface mass per operational year to preserve microbial habitat integrity
- Settlement permitted only in pre-approved zones outside core biosphere regions (buffer zone ≥ 50 km from any active biosphere boundary)
- No subsurface drilling within 500 m of any identified microbial concentration

**Quarantine Enforcement:** Active monitoring with automated containment triggers:
- If external contamination detected: body classification auto-upgrades to Class IIIB
- Extraction exceeding cap triggers automated resource node suspension and SDC (Solar Defense Command) notification
- Quarantine violation within 24 hours requires manual override by system administration

### 5.5 Class IV — Protected World (Complex Life Present)

**Trigger Criteria:**
- `biosphere.has_complex_life == true` OR `biodiversity_index >= 0.3`
- Multicellular flora/fauna confirmed through biosphere simulation feedback loops
- Complex biome distribution exceeds threshold with structured trophic layers

**Containment Rules:**
- Full extraction freeze on all resource nodes within the planet's gravity well
- Total settlement ban; only science-only orbital and atmospheric observation platforms permitted
- No material import/export — all craft must maintain sterile integrity (no biological exchange with host system)
- Orbital interdiction enforced by SDC protocol for any vessel approaching < 500 km from planetary surface

**Quarantine Enforcement:** Absolute quarantine with automated interdiction:
- Any extraction attempt triggers immediate resource node lockdown
- SDC orbital interdiction automatically deploys monitoring vessels at all accessible approaches
- Classification downgrade to Class IVB (see below) if complex life status is confirmed during operations
- Violation requires system admin override and generates a governance incident log

### 5.6 Class V — Quarantine World (Active Biological Hazard)

**Trigger Criteria:**
- Biosphere simulation indicates invasive or pathogenic biological activity threatening external ecosystems
- Hostile biochemical states detected (e.g., aggressive biosphere expansion, predatory food chains targeting non-native species)
- Previous contamination event caused irreversible ecological disruption requiring isolation

**Containment Rules:**
- Maximum quarantine — all material, energy, and information exchange prohibited across the body's orbital boundary
- No approach within 2 AU of planetary surface without SDC authorization
- All prior infrastructure on or near the body must be decommissioned or maintained under constant surveillance
- The body is placed under a no-fly zone extending to its Hill sphere boundary

**Quarantine Enforcement:** Total isolation protocol:
- Automated orbital blockade deployed at the system's Lagrange points
- Any approaching vessel triggers automated deflection (delta-v push) away from the quarantine zone
- Classification persists until biosphere stability returns to Class III or below over a minimum of 10 operational years
- Governance override requires multi-node SDC consensus and cannot be unilaterally lifted

### 5.7 Protection Class Transition Matrix

Classification transitions are driven by biosphere state changes during tick-level simulation. All thresholds and triggers below are **[PROPOSED / PLACEHOLDER]** figures derived from NASA Planetary Protection Program guidelines (cosmic safety protocols) extrapolated to the game framework — not validated against game constants or official design documents.

| Current Class | Biosphere Change Trigger | New Class | Auto-Transition? | Grounding |
|---------------|-------------------------|-----------|-----------------|-----------|
| I             | Organic synthesis detected (abiotic) | II | Yes | **[PROPOSED / PLACEHOLDER]** — abiotic organic detection threshold from astrobiology literature |
| II            | Self-replication confirmed | III | Yes | **[PROPOSED / PLACEHOLDER]** — self-replication trigger; conceptually grounded in origin-of-life research |
| III           | Multicellular emergence | IV | Yes | **[PROPOSED / PLACEHOLDER]** — multicellular threshold from Earth evolutionary timeline extrapolation |
| IV            | Biosphere collapse (extinction event) | III | Yes, after 5-year observation | **[PROPOSED / PLACEHOLDER]** — 5-year observation period is synthetic; no architecture backing |
| III/IV        | Invasive species established | V | No (admin override) | **[PROPOSED / PLACEHOLDER]** — invasive threshold from ecological modeling; not game-validated |
| Any           | Terraforming completes biosphere reset | I or II | Admin override only | **[PROPOSED / PLACEHOLDER]** — terraform-triggered reset mechanism is conceptual |

---

## 6. Biological Contamination Risk Thresholds

### 6.1 Cross-Contamination Propagation Model

Biological contamination propagates between celestial bodies through cargo, craft, and atmospheric exchange:
```
R_contam = R_source * P_transport * P_survival * P_establishment

where:
  R_source         = contamination rate at source body (organisms/year)
  P_transport      = survival probability during transit (function of duration, shielding)
  P_survival       = survival probability through target atmospheric entry
  P_establishment  = ecological establishment probability (1 if habitat suitable, 0 otherwise)
```

**Contamination Risk Matrix by Transit Mode:**

> **Note:** The following values are **[PROPOSED / PLACEHOLDER]** figures derived from orbital mechanics and biological survival models. They have not been validated against game constants or StarSim operational data.

| Transit Mode | Typical Duration | P_survival (unshielded) | P_survival (Al hull) | Notes | Grounding |
|-------------|-----------------|------------------------|---------------------|-------|-----------|
| Skimmer     | < 1 day         | ~90%                   | ~85%                | Minimal shielding, short transit | **[PROPOSED / PLACEHOLDER]** — survival model extrapolation from biological desiccation/resistance data |
| Cycler      | 30–200 days     | ~40%                   | ~65%                | Moderate hull protection | **[PROPOSED / PLACEHOLDER]** — multi-day exposure modeling; not game-validated |
| Heavy Tug   | 100–500 days    | ~10%                   | ~35%                | Extended transit, cargo shielding | **[PROPOSED / PLACEHOLDER]** — long-duration exposure model; not game-validated |

### 6.2 Sterilization Protocol Thresholds

All biological material between bodies must meet minimum sterilization standards based on target class. All thresholds below are **[PROPOSED / PLACEHOLDER]** figures derived from NASA Planetary Protection Program guidelines (cosmic safety protocols) extrapolated to the game framework — not validated against game constants.

| Target Class | Minimum Sterilization Standard | Verification Required | Grounding |
|-------------|-------------------------------|----------------------|-----------|
| I           | None                          | None                 | No sterilization required; sterile world |
| II          | ≥ 6 log₁₀ reduction of viable organisms | Spot check (10%)    | **[PROPOSED / PLACEHOLDER]** — NASA Category II sterilization guideline extrapolation |
| III         | ≥ 12 log₁₀ reduction + heat/chemical cert. | Full batch cert.    | **[PROPOSED / PLACEHOLDER]** — NASA Category III sterilization guideline extrapolation |
| IV          | 100% decontamination verified | Triple verification  | **[PROPOSED / PLACEHOLDER]** — NASA Category IV forward-sterilization guideline extrapolation |
| V           | Prohibited                    | N/A                  | No biological exchange permitted; total quarantine |

### 6.3 Contamination Event Detection

The `Biosphere` model's simulation loop includes a contamination detection subroutine:
```ruby
# Target design intent — not implemented in current code
class BiosphereContaminationDetector
  def self.detect(celestial_body, incoming_organism_count, biosphere_state)
    return nil if celestial_body.protection_class == :class_i

    established = (incoming_organism_count > ESTABLISHMENT_THRESHOLD) &&
                  biosphere_state.habitat_suitable?(incoming_species)

    case established
    when true then contamination_event(celestial_body, incoming_species)
    when false then nil  # organisms die during transit/atmospheric entry
    end
  end
end
```

---

## 7. Integration with StarSim Procedural Generation

### 7.1 Protection Class Assignment During System Generation

During `ProceduralGenerator.generate_system_seed`, each generated body receives a biosphere evaluation:
```ruby
# Pseudo-code for class assignment during system generation
def assign_protection_class(celestial_body)
  bio = celestial_body.biosphere
  return :class_i if bio.nil? || bio.biodiversity_index.zero?

  if bio.has_complex_life
    :class_iv
  elsif bio.biodiversity_index >= 0.3
    :class_iv
  elsif bio.has_microbial_life || bio.biodiversity_index >= 0.05
    :class_iii
  elsif bio.biodiversity_index > 0 && bio.biodiversity_index < 0.05
    :class_ii
  else
    :class_i
  end
end
```

### 7.2 Biosphere Complexity Drive

The `biosphere_complexity` parameter in `ProceduralGenerator` directly controls the upper bound of biodiversity_index values assigned. All distributions below are **[PROPOSED / PLACEHOLDER]** figures derived from ecological diversity modeling extrapolated to the game framework — not validated against game constants or architecture specs.

| biosphere_complexity | Biodiversity Index Range | Expected PPC Distribution | Grounding |
|---------------------|-------------------------|---------------------------|-----------|
| :none               | 0                       | 100% Class I             | **[PROPOSED / PLACEHOLDER]** — no biodiversity; all sterile by definition |
| :primitive          | 0–0.04                  | 80% Class I, 20% Class II | **[PROPOSED / PLACEHOLDER]** — low-diversity ecological model extrapolation |
| :auto               | 0–0.3                   | 60% Class I, 25% Class II, 15% Class III | **[PROPOSED / PLACEHOLDER]** — moderate diversity model; not game-validated |
| :complex            | 0–1.0                   | 40% Class I, 30% Class II, 20% Class III, 10% Class IV | **[PROPOSED / PLACEHOLDER]** — high-diversity ecological model extrapolation |

### 7.3 Terraforming Impact on Protection Classification

Terraforming operations that alter biosphere state trigger automatic re-evaluation:
```ruby
# On biosphere update during terraforming simulation
def on_biosphere_terraform_update(celestial_body, new_biodiversity)
  old_class = celestial_body.protection_class
  new_class = assign_protection_class_for_index(new_biodiversity)

  if new_class > old_class  # Classification upgrade (stricter)
    trigger_containment_upgrade(celestial_body, new_class)
  elsif new_class < old_class  # Classification downgrade (relaxation)
    schedule_containment_review(celestial_body, old_class, new_class)
  end
end
```

---

## 8. Missing Hooks & Implementation Status

### 8.1 Current Code Gaps

| Gap | Impact | Target Resolution |
|-----|--------|------------------|
| **No `protection_class` attribute** on CelestialBody or Biosphere models | PPC framework cannot be queried at runtime | Add column + service for assignment during generation |
| **No stellar radiation model** in any active class | Radiation pressure, flare flux, and solar wind erosion not computed | New `Astrophysics::RadiationEnvironment` service |
| **No magnetic shielding computation** | Magnetosphere effects on atmospheric retention unmodeled | Integrate with CelestialBody gravity/density calculations |
| **No radiation dose accumulation** for hull units | Hull degradation under prolonged stellar environments untracked | Add `Hull::RadiationExposureService` |
| **No quarantine enforcement logic** | PPC containment rules exist only as documentation | Implement automated enforcement triggers in tick loop |

### 8.2 Dependencies Between Subsystems

```
StarSim Procedural Generator
    └── CelestialBody Model (gravity, density, atmosphere)
            └── Biosphere Sphere (biodiversity_index, habitable_ratio)
                    ├── Protection Class Assignment Service
                    │       └── Containment Enforcement Triggers
                    └── Contamination Risk Assessment
            └── Atmosphere Sphere
                    └── Solar Wind Erosion Model
                            └── Magnetic Shielding Attenuation
                                    └── Dynamic Magnetopause Calculation
```

---

## 9. References & Governance

**Design Authority:** This document defines target backend simulation behavior for stellar astrophysics and planetary protection enforcement. Mismatches between documentation and implementation are logged as architectural gaps for human review.

**Cross-link:** For StarSim procedural system generation mechanics, see **[StarSim Procedural Generation](../design/starsim_and_protection_classes.md)**.
**Cross-link:** For planetary protection governance hierarchy and SDC oversight protocols, see **[Planetary Protection & Environmental Governance](../infrastructure/planetary_protection_environmental_governance.md)**.
**Cross-link:** For ISRU fabrication chain specifications that interface with protected-class bodies, see **[ISRU Fabrication Chain](../technical/isru_fabrication_chain.md)**.
**Cross-link:** For atmospheric harvesting targets and extraction-rate ceilings constrained by protection classes, see **[Atmospheric Harvesting](../infrastructure/atmospheric_harvesting.md)**.
**Cross-link:** For pre-player-era logistics pipeline transit decay equations that intersect with radiation-exposed hull durability timelines, see **[Pre-Player Era Logistics Pipeline](../infrastructure/pre_player_era_logistics_pipeline.md)**.

---

*Document authored as part of the Galaxy Game wiki governance framework. All content is DESIGN INTENT — no runtime enforcement exists in the codebase as of audit baseline.*
