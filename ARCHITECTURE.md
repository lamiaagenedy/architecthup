# ARCHITECTURE.md - Feature-First Flutter Architecture

## Overview

ArchitectHub uses a feature-first Flutter architecture.

The app is organized around business capabilities first, not around app-wide technical layers. Each business feature owns its own `data`, `domain`, and `presentation` folders, while `app`, `core`, and `shared` contain only cross-cutting code.

This keeps related code together, reduces cross-feature coupling, and scales cleanly as the product grows across splash, auth, dashboard, projects, project details, maintenance, landscape, maps, analytics, and profile.

---

## Approved Top-Level Structure

Only the following top-level entries are part of the approved structure inside `lib/`:

```text
lib/
|-- app/
|-- core/
|-- shared/
|-- features/
`-- main.dart
```

Anything outside the list above must be justified or removed.

---

## Folder Responsibilities

### `lib/app`

Use `app/` for whole-application wiring only.

Allowed examples:
- app bootstrap
- root `MaterialApp`
- app-level Riverpod composition
- global router registration
- navigation observers

Not allowed:
- feature repositories
- feature screens
- business use cases

### `lib/core`

Use `core/` only for cross-cutting technical infrastructure that is not owned by one feature.

Allowed examples:
- environment/config
- logging
- error handling
- network client setup
- theme tokens
- global constants and extensions

Not allowed:
- feature-specific business logic
- feature-specific state controllers
- product workflows

### `lib/shared`

Use `shared/` for code reused by multiple features but that is not app bootstrap.

Allowed examples:
- shared UI primitives
- shared styling helpers
- shared persistence bootstrap
- shared storage wrappers

Not allowed:
- code that clearly belongs to one feature
- repositories or models used by only one module

### `lib/features/<feature_name>`

Every business feature owns its own `data`, `domain`, and `presentation` layers.

```text
features/<feature_name>/
|-- data/
|-- domain/
`-- presentation/
```

Business code must live here, not in any global top-level layer folder.

---

## Current Feature Map

```text
features/
|-- analytics/
|-- auth/
|-- dashboard/
|-- landscape/
|-- maintenance/
|-- maps/
|-- profile/
|-- project_details/
|-- projects/
|-- quality/
|-- security/
|-- splash/
`-- tasks/
```

Some of these modules currently contain placeholder presentation code only. That is acceptable for the current phase because the goal is architecture correctness, not full feature delivery.

---

## Example Feature Layout

```text
features/auth/
|-- data/
|   |-- datasources/
|   |   |-- local/
|   |   `-- remote/
|   `-- repositories/
|-- domain/
|   |-- entities/
|   |-- repositories/
|   `-- usecases/
`-- presentation/
    |-- providers/
    `-- screens/
```

### Dependency Direction

Inside a feature, dependency flow should remain:

```text
presentation -> domain -> data -> core/shared
```

Rules:
- presentation should not import feature data implementations directly
- data implements domain contracts
- features may depend on `core` and `shared`
- cross-feature dependencies should be avoided unless coordinated through `app` or extracted into `shared`

---

## App-Wide Modules

### Navigation

Global route registration lives in `app/navigation/`, but route targets belong to their owning features.

The authenticated app shell also belongs in `app/navigation/` because it is application wiring, not a business feature. The shell may own shared mobile navigation chrome such as the bottom tab bar, while each tab screen still lives inside its feature module.

### Dependency Injection

App-level providers in `app/di/` should only wire shared infrastructure and compose feature dependencies needed by startup or routing.

Feature-specific providers belong inside their own feature folders.

---

## Shared Persistence

Shared persistence bootstrap currently lives in:

```text
shared/data/local/
|-- app_database.dart
|-- preferences_store.dart
`-- connection/
```

That is valid because database/bootstrap wiring is a cross-feature concern. Feature-specific tables, DAOs, or persistence policies should move into the owning feature when they become business-specific.

---

## Enforcement Rules

- No top-level business `data`, `domain`, or `presentation` trees are allowed.
- No feature-specific repositories, models, screens, providers, or widgets may live in `core` or `shared`.
- Empty legacy folders are cleanup artifacts only and must not receive new code.

---

## Architecture Goals

This structure optimizes for:
- maintainability
- scalability
- clearer ownership
- easier onboarding
- simpler refactoring as the product grows

The goal is practical architecture with strong boundaries, not unnecessary ceremony.
