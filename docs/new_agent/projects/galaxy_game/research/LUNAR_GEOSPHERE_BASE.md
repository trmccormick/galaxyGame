# Lunar Geosphere Baseline

## Primary Lunar Resources
- **Depleted Regolith** (Primary Mass) - Anorthositic lunar soil, primary construction material
- **Iron** (Additive) - Extracted from regolith for metallurgical processes

## Shackleton Crater Mining Statistics

### Site Characteristics
- **Location**: Lunar South Pole (-89.9°S, 0°E)
- **Diameter**: 21 km
- **Depth**: 4.2 km rim height
- **Permanently Shadowed Regions**: ~10-15% of crater floor maintains <100K temperatures
- **Peak Illumination**: Rim areas receive near-constant sunlight (89% of lunar day)

### Resource Deposits
- **Water Ice**: 1-5% by mass in permanently shadowed regions (PSRs)
  - Total estimated mass: 10^9 - 10^10 kg in Shackleton deposits
  - Distribution: Concentrated in cold traps (<110K)
- **Regolith Volatiles**:
  - H₂O: 100-500 ppm in sunlit regolith
  - CO₂: 10-50 ppm
  - H₂: 10-30 ppm
  - He³: 5-15 ppm (solar wind implant)
- **Iron Content**: 5-15% FeO in regolith
  - Oxide form: Magnetite (Fe₃O₄), Hematite (Fe₂O₃)
  - Metallic iron: <1% (solar wind reduction)

### Mining Operations Parameters

#### Extraction Rates (Early-Stage ISRU)
- **Regolith Harvesting**: 100-500 kg/hour per mining unit
- **Water Ice Extraction**: 10-50 kg/hour from concentrated deposits
- **Iron Recovery**: 5-25 kg/hour from processed regolith
- **Helium-3 Harvesting**: 0.1-0.5 kg/hour from surface scraping

#### Processing Efficiencies
- **Thermal Extraction**: 70-85% volatile recovery from heated regolith
- **Electrochemical Reduction**: 60-80% iron yield from oxides
- **Cryogenic Distillation**: 90-95% water purity from ice deposits

## Expected Loss Rate (Early-stage Sourcing)
- **15% loss rate** applies to all early-stage sourcing of iron and silicates
- **Input → Output calculation**:
  - 100 units regolith input → 85 units usable regolith output
  - 100 units iron ore input → 85 units usable iron output
- **Loss mechanisms**:
  - Processing inefficiencies (8%)
  - Material handling losses (4%)
  - Equipment contamination (3%)

## Market Gaps
- **Venusian CNTs** (carbon nanotubes, powder or fiber) required for advanced ship and station components
- **Rare Earth Elements** from lunar KREEP terranes for electronics manufacturing
- **High-purity Silica** for optical and semiconductor applications

## Economic Integration

### GCC Currency Peg
- **1:1 USD/GCC parity** maintained across all lunar operations
- **No conversion logic required** - direct equivalence simplifies accounting
- **Transaction costs**:
  - SCC Surcharge: 0.5% on all Trading PLEX transactions
  - Broker Fee: 0.3% on all Trading PLEX transactions
  - Sales Tax: 3.37% on all Trading PLEX transactions

### Resource Valuation (GCC per kg)
- **Water Ice**: 50-100 GCC/kg (varies by purity and delivery terms)
- **Liquid Oxygen**: 10-20 GCC/kg
- **Iron**: 5-15 GCC/kg (refined ingot)
- **Helium-3**: 5000-10000 GCC/kg
- **Regolith**: 0.1-0.5 GCC/kg (processed construction material)

### Production Scaling
- **Phase 1** (Bootstrap): 100-500 kg/day total output
- **Phase 2** (Expansion): 1-5 tonnes/day
- **Phase 3** (Industrial): 10-50 tonnes/day
- **Break-even timeline**: 6-12 months from initial deployment

## Technical Considerations

### Power Requirements
- **Solar**: Primary power source (rim placement for 89% uptime)
- **Nuclear**: Backup for lunar night (14 Earth days)
- **Power density**: 50-100 W/kg for ISRU equipment

### Environmental Factors
- **Temperature extremes**: 100K to 400K across site
- **Radiation**: 0.5-1.0 Sv/year (requires shielding)
- **Dust**: Electrostatic adhesion requires mitigation
- **Micrometeorite flux**: 1-10 impacts/m²/year

### Infrastructure Requirements
- **Mining units**: Robotic excavators and processors
- **Storage**: Cryogenic tanks for volatiles, ambient for solids
- **Transportation**: Surface rovers and hopper systems
- **Power distribution**: Wireless beaming from solar arrays

## Habitat Infrastructure

### Population Capacity Only
- **Habitat units expose population_capacity** from `operational_data` JSON files
- **Population capacity = number of beds** (sleeping accommodations)
- **No resource production logic** in Habitat units
- **No Resource.consume/Resource.produce calls** - these are dead code
- **Population management delegated** to Settlement and Craft concerns

### Life Support Integration
- **Basic needs defined in game constants**, not unit classes:
  - Consumption per person per day: food, water, O₂
  - Waste per person per day: CO₂, wastewater, biowaste
- **Services calculate and adjust settlement inventory** automatically
- **Habitat contributes population_capacity only**
- **No direct inventory calculations** in Habitat units

### Lunar Habitat Specifications
- **Pressurized volume**: 500-2000 m³ per habitat module
- **Population density**: 2-4 people per 100 m³ (including life support)
- **Radiation shielding**: 5-10 g/cm² regolith coverage minimum
- **Thermal control**: Active heating/cooling systems required
- **Power requirements**: 5-15 kW per module (continuous)

## Financial Considerations

- **No conflicts** with 1:1 USD/GCC peg logic - all pricing denominated in GCC
- **Cost recovery** through resource sales and settlement services
- **Investment horizon**: 5-10 year ROI on lunar infrastructure
- **Risk factors**: Equipment failure, dust contamination, power interruptions