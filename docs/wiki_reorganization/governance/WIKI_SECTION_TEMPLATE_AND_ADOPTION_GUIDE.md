# Galaxy Wiki Reorganization — Section Template and Adoption Guide

Use this exact title unless an established repository naming convention requires a minor formatting adjustment.

---

**Status**: Canonical  
**Last Updated**: 2026-09-15  
**Purpose**: Establish the working documentation-organization standard for all future Galaxy wiki-reorganization domain work.  
**Authority**: Economy is the established source pattern; Transportation is the first normalized example.  
**Scope**: Documentation structure, page ownership, maturity/status labels, evidence presentation, cross-domain linking, and adoption workflow.

---

## 1. Purpose and Authority

This guide governs:

- **Documentation structure** — how domain sections are organized within `wiki_reorganization/`.
- **Page ownership** — which domain section holds canonical authority for a given concept.
- **Maturity/status labels** — the six maturity states that describe where a domain section is in its lifecycle.
- **Evidence presentation** — how to distinguish verified implementation behavior, source evidence, canonical design decisions, and deferred design.
- **Cross-domain linking** — how domains reference each other without duplicating canonical content.
- **Adoption workflow** — the required sequence for moving a domain from discovery through canonical foundation and beyond.

### What This Guide Does NOT Do

This guide does **not**:

- Define gameplay architecture, game-system design, or monetary policy.
- Replace code, tests, source data, task templates, or human design authority.
- Authorize implementation changes of any kind.
- Automatically canonicalize folders that exist.
- Relocate, archive, rename, or delete phase artifacts.
- Update canonical indexes or site maps on its own.
- Decide unresolved game-system, financial, timing, or architecture questions.

### Authority Chain

1. **Economy** is the established source pattern — its structure, metadata conventions, and hub layout define the baseline.
2. **Transportation** is the first normalized cross-domain example — it demonstrates that the Economy pattern applies beyond economy documentation.
3. **Domain-first organization** is the intended final direction — future domains are organized by game-system domain, not by reorganization chronology.
4. **Reorganization phase artifacts** (`phase2_alignment/`, `phase3_alignment/`, `phase4/`, `analysis/`, `inventory/`, `proposals/`) remain transitional or historical evidence until separately dispositioned. Their existence does not establish canonical authority for any domain.

---

## 2. Domain Section Maturity

A domain section progresses through six maturity states. A folder is **not** canonical merely because it exists — canonical status requires explicit approval through the adoption workflow (Section 8).

| State | Purpose | Allowed Content | Prohibited Content | Primary Navigation? |
|---|---|---|---|---|
| **Discovery / Inventory** | Existing material is being located and mapped across the repository. | Inventory lists, evidence catalogs, conflict reports, authority maps, terminology inventories. | Canonical status labels, definitive architecture descriptions, binding decisions. | No — discovery material is transitional evidence. |
| **Proposal / Alignment** | Structure and wording await review before canonical adoption. | Proposed text with options, alignment notes, cross-domain ownership cards, draft GAPS entries. | Canonical status labels, removal of source material, binding implementation claims. | No — proposals are pending approval. |
| **Canonical Foundation** | Core domain definitions are approved and authoritative. | Canonical decisions with explicit evidence boundaries, numbered topic pages (01+), hub README. | Unverified claims presented as settled; content without review/approval. | Yes — this is the primary canonical authority for the domain. |
| **Expanding Canonical Section** | New approved topic pages are added to an established foundation. | Additional numbered canonical pages, cross-links to existing pages, updated documentation map. | Unreviewed content at canonical status; empty placeholder pages. | Yes — expanding pages inherit canonical authority from the foundation review. |
| **Audit / Maintenance** | Existing material is checked for staleness against source evidence. | Audit records, GAPS entries (resolved/active), deprecation/relocation records, updated metadata. | New canonical content without completing the adoption workflow first. | No — audit files are maintenance records, not navigation pages. |
| **Archived Reorganization Evidence** | Historical path to current documentation is preserved for traceability. | Read-only traceability references, phase reports, session artifacts in `reports/`. | Primary navigation role; canonical status labels; active cross-links from canonical pages. | No — archived material is historical, not navigational. |

> **Rule**: Folder existence does not establish canonical authority. Canonical status requires explicit approval through the adoption workflow (Section 8).

---

## 3. Standard Domain Layout

This is the minimum viable layout for any domain section:

