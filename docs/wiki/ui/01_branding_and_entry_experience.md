> **Wiki section:** UI & Experience · **Status:** DESIGN INTENT  
> **Last Updated:** 2026-11-04

# Branding and Entry Experience

This page records the initial shared branding and entry-page decisions for the Galaxy Game UI. The landing page is being reviewed first; sign-in follows after the landing page is accepted.

## Ownership and source of truth

**ESTABLISHED INTENT — 2026-11-04**

- UI design intent belongs in the main `galaxyGame` repository under `docs/wiki/ui/`, even when implementation work is performed in the separate `galaxy-game-ui` prototype repository.
- This wiki page records product design intent. The prototype repository contains implementation and prototype-specific development material; it is not the authority for product design.
- Implementation tasks should reference this page and focus on specific work and acceptance criteria.
- After a view is implemented and reviewed, update this page to reflect the actual accepted view. Do not leave an outdated proposal presented as the final design.

## Shared visual identity

**ESTABLISHED INTENT — 2026-11-04**

- Retain the existing cyan/blue visual identity and established page layout during this cleanup; this is not a request for a broad redesign.
- The selected source image is **Luminous Blue Spiral Galaxy Icon.png**. Use this same selected image for the main Galaxy Game logo and as the source for a suitably sized favicon.
- The alternative **Glowing Blue Spiral Galaxy Icon.png** was not selected and must not be used for this work.
- Replace the existing WVU favicon/branding where it is still being used as Galaxy Game site identity.
- Preserve the existing hero banner unless review identifies a specific problem that warrants discussion.

**DIRECTION — 2026-11-04**

- The supplied Command Center dashboard screenshot is a visual reference for the cyan-on-dark appearance and square galaxy-icon treatment. It is a reference, not an instruction to redesign the dashboard as part of this task.
- Verify that the existing cyan design tokens are consistent and that the selected logo/favicon render cleanly. Make targeted corrections only where an actual issue is found.

## Shared application visual direction

**ESTABLISHED INTENT — 2026-11-11**

The shared visual direction across Main Game, Admin, and AI Manager is a dark desktop operations interface built around charcoal/navy surfaces and cyan as the primary accent.

- Continue the dark charcoal/navy + cyan direction already established in the UI prototype. This is a continuation and refinement of useful existing work, not a restart or a wholesale redesign.
- Use a consistent design language across all three interfaces while allowing their layouts, information density, and workflows to differ.
- Use green primarily for success, healthy/operational state, and positive outcomes; it should not dominate the overall interface.
- Use amber for warnings and red for errors or critical conditions. Status must also be communicated through labels, icons, or text rather than color alone.
- Keep typography readable and appropriately compact for information-dense operational screens. Avoid oversized text, crowded paragraphs, and controls that overwhelm the data.
- Reuse and refine the prototype's existing tokens, components, and stronger layouts. Do not introduce a competing palette or copy the legacy green-on-black terminal styling as the general application theme.
- The main application remains a source of existing functionality and useful visualizations, not the automatic visual standard. The prototype's stronger presentation and layouts should be retained where they work.
- EVE is a reference for information organization and interaction patterns only; its visual styling and game concepts are not requirements.

**Landing-page image direction — ESTABLISHED INTENT — 2026-11-11**

The earlier space-background treatment on the landing page was part of the visual identity and should be restored/reintroduced using the existing approved imagery where available. This is selective: a prominent space image belongs on the landing page, but operational screens should not be decorated with large imagery where it reduces readability. Do not invent or substitute a new logo or unapproved brand asset.

## Entry experience sequence

**ESTABLISHED INTENT — 2026-11-04**

1. Complete and review the landing page first.
2. Do not move on to sign-in implementation until the owner has reviewed the landing page.
3. Apply the shared branding to sign-in after the landing page is accepted.

**OPEN**

- Final landing-page appearance is pending review of the rendered implementation.
- Sign-in layout and its detailed visual treatment have not yet been reviewed or approved.
- Authentication flow and post-authentication routing (including admin/player destinations and sign-out behavior) are outside the current logo/landing-page cleanup and remain to be examined separately.

## Review and evidence record

The current prototype state and the supplied Command Center screenshot are preliminary references. They must not be described as final approved views.

After owner review, record:
- the accepted landing-page screenshot or other durable visual reference;
- the accepted sign-in screenshot when that view is reviewed;
- any deviations from the intent above and the owner's decision;
- any remaining open questions.

Do not invent or infer a final design from an implementation that has not been reviewed.

## Change History

- **2026-11-04** — Recorded initial shared-branding and entry-experience intent while landing-page implementation is in progress. Final rendered views remain pending owner review.
- **2026-11-11** — Confirmed the shared dark charcoal/navy + cyan direction, status-color roles, typography/readability expectations, and selective restoration of the landing-page space background.
