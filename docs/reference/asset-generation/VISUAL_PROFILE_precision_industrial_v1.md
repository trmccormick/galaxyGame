# GalaxyGame Visual Profile: precision_industrial_v1

**Status:** Canonical
**Profile ID:** `precision_industrial_v1`
**Version:** 1.1
**Applies To:** Components, Equipment, Units, Vehicles

**Paste this at the start of any image-generation session, before any
unit-specific request. Treat everything below as fixed canon, not a
suggestion to reinterpret, improve, or vary. Do not introduce alternate
manufacturing languages for a unit assigned this visual profile unless
explicitly asked to in that same message.**

## Purpose

Visual Profiles define the industrial design language of an asset.

They do **not** define:
- Gameplay
- Operational behavior
- Manufacturing recipes
- Technology progression
- Statistics

Those belong in blueprint and operational data. Visual Profiles exist
solely to ensure consistent asset generation.

## What this document is

`precision_industrial_v1` is a **Visual Profile** — a reusable, named
description of manufacturing philosophy, material language, finish, and
industrial character. It is independent of Technology Level and
Manufacturing Origin, which are separate axes:

| Axis | Example values | Independent of visual profile? |
|---|---|---|
| Technology Level | TL1, TL2, TL3, TL4... | Yes |
| Manufacturing Origin | Earth, Orbital, Mars... | Yes |
| Manufacturing Method | Precision Factory, ISRU-printed... | Yes |
| Visual Profile | `precision_industrial_v1` | This document |

A unit references a visual profile by ID (`"visual_profile":
"precision_industrial_v1"`); it does not inline style text. The
PromptBuilder is responsible for expanding the profile ID into prompt
text. Changing the look later means editing this one document, not every
unit's blueprint.

Today, `precision_industrial_v1` happens to describe Earth-manufactured
TL3 equipment (the RH-400 reference). That is a current fact, not a
permanent binding — the same profile could later apply to an orbital or
Mars-built factory unit if the manufacturing philosophy matches. Do not
assume this profile implies Earth as the only valid origin.

## Canonical Reference Assets

The canonical reference is the **RH-400 Regolith Harvester Rover**
catalog render / engineering blueprint / exploded-view set already
generated and approved (silhouette, proportions, material language, and
lighting all locked). Every unit assigned `precision_industrial_v1`
should look like it was built by the same engineering organization as
that reference.

> This is currently a single-asset reference. Additional units will be
> added to this list only once their own assets are generated and
> approved under this profile — do not treat unapproved/hypothetical
> units as reference material.

## Locked attributes

- **Typical Manufacturing Method:** Most assets using this profile are
  expected to originate from precision industrial factories. This is
  descriptive, not prescriptive — Manufacturing Method remains a
  separate blueprint property, so an orbital factory producing
  equipment with this same appearance would not contradict the profile.
- **Materials:** high-strength aerospace steel, aluminum structural
  members, abrasion-resistant composite panels, sealed hydraulic
  systems, reinforced rubber tracks
- **Finish:** clean white/light-gray primary paneling over dark
  gray/black mechanical undercarriage, precision-machined surfaces,
  minimal visible construction seams — NASA/ESA-inspired
  aerospace-industrial aesthetic
- **Markings:** black/yellow hazard striping used functionally (moving
  parts, edges only), unit ID stenciled on the hull
- **Overall impression:** purpose-built, factory-assembled, clean
  industrial — decorative geometry is never used to suggest
  sophistication; functional components should dominate the design

## Silhouette rules (applies to all units under this profile)

- Strong, primary silhouette recognizable at 64×64 pixels
- Every vehicle identifiable by silhouette before surface detail
- Functional components (scoops, treads, hoppers, sensors) should
  dominate the outline
- Decorative geometry must never obscure recognition

## Consistency & Family Relationship Rules

When generating assets under this profile:

- Maintain consistent proportions across related vehicles.
- Reuse standardized connectors.
- Reuse standardized access hatches.
- Reuse standardized warning markings.
- Reuse standardized lighting fixtures.
- Reuse standardized sensor packages where appropriate.

Vehicles within this profile should appear to share common engineering
heritage — different machines should look like they were produced by
the same manufacturer using common components and design practices. The
objective is a common engineering ecosystem, not isolated vehicle
designs.

## Explicitly excluded from this profile

Do **not** apply any of the following to a `precision_industrial_v1` unit:

- Frontier / bootstrap / improvised-construction language
- DMLS or 3D-printed rough surface finish, visible layer lines, exposed
  reinforcement ribs
- Regolith-composite or ISRU-derived material appearance

(These belong to separate, not-yet-formalized visual profiles for
settlement-fabricated equipment. No such profile is defined yet — do not
invent one; flag it as pending if asked.)

## Camera, orientation, and sprites — RESOLVED

- **Rendering is top-down**, a plain square grid — direct
  `(col,row) → (col*tileSize+offsetX, row*tileSize+offsetY)` mapping, no
  rotation, shear, or diamond transform. It is **not** isometric.
  (Confirmed against `surface_view.js`, commit `d1125bd6`.)
- **No directional sprite set is needed.** Each unit type is a single
  static top-down image. The engine does not rotate sprites, and there
  is no facing/direction field in grid cell data.
- Any prior reference to "3/4 isometric, facing northeast" in other
  documents (e.g. the Sprite Render Template) is stale and should be
  corrected to match the above, not treated as a live spec.

## PromptBuilder Contract

- The PromptBuilder must expand this profile into prompt text.
- Blueprints and operational data reference the profile by ID only.
- Generated prompts must never redefine or reinterpret the visual
  profile.
- Any prompt generated for a unit under this profile inherits all
  locked attributes automatically.
- Only **SUBJECT**, **FUNCTION**, and **RECOGNITION_FEATURES** should
  vary per unit within this profile — everything else is fixed.

## Evolution Policy

- Minor revisions (clarifications, additions that don't change the
  locked visual identity): `precision_industrial_v1.1`,
  `precision_industrial_v1.2`, etc.
- Major visual redesign (would change the locked identity):
  `precision_industrial_v2`.
- Existing approved assets retain the profile version used at time of
  approval — a version bump does not retroactively invalidate prior
  approved work.

## How to use with the Sprite Render Template

Apply this document as the fixed content of the STYLE / MANUFACTURING /
MATERIALS sections of the GalaxyGame Sprite Render Template v1.0. Only
SUBJECT, FUNCTION, and RECOGNITION_FEATURES should vary per unit within
this profile.