```text
wiki_reorganization/[domain]/
├── README.md                          # Domain hub — maps canonical pages, lists key models/services
├── 01-[primary-topic].md              # Numbered canonical pages in logical reading order
├── 02-[secondary-topic].md
├── ...
├── GAPS.md                            # Only when evidence-backed gaps exist
├── AUDIT-[DOMAIN]-DOCS.md             # Only after a domain audit is performed
└── reports/                           # Only when noncanonical session artifacts exist
    └── [report-name].md
```

### Layout Rules

1. **`README.md` is the domain hub.** It maps canonical pages, lists key models/services, and provides cross-domain references. It must NOT duplicate all canonical topic content — it links to them.

2. **Numbered pages are canonical topics in logical reading order.** Pages are zero-padded (`01-`, `02-`, etc.) and follow the domain's natural learning progression.

3. **Do not create empty numbered pages merely to fill sequence numbers.** A page exists only when it has substantive, approved content.

4. **`GAPS.md` is for evidence-backed documentation/implementation-alignment gaps.** It uses structured gap entries (Section 6). If no evidence-backed gaps exist, the file is not created.

5. **Audit files are audit/disposition records, not normal topic pages.** `AUDIT-[DOMAIN]-DOCS.md` documents what was audited, what overlap/redundancy was found, and what actions were taken. It is not a canonical topic page.

6. **Reports live under `reports/` and never compete with root canonical pages.** Reports are noncanonical session artifacts (e.g., foundation reports, alignment sessions). They provide process traceability but have no canonical authority.

7. **A domain may begin with only `README.md` and `01-*.md`.** Maturity determines additional files — GAPS appears when gaps are found; AUDIT appears after an audit is performed; reports appear when session artifacts need preservation.

### Evidence from Established Domains

- **Economy** (`economy/`) follows this layout exactly: README hub, 01–07 numbered canonical pages, GAPS.md with five structured gap entries, AUDIT-ECONOMY-DOCS.md with three-step audit record.
- **Transportation** (`transportation/`) follows the same layout: README hub, 01–02 numbered canonical pages, GAPS.md with three structured gap entries, reports/GCC_WIKI_FOUNDATION_REPORT.md as a session artifact.

---

## 4. Naming, Metadata, and Page Structure

### Filename Conventions

- **Zero-padded two-digit prefixes** for canonical topic pages: `01-`, `02-`, `03-`, etc.
- **Descriptive, lowercase snake_case filenames**: `craft-taxonomy.md`, `currencies-and-accounts.md`.
- **Hub file**: `README.md` (standard Markdown convention).
- **Gap tracking**: `GAPS.md` (uppercase, consistent with Economy/Transportation).
- **Audit files**: `AUDIT-[DOMAIN]-DOCS.md` (uppercase domain placeholder).
- **Report files**: Descriptive lowercase names under `reports/`.

### Standard Canonical Metadata

Every canonical page MUST include:

```markdown
**Status**: Canonical
**Last Updated**: YYYY-MM-DD
```

### Optional Provenance Metadata

When a page supersedes or derives from existing material:

```markdown
**Supersedes**: [path or document]
**Derived from**: [path or document]
```

### Extended Alignment Metadata

For pages with meaningful implementation/design divergence, include extended metadata **in addition to** standard canonical metadata:

```markdown
**Status**: Canonical design decision with implementation-alignment notes
**Scope**: [domain scope]
**Implementation status**: [confirmed / partial / not implemented]
**Decision authority**: [human-design / source-evidence / canonical-decision]
**Last evidence review**: YYYY-MM-DD
**Related pages**: [[cross-links]]
```

> **Note**: Extended metadata is an exception used to preserve alignment clarity, not a replacement for ordinary canonical metadata. Use it only when implementation behavior diverges from documented design and both must remain visible.

### Standard Page Outline

```text
Title and metadata
→ numbered major sections
→ definition/boundary
→ canonical design rules
→ verified source/implementation evidence where relevant
→ implementation-alignment/deferred callouts where needed
→ model/configuration tables where useful
→ See Also
→ Change History
```

### Optional Domain Features

Audience guides, diagrams, code blocks, model tables, and configuration tables are **optional** features justified by domain needs — not universal required boilerplate.

- Economy includes an audience guide (players, administrators, developers) because economic documentation serves three distinct operational roles.
- Transportation does not include an audience guide because its documentation serves a single primary role (craft taxonomy and classification).
- Both are valid. Include optional features only when they serve the domain's actual contributors.

---

## 5. Claim Categories and Evidence Discipline

### Claim Categories

Every claim on a wiki page MUST be categorized into one of these categories:

