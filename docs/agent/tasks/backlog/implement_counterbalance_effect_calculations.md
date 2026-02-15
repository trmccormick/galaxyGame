# Implement Counterbalance Effect Calculations

## Task Overview
Implement system-specific counterbalance effect calculations that determine wormhole stability and mass limits based on gravitational anchor positioning and system characteristics.

## Background
Our updated wormhole mechanics establish that counterbalance effects determine system stability:
- **Sol System**: Jupiter provides perfect 180° counterbalance (1.0 stability multiplier)
- **Eden System**: Gas Giant 18 positioned opposite but offset (0.6 stability multiplier)
- **Mass Limits**: Base 500k tons × stability multiplier = system-specific limits
- **Strategic Depth**: Counterbalance positioning affects expansion timing and risk

## Requirements

### Phase 1: Counterbalance Physics Engine (Priority: High)
**Gravitational Calculations:**
- Calculate optimal 180° counterbalance positions for gas giants
- Implement offset positioning effects on stability
- Add Hill sphere overlap analysis for anchor effectiveness
- Create stability multiplier algorithms

**System Analysis:**
- Scan celestial bodies for potential anchors (gas giants, brown dwarfs)
- Evaluate anchor mass and positioning relative to wormhole
- Calculate counterbalance effectiveness scores
- Generate system stability profiles

### Phase 2: Mass Limit Integration (Priority: High)
**Dynamic Mass Limits:**
- Base mass limit: 500,000 tons
- Apply stability multipliers per system
- Update wormhole contracts with calculated limits
- Implement real-time mass limit monitoring

**Risk Assessment:**
- Low Risk: < 50% of mass limit
- Moderate Risk: 50-75% of mass limit
- High Risk: 75-90% of mass limit
- Snap Imminent: > 90% of mass limit

### Phase 3: Buildup Rate Analysis (Priority: Medium)
**Strategic Timing:**
- Monitor infrastructure accumulation rates
- Predict snap timing based on current buildup speed
- Provide AI Manager with timing intelligence
- Enable strategic delay vs acceleration decisions

**Economic Impact:**
- Slow buildup extends development timeline
- Fast buildup accelerates toward snap triggers
- Balance expansion speed vs stability risks

### Phase 4: UI Integration (Priority: Medium)
**Admin Dashboard:**
- Display system stability multipliers
- Show current mass accumulation vs limits
- Provide buildup rate projections
- Alert on approaching risk thresholds

**Real-time Monitoring:**
- Live counterbalance effectiveness display
- Mass limit progress bars
- Risk level indicators
- Strategic timing recommendations

## Success Criteria
- Counterbalance effects accurately calculated for all systems
- Mass limits properly adjusted by stability multipliers
- Buildup rate analysis provides strategic intelligence
- Admin interface displays counterbalance and mass data
- AI Manager uses counterbalance data for expansion decisions

## Files to Create/Modify
- `galaxy_game/app/services/wormhole/counterbalance_calculator.rb` (new)
- `galaxy_game/app/models/wormhole_stability_profile.rb` (new)
- `galaxy_game/app/services/ai_manager/mass_limit_monitor.rb` (new)
- `galaxy_game/app/views/admin/wormhole_stability/show.html.erb` (new)
- Update existing wormhole contract generation logic

## Testing Requirements
- Unit tests for counterbalance calculations
- Integration tests with wormhole contracts
- UI tests for admin dashboard components
- Scenario tests for different system configurations

## Dependencies
- Wormhole mechanics implementation
- Celestial body scanning capabilities
- Admin dashboard framework
- AI Manager maturity tracking system

## Risk Assessment
**High Risk**: Complex physics calculations could introduce errors
**Mitigation**: Start with simplified models, validate against known systems

**Medium Risk**: UI integration complexity
**Mitigation**: Build on existing admin dashboard patterns

**Low Risk**: Backward compatibility
**Mitigation**: Maintain existing mass limit defaults during transition</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/implement_counterbalance_effect_calculations.md