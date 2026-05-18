# 2026-04-21-HIGH-BUG-FIX-SETTLEMENT GCC ACCOUNT CONVENIENCE METHOD

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** BUG-FIX
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Task: Add gcc_account convenience method to BaseSettlement
## Priority: Low
## Problem: settlement.account is ambiguous and fragile — returns nil or wrong
  account when multiple currency accounts e...

---

## Original Content

# Task: Add gcc_account convenience method to BaseSettlement
## Priority: Low
## Problem: settlement.account is ambiguous and fragile — returns nil or wrong
  account when multiple currency accounts exist. Specs keep breaking because
  they use settlement.account instead of find_or_create_for_entity_and_currency.
## Fix: Add convenience method to Settlement::BaseSettlement:
  def gcc_account
    Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: self,
      currency: Financial::Currency.find_by!(symbol: 'GCC')
    )
  end
## Also consider: similar method for player model
## Note: Do not remove has_one :account — may be used elsewhere. Just add
  the convenience method alongside it.

