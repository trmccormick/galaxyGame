# Backlog Task: Refactor and Organize CSS/SCSS for Application

## Problem
Current CSS/SCSS structure mixes global, admin, and card-specific styles. Some views import component styles as main layout styles, leading to confusion and inconsistent styling. General layout styles are not always separated from admin or card-specific styles.

## Goals
- Separate global layout/styles from admin-specific and card-specific styles.
- Ensure each view imports only the relevant stylesheets (global, admin, card, etc.).
- Move shared layout styles to a main application stylesheet.
- Keep admin section styles modular (sidebar, dashboard, etc.).
- Keep card styles in their own SCSS file, imported only where needed.
- Audit all views for correct stylesheet usage.
- Update documentation to clarify stylesheet structure and usage.

## Steps
1. Audit all SCSS/CSS files for purpose and usage.
2. Identify styles that should be global, admin-specific, or card-specific.
3. Refactor SCSS files: move styles to appropriate files.
4. Update views to import only necessary stylesheets.
5. Test all views for layout and style consistency.
6. Update documentation for stylesheet structure.

## Acceptance Criteria
- No mixing of component styles with layout styles.
- All views import only relevant stylesheets.
- Global layout styles are in main application stylesheet.
- Admin and card styles are modular and separated.
- Documentation updated.

---

Created: 2026-02-22
Priority: Medium
Owner: UI/Frontend Team
