# AI Manager Escalation System Testing

## Task Overview
Test the implemented AI Manager operational escalation system with expired buy orders.

## Specific Steps
1. Run database migration for ScheduledImports:
   ```
   rails db:migrate
   ```

2. Create test data - expired buy orders (>24 hours old, active status)

3. Trigger escalation check:
   - Call ResourceAcquisitionService.check_expired_orders
   - Verify EscalationService.handle_expired_buy_orders is invoked

4. Test escalation strategies:
   - Special missions for critical resources (oxygen, water, nitrogen)
   - Automated harvesters for locally available materials
   - Scheduled imports as fallback

5. Validate job scheduling:
   - HarvesterCompletionJob enqueues correctly
   - ScheduledImport records created

## Expected Outcome
- Escalation triggers work for expired orders
- Appropriate strategies selected based on material availability
- Jobs scheduled and imports tracked

## Dependencies
- EscalationService implementation completed
- ScheduledImport model and migration ready

## Success Criteria
- Expired orders trigger escalation
- Correct strategy selection (special mission/harvester/import)
- No errors in escalation logic