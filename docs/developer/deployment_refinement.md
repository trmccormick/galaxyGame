# Deployment System Refinement Notes
## For Future Development Sprint

### Core Concepts to Retain
Based on review of DeploymentPreconditions.rb-proposal and DeploymentService.rb-proposal, the following elements remain valuable for future implementation:

#### 1. Precondition Checking Module
- **Modular Design**: Maintain the `DeploymentPreconditions` module structure for reusable precondition checks.
- **Key Methods to Implement**:
  - `robots_available?(location)`: Check for deployment-capable units or capacity at location.
  - `has_sufficient_space?(location, craft)`: Validate space requirements vs. available capacity.
  - Additional checks: atmosphere compatibility, power requirements, terrain suitability.

#### 2. Deployment Service Architecture
- **Transactional Deployment**: Use `ActiveRecord::Base.transaction` for atomic deployment operations.
- **Error Handling**: Comprehensive logging and rollback mechanisms.
- **Integration Points**: Connect with inventory, blueprints, and manufacturing systems.

#### 3. Assembly Integration
- **Replace Outdated References**: Instead of `UnitModuleAssemblyService`, integrate with `Manufacturing::AssemblyService`.
- **Job-Based Assembly**: Align deployment with asynchronous job processing rather than immediate assembly.
- **Blueprint Resolution**: Use existing `Lookup::BlueprintLookupService` for craft specifications.

### Architectural Alignment with Current System
- **Manufacturing Compatibility**: Deployment should trigger or follow manufacturing jobs, not replace them.
- **Economic Integration**: Ensure deployment costs and fees align with the economic loop (NPC pricing, contracts).
- **Model Dependencies**: Verify and implement required associations (e.g., `base_units` on settlements, craft capacity tracking).

### Implementation Priorities
1. **High Priority**: Implement precondition checks with real logic using current model structures.
2. **Medium Priority**: Create deployment service that integrates with `Manufacturing::AssemblyService` job completion.
3. **Low Priority**: Add advanced checks (atmosphere, power) once basic deployment flow is established.

### Potential Conflicts to Resolve
- **Synchronous vs. Asynchronous**: Current manufacturing uses jobs; deployment proposals assume immediate assembly.
- **Inventory Flow**: Clarify how "unassembled crafts" exist in inventory vs. job results.
- **Craft Initialization**: Update craft creation to match current `Craft::BaseCraft` model requirements.

### Testing Considerations
- **Precondition Tests**: Unit tests for each check method with various scenarios.
- **Integration Tests**: End-to-end deployment flows including manufacturing completion.
- **Economic Tests**: Verify costs, fees, and market interactions during deployment.

### Next Steps
- Review current `Manufacturing::AssemblyService` for deployment hooks.
- Define deployment as a post-manufacturing step in job completion.
- Prototype precondition checks against existing settlement and craft models.</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/galaxy_game/deployment_refinement_notes.md