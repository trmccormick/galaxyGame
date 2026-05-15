# Samvera Hyku — Domain Context Guide
**Last Updated**: May 14, 2026
**Populated By**: GitHub Copilot
**Source**: `docs/agent/`

> This file provides domain context for any agent working on Hyku.
> `@file` this into your Continue session before starting any Hyku task.
> Hyku is a multi-tenant repository application built on Hyrax.
> See also: `agent_guides/samvera_hyrax.md` for Hyrax engine context.

---

## What Hyku Is
Hyku is an open-source, multi-tenant digital repository application built on the Samvera ecosystem. It serves as a "Hydra-in-a-Box" solution, providing a ready-to-deploy platform for institutions to manage, preserve, and share digital collections. Hyku leverages the Hyrax framework (part of Samvera) for core repository functionalities like metadata management, file storage, search, and access controls. It is designed for scalability, supporting multiple independent tenants (e.g., institutions or departments) on a single infrastructure, while allowing customization through themes, flexible metadata schemas, and integrations like IIIF for images, OAI-PMH for harvesting, and analytics tools.

Hyku was developed by the Hydra-in-a-Box Project (a collaboration between DPLA, DuraSpace, and Stanford University) under an IMLS grant. It is maintained by the Samvera community and licensed under Apache 2.0. The application emphasizes ease of deployment via Docker, Kubernetes, or AWS, making it suitable for production environments in libraries, archives, and research institutions.

---

## Multi-Tenancy Model
Hyku's multi-tenancy is implemented using the Apartment gem, which creates isolated PostgreSQL schemas for each tenant. This ensures data separation while sharing application code and infrastructure. Key aspects:

- **Tenant Creation**: Each tenant is represented by an `Account` model with a unique UUID. When created, it generates:
  - A PostgreSQL schema (via Apartment).
  - A dedicated Solr collection for indexing.
  - A Fedora container for object storage.
  - A Redis namespace for caching and jobs.
  - A `Site` singleton model for tenant-specific configuration (e.g., application name, branding).

- **Data Isolation**: Most models (e.g., works, users, roles) are scoped to the tenant's schema. Global models like `Account` and `User` (for cross-tenant auth) are excluded from Apartment scoping.

- **Tenant Switching**: The `Account#switch!` method activates the tenant's context by switching the database schema, Solr collection, Fedora endpoint, and Redis namespace. This is done dynamically based on the request's domain (e.g., `tenant.example.com`).

- **Domain-Based Routing**: Tenants are accessed via subdomains (e.g., `%{tenant}.example.com`), determined by the `HYKU_DEFAULT_HOST` env var. An admin interface (e.g., `admin-hyku.example.com`) manages tenant creation.

- **User and Role Management**: Users and roles are per-tenant. Superadmins can manage all tenants, while site admins are limited to their tenant. Authentication can be shared across tenants if configured.

- **Single-Tenant Mode**: Optional mode (`HYKU_MULTITENANT=false`) for non-multi-tenant deployments, using a single schema and domain.

This model allows efficient resource sharing (e.g., one server hosts multiple repositories) while maintaining isolation.

---

## Tech Stack
Hyku is a Ruby on Rails application layered on top of the Hyrax framework. It follows a modular, service-oriented architecture:

- **Core Framework**:
  - **Rails**: Web framework handling routing, controllers, views, and models.
  - **Hyrax**: Provides repository-specific features like work models, file uploads, indexing, and workflows. Hyku extends Hyrax with multi-tenancy and theming.
  - **Blacklight**: Search interface and Solr integration for discovery.

- **Persistence Layer**:
  - **Valkyrie/Wings**: Abstraction for data storage. Wings bridges ActiveFedora (legacy) to Valkyrie (modern). Supports Fedora 4 for metadata/objects and PostgreSQL for relational data.
  - **Solr**: Indexing and search engine, with per-tenant collections.
  - **Fedora**: RDF-based repository for digital objects, with per-tenant containers.
  - **Redis**: Caching, sessions, and background job queues (namespaced per tenant).

- **Key Components and Services**:
  - **Models**: `Account` (tenant management), `Site` (tenant config), `User`/`Role` (auth), `SolrDocument` (search results), `GenericWork` (digital objects).
  - **Controllers**: `CatalogController` (search), `Hyrax::WorksController` (CRUD for works), admin controllers for tenant management.
  - **Services**: `Bulkrax` (import/export), `Hyrax::FileSetDerivativesService` (file processing), analytics services.
  - **Initializers**: Configure Hyrax, Valkyrie, Apartment, and integrations (e.g., `config/initializers/hyrax.rb`, `apartment.rb`).
  - **Jobs**: Background processing via ActiveJob (Sidekiq by default) for indexing, derivatives, and bulk operations.
  - **Storage Adapters**: Valkyrie adapters for disk, S3, or MinIO storage.

- **Deployment Options**:
  - **Docker**: Containerized setup with `docker-compose` for local dev/prod.
  - **Kubernetes/Helm**: Charts for scalable deployments.
  - **AWS**: CloudFormation templates for EC2, RDS, etc.

