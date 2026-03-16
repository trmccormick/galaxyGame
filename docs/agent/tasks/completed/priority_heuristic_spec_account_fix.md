# Task: Fix priority_heuristic_spec — settlement.account nil failures
## Priority: High (12 failures in overnight run)
## Root cause: Same pattern as assembly_service_spec fix — settlement.account
  returns nil because no GCC-specific account exists. Fix uses
  find_or_create_for_entity_and_currency with GCC currency instead of
  settlement.account throughout the spec.
## Affected file: spec/services/ai_manager/priority_heuristic_spec.rb
## Pattern: Replace all settlement.account.update!(balance: X) with:
  gcc_currency = Financial::Currency.find_by!(symbol: 'GCC')
  account = Financial::Account.find_or_create_for_entity_and_currency(
    accountable_entity: settlement,
    currency: gcc_currency
  )
  account.update!(balance: X)
## Verify: docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test
  bundle exec rspec spec/services/ai_manager/priority_heuristic_spec.rb
  --format documentation 2>&1 | tail -20'
## Note: This is a systemic issue — has_one :account on BaseSettlement is
  misleading. Settlements are multi-currency. Consider adding a gcc_account
  convenience method. Separate task.
