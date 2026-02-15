# EAP Framework & Market Dynamics Integration

**Date:** February 13, 2026
**Priority:** CRITICAL
**Impact:** Affects AI decision-making for Luna colony economics and EVE-like market system

## Executive Summary

The Earth Adjusted Price (EAP) framework must be integrated with the EVE-like market order system and NPC behavior models. Current pricing data underestimates Earth import costs, lacks interplanetary transport routes, and doesn't account for logistics company business models. NPCs need realistic pricing behavior that reflects resource harvesting operations and market stabilization roles.

## Problem Analysis

### Current Issues
1. **Unrealistic Earth Spot Prices**
   - Nitrogen: $0.05/kg (impossible - liquefaction costs alone exceed this)
   - Carbon dioxide: Not defined
   - Methane: Not defined

2. **Missing Transport Infrastructure**
   - No titan_to_luna transport multipliers
   - No venus_to_luna transport multipliers
   - No mars_to_luna transport multipliers

3. **Market System Disconnect**
   - EAP framework not integrated with market orders
   - NPC pricing behavior uses generic markup, not resource-specific economics
   - Missing logistics company service pricing (AstroLift model)

4. **NPC Behavior Gaps**
   - No resource harvesting NPC behavior (Venus CO2, Titan CH4)
   - Missing logistics company economics (transport fees, fuel sales)
   - Market stabilization doesn't account for interplanetary supply chains

## Objectives

1. **Update Earth spot prices** with realistic industrial costs
2. **Add planetary transport routes** for interplanetary logistics
3. **Integrate EAP with market order system** and NPC pricing
4. **Model infrastructure joint ventures** (DC-Logistics partnerships for L1/LEO depots and Ceres extraction)
5. **Model logistics company economics** (AstroLift business model)
6. **Define NPC resource harvesting behavior** for sustainable operations
7. **Validate framework** against market dynamics and space economics

## Success Criteria

- EAP framework accurately reflects real-world space economics
- Market orders reflect realistic supply/demand dynamics
- NPC behavior supports sustainable colony operations
- AI makes informed resource allocation decisions
- Logistics companies have viable business models

## Implementation Phases

### Phase 1: Update Earth Spot Prices (2 hours)
**Objective:** Replace unrealistic prices with industrial reality

**Tasks:**
1. Research current industrial gas prices (N2, CO2, CH4)
2. Update `economic_parameters.yml` earth_spot_prices section
3. Add missing gas commodities (CO2, CH4)
4. Validate against current market data

**Files to Modify:**
- `galaxy_game/config/economic_parameters.yml`

### Phase 2: Add Planetary Transport Routes (3 hours)
**Objective:** Define interplanetary logistics costs

**Tasks:**
1. Calculate distance-based transport multipliers
2. Add titan_to_luna, venus_to_luna, mars_to_luna routes
3. Consider delta-v requirements and fuel costs
4. Update route_modifiers section

**Files to Modify:**
- `galaxy_game/config/economic_parameters.yml`

### Phase 3: Integrate EAP with Market Orders (4 hours)
**Objective:** Connect EAP economics to EVE-like market dynamics

**Tasks:**
1. Update NPC pricing behavior to use EAP costs as baseline
2. Modify `market_listing_service.rb` to incorporate EAP calculations
3. Add market order impact on EAP calculations
4. Model supply/demand effects on pricing

**Files to Modify:**
- `galaxy_game/config/economic_parameters.yml` (NPC behavior section)
- `galaxy_game/app/services/market_listing_service.rb`
- `galaxy_game/app/services/ai_manager/market_stabilization_service.rb`

### Phase 4: Model Infrastructure Joint Ventures (3 hours)
**Objective:** Implement L1/LEO depot economics and DC-logistics partnerships

**Tasks:**
1. Define joint venture ownership models (DC partnerships with logistics companies for L1/LEO and Ceres)
2. Model LEO fuel depot economics and Luna-to-LEO fuel transfer
3. Add Ceres asteroid belt extraction infrastructure
4. Create depot utilization incentives for cost reduction

