# Samvera Hyrax — Domain Context Guide
**Last Updated**: May 14, 2026
**Populated By**: GitHub Copilot
**Source**: `docs/agent/`

> This file provides domain context for any agent working with the Hyrax engine.
> `@file` this into your Continue session before starting any Hyrax-level task.
> Hyrax is the underlying engine Hyku is built on.
> See also: `agent_guides/samvera_hyku.md` for Hyku-specific context.

---

## What Hyrax Is
Hyrax is a Ruby on Rails Engine built by the Samvera community, providing a robust foundation for creating digital repository applications. It is not a standalone web application; instead, it is designed to be mounted within a Rails application, which is then referred to as a "Hyrax-based application." Hyrax leverages modern Ruby on Rails practices and integrates with key components like Blacklight for search interfaces, Valkyrie for data persistence, and Solr for indexing. It supports the Hydra Works model for managing repository objects and is licensed under Apache 2.0. Hyrax enables institutions to build flexible, scalable digital repositories for managing, preserving, and providing access to digital content.

---

## Works and FileSets
In Hyrax, the core domain model follows the Hydra Works specification, implemented using Valkyrie resources (with legacy support for ActiveFedora). Key relationships and behaviors include:

- **Hyrax::Work**: A Valkyrie model representing repository objects (e.g., articles, datasets). Works can contain other works and file sets. Key attributes include `member_ids` (holding IDs of child works and file sets), `admin_set_id` (linking to an administrative set), and optional `representative_id` and `thumbnail_id` (pointing to associated file sets).
  - Relationships: Work to Administrative Set (1..1: each work belongs to one admin set); Work to Work (hierarchical, 0..1 parent); Work to FileSet (0..m: a work can have many file sets).
  - Example: Adding a file set to a work via `work.member_ids += [file_set.id]; Hyrax.persister.save(resource: work)`.

- **Hyrax::FileSet**: A Valkyrie model for file-based content (e.g., PDFs, images). File sets represent individual files attached to works.
  - Relationships: FileSet to Work (1..1: each file set belongs to exactly one work); FileSet to FileMetadata (1..m: file sets contain metadata about stored files).
  - Behaviors: File sets inherit visibility and permissions from their parent work. They support operations like characterization, derivatives generation, and fixity checking. File sets can serve as representatives or thumbnails for works.
  - Example: Attaching a file set to a work via actors (e.g., `FileSetActor#attach_to_work(work)`), which updates `work.ordered_members` and sets representative/thumbnail if needed.

- **Key Interactions**: Works aggregate file sets via `member_ids`. File sets have a `parents` method to access their containing work. Sibling file sets (in the same work) can be queried via `related_files`. Permissions propagate from work to file sets. Deletion of a work cascades to its file sets.

This model supports hierarchical structures, metadata inheritance, and flexible content aggregation, enabling complex repository objects.

---

## Actor Stack
Hyrax uses an actor pattern for handling complex operations like work creation, file uploads, and metadata updates. Actors are middleware classes that chain together to perform sequential steps, allowing for extensibility and customization.

- **Core Concept**: Actors implement the Chain of Responsibility pattern. Each actor performs a specific task (e.g., validation, persistence) and can pass control to the next actor in the stack.
- **Key Actors**:
  - `Hyrax::Actors::FileSetActor`: Handles file set operations (create, update, attach to work).
  - `Hyrax::Actors::AbstractActor`: Base class for custom actors.
  - `Hyrax::Actors::Environment`: Context object passed through the chain, containing user, work, and attributes.

- **How It Works**: Operations start with `Hyrax::CurationConcern.actor_factory.build(work, user).create(attributes)`, which builds and executes the actor stack. Middleware can be inserted or replaced for customization.
- **Customization**: Override or prepend actors to add logic (e.g., custom validation). Use `Hyrax::Actors::ActorFactory#insert_after` to modify the chain.

- **Example**: Creating a work with file sets involves actors for metadata assignment, file processing, indexing, and notifications.

---

## Indexing
Hyrax uses Solr for full-text indexing and search, integrated via Blacklight. Indexing is handled by indexer classes that map model attributes to Solr fields.

- **Indexers**: Classes like `Hyrax::Indexers::FileSetIndexer` and `Hyrax::ValkyrieIndexer` define how objects are indexed. They use index maps to specify field mappings.
- **Process**: After persistence, background jobs (e.g., `IngestJob`) trigger indexing. Reindexing can be done via `Hyrax::Reindexer` or rake tasks.
- **Adding Fields**: Customize indexers by overriding methods or adding to index maps. Use `Hyrax::Indexer` base class for Valkyrie resources.
- **Gotchas**: Ensure index maps match Solr schema. Reindex after schema changes. Use queued indexing for performance in production.

---

## Forms and Permissions
- **Forms**: Hyrax uses form objects (e.g., `Hyrax::Forms::WorkForm`) for validation and UI binding. Forms handle metadata input and file uploads. Customize by subclassing and overriding fields or validation.
- **Permissions**: Role-based access with visibility levels (public, institutional, private). Permissions are managed via `Hyrax::PermissionManager` and propagate from works to file sets. Use `Ability` classes for authorization checks.

---

## Engine Override Patterns
Hyrax follows Rails conventions with custom patterns for repository operations. Key patterns include actors for actions, presenters for views, and transactions for complex flows.

- **Actor Pattern**: Actions are decoupled; e.g., `actor = Hyrax::Actors::FileSetActor.new(file_set, user); actor.create_metadata; actor.attach_to_work(work)`.
- **Presenter Pattern**: Separate view logic; e.g., `FileSetPresenter` provides display methods like `human_readable_type`.
- **Transaction Pattern**: Declarative steps; e.g., `Hyrax::Transactions::Container['change_set.create_work'].call(work_form)`.
- **Event Bus**: Publish/subscribe; e.g., `Hyrax.publisher.publish('object.deposited', object: file_set)`.
- **Generator Usage**: Create work types: `rails generate hyrax:work_resource Article` (generates model, indexer, etc.).
- **Custom Queries**: Access relationships; e.g., `Hyrax.custom_queries.find_child_file_sets(resource: work)`.
- **Middleware Customization**: Modify actor stack; e.g., `Hyrax::Actors::ActorFactory#insert_after(...)`.

Examples illustrate extensibility: override actors for custom logic, use forms for metadata, and leverage jobs for async processing.

---

## Testing Conventions
Hyrax uses RSpec for testing. Key conventions include:

- **Factories**: Use FactoryBot for creating test objects; e.g., `FactoryBot.create(:work)`.
- **Shared Examples**: Provided by Hyrax; e.g., `it_behaves_like 'a Hyrax::Work'` for work models.
- **Strategies**: For Valkyrie objects, use `create_valkyrie` or similar helpers.
- **Testing Actors/Indexers**: Mock dependencies, test actor chains, verify indexing fields.

---

## What Not To Do
- Do not patch Hyrax engine files directly; use decorators, concerns, or host app overrides.
- Avoid bypassing the actor stack; always use actors for operations to ensure consistency.
- Do not mix ActiveFedora and Valkyrie patterns; choose one persistence model.
- Avoid custom indexing without updating the Solr schema.
- Do not ignore permissions propagation; ensure work and file set visibility align.