| Category | Meaning | Example |
|---|---|---|
| **Verified current implementation behavior** | Confirmed by running code, tests, or debugger evidence. | "NpcPriceCalculator.cost_based_bid returns a hash with buy_price and sell_price keys." |
| **Verified source/configuration evidence** | Confirmed by reading source files, configuration, or data manifests — but not confirmed as active runtime behavior. | "economic_parameters.yml contains `currency.usd_to_gcc_peg: 1.0`." |
| **Canonical human design decision** | Approved by human authority as the intended game design. | "GCC is a currency, not a material." |
| **Wiki terminology convention** | Established naming/wording rule for documentation consistency. | "Craft are manufactured mobile vehicles; natural satellites belong to Universe Generation." |
| **Planned implementation** | Documented intent for future work that has not been implemented or verified. | "Phase 2: Soft peg with ±10% fluctuation (exploratory/deferred)." |
| **Deferred future design** | Design decision explicitly marked as deferred — no implementation timeline. | "Halving schedule: TBD." |
| **Conflicting/stale claim** | A claim that conflicts with current evidence or is superseded by newer material. | "AI Manager architecture document describes 8 files while the actual system has 80+." |
| **Unverified/insufficient evidence** | A claim where no sufficient evidence exists — neither source nor design authority confirms it. | "[FILL IN: evidence or decision needed]" |
| **Implementation-alignment gap** | A known divergence between documented design and verified source behavior. | "GCC mining satellite terminology is established, but LDC authorization guard in mining paths is not verified." |

### Evidence Discipline Rules

1. **Code comments are NOT runtime evidence.** Comments document intent, not behavior.
2. **Configuration is NOT active behavior** without a verified consumer (a service or model that reads and acts on it at runtime).
3. **Design intent must NOT overwrite current source behavior.** Both the documented design and the current implementation must be stated visibly.
4. **Current prototype behavior must NOT override approved design policy.** Both the policy and the current evidence must be stated visibly.
5. **Canonical policy and current implementation divergence must both remain visible.** Neither is discarded; both are preserved with clear labels.
6. **Use `[FILL IN: evidence or decision needed]` rather than guessing.** Never invent claims to fill gaps.
7. **Do not call a design decision implemented** without code/test/runtime evidence.
8. **Do not call source inspection a runtime test.** Reading a config file is evidence of configuration, not evidence of active behavior.

### Retired and Deprecated Source Rule

Before citing a source file as current implementation evidence, inspect its file
header and nearby deprecation, retirement, or compatibility annotations.

An explicit `RETIRED`, `DEPRECATED`, `DO NOT USE`, or equivalent marker takes
precedence over inferences drawn from the file's inheritance, associations,
methods, or comments. A retained class may exist only for history, migrations,
compatibility, or reference.

When a retired file names a replacement, independently verify the replacement
before attributing the old class's behavior, ownership, interface, or lifecycle
to it.

---

## 6. Gaps, Audits, Reports, and Review Records

### GAPS.md Entry Template

```markdown
### Gap [Letter]: [Short Title] — [STATUS]

**Description**: [What is missing or misaligned]

**Evidence**:
- [source path/section]
- [additional evidence as needed]

**Impact**: [what is unclear, unsafe, or blocked]

**Backlog Coverage**:
- None identified.
- Draft only — non-dispatched task exists.
- Approved/planned — task exists but is not active.
- Active implementation — only with verified status.
- Resolved — link to acceptance/verification evidence.
```

### Documentation Audit Record Template

```markdown
# [DOMAIN] Documentation Audit Report

**Date**: YYYY-MM-DD
**Auditor**: [Agent/Reviewer name]

## STEP 1 — EXISTING FILES INVENTORY
[Table: file path, primary focus, authority status]

## STEP 2 — OVERLAP & REDUNDANCY ANALYSIS
[High overlap pairs with supersede/deprecate actions]

## STEP 3 — BROKEN LINK CHECK
[Files referencing audited paths and their current status]
```

### Implementation-Alignment Callout Template

> **⚠ Implementation-Alignment Note**: [Description of gap between documented design and verified source behavior. Distinguish: verified current implementation, verified source evidence, canonical human design decision, planned implementation.]

### Deferred/Exploratory Design Callout Template

> **🔸 Deferred Design**: [Description of design decision not yet made. Use `[FILL IN: evidence or decision needed]` rather than guessing.]

### Cross-Domain Ownership/Alignment Card Template

```markdown
### Alignment Card: [Concept Name]

| Field | Value |
|-------|-------|
| **Candidate Primary Owner** | [domain/page] |
| **Candidate Secondary Owner** | [domain/page] |
| **Recommended Primary** | [domain/page] — [reason] |
| **Secondary Summary Scope** | [what the secondary domain summarizes, if anything] |
| **Terminology Consistency** | [confirmed / needs alignment] |
| **Decision Date** | YYYY-MM-DD |
| **Decided By** | [human/Gemini/Claude] |
```

