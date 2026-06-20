# Escalation Spec Data Flow (Architecture Review)

## 1. Model Associations

- **Settlement**
  - has_one :inventory (polymorphic)
- **Inventory**
  - belongs_to :inventoryable (polymorphic)
  - has_many :items
- **Item**
  - belongs_to :inventory
  - name: string (e.g., 'medicine')
  - amount: integer/float
- **Colony**
  - has_one :inventory
  - has_many :items, through: :inventory

## 2. Test Data Expectations (from escalation_integration_spec.rb)

- **Robot/Harvester**
  - `expect(harvester.operational_data['target_quantity']).to eq(1000)`
  - 3 robots expected in some tests
- **Import**
  - `expect(import.quantity).to eq(500)`
- **Emergency Mission**
  - `expect(mission[:resource_type]).to eq(:medicine)`

## 3. Data Flow Example

1. **Inventory Setup**
   - `settlement.inventory.items.create(name: 'medicine', amount: 10)`
2. **Order Creation**
   - `create(:market_order, resource: 'medicine', quantity: 500, base_settlement: settlement, created_at: 25.hours.ago)`
3. **Escalation Trigger**
   - `AIManager::EscalationService.handle_expired_buy_orders([order])`
4. **Emergency Mission**
   - `AIManager::EscalationService.create_special_mission_for_order(order)`
   - Expects mission for medicine shortage if inventory is empty and order is unfulfilled

## 4. Mapping Summary

- **Item#name** matches **MarketOrder#resource**
- **Item#amount** and **MarketOrder#quantity** are compared in logic/tests
- Emergency mission for medicine is triggered by shortage (no items in inventory, unfulfilled order)
- Test expects 1000 for harvester, 500 for import, and medicine mission for shortage

---

**NO CODE CHANGES — review only.**

---

_This file documents the architecture and data flow for escalation integration specs. Use as a reference for future test/data fixes._
