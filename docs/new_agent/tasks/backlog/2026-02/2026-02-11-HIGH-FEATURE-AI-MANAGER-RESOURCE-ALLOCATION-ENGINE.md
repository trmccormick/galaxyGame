---
status: SPRINT_READY
priority: HIGH
type: feature
system_domain: AI_MANAGER | MANUFACTURING
mvp_alignment: AI_MANAGER_LUNA_SETTLEMENT | ISRU_PRODUCTION
local_worker_safe: true
---

# TASK: Implement the Resource Allocation Engine
**Status**: SPRINT_READY
**Priority**: HIGH
**Type**: feature
**Created**: 2026-02-11
**Last Updated**: 2026-05-16

---

## Local Worker Triage Report
- **Template Conformance**: PASS
- **Docker Wrapper Check**: PASS
- **MVP Alignment**: VALID
- **Action Line**: READY FOR CLOUD HANDOFF / IMPLEMENTATION DESIGN LOCKED

---

## Context & Critical Domain Rules
The AI Manager module requires a unified, testable Rails Service Object (`AiManager::ResourceAllocator`) to efficiently route materials between local storage depots and active panel construction zones without manual direct database queries.

When implementing, the agent must embed these three industrial loop rules:
1. **Market vs. Build Thresholds**: Evaluate if it is more cost-effective to buy raw materials off the market (accounting for SCC Surcharge, Broker Fees, and Sales Tax) or route materials to build local extraction units. [cite: 2026-02-24, 2026-02-26]
2. **Transit Loss Rates**: Calculations must factor in systemic loss rates during resource handling and transport. [cite: 2026-02-03]
3. **Luna Pattern Priority**: Staging must favor using local resources to build local orbital or L1-style depots first, harvesting local assets before attempting to allocate imported materials. [cite: 2026-01-08]

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/resource_allocator.rb` | Handle allocation math & logic execution | `def allocate_resources` |
| `app/models/inventory_ledger.rb` | Model storing resource ledger data | `has_many :allocations` association |
| `app/models/allocation.rb` | Allocation data records | Model associations |
| `spec/services/ai_manager/resource_allocator_spec.rb` | Test suite for verification | Validate loss, market, and Luna priorities |

---

## Implementation Blueprint Reference

### Step 1 — Resource Allocator Service Blueprint
Implement the service skeleton to catch loss rates, check local compliance, and calculate market fallbacks:

```ruby
module AiManager
  class ResourceAllocator
    DEFAULT_LOSS_RATE = 0.05 # 5% baseline transport loss

    def initialize(inventory_ledger)
      @inventory_ledger = inventory_ledger
    end

    def allocate_resources(destination_type:, required_materials: {})
      allocations = []

      required_materials.each do |material, amount_needed|
        gross_amount = calculate_gross_with_loss(amount_needed)

        # Luna Pattern: Prioritize local stock check
        if local_stock_available?(material, gross_amount)
          allocations << execute_local_allocation(material, gross_amount)
        else
          # Fallback: Evaluate Market vs. Build math
          allocations << handle_supply_fallback(material, gross_amount, destination_type)
        end
      end
      allocations.compact
    end

    private

    def calculate_gross_with_loss(net_amount)
      (net_amount / (1.0 - DEFAULT_LOSS_RATE)).round(4)
    end

    def local_stock_available?(material, amount)
      @inventory_ledger.current_stock_for(material) >= amount
    end

    def execute_local_allocation(material, amount)
      @inventory_ledger.allocations.create!(
        material: material,
        amount: amount,
        source_type: :local_depot,
        status: :allocated
      )
    end

    def handle_supply_fallback(material, amount, destination_type)
      # Evaluate threshold rules (e.g. market purchase vs triggering local infrastructure build order)
    end
  end
end
Step 2 — Model Updates
Ensure associations are declared smoothly:

Ruby
class InventoryLedger < ApplicationRecord
  has_many :allocations, dependent: :destroy

  def current_stock_for(material)
    return 0 unless respond_to?(:material_balances)
    material_balances.fetch(material.to_s, 0)
  end
end
Step 3 — Verification Spec Blueprint
Ruby
require 'rails_helper'

RSpec.describe AiManager::ResourceAllocator, type: :service do
  let(:inventory_ledger) { create(:inventory_ledger) }
  let(:allocator) { described_class.new(inventory_ledger) }

  describe '#allocate_resources' do
    context 'when evaluating the Luna Pattern and Loss Rates' do
      before do
        allow(inventory_ledger).to receive(:current_stock_for).with(:iron).and_return(200)
      end

      it 'factors in systemic transport loss rates correctly' do
        results = allocator.allocate_resources(destination_type: 'Luna_Tube_Base', required_materials: { iron: 100 })
        expect(results.first.amount).to be_within(0.0001).of(105.2632)
      end
    end
  end
end
Verification Command
Bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/resource_allocator_spec.rb 2>&1 | tail -20'

---

### 📋 Updates to pass to Continue

To apply this to the file directly through the agent, you can feed Continue this quick script instruction:

```text
/edit Read the file at `docs/new_agent/tasks/backlog/reorganization attempt 2/2026-02/2026-02-11-HIGH-FEATURE-AI-MANAGER-RESOURCE-ALLOCATION-ENGINE.md` and replace its entire content with the finalized SPRINT_READY task definition containing our specific domain rules (Market vs Build, Loss Rates, and the Luna Pattern) and implementation reference boilerplate.