### Review/Disposition Record Template

```markdown
### Disposition [Number]: [Topic]

| Item | Source | Action | Target | Rationale |
|------|--------|--------|--------|-----------|
| [file/page] | [path] | [merge/split/archive/keep] | [target] | [brief reason] |
```

### Source-Evidence Citation Block Template

```markdown
**Evidence**:
- Source: `[file_path:line_or_section]` — [what was verified]
- Confidence: [high/medium/low] — [why this confidence level]
- Category: [verified-current-implementation / verified-source-evidence / canonical-human-design / wiki-terminology-convention / planned-implementation / deferred-future-design / conflicting-stale-claim / unverified-insufficient-evidence / implementation-alignment-gap]
```

### Reports vs. Canonical Authority

Reports and proposals are useful supporting evidence but are **not** canonical authority when a canonical page or approved decision record exists. They provide process traceability (what was done, how it was done) without claiming content authority.

---

## 7. Cross-Domain Ownership and Links

### Governing Rule

> One concept has one primary canonical owner page. Other domains cross-link to that page and summarize only the local operational implication.

### Why This Matters

- **Prevents duplicate canonical definitions** — if two domains both claim authority over the same concept, contributors cannot know which is correct.
- **Reduces maintenance burden** — changes to a concept are made in one place; other domains reference it.
- **Clarifies contributor expectations** — a contributor knows exactly where to find authoritative information about any concept.

### Shared Terms and Glossary

Shared terms (e.g., "GCC," "craft," "satellite") may have a glossary/reference owner for the definition, but each domain page owns its operational rules for that term within the domain's scope.

### Linking Conventions

- Use **relative links** consistently within and between domains: `../economy/02-currencies-and-accounts`.
- Cross-domain links should point to the specific section or page, not just the domain hub.
- When a cross-domain concept is referenced, summarize only the local operational implication — do not repeat the full definition.

### Alignment Card Requirement

When ownership of a concept between two domains is unclear, create an alignment card (Section 6 template) **before** adopting competing canonical wording. The alignment card documents both candidate owners, the recommended primary, and terminology consistency.

### Examples from Established Domains

- **Economy ↔ Transportation**: GCC mining satellite terminology is owned by Transportation (`02-gcc-mining-satellite.md`). Economy pages reference it via cross-link, summarizing only the financing implications (bond model, issuance boundary). No repetition of taxonomy or classification content in Economy.
- **Transportation ↔ Economy**: Currency governance models are defined in Economy (`02-currencies-and-accounts.md`). Transportation's craft taxonomy references them for per-craft currency policy but does not redefine the multi-currency architecture.

---

## 8. Adoption Workflow

Every domain section MUST follow this required sequence when moving from discovery through canonical foundation and beyond:

```text
1. Inventory existing sources and current ownership
2. Extract evidence and terminology
3. Classify claims and identify conflicts
4. Produce an alignment proposal / proposed text
5. Obtain required human, Gemini, and/or Claude/Qwen review
6. Apply bounded approved wiki-only changes
7. Validate links and content preservation
8. Update active canonical index/site map only after normalized review
9. Record gaps, review disposition, and recommended next action
```

### Reviewer Roles

| Role | Responsibility |
|------|---------------|
| **Human** | Game policy, scope, canonical terminology, tradeoffs, and approval of edits. Human authority is final on all game-design and scope decisions. |
| **Gemini** | Documentation structure, terminology consistency, cross-domain ownership alignment, and structural review. Gemini ensures the wiki reads consistently across domains. |
| **Claude/Qwen** | Repository/code/data evidence verification when required. Claude/Qwen confirms what source files, configuration, or data manifests actually contain versus what is claimed. |

### Stage Gate Requirements

- **Before Stage 5 (Review)**: All inventory and classification work must be complete. No canonical claims may be made until review is obtained.
- **Before Stage 6 (Apply Changes)**: Review approval from all required reviewers must be documented.
- **Before Stage 8 (Update Index/Site Map)**: All domain pages must pass the post-edit validation checklist (Section 9).

---

## 9. Checklists

### Pre-Edit Checklist

Before making any changes to a domain section:

- [ ] Existing domain sources inventoried and cataloged.
- [ ] Canonical ownership for each concept checked — no duplicate canonical pages created.
- [ ] Evidence vs. design distinction identified for every claim.
- [ ] Proposed file path matches the domain structure (Section 3).
- [ ] Filename follows zero-padded naming convention (Section 4).
- [ ] Necessary approvals obtained from required reviewers.
- [ ] Cross-links and report/audit placement planned.
- [ ] Gaps recorded where evidence exposes them (using Section 6 template).

