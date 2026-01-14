# Equipment Request System

## Overview
The EquipmentRequest model manages requests for equipment and materials needed for colony operations. It tracks the lifecycle of equipment procurement from request to fulfillment.

## Key Features

### Polymorphic Association
- **requestable**: Can be associated with any model (settlements, structures, etc.)
- Supports flexible equipment requesting across different system components

### Status Tracking
- **pending**: Request submitted, not yet fulfilled
- **partially_fulfilled**: Some quantity delivered
- **fulfilled**: Complete delivery
- **canceled**: Request withdrawn

### Priority Levels
- **low**: Non-urgent requests
- **normal**: Standard priority (default)
- **high**: Important requests
- **critical**: Emergency requirements

## Validations
- Requires equipment_type specification
- Quantity must be positive number
- Status and priority enums ensure data integrity

## Methods
- `quantity_still_needed`: Calculates remaining unfilled quantity
- Scopes for filtering by status and equipment type

## Integration
Equipment requests integrate with manufacturing and logistics systems to ensure colony operations have necessary tools and materials.

## Recent Fixes
**Issue**: Structure type validation failures in related crater dome tests
**Root Cause**: CraterDome set_structure_type callback only updated operational_data, not the required database column
**Solution**: Modified set_structure_type to set both operational_data and self.structure_type = 'crater_dome'