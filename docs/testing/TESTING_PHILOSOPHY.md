# Testing Philosophy

## Overview

Galaxy Game implements a comprehensive testing strategy that balances development velocity, code quality, and system reliability. Our testing philosophy emphasizes prevention over detection, automation over manual processes, and systematic coverage over ad-hoc validation. The grinder protocol serves as our systematic approach to eliminating test failures and maintaining test suite health.

## Testing Pyramid

### Unit Tests (Base Layer - 70% of Tests)
**Purpose**: Validate individual components in isolation
**Scope**: Single classes, methods, and functions
**Characteristics**:
- Fast execution (< 100ms per test)
- No external dependencies (database, network, filesystem)
- Focus on business logic and edge cases
- Extensive use of mocks and stubs

**Best Practices**:
```ruby
# Good: Isolated unit test
describe Financial::Account do
  describe '#transfer_funds' do
    it 'transfers amount between accounts' do
      source = create(:account, balance: 1000)
      destination = create(:account, balance: 500)
      
      source.transfer_funds(300, destination, 'test transfer')
      
      expect(source.balance).to eq(700)
      expect(destination.balance).to eq(800)
    end
  end
end
```

### Integration Tests (Middle Layer - 20% of Tests)
**Purpose**: Validate component interactions and data flow
**Scope**: Multiple classes, database operations, external services
**Characteristics**:
- Medium execution time (100ms - 10s per test)
- Real database connections and external dependencies
- Test complete workflows and system boundaries
- Use of test databases and fixtures

**Best Practices**:
```ruby
# Good: Integration test with real dependencies
describe 'Contract fulfillment workflow' do
  it 'completes contract from creation to settlement' do
    contract = create(:contract, :active)
    supplier = create(:organization, :npc)
    buyer = create(:player)
    
    # Execute contract workflow
    fulfillment_service = Contract::FulfillmentService.new(contract)
    result = fulfillment_service.execute
    
    expect(result.success?).to be true
    expect(contract.status).to eq('completed')
    expect(buyer.account.balance).to be < buyer.account.balance_was
  end
end
```

### Acceptance Tests (Top Layer - 10% of Tests)
**Purpose**: Validate end-to-end user scenarios and business value
**Scope**: Complete user journeys, UI interactions, external integrations
**Characteristics**:
- Slow execution (10s - 60s per test)
- Full system deployment required
- Business-focused scenarios
- Minimal technical assertions

**Best Practices**:
```ruby
# Good: Acceptance test for user journey
feature 'Player establishes lunar colony' do
  scenario 'from contract signing to operational base' do
    given_i_am_a_player_with_funds
    and_there_is_an_available_lunar_contract
    
    when_i_sign_the_contract
    and_the_system_deploys_construction_craft
    and_construction_completes
    
    then_i_should_have_an_operational_lunar_base
    and_my_account_should_reflect_construction_costs
  end
end
```

## Coverage Goals

### Target Metrics
- **Overall Coverage**: > 90% line coverage, > 85% branch coverage
- **Critical Path Coverage**: 100% coverage for financial transactions, contract logic
- **New Code Coverage**: 100% coverage required for all new features
- **Legacy Code Coverage**: Minimum 80% coverage, with targeted improvements

### Coverage Analysis
```ruby
# Coverage configuration in spec_helper.rb
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/db/'
  
  add_group 'Models', 'app/models'
  add_group 'Services', 'app/services'
  add_group 'Controllers', 'app/controllers'
  
  minimum_coverage 90
  minimum_coverage_by_file 80
end
```

### Coverage Exceptions
- **Generated Code**: Scaffolding, migrations, auto-generated files
- **Configuration**: Environment-specific setup code
- **Error Handlers**: Exception paths that are difficult to trigger
- **Performance Optimizations**: Code paths rarely executed in normal operation

## Grinder Protocol: Systematic Test Failure Elimination

### Protocol Overview
The grinder protocol provides a systematic methodology for identifying, analyzing, and fixing test failures. It emphasizes root cause analysis over symptomatic fixes and cascading fix identification.

### Phase 1: Failure Identification
**Objective**: Locate the highest-impact test failures
```bash
# Get latest test results
LATEST_LOG=$(ls -t log/rspec_full_*.log 2>/dev/null | head -n 1)

# Identify highest failure count
TARGET_SPEC=$(grep "rspec ./spec" $LATEST_LOG | \
              awk '{print $2}' | \
              cut -d: -f1 | \
              sort | \
              uniq -c | \
              sort -nr | \
              head -1 | \
              awk '{print $2}')

echo "Next target: $TARGET_SPEC"
```

### Phase 2: Root Cause Analysis
**Objective**: Understand why tests are failing
**Analysis Checklist**:
- [ ] Factory data validity (molar_mass, associations)
- [ ] Schema changes (attribute names, relationships)
- [ ] Mock/stub accuracy (method signatures, return values)
- [ ] Database state (cleaner strategy, transaction isolation)
- [ ] External dependencies (network, filesystem, time)
- [ ] Race conditions (async operations, threading)

