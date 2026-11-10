# Atmospheric Escape, Retention & Recovery

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-10  
> *Audit Summary:* Not yet verified against code. Only points marked ESTABLISHED INTENT were stated by the owner.

> **Wiki section:** Player / Infrastructure · **Status:** design intent — planetary rates and technology effects require game-specific calibration

## ESTABLISHED INTENT (2026-11-10)

Atmospheric escape is a natural loss of planetary material and therefore another part of the game's resource economy. It is not a separate pollution, damage, or mandatory terraforming subsystem. The same gas inventories and composition model used by atmospheric harvesting and transfers should represent natural losses and any recovered material.

All planets can lose atmospheric constituents. The mechanisms and rates depend on the body, its atmosphere, gravity, upper-atmosphere conditions, stellar radiation and wind, and magnetic environment. Earth is not a perfectly closed system simply because it has a global magnetic field. Venus has an induced magnetosphere but no intrinsic global dipole. Mars has no present-day global dipole field and experiences solar-wind interaction as well as photochemical escape.

The gameplay opportunity is to let technology change the balance between:
- atmospheric material naturally escaping to space;
- material retained by the planet;
- material deliberately harvested from the atmosphere or upper atmosphere;
- escaping material intercepted and recovered in space; and
- gases replenished through industrial, geological, or imported sources.

This is an additional resource-harvesting and resource-retention path alongside surface mining, subsurface extraction, ice/volatile harvesting, and conventional atmospheric harvesting. It is optional. It must not become a mandatory progression gate or a fixed technology sequence.

## Planetary reference context

These are scientific context, not runtime constants or prescribed game rates. Escape rates vary with solar activity, season, atmospheric state, measurement method, and which processes are included. Particle counts for different species cannot be compared directly without converting by particle mass. Gross ion outflow is also not always equal to net permanent atmospheric loss because some material can be trapped and later returned.

| Body | Present-day context | Gameplay-relevant distinction |
|---|---|---|
| Earth | Hydrogen escapes; oxygen and other ions also flow out through polar/magnetospheric pathways. Some outflow is trapped or returned, so gross outflow must not be mistaken for net loss. | A strong intrinsic magnetic field changes and often limits direct solar-wind erosion, but does not eliminate atmospheric escape. |
| Venus | Hydrogen escapes through photochemical and ion processes. Oxygen and other heavy ions are also removed through solar-wind interaction with the induced magnetosphere and upper atmosphere. | No intrinsic global dipole; its massive CO₂ atmosphere is not being rapidly stripped away today. Hydrogen/water-related loss and ion escape are more relevant than treating the entire CO₂ inventory as quickly depleted. |
| Mars | Present-day escape includes photochemical neutral escape, ion escape, sputtering, and hydrogen-related processes. MAVEN-based estimates put total present-day loss on the order of 1–2 kg/s, with substantial variation by process and solar conditions. | Its weak present-day global magnetic protection and thin atmosphere make solar-wind-driven loss especially relevant. Historical loss over geological time is much larger than the present-day rate. |

Scientific grounding for these distinctions includes the review *Atmospheric Escape Processes and Planetary Atmospheric Evolution* (2020); MAVEN-based estimates summarized by Jakosky et al., *Loss of the Martian atmosphere to space* (2018); Venus Express ion-escape measurements (Fedorov et al. 2011 and subsequent Venus Express studies); and studies of Earth's polar ion outflow and ion return (Seki et al. 2001; Kislyakova et al. 2020). These references describe real planetary processes, not fixed game balance values.

Historical atmospheric loss must be kept separate from the current rate. For example, estimates that Mars lost at least roughly 0.8 bar of CO₂ over its history do not mean it loses that amount at the present-day rate. Likewise, modeled historical escape from early Earth or Venus should not be applied as a modern constant.

## Technology and harvesting opportunities

Technology may create several approaches. These are options to evaluate based on local conditions, available resources, infrastructure, and expected return; they are not approved fixed recipes.

### 1. Atmospheric retention and shielding

Planetary or orbital infrastructure could reduce some escape mechanisms by changing the body's interaction with stellar wind and energetic particles. An artificial magnetic shield is one proposed example, including concepts positioned upstream near a star–planet Lagrange region.

