# Contributor Guide — Phase 4 Wiki

**Created**: 2026-07-16  
**Purpose**: How future documentation should be organized, named, and maintained to prevent future documentation drift.

---

## How to Use This Guide

This guide is for:
- **New contributors** who need to understand where documentation lives
- **Existing contributors** adding new documentation
- **AI agents** generating or updating documentation
- **Project maintainers** reviewing documentation changes

Read this before creating, modifying, or archiving any documentation.

---

## Documentation Organization Philosophy

### Organize by Game Concept, Not Code Structure

✅ **Correct**: `docs/economy/pricing.md` — "How pricing works"  
❌ **Wrong**: `docs/architecture/economy/pricing.md` — "How the economy subsystem is coded"

The wiki describes **what the game is**, not **how the codebase is structured**.

### One Canonical Page Per Topic

Each major topic has ONE authoritative page. All other pages on that topic link to it.

✅ **Correct**: ECONOMY_OVERVIEW is the canonical economy page; PRICING links to it  
❌ **Wrong**: Two equally-weighted economy pages with no hierarchy

### Distinguish Active from Historical

- **Active docs** live in the wiki structure (12 sections)
- **Historical docs** live in `docs/archive/`
- **Status reports, execution plans, agent handoffs** are ephemeral — archive after use

---

## Where New Pages Belong

### Quick Reference: Which Section?

| Your Topic Goes In | Section Number |
|---------------------|---------------|
| What is Galaxy Game? Why does it exist? | 1. Vision |
| Story, narrative, acts, timeline | 2. Story & Timeline |
| Sol system, Eden, planets, stars, wormholes | 3. Universe |
| StarSim, TerraSim, spheres, biomes, terraforming | 4. Simulation |
| Currency, markets, trading, NPC economy, contracts, pricing | 5. Economy |
| Resources, ISRU, blueprints, construction, tech levels, manufacturing | 6. Manufacturing |
| Colonies, settlements, structures, worldhouses, orbital depots | 7. Settlements |
| Craft, stations, depots, shipyards, cyclers, logistics | 8. Transportation |
| AI Manager architecture, subsystems, service portfolio | 9. AI Manager |
| Planetary gameplay, orbital gameplay, industry, mining, trading, terraforming, exploration | 10. Gameplay |
| Architecture, coding standards, JSON standards, development phases, testing, AI workflow | 11. Development |
| Glossary, terminology, game constants, resource lists, blueprint index, schemas | 12. Reference |

### If You're Unsure

Ask: "What does a player or contributor need to understand about this topic?"

- If it's about **how the game works** → Simulation, Economy, Manufacturing, Settlements, Transportation
- If it's about **what the game is** → Vision, Story, Universe
- If it's about **how to play** → Gameplay
- If it's about **how to build** → Development
- If it's a **reference lookup** → Reference

---

## Naming Conventions

### File Names

Use `snake_case` with descriptive names:

✅ **Correct**: `economy/pricing.md`, `simulation/biome_system.md`  
❌ **Wrong**: `Economy/Pricing.md`, `simulation/biomeSystem.md`

### Page Titles

Use title case in the document heading:

```markdown
# Pricing System

The pricing system determines...
```

### Section Headers

Use consistent header hierarchy within each page:

```markdown
# Page Title (h1)

## Overview (h2) — always first section

## Details (h2)

### Sub-topic (h3)

#### Sub-sub-topic (h4) — rarely needed
```

### Link Paths

Use relative paths from the wiki root:

```markdown
[Topic Name](../economy/pricing)
[See also: Glossary](../../reference/glossary)
```

---

## Creating a New Wiki Page

### Step 1: Determine If It Already Exists

Check the CANONICAL_DOCUMENT_INDEX.md in this directory. If a canonical page exists for your topic, contribute to it instead of creating a new page.

### Step 2: Choose Your Section

Use the table above to determine which section your page belongs in.

### Step 3: Create the Page

```markdown
# Page Title

## Overview

Brief description of what this page covers. Links to canonical page.

## Details

Main content goes here.

## See Also

- [Related Topic](../related/topic)
- [Canonical Page](../section/canonical-page)
- [Glossary Term](../../reference/glossary#term)
```

### Step 4: Add Cross-References

Link to:
1. The canonical page for this topic (if different from your page)
2. Related canonical pages in adjacent sections
3. The Glossary for key terms on first use
4. Any supporting pages that provide detailed sub-topic coverage

### Step 5: Update the Canonical Document Index

Add your page to CANONICAL_DOCUMENT_INDEX.md if it's a new canonical topic, or update an existing entry if it supports an existing canonical page.

---

## Modifying Existing Documentation

### When to Modify vs Create New

| Situation | Action |
|-----------|--------|
| Adding detail to an existing topic | Modify the existing page |
| Covering a sub-topic not yet documented | Create a new supporting page |
| Changing a core game concept | Update canonical page + notify maintainers |
| Documenting a new game feature | Create new page in appropriate section |
| Updating outdated content | Modify the existing page; note update date |

### How to Modify

1. **Read the full page** before editing — understand context
2. **Preserve cross-references** — don't remove links to other pages
3. **Update the See Also section** if your changes affect related topics
4. **Add a change note** at the bottom of significant updates:

