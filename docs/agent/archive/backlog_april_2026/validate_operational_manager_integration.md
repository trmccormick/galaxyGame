# OperationalManager Escalation Integration

## Task Overview
Verify that OperationalManager properly integrates escalation checks into decision cycles.

## Specific Steps
1. Test OperationalManager.make_decision includes check_market_escalation

2. Create scenario with expired buy orders

3. Run OperationalManager decision cycle

4. Verify:
   - check_market_escalation called
   - EscalationService triggered
   - Proper error handling and logging

5. Test multiple decision cycles to ensure consistent behavior

## Expected Outcome
- Escalation checks run during normal AI decision cycles
- No performance impact on decision making
- Proper error isolation (escalation failures don't break decisions)

## Dependencies
- OperationalManager updated with check_market_escalation
- EscalationService tested separately

## Success Criteria
- Escalation integrated into decision flow
- Logging shows escalation activity
- No decision cycle failures due to escalation