A shield must not be modeled as a universal switch that stops all atmospheric loss. Its effectiveness depends on field geometry, stellar-wind conditions, ionosphere response, and the escape mechanism. Magnetic fields can also channel energy into ion outflow, so the net effect must be represented conservatively and based on the technology's modeled capability.

### 2. Upper-atmosphere and exosphere harvesting

Specialized orbital or high-altitude equipment could attempt to collect useful atmospheric constituents before they escape. This is distinct from skimming dense lower-atmosphere gas: the accessible material, density, particle charge, collection method, and throughput are different.

Collection should transfer only the mass actually captured into craft or facility inventory. Do not treat all particles observed escaping as readily recoverable, and do not assume capture is energetically or economically worthwhile.

### 3. Orbital interception and recovery

Orbital infrastructure may be able to intercept a fraction of escaping neutral or charged material, process it, and store usable constituents. Magnetic or electrostatic collection is a possible high-technology direction for charged particles. This is speculative engineering and should remain an optional technology path until a credible implementation and cost model are established.

Recovered material becomes inventory at the collecting facility. It does not automatically return to the planet's atmosphere.

### 4. Monitoring and adaptive management

Orbital sensors and atmospheric observations can estimate composition, escape trends, and stellar-weather effects. The AI Manager can use these estimates to compare the value of retention infrastructure, direct harvesting, orbital recovery, replenishment, or importing resources.

The AI Manager should evaluate these as alternative or complementary approaches rather than follow a scripted sequence. A planet with abundant accessible gas may favor conventional atmospheric harvesting; a resource-poor or valuable atmosphere may justify retention or recovery infrastructure.

## Simulation intent

Reuse the existing atmospheric gas model and gas-transfer/accounting paths. This design does not call for a separate atmospheric-loss inventory or particle-by-particle simulation.

At the appropriate simulation interval:
1. Estimate natural loss by relevant gas species using a simplified body/environment profile.
2. Remove that mass from the existing atmospheric gas quantities.
3. Apply any supported retention technology as a modifier to the relevant loss mechanisms, not as an arbitrary global percentage applied to every gas.
4. If a harvesting facility captures material, transfer the captured mass into its existing storage/inventory path and account for collection efficiency and operating cost.
5. Let the existing composition, pressure, and atmospheric calculations reflect the changed gas quantities.

Keep the model proportionate to gameplay importance. A periodic aggregate adjustment is sufficient; detailed plasma physics, individual particle tracking, and high-frequency atmospheric fluid dynamics are out of scope. Solar activity may modulate losses at a coarse level if the simulation already represents or can reasonably expose that environmental input.

Local operational emissions and natural escape are separate causes that affect the same atmosphere. Emissions add gas where released; natural escape removes gas from the planetary atmosphere. Recovered escaping material goes to facility inventory. Do not assume instantaneous planet-wide mixing unless that is how the existing atmosphere model works.

## Open implementation questions

- Which atmospheric gas quantities and update methods are authoritative in the current code?
- Does the active simulation already model any atmospheric escape, stellar-wind forcing, magnetic protection, or return of escaping ions?
- What is the smallest useful species-dependent loss model supported by current body and star data?
- Which technology effects can be represented with existing properties or infrastructure capabilities?
- Can an existing harvester/storage/transfer path represent upper-atmosphere or exosphere recovery without creating a parallel inventory system?
- What simulation interval and rate calibration keep the effect meaningful without making it computationally expensive?

Do not invent fixed loss rates or technology effectiveness values to close these questions. Treat scientific measurements as calibration references, not direct game constants. Any implementation should be checked against current code and tested for constituent mass balance, stable long-term behavior, and technology effects.

## Related wiki pages

- [Atmospheric harvesting](atmospheric_harvesting.md) — conventional harvesting from planetary atmospheres.
- [Skimmers & mixed volatiles](../logistics/skimmer_and_mixed_volatiles.md) — atmospheric intake, processing, exhaust, and gas cargo accounting.
- [Terraforming options](terraforming_options.md) — planetary atmosphere development and alternative terraforming approaches.