**Files to Modify:**
- `galaxy_game/config/economic_parameters.yml` (add infrastructure section)
- `galaxy_game/app/services/market_listing_service.rb` (infrastructure services)

**Joint Venture Economics:**
```yaml
infrastructure_ownership:
  l1_depot:
    ownership: "joint_venture"
    partners: ["astrolift", "ldc"]
    revenue_sharing: 0.6  # 60% AstroLift, 40% LDC
    partnership_model:
      astrolift: "logistics_expertise"
      ldc: "lunar_resources"
  leo_depot:
    ownership: "joint_venture" 
    partners: ["astrolift", "ldc"]
    fuel_transfer_efficiency: 0.85  # 85% efficient Luna-LEO transfer
  ceres_extraction:
    ownership: "joint_venture"
    partners: ["astrolift", "mdc"]
    revenue_sharing: 0.6  # 60% AstroLift, 40% MDC
    partnership_model:
      astrolift: "logistics_transport"
      mdc: "asteroid_resources"
```

**Partnership Model:**
- **Universal DC Model**: Shared infrastructure applies to all Development Corporation orbital stations and surface depots across the solar system
- **Logistics Company Contribution**: Transport operations, depot management, infrastructure expertise (AstroLift, Zenith Orbital, Vector Hauling, etc.)
- **Competitive Collaboration**: Even competing logistics companies can co-invest in infrastructure projects while maintaining market competition
- **Shared Infrastructure Model**: Like airlines using the same airports, multiple logistics companies operate from shared facilities at all DC locations
- **Multi-Company Joint Ventures**: Single projects can involve multiple logistics corporations with complementary expertise
- **Commercial Spacecraft Operations**: Companies can build and sell craft at shipyards using local resources to players and other corporations
- **Player Economic Hubs**: All DC stations/depots serve as essential locations for players to sell harvested resources and acquire equipment
- **LDC Contribution**: Lunar resources, infrastructure construction, non-profit expansion focus
- **MDC Contribution**: Asteroid belt resources, mining expertise, belt infrastructure development
- **Mutual Benefits**: All parties profit from joint ventures; DCs sell resources at depots and to logistics partners for operations
- **Shipyard Access**: Logistics companies gain construction capabilities at all DC station/shipyard locations
- **Asteroid Access**: Logistics companies gain asteroid belt resource extraction and processing
- **DC Status**: Non-profit Development Corporations focused on footholds and expansion (not profit maximization)

**LEO Fuel Depot Benefits:**
- **Cost Reduction:** Eliminate fuel lift from Earth's gravity well
- **Onward Journey Support:** Refuel craft for Mars/Venus/Titan missions
- **Economic Multiplier:** Luna fuel production scales interplanetary operations
- **Infrastructure ROI:** Depot operations fund Mars expansion

### Phase 5: Model Logistics Company Economics (3 hours)
**Objective:** Implement AstroLift business model in market system

**Tasks:**
1. Define service-based pricing for transport operations
2. Add fuel sales markup economics
3. Model maintenance and depot operations
4. Create competitive logistics market dynamics

**Files to Modify:**
- `galaxy_game/config/economic_parameters.yml` (add logistics section)
- `galaxy_game/app/services/market_listing_service.rb`

**Business Model Components:**
```yaml
logistics_services:
  transport_per_kg_km: 0.001  # GCC per kg per km
  fuel_markup: 1.5           # 50% markup on production costs
  maintenance_hourly: 500    # GCC per hour
  depot_storage_daily: 0.1   # GCC per kg per day
```

### Phase 6: Define NPC Resource Harvesting Behavior (3 hours)
**Objective:** Create realistic NPC behavior for resource operations

**Tasks:**
1. Define AstroLift NPC behavior for Venus/Titan harvesters
2. Add LDC NPC behavior for colony resource needs
3. Implement market stabilization for resource shortages
4. Model competitive logistics company dynamics

**Files to Modify:**
- `galaxy_game/app/services/ai_manager/market_stabilization_service.rb`
- `galaxy_game/config/economic_parameters.yml` (NPC behavior enhancement)