```markdown
## Change History

- **2026-07-16**: Updated pricing formula per Phase 4 wiki construction (Phase 4)
```

---

## Archiving Documentation

### When to Archive

Archive a document when:
- Its content has been merged into another page
- It's a status report, execution plan, or agent handoff that served its purpose
- It describes development history or prototype exploration
- It's superseded by a canonical wiki page

### How to Archive

1. Move the file to `docs/archive/` (or appropriate subdirectory)
2. Add a redirect comment at the top of the original location:

```markdown
<!-- ARCHIVED: 2026-07-16 (Phase 4) -->
<!-- Content merged into: [Target Page](../../wiki/path) -->
<!-- Original location: docs/... -->
```

3. Update CANONICAL_DOCUMENT_INDEX.md to reflect the merge target

### What NOT to Archive

- Active canonical wiki pages
- Supporting wiki pages that provide useful detail
- Developer constraints (GUARDRAILS.md)
- Testing references (PRACTICAL_TESTING_GUIDE.md)
- Terminology references (GLOSSARY_SYSTEM_MECHANICS.md)

---

## Preventing Documentation Drift

### The Three Rules of Documentation Hygiene

**Rule 1: One canonical page per topic**

If you find two pages covering the same topic, merge them. Keep the more comprehensive one as canonical; archive the other with a redirect.

**Rule 2: Link to canonical pages**

Every supporting page must link to its canonical page at the top. Every canonical page should link to all its supporting pages.

**Rule 3: Archive before you delete**

Never delete documentation without archiving it first. Historical value is unpredictable — a prototype reference today might be essential context tomorrow.

### Regular Maintenance Tasks

| Task | Frequency | Who |
|------|-----------|-----|
| Review new docs for correct section placement | Every PR | Contributor |
| Check for duplicate canonical topics | Monthly | Maintainer |
| Archive superseded documents | Quarterly | Maintainer |
| Update CANONICAL_DOCUMENT_INDEX.md | With each new canonical page | Contributor |
| Verify cross-references are working | Quarterly | Maintainer |

---

## AI Agent Documentation Guidelines

### When AI Generates Documentation

AI agents should follow these rules when generating or modifying documentation:

1. **Follow the section placement table** — don't put economy docs in architecture/
2. **Use snake_case file names** — not PascalCase or camelCase
3. **Include cross-references** — link to canonical pages and glossary terms
4. **Distinguish intent from implementation** — describe what the game does, not how it's coded
5. **Archive ephemeral content** — status reports, execution plans, agent handoffs go to archive/

### What AI Should NOT Do

- ❌ Create new canonical topics without checking CANONICAL_DOCUMENT_INDEX.md first
- ❌ Merge documents without noting the merge target
- ❌ Delete any documentation (archive instead)
- ❌ Change canonical design intent documented in existing pages
- ❌ Introduce new terminology without adding it to the Glossary

---

## Documentation Review Checklist

Before submitting any documentation change, verify:

- [ ] Page is in the correct section (use the table above)
- [ ] File name uses snake_case
- [ ] Page title uses title case
- [ ] Cross-references to canonical pages are included
- [ ] Key terms link to Glossary on first use
- [ ] See Also section is populated with related pages
- [ ] No duplicate content exists (check CANONICAL_DOCUMENT_INDEX.md)
- [ ] If merging, the source has a redirect comment
- [ ] If archiving, the document is moved to docs/archive/
- [ ] Change history note added if this is a significant update

---

## Emergency Procedures

### If You Find Broken Cross-References

1. Note which links are broken
2. Update them to point to the correct canonical page
3. If the target page no longer exists, archive it and update the link to the merge target
4. Report to maintainers for CANONICAL_DOCUMENT_INDEX.md update

### If You Find a Contradiction Between Docs

1. Check CANONICAL_DOCUMENT_INDEX.md for the authoritative page
2. Update the non-authoritative page to reference the canonical one
3. If both claim to be canonical, merge them and keep the more comprehensive as canonical
4. Notify maintainers of the resolution

### If You're Unsure Where Something Belongs

1. Check CANONICAL_DOCUMENT_INDEX.md — it may already exist
2. Ask: "What does a player need to understand about this?"
3. When in doubt, ask a maintainer before creating or moving pages

---

## Quick Reference Card

```
Vision (1)        → What is Galaxy Game? Why does it exist?
Story (2)         → Narrative, acts, timeline, Snap Event
Universe (3)      → Sol, Eden, planets, stars, wormholes
Simulation (4)    → StarSim, TerraSim, spheres, biomes, terraforming
Economy (5)       → Currency, markets, trading, NPC economy, pricing
Manufacturing (6) → Resources, ISRU, blueprints, construction, tech levels
Settlements (7)   → Colonies, settlements, structures, worldhouses, orbital
Transportation (8)→ Craft, stations, depots, cyclers, logistics
AI Manager (9)    → Architecture, subsystems, service portfolio
Gameplay (10)     → Planetary, orbital, industry, mining, trading, terraforming, exploration
Development (11)  → Architecture, standards, phases, testing, AI workflow
Reference (12)    → Glossary, terminology, constants, indices, schemas

Archive → docs/archive/ (ephemeral, historical, superseded)
Index   → CANONICAL_DOCUMENT_INDEX.md
Glossary→ reference/glossary.md
```
