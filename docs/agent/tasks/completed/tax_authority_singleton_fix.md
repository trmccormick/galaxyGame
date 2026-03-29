# Task: Fix TaxAuthority singleton spec

**Spec**: `spec/models/organizations/tax_authority_spec.rb:19`
**Priority**: MEDIUM  
**Est. time**: 15 minutes  
**Files**: `app/models/organizations/tax_authority.rb`

## Issue
Organizations::TaxAuthority.instance always returns the same single instance

text
Expected: Singleton pattern (`.instance` returns identical object twice)  
Actual: Returns different instances (missing `@@instance` memoization)

## Diagnostic Commands
```bash
docker exec -it web bash -c "grep -n 'def instance\|def self.instance\|@@instance' app/models/organizations/tax_authority.rb"
docker exec -it web bash -c "grep -A5 -B5 'class TaxAuthority' app/models/organizations/tax_authority.rb"
docker exec -it web bash -c "cat spec/models/organizations/tax_authority_spec.rb | grep -A5 -B5 'always returns the same'"
```

## Expected patterns (check these)
1. **Missing singleton**: No `@@instance` class var or `cattr_accessor`
2. **Wrong pattern**: Uses `new` instead of cached instance
3. **Partial**: Has `instance` but returns `self.class.new`

## Surgical Fix Template
```ruby
class << self
  cattr_accessor :instance, default: nil
  
  def instance
    @instance ||= new
  end
end
```

## What NOT to do
- Don't add validations/database calls
- Don't modify other TaxAuthority methods
- Don't change class inheritance

## Verification
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/organizations/tax_authority_spec.rb --format documentation'
Expected: 0 failures

text

## Completion Report Required
Line numbers changed

Before/after instance method

rspec output (full summary line)

Any unexpected failures