**Root Cause Categories**:
1. **Factory Issues**: Invalid test data creation
2. **Schema Drift**: Code/schema mismatches
3. **Mock Problems**: Incorrect test doubles
4. **State Pollution**: Test interference
5. **Environment Issues**: Configuration, dependencies

### Phase 3: Fix Implementation
**Objective**: Apply minimal, targeted fixes
**Fix Hierarchy** (prefer top items):
1. **Factory Updates**: Fix data creation issues
2. **Schema Alignment**: Update code to match schema
3. **Test Corrections**: Fix test logic (last resort)
4. **Environment Fixes**: Address configuration issues

**Cascading Fix Detection**:
```ruby
# After fixing one spec, check for cascade effects
run_in_terminal "bundle exec rspec ./spec --format progress"
# Look for reduced failure counts in related areas
```

### Phase 4: Verification and Documentation
**Objective**: Ensure fixes are complete and documented
```ruby
# Full verification
run_in_terminal "bundle exec rspec $TARGET_SPEC --format documentation"

# Check for regressions
run_in_terminal "bundle exec rspec ./spec/systems/ --format progress"

# Document findings
update_synthesis_report "Fixed $TARGET_SPEC: $ROOT_CAUSE -> $SOLUTION"
```

### Grinder Protocol Best Practices

#### Fix Prioritization
- **High Impact First**: Target specs with >20 failures
- **Root Cause Focus**: Address underlying issues, not symptoms
- **Cascade Exploitation**: One fix often resolves multiple specs
- **Atomic Commits**: Code + documentation together

#### Common Patterns
- **Gas Factory Fixes**: Update molar_mass values for atmospheric gases
- **Account References**: Use :financial_account over :account
- **Schema Updates**: Align code with database changes
- **Cleaner Strategy**: Switch to :deletion for deadlock prevention

#### Success Metrics
- **Failure Reduction**: >80% reduction in targeted spec failures
- **Cascade Effects**: 2-5x additional specs fixed per root cause fix
- **Time Efficiency**: <30 minutes per spec fix cycle
- **Documentation**: 100% of fixes documented with root cause

## Test Data Management

### Factory Patterns
**Purpose**: Consistent, realistic test data creation
```ruby
# Good: Comprehensive factory with traits
FactoryBot.define do
  factory :gas do
    name { 'Nitrogen' }
    formula { 'N2' }
    
    trait :n2 do
      name { 'Nitrogen' }
      formula { 'N2' }
      molar_mass { 28.02 }
    end
    
    trait :o2 do
      name { 'Oxygen' }
      formula { 'O2' }
      molar_mass { 32.0 }
    end
  end
end
```

### Fixture Strategy
- **Minimal Fixtures**: Use factories for most test data
- **Shared Fixtures**: Celestial bodies, materials (rarely change)
- **Generated Data**: Create test-specific data in test setup
- **Cleanup Strategy**: DatabaseCleaner with :deletion strategy

## Continuous Integration

### CI Pipeline Requirements
- **Fast Feedback**: Unit tests run on every commit
- **Full Suite**: Complete test suite runs nightly
- **Coverage Reporting**: Automated coverage analysis and reporting
- **Failure Alerts**: Immediate notification of test failures

### Branch Protection
- **Required Reviews**: All PRs require code review
- **Status Checks**: Tests must pass before merge
- **Coverage Gates**: Minimum coverage requirements
- **Grinder Protocol**: Major failures require grinder analysis

## Test Organization

### Directory Structure
```
spec/
├── models/           # Unit tests for models
├── services/         # Unit/integration tests for services
├── controllers/      # Integration tests for controllers
├── features/         # Acceptance tests
├── support/          # Shared test code
├── factories/        # FactoryBot definitions
└── fixtures/         # Static test data
```

### Naming Conventions
- **Describe Blocks**: Use descriptive names, not class names
- **Context Blocks**: Group related scenarios
- **It Blocks**: Start with "should" or describe expected behavior
- **Test Files**: Match class/file names with _spec.rb suffix

## Performance Testing

### Load Testing
- **API Endpoints**: 1000+ concurrent requests
- **Database Operations**: High-volume transaction processing
- **AI Services**: Complex mission planning under load

### Performance Benchmarks
- **Test Execution**: < 10 minutes for full suite
- **Individual Tests**: < 1 second average execution time
- **Memory Usage**: < 2GB peak during test runs
- **Database Connections**: Efficient connection pooling

## Future Testing Enhancements

### Planned Improvements
- **Property-Based Testing**: Generate test cases from specifications
- **Mutation Testing**: Validate test suite effectiveness
- **Visual Testing**: UI component validation
- **Performance Regression**: Automated performance monitoring

### Research Areas
- **AI-Assisted Testing**: ML-based test case generation
- **Chaos Engineering**: System resilience testing
- **Contract Testing**: API boundary validation
- **Security Testing**: Automated vulnerability assessment