### Post-Edit Validation Checklist

After making changes to a domain section:

- [ ] Content preservation checked — no loss of existing information.
- [ ] All links validated — relative links resolve correctly within and across domains.
- [ ] Status/metadata accurate on every modified page.
- [ ] GAPS entries updated where necessary (gaps resolved, new gaps added).
- [ ] Reports separated from canonical pages (reports in `reports/`, not at root).
- [ ] No unsupported runtime claims introduced — all claims categorized per Section 5.
- [ ] Index/site-map update considered only after normalized review (Stage 8 of workflow).
- [ ] Change History updated on every modified page.

---

## 10. Worked Example

The following example shows a hypothetical domain ("Stations") progressing through all maturity states. This is a structural illustration only — no substantive station rules are written, and no Station documentation is created.

### Stage 1: Discovery / Inventory

```
wiki_reorganization/stations/          # Domain folder exists but not yet canonical
├── DISCOVERY-INVENTORY.md             # Inventory of existing station docs across the repo
└── CLAIMS-CLASSIFICATION.md           # Claims classified by category (Section 5)
```

**Actions**: Scan `docs/architecture/`, `phase4/`, source code for all station-related material. Classify each claim. Identify conflicts.

### Stage 2: Proposal / Alignment

```
wiki_reorganization/stations/          # Still not canonical — proposal stage
├── PROPOSED-STRUCTURE.md              # Proposed domain layout and page outline
├── ALIGNMENT-CARD-STATIONS-CRAFT.md   # Cross-domain ownership card (Stations vs. Transportation)
└── PROPOSED-PAGES/                    # Draft proposed text awaiting review
    ├── 01-station-overview.md
    └── 02-station-construction.md
```

**Actions**: Produce proposed pages using the template. Create alignment card if Transportation also claims authority over station-related concepts. Submit for review.

### Stage 3: Review

**Actions**: Human reviews game policy (are stations a settlement type or a transportation node?). Gemini reviews terminology consistency with Transportation and Settlements domains. Claude/Qwen verifies source evidence for any implementation claims.

### Stage 4: Canonical Foundation

```
wiki_reorganization/stations/          # NOW CANONICAL
├── README.md                          # Domain hub — maps canonical pages, key models
├── 01-station-overview.md             # Approved canonical page
└── GAPS.md                            # Gaps found during review (if any)
```

**Actions**: Apply approved changes. Set Status: Canonical on all pages. Update Change History. Validate links.

### Stage 5: Expanding Canonical Section

```
wiki_reorganization/stations/          # Expanding canonical section
├── README.md
├── 01-station-overview.md
├── 02-station-construction.md         # New approved page
├── 03-station-lifecycle.md            # New approved page
└── GAPS.md
```

**Actions**: Add numbered pages following the adoption workflow. Each new page goes through inventory → classify → propose → review → apply.

### Stage 6: Audit / Maintenance

```
wiki_reorganization/stations/          # Audit/maintenance stage
├── README.md
├── 01-station-overview.md
├── 02-station-construction.md
├── 03-station-lifecycle.md
├── GAPS.md                            # Updated with audit findings
└── AUDIT-STATIONS-DOCS.md             # Audit record
```

**Actions**: Periodic audit against source code. Update GAPS with resolved/new gaps. Deprecate stale pages.

---

## 11. Non-Goals

This guide explicitly does **NOT**:

- Automatically canonicalize folders that exist in the repository.
- Replace code, tests, source data, task templates, or human design authority.
- Authorize implementation changes of any kind — wiki-only changes only.
- Require every domain to contain every optional file (GAPS only when gaps exist; AUDIT only after audit performed).
- Require Economy-specific presentation patterns everywhere (audience guides, economic diagrams, rate tables are not universal requirements).
- Relocate or archive phase artifacts (`phase2_alignment/`, `phase3_alignment/`, `phase4/`, `analysis/`, `inventory/`, `proposals/`).
- Update canonical indexes or site maps on its own — index updates require normalized review (Stage 8 of the adoption workflow).
- Decide unresolved game-system, financial, timing, authorization, rig, lifecycle, or architecture questions.
- Use documentation structure work to settle any unresolved design decision.

---

## Change History

- **2026-09-15**: Created guide — establishes reusable section-template and adoption standard for all future wiki-reorganization domain work. Based on Economy (source pattern) and Transportation (normalized example) structural evidence.