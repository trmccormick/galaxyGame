# Update PLAYER_CONTRACT_SYSTEM.md Documentation

## Task Overview
Document the new AI Manager operational escalation workflow in the system documentation.

## Specific Steps
1. Locate PLAYER_CONTRACT_SYSTEM.md in docs/

2. Add section on "Operational Phase Escalation"
   - Describe 3-tier strategy: Special Missions → Automated Harvesters → Scheduled Imports
   - Include escalation triggers (expired buy orders >24h)
   - Document cost calculations and priority logic

3. Add code examples:
   - EscalationService.handle_expired_buy_orders usage
   - ResourceAcquisitionService.check_expired_orders integration
   - OperationalManager.check_market_escalation

4. Update operational behavior section:
   - Bootstrap vs operational resource management phases
   - Automated fallback mechanisms

## Expected Outcome
- Complete documentation of escalation system
- Clear integration points identified
- Examples for future maintenance

## Dependencies
- Escalation system implementation completed and tested

## Success Criteria
- Documentation accurately reflects implemented behavior
- No gaps in escalation workflow explanation
- Examples are functional and clear