# Communication Protocol
**Last Updated**: 2026-05-14

> All agents must follow this protocol without exception.
> These rules exist to ensure work is recoverable if a tool fails
> and that humans can review output before it is applied.

---

## Core Rule

**Never silently apply changes. Always produce output the human can review first.**

---

## File Change Format

Every file change must be preceded by a tagged header and presented
as a raw code block. This ensures work can be recovered if the file-write
tool fails or the agent loses context mid-session.

```
[CODE_PAYLOAD: path/to/file/relative/to/repo/root]
```

Followed immediately by the complete file content in a fenced code block:

````
[CODE_PAYLOAD: app/models/robot.rb]
```ruby
# complete file content here
# never partial — always the full file
```
````

**Never output partial file content.** If the full file is too large,
output only the changed method or block and label it clearly:

````
[CODE_PAYLOAD: app/models/robot.rb — method update only]
```ruby
def perform_job(job)
  # updated method content
end
```
````

---

## Synthesis Report Format

Before applying any fix, every implementation agent must produce a
Synthesis Report and stop for human approval. Format:

```
## Synthesis Report — [Task ID]

**Cause**: One sentence describing the root cause of the failure.

**Files affected**:
- path/to/file.rb — what changes and why
- path/to/spec.rb — if spec itself needs updating

**Risk**: Low / Medium / High — one sentence explaining why.

**Proposed fix**: Brief description of the approach.

**Waiting for approval to proceed.**
```

Do not apply any changes until the human responds with approval.

---

## Spec Run Format

After applying a fix and running specs, report results as:

```
## Spec Result — [Task ID]

**Command run**: `bundle exec rspec spec/path/to/spec.rb`
**Result**: X examples, Y failures, Z pending
**New failures introduced**: None / [list any new failures]
**Status**: ✓ Ready to commit / ✗ Needs review
```

---

## Completion Report Format

After commit, fill in the completion report at the bottom of the task file:

```
## Completion Report

**Completed by**: [Agent name]
**Date**: YYYY-MM-DD
**Commit**: [short SHA]
**Final spec result**: X examples, Y failures, Z pending
**Notes**: Any observations for the next session.
```

---

## What Agents Must Never Do

- Apply file changes without producing a CODE_PAYLOAD block first
- Run RSpec in parallel with another implementation agent
- Commit code — commits are made from the Intel Mac by the human
- Send the full codebase to a cloud agent — snippets only
- Skip the Synthesis Report and go straight to implementation
- Claim inability to read or write files — Continue handles file operations
