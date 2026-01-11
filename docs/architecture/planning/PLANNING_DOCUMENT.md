# Component Generation System - Planning Document

## Goals
- Auto-generate missing components referenced in higher-level structures
- Maintain gameplay balance with reasonable crafting requirements
- Use a finite set of base materials that players can readily obtain
- Generate both blueprint and operational data for components

## Services Architecture

### 1. Component Resolver Service
- Detects missing components in a craft or structure
- Determines component type (unit, module, material)
- Delegates to specialized generators

### 2. Unit Blueprint Generator
- Generates unit blueprints for specific types (power, electronics, etc.)
- Uses predefined templates based on unit purpose
- Constrains crafting materials to accessible base resources

### 3. Operational Data Generator
- Creates operational data files to match blueprints
- Sets balanced operational properties

### 4. Material Requirements Manager
- Maintains a list of base materials that are harvestable
- Creates sensible material requirements for components
- Ensures crafting depth remains manageable (max 2-3 levels)

## Base Materials List
Limited set of directly harvestable/purchasable materials:
- Metals: iron, aluminum, copper, titanium
- Electronics: circuit_boards, processors, batteries
- Construction: plastics, glass, ceramics, composite_materials
- Resources: water, oxygen, hydrogen, methane

## Implementation Phases
1. Define unit templates for common satellite components
2. Create the ComponentResolver service
3. Implement Unit Blueprint Generator
4. Implement Operational Data Generator
5. Integration testing with satellite construction

## Expected Outcome
- Integration tests automatically create missing components
- Generated components use sensible, obtainable materials
- Players have clear crafting paths without dependency loops