- **External Integrations**: IIIF viewers, OAI-PMH endpoints, SWORD deposits, email (SMTP), and analytics.

The architecture supports both ActiveFedora (legacy) and Valkyrie (modern) persistence, with a migration path for upgrading.

**Prerequisites** (from Configuration):
- Ruby 3.3.x, Rails 7.2.x.
- PostgreSQL, Solr 8.x, Fedora 4.x, Redis.
- Optional: FITS for characterization, Tesseract for OCR, LibreOffice for derivatives.

---

## Community Conventions
- **README**: Overview, getting started, links to docs/wiki.
- **Docs**: `docs/getting-started.md` (installation), `docs/configuration.md` (env vars), `docs/using-hyku.md` (usage), `docs/wiki/` (detailed guides on multi-tenancy, themes, etc.).
- **Architectural Decisions**:
  - Valkyrie adoption for future-proofing (vs. ActiveFedora).
  - Apartment for schema-based multi-tenancy (scalable, isolated).
  - UUIDs for identifiers (faster than NOIDs).
  - Queued indexing for performance.
  - M3 for metadata flexibility (UI-driven, no dev intervention).

For full details, refer to the [Hyku GitHub Wiki](https://github.com/samvera/hyku/tree/main/docs/wiki) and [Samvera Docs](https://samvera.atlassian.net/wiki/spaces/hyku).

---

## Key Concepts
- **Multi-Tenant Architecture**: Supports isolated tenants with shared infrastructure, each with its own data schema, search index, and storage.
- **Repository Management**: Ingest, store, and manage digital objects (works, filesets, collections) with support for various file types (PDFs, images, audio, video).
- **Search and Discovery**: Powered by Blacklight and Solr, offering faceted search, advanced querying, and OAI-PMH harvesting.
- **Metadata Flexibility**: Configurable metadata schemas using M3 (Machine-readable Metadata Modeling) profiles, allowing UI-based customization without code changes.
- **File Handling and Derivatives**: Automatic generation of derivatives (thumbnails, OCR, etc.) using tools like FITS and Tesseract.
- **Access Controls and Permissions**: Role-based access (e.g., site admins, superadmins) with integration for authentication via LDAP, Shibboleth, or OAuth.
- **Theming and Branding**: Customizable UI themes, logos, and appearance settings per tenant.
- **Import/Export**: Bulkrax gem for CSV, XML, and OAI-based bulk imports/exports.
- **Analytics and Reporting**: Integration with Google Analytics 4, Matomo, or custom providers for usage statistics.
- **IIIF Support**: Image viewing and annotation via IIIF manifests.
- **API and Integrations**: RESTful APIs, SWORD for deposit, and support for DOIs via DataCite.
- **Internationalization**: Multi-language support with I18n.
- **Background Processing**: Asynchronous jobs via Sidekiq or GoodJob for tasks like indexing and derivatives.

---

## WVU Deployment Context
WVU uses a customized instance of Hyku called "WVU Knapsack", which isolates WVU-specific customizations (themes, work types, authorities) from the core Hyku application. This allows transparent overrides without modifying upstream code, ensuring maintainability as Hyku updates can be pulled via git submodule.

See `agent_guides/wvulibraries_knapsack.md` for details on WVU-specific overrides, deployment, and local development setup.

---

## Common Workflows
- **Setup Steps**:
  1. Clone the repo: `git clone https://github.com/samvera/hyku.git`.
  2. For Docker: Install Stack Car for DNS/TLS, run `docker compose build && docker compose up`.
  3. For local: Install dependencies, run `bin/setup`, then `rails s` and background services (Solr, Fedora via wrappers).
  4. Seed database: `rails db:seed` (creates admin user).
  5. Generate work types: `rails generate hyrax:work_resource MyWork`.
  6. Configure Hyrax (e.g., in `config/initializers/hyrax.rb`): Set paths (e.g., `config.fits_path`), enable features, register workflows.
  7. Start servers: `rails s` (dev); use Puma/Sidekiq for production.
  8. Enable notifications/workflows as needed.

- **Key Env Vars**:
  - `HYKU_MULTITENANT`: Enable multi-tenancy (default: true).
  - `DB_*`: Database config.
  - `SOLR_*`: Solr connection.
  - `FCREPO_*`: Fedora config.
  - `HYKU_DEFAULT_HOST`: Tenant subdomain pattern.
  - `HYRAX_FLEXIBLE`: Enable flexible metadata.
  - `REPOSITORY_S3_STORAGE`: Use S3 for files.

- **Production**: Use Kubernetes/Helm or AWS templates. Ensure SSL, backups, and monitoring.

---

## What Not To Do
- Avoid modifying core Hyku code directly; use decorators or overrides for customizations to maintain upstream compatibility.
- Do not mix tenant-scoped and global data without proper Apartment exclusion.
- Avoid hardcoded tenant logic; rely on dynamic switching via `Account#switch!`.
- Do not use legacy ActiveFedora patterns if Valkyrie is adopted; migrate to modern persistence.
- Avoid bypassing role-based permissions; always check user context in multi-tenant environments.