**NPC Behavior Models:**

**AstroLift (Logistics Company):**
- **Buy Orders:** H2 feedstock, maintenance supplies, fuel for operations
- **Sell Orders:** Venus CO2 ($0.15/kg), Titan CH4 ($2.53/kg), O2 ($5/kg)
- **Services:** Transport contracts, fuel sales, maintenance

**LDC (Development Corp):**
- **Buy Orders:** O2, CH4, CO2 for operations and production
- **Sell Orders:** Manufactured goods, refined materials
- **Operations:** Colony infrastructure, resource processing

**Market Stabilization NPC:**
- **Interventions:** Buy unsold goods, sell essentials during shortages
- **Stabilization:** Import critical resources, stabilize prices
- **Backup:** Ensure colony survival during supply disruptions

### Phase 7: Framework Validation and Testing (3 hours)
**Objective:** Ensure economic models work with market dynamics

**Tasks:**
1. Test NPC order placement and fulfillment
2. Validate market price stabilization
3. Test AI decision-making with integrated economics
4. Document NPC behavior patterns

**Testing Scenarios:**
- Resource shortage response
- Price stabilization effectiveness
- Logistics company profitability
- Player market participation

## Dependencies

- Requires operational market order system
- Needs existing NPC pricing code integration
- Depends on planetary resource data
- Requires transport route calculations

## Risk Assessment

**High Risk:** Incorrect NPC pricing could break market dynamics
**Medium Risk:** Missing transport routes could create arbitrage opportunities
**Low Risk:** NPC behavior can be iteratively refined

## Timeline

- **Phase 1:** 2 hours (immediate - pricing data readily available)
- **Phase 2:** 3 hours (requires orbital mechanics research)
- **Phase 3:** 4 hours (complex market integration)
- **Phase 4:** 3 hours (infrastructure joint venture modeling)
- **Phase 5:** 3 hours (business model implementation)
- **Phase 6:** 3 hours (NPC behavior modeling)
- **Phase 7:** 3 hours (validation and testing)

**Total Estimate:** 21 hours
**Priority Justification:** Critical for Luna colony economic viability and market system functionality

## Success Metrics

1. **Pricing Accuracy:** Earth spot prices within 20% of industrial reality
2. **Market Integration:** EAP costs reflected in NPC buy/sell orders
3. **NPC Behavior:** Realistic resource harvesting and service provision
4. **Economic Stability:** Market stabilization prevents extreme price volatility
5. **Business Viability:** Logistics companies can operate profitably

## NPC Behavior Integration

### Resource Harvesting NPCs (AstroLift)
**Market Participation:**
- **Buy Orders:** Place orders for operational resources at EAP + transport costs
- **Sell Orders:** Offer harvested products at production cost + service markup
- **Service Orders:** Transport contracts, maintenance services, depot operations

**Economic Incentives:**
- Profit from fuel sales (Sabatier CH4 at markup)
- Revenue from transport services
- Maintenance contracts for owned craft
- Depot operations at Luna bases

### Development Corporation NPCs (LDC/DC)
**Market Participation:**
- **Buy Orders:** Essential resources for colony operations
- **Sell Orders:** Locally manufactured goods and services
- **Strategic Behavior:** Long-term contracts with logistics companies

**Economic Strategy:**
- Cost-based purchasing with budget constraints
- Sell excess production to fund operations
- Participate in market stabilization when needed

### Market Stabilization NPCs
**Intervention Triggers:**
- Essential item shortages (<10% inventory)
- Extreme price volatility (>50% change in 24 hours)
- New player protection (first 30 days)
- Colony survival threats

**Stabilization Methods:**
- Buy unsold player goods at fair prices
- Sell essential items at cost + minimal markup
- Import critical resources from other settlements
- Coordinate logistics for emergency supply runs

## Next Steps

Begin with Phase 1 (Earth spot prices) as it provides the foundation for market integration. Follow with Phase 3 (market integration) to connect EAP to the existing market order system.</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/critical/eap_market_integration.md