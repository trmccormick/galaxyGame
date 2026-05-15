# WVU Libraries Knapsack — Domain Context Guide
**Last Updated**: May 14, 2026
**Populated By**: GitHub Copilot
**Source**: `docs/agent/`

> This file provides context for any agent working on WVU Libraries local
> customizations delivered via the knapsack pattern.
> `@file` this into your Continue session for any WVU-specific task.
> See also: `samvera_hyku.md` and `samvera_hyrax.md` for upstream context.

---

## What the Knapsack Is
The WVU Knapsack is a customized instance of Hyku, an open-source digital repository platform built on Samvera technologies (Hyrax, Blacklight, etc.). It serves as the digital repository for West Virginia University (WVU) Libraries, enabling management of digital collections, scholarly works, and institutional assets. The "knapsack" pattern isolates WVU-specific customizations (e.g., themes, work types, authorities) from the core Hyku application, allowing transparent overrides without modifying upstream code. This ensures maintainability, as updates to Hyku can be pulled via git submodule while preserving local changes.

Key aspects:
- **Repository**: Hosted at https://github.com/wvulibraries/wvu_knapsack.
- **Hyku Submodule**: Core Hyku code is in `./hyrax-webapp/` (git submodule from https://github.com/samvera/hyku).
- **Upstream Template**: Based on https://github.com/samvera-labs/hyku_knapsack.
- **Production URL**: https://admin-hyku.lib.wvu.edu (superadmin interface); tenant URLs like `https://{tenant}-hyku.lib.wvu.edu`.
- **License**: Apache 2.0.

---

## Repository / Project Structure
- **Knapsack Structure** (isolates custom code from core):
  - `app/`: Overrides/decorators (views, models, controllers, components, jobs, mailers).
  - `config/`: Initializers (e.g., host auth, session overrides), environments, routes.
  - `bundler.d/`: Gem additions.
  - `lib/`: Engine, generators, decorators.
  - `hyrax-webapp/`: Git submodule (Hyku core — read-only).
  - Docker/Compose files: `docker-compose.production.yml` (VM), `docker-compose.local.yml` (smoke test).
  - Scripts: `up.sh`/`down.sh` (VM), `up.sc.local.sh` (Stack Car dev), `scripts/setup.sh` (DB/Solr init).

- **Core Components**:
  - **Hyku Engine**: Rails engine loading decorators and overrides in `to_prepare` blocks.
  - **Hyrax**: Handles works, filesets, collections, metadata, and derivatives.
  - **Blacklight**: Search and discovery interface with custom constraints.
  - **Valkyrie**: Resource-oriented modeling for works (e.g., `Hyrax::ValkyrieWorkIndexer`).
  - **Fedora/Solr**: Storage/indexing (SolrCloud with ZooKeeper).
  - **PostgreSQL/Redis**: DB/caching.
  - **Stack Car**: Local dev proxy for HTTPS wildcard domains (e.g., `*.localhost.direct`).

- **Loading Mechanism**: Engine loads `*_decorator.rb` files via `Rails.configuration.cache_classes ? require(c) : load(c)`. Overrides take precedence due to Rails autoload paths.

- **Multitenant Routing**: Uses `HYKU_ADMIN_HOST`, `HYKU_DEFAULT_HOST`, and `HYKU_ROOT_HOST` for admin/tenant separation.

- **Data Persistence**: Bind mounts in `./data/` (DB, Solr, Fedora, uploads, assets, bundle cache).

Architectural Decisions: Knapsack pattern ensures upstream compatibility. Submodule for Hyku updates. Docker for portability. Focus on decorators for maintainability.

---

## Override Patterns
The knapsack uses a "higher precedence" loading mechanism: Files in the knapsack override those in the Hyku submodule without editing core code. Overrides are applied via decorators (modules prepended to classes) or direct file copies.

- **Decorator Pattern**: Files named `*_decorator.rb` in `app/` or `lib/` are auto-loaded. They prepend modules to existing classes for non-invasive changes.
  - Example: `app/controllers/catalog_controller_decorator.rb` configures Blacklight advanced search facets.
  - Example: `lib/blacklight_advanced_search/render_constraints_override_decorator.rb` overrides to fix double-rendering of constraint filters by rebinding methods.
  - Example: `config/initializers/hyrax_controlled_vocabularies_decorator.rb` adds custom services (e.g., 'congress' authority) to Hyrax's controlled vocabularies.

- **File Override Pattern**: Copy files from `hyrax-webapp/` to the same relative path in the knapsack, modify, and add an override comment.
  - Example: `app/views/themes/wvu_show/hyrax/base/_show_actions.html.erb` overrides show actions to add analytics buttons and adjust permissions checks.
  - Comment Format: `# OVERRIDE Hyku v5.0.1 — reason for override` (e.g., for version tracking).

- **Custom Work Types**: Use `rails generate hyku_knapsack:work_resource WorkType` to scaffold models, controllers, forms, indexers, and views. This creates files in the knapsack (e.g., `app/controllers/hyrax/documents_controller.rb` with behaviors like `Hyrax::WorksControllerBehavior` and `Hyku::WorksControllerBehavior`).

- **Authorities and Vocabularies**: Overrides allow multiple authority directories (knapsack + Hyku). Local YAML files in `config/authorities/` define custom vocabularies (e.g., disciplines).

- **Gems and Dependencies**: Add gems via files in `bundler.d/` (e.g., `bundler.d/example.rb` for `gem 'some-gem'`). Avoid editing `Gemfile` to prevent drift.

- **Initializers and Config**: Custom Rails initializers (e.g., `config/initializers/knapsack_authorities.rb`) handle multi-path authorities and patches (e.g., for Bulkrax ZIP errors or ImageMagick derivatives).

Best Practices: Follow the [Decorators and Overrides wiki](https://github.com/samvera-labs/hyku_knapsack/wiki/Decorators-and-Overrides). Use generators for new work types. Test overrides in local dev before production.

---

## Configuration & Environment
- **Environment Variables** (via `.env.*` files):
  - Templates: `.env.production.example`, `.env.db.example`, etc. (committed).
  - Live files: Gitignored (e.g., `.env.production` with secrets like `SECRET_KEY_BASE`, `DB_PASSWORD`).
  - Key Vars: `APP_NAME=wvu-knapsack`, `HYKU_ADMIN_HOST=admin-wvu-knapsack.*`, `HYKU_MULTITENANT=true`, `DISABLE_FORCE_SSL=true` (for HTTP dev).
  - Password Sync: `POSTGRES_PASSWORD` must match `DB_PASSWORD` and Fedora `JAVA_OPTS`.

- **Key Config Files**:
  - `config/initializers/host_authorization.rb`: Allows `*.lib.wvu.edu` + `HYKU_EXTRA_HOSTS`.
  - `config/initializers/session_store_override.rb`: Drops Secure cookie flag for HTTP.
  - `docker-compose.production.yml`: Production stack.
  - `scripts/setup.sh`: Idempotent DB/Solr/tenant init (migrations, seeds, assets).

---

## Local Development Setup
- **Prerequisites**:
  - Docker Desktop.
  - Stack Car (`gem install stack_car`) for local dev.
  - Ruby (for `sc` commands).
  - For VM: RHEL with Docker CE, SELinux labeling (`chcon -Rt svirt_sandbox_file_t ./data`), DNS (`*.lib.wvu.edu` → VM IP), SSL reverse proxy (Nginx/Traefik).

- **Setup Workflows**:
  - **Local Dev (Stack Car)**: Clone with `--recurse-submodules`, create `required_for_knapsack_instances` branch, `sc proxy up`, `sh up.sc.local.sh` (rebuilds images), access at `https://admin-wvu-knapsack.localhost.direct`.
  - **Local Production Smoke Test**: Copy `.env.*.example` to `.env.*`, `docker compose -f docker-compose.local.yml up -d`, run `setup.sh`, access at `http://admin-wvu-knapsack.lvh.me:3000`.
  - **VM Production**: Clone, copy env files, `sh up.sh` (builds/pulls images), run `setup.sh`, reverse proxy to port 3000.

- **Updates**: Pull submodule (`git submodule update`), restart. Run `setup.sh` for migrations/assets.

---

## Testing Conventions
- **Spec Example**: `spec/models/medicine_spec.rb` uses shared specs for Hyrax works.
  ```ruby
  RSpec.describe Medicine do
    it_behaves_like 'a Hyrax::Work'
  end
  ```

- **Generator Output**: `rails generate hyku_knapsack:work_resource Medicine` creates `app/models/medicine.rb`, `app/controllers/hyrax/medicines_controller.rb`, `app/forms/hyrax/medicine_form.rb`, etc.

---

## Deployment Notes
- **Architectural Decisions**:
  - Knapsack pattern for customization without core edits, enabling easy upstream updates.
  - Submodule for Hyku to track versions without bundling.
  - Docker for consistent environments; bind mounts for data persistence.
  - Multitenancy via env vars; decorators for extensibility.
  - Focus on Rails conventions (e.g., autoload, initializers) for overrides.
  - Security: Host authorization, SSL enforcement, password sync.
  - Performance: ImageMagick patches, SolrCloud, caching.

- **Branch Conventions**: Use `required_for_knapsack_instances` branch for local dev. Pull submodules carefully to avoid conflicts.

---

## What Not To Do
- Do not edit files in `hyrax-webapp/` directly; use overrides in the knapsack.
- Avoid modifying `Gemfile`; use `bundler.d/` files for gems.
- Do not bypass decorators; always use prepend for class modifications.
- Avoid hardcoded paths; rely on env vars for configuration.
- Do not ignore version tracking in override comments.
