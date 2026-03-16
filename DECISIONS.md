# DECISIONS.md - Architectural Decisions & Alternatives

## Overview

10 major architectural decisions made for ArchitectHub Flutter migration, including alternatives considered and rationale.

---

## Decision 1: Clean Architecture (6-Layer)

### Decision
Implement **Clean Architecture with 6 distinct layers**: Presentation → Application → Domain → Data → Core → External.

### Alternatives Considered
1. **Simple 3-Layer** (UI → Logic → Data) - Simpler initially, but lacks testability and scale
2. **MVVM Pattern** - Common in Flutter, but less clear about data flow
3. **Redux/BLoC Architecture** - Excellent for state, but overly complex for team new to Flutter

### Rationale
- ✅ Clear separation of concerns (each layer has one responsibility)
- ✅ Highly testable (mock interfaces at each boundary)
- ✅ Framework-independent (swap Firebase for another backend)
- ✅ Scales well (add features without rewriting)
- ✅ Team already familiar (similar to React Native clean architecture)
- ✅ Matches CLAUDE.md guidance

### Implementation Status
🟢 **APPROVED** - Use for all features

### References
- ARCHITECTURE.md (complete 6-layer diagram and folder structure)
- CLAUDE.md (architecture rules section)

---

## Decision 2: Riverpod for State Management

### Decision
Use **Riverpod** (NOT GetIt service locator or Provider package).

### Alternatives Considered
1. **GetIt Service Locator** - Simple but not type-safe, no DI
2. **Provider Package** - Good but requires BuildContext, less testable
3. **BLoC Pattern** - Excellent but more boilerplate
4. **Redux** - Scalable but overkill for MVP
5. **MobX** - Good but requires build_runner complexity

### Rationale
- ✅ Type-safe (no string-based lookups)
- ✅ Built-in dependency injection (no service locator)
- ✅ AsyncValue<T> handles loading/error/data states elegantly
- ✅ Zero boilerplate for simple providers
- ✅ FamilyProvider for parameterized queries (projectDetail.family())
- ✅ Works perfectly with Freezed entities
- ✅ Testable without BuildContext
- ✅ Hot reload works seamlessly

### Counter-Arguments
- ❌ Slightly steeper learning curve vs Provider
- ❌ Requires understanding of ref.watch/ref.read
- ✅ But CLAUDE.md has 4 detailed examples to mitigate

### Implementation Status
🟢 **APPROVED** - Mandatory for all state management

### Example Usage
```dart
// Provider (sync)
final appColorProvider = Provider((ref) => Color(0xFF2563EB));

// FutureProvider (async, like API calls)
final projectsProvider = FutureProvider((ref) => repo.getProjects());

// FamilyProvider (parameterized, like detail views)
final projectDetailProvider = FutureProvider.family(
  (ref, String id) => repo.getProjectById(id),
);

// StateNotifierProvider (complex state with multiple fields)
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(ref.watch(repoProvider)),
);
```

---

## Decision 3: GoRouter for Navigation

### Decision
Use **GoRouter** (Flutter's official declarative router, NOT Navigator 1.0 or React Navigation equivalent).

### Alternatives Considered
1. **GetX Navigation** - Simple but breaks clean architecture patterns
2. **Navigator 2.0 (imperative)** - Full control but verbose boilerplate
3. **AutoRoute** - Good but too much code generation complexity

### Rationale
- ✅ Official Flutter navigation (endorsed by Google)
- ✅ Type-safe route definitions
- ✅ Deep linking built-in (share project link opens detail screen)
- ✅ Route guards (redirect unauthenticated users to login)
- ✅ Declarative syntax (routes defined once, not scattered)
- ✅ Works with any state management (Riverpod)
- ✅ Web support (same routes work on web + mobile)

### Navigation Structure
```
/ (dashboard)
├── /projects (list)
│   ├── /projects/:id (detail)
│   └── /projects/new (modal)
├── /tasks (list)
│   └── /tasks/:id (detail)
├── /maintenance (list)
├── /quality (checklist)
├── /map
└── /login (entry point)
```

### Implementation Status
🟢 **APPROVED** - Use GoRouter for all navigation

---

## Decision 4: Freezed for Immutable Entities

### Decision
All entities MUST be immutable using **Freezed code generation**.

### Alternatives Considered
1. **Manual Freezed** - More control, more boilerplate
2. **Equatable Package** - Good for equality, requires manual copyWith()
3. **JSON Serializable only** - No equality/copyWith, more bugs
4. **Mutable classes** - Simple initially, causes state mutation bugs

### Rationale
- ✅ Auto-generates: copyWith(), equality, toString(), hashCode
- ✅ Immutability prevents accidental state mutations
- ✅ Integrates seamlessly with JSON serialization
- ✅ Freezed unions for Either<Error, Success> pattern
- ✅ Reduces bugs (can't accidentally modify entity)
- ✅ Works perfectly with Riverpod's value comparison

### Example
```dart
@freezed
class Project with _$Project {
  const factory Project({
    required String name,
    required ProjectStatus status,
  }) = _Project;
}

// Auto-generated:
// - copyWith() for immutable updates
// - == and hashCode for value equality
// - toString() for debugging
// - fromJson/toJson for serialization
```

### Implementation Status
🟢 **APPROVED** - Mandatory for all entities

---

## Decision 5: Dio HTTP Client (NOT http or dio_http_package)

### Decision
Use **Dio** for all HTTP requests (with custom interceptors).

### Alternatives Considered
1. **http package** - Built-in but minimal features, no interceptors
2. **Chopper** - Code generation wrapper, adds complexity
3. **Custom HttpClient** - Too much boilerplate

### Rationale
- ✅ Interceptors for auth, logging, error handling (request/response pipeline)
- ✅ Automatic retry logic (exponential backoff)
- ✅ Request/response transformation
- ✅ Timeout handling and cancellation
- ✅ Form data, multipart uploads
- ✅ Industry standard (used in 100K+ Flutter apps)
- ✅ Can mock for testing easily

### Interceptor Chain
```
Request → AuthInterceptor → LoggingInterceptor → Server
Response ← AuthInterceptor ← LoggingInterceptor ← Server
```

### Implementation Status
🟢 **APPROVED** - Mandatory for all HTTP

---

## Decision 6: Drift + Hive for Data Persistence

### Decision
Use **Drift (SQLite)** for relational data + **Hive** for app cache + preferences.

### Alternatives Considered
1. **Firebase Realtime DB** - Cloud-only, dependent on backend
2. **Sqflite** - Works but less type-safe than Drift
3. **ObjectBox** - Great but less mature than Drift
4. **Isar** - New and fast but fewer examples

### Rationale
**Drift (SQLite)**:
- ✅ Type-safe queries (SQL generation at compile-time)
- ✅ Relational schema (projects, tasks, maintenance with foreign keys)
- ✅ Transactions for data consistency
- ✅ Migration strategy (schema versioning)
- ✅ Offline-first caching layer

**Hive**:
- ✅ Ultra-fast key-value store (no SQL)
- ✅ Stores objects natively (JSON serialization)
- ✅ Zero-touch encryption
- ✅ Perfect for: tokens, preferences, cache TTL

### Data Model
```
Drift (Relational):
├── Projects (name, type, status, budget, dates)
├── Tasks (title, priority, dueDate, projectId)
├── Maintenance (name, dueDate, status)
├── Users (email, role, avatarUrl)
└── Teams (projectId, members)

Hive (Key-Value):
├── authTokens (access_token, refresh_token)
├── userPreferences (language, theme, notifications)
├── lastSyncTime (timestamp)
└── offlineQueue (sync mutations when reconnect)
```

### Implementation Status
🟢 **APPROVED** - Drift for structured data, Hive for preferences

---

## Decision 7: Either Pattern (dartz) for Error Handling

### Decision
Use **Either<Left, Right>** functional pattern for error handling (NOT try-catch in UI layer).

### Alternatives Considered
1. **Exceptions everywhere** - Simpler initially, unpredictable failures
2. **Result<T> wrapper** - Similar to Either, fewer libraries
3. **Optional<T> (null-safety)** - Doesn't convey error info

### Rationale
- ✅ Forces error handling (compiler error if not handled)
- ✅ Error info flows through UI layer (snackbar messages)
- ✅ No uncaught exceptions in user layer
- ✅ Functional programming pattern (pure functions)
- ✅ Clear error → Success path

### Pattern
```dart
Future<Either<AppException, Project>> createProject(...) async {
  try {
    final project = await repo.create(...);
    return Right(project); // Success
  } on AppException catch (e) {
    return Left(e); // Error
  }
}

// Usage in UI:
result.fold(
  (error) => showSnackBar(error.message), // Left branch
  (project) => navigateBack(), // Right branch
);
```

### Implementation Status
🟢 **APPROVED** - Mandatory for all use cases

---

## Decision 8: Material 3 Design System (NOT custom components)

### Decision
Use **Flutter's built-in Material 3 components** (NOT custom Material Design wrapper).

### Alternatives Considered
1. **Custom component library** - Full control, massive maintenance burden
2. **Figma → Flutter** - Beautiful but time-consuming
3. **Material 2** - Outdated by Flutter 3.10

### Rationale
- ✅ Google-designed, WCAG AA accessibility built-in
- ✅ System fonts (Segoe UI, San Francisco, Roboto) auto-selected per platform
- ✅ Dark mode automatic (system preference)
- ✅ Responsive breakpoints (600px, 840px+ for tablets)
- ✅ Reduce custom CSS-like theming
- ✅ Consistent with Android 12+ design language

### Provided Components
```
Buttons: ElevatedButton, OutlinedButton, TextButton, FilledButton
Inputs: TextField, DropdownMenu, Checkbox, Radio, Slider
Containers: Card, ListTile, Chip
Modals: AlertDialog, ModalBottomSheet, SnackBar
Navigation: BottomNavigationBar, NavigationRail, Tabs
```

### Implementation Status
🟢 **APPROVED** - Use Material 3 for all UI

### Reference
UI_UX_GUIDELINES.md (color palette, typography, spacing, components)

---

## Decision 9: Automated Testing (80%+ Coverage Required)

### Decision
Require **80%+ code coverage** on Domain + Data layers, selective coverage on Presentation.

### Alternatives Considered
1. **No automated tests** - Faster initially, becomes unmaintainable
2. **100% coverage everywhere** - Overkill for UI layer
3. **Manual testing only** - Slow, unreliable, doesn't scale

### Rationale
- ✅ Domain layer (entities, use cases): 100% coverage critical
- ✅ Data layer (repositories, datasources): 100% coverage critical
- ✅ Presentation layer: Test complex screens (detail, forms), skip pure widgets
- ✅ Catch regression before testing
- ✅ Refactor safely
- ✅ Documentation (tests show how to use)

### Test Pyramid
```
       △ (Manual testing)
      User flows, integration tests
     
    ▼ (Widget tests)
   Complex screens, forms, navigation
   
  ▼ (Unit tests)
 Use cases, repositories, entities
└────────────────────────┘  ← 100% coverage required
```

### Tools
- **flutter_test** (built-in)
- **mockito** (mocking)
- **riverpod_test** utilities

### Implementation Status
🟢 **APPROVED** - 80%+ coverage gate for Phase 8 release

---

## Decision 10: Monorepo vs Separate Repositories

### Decision
**Single Flutter repository** (NOT separate frontend/backend monorepo).

### Rationale
- ✅ Flutter app is self-contained
- ✅ Easier to build, test, deploy
- ✅ Backend separate (microservices or monolithic backend repo)
- ✅ CI/CD simpler (only build Flutter when Dart code changes)
- ✅ Team ownership (Flutter team owns this repo)

### Repository Structure
```
architecture-hub-flutter/
├── lib/                    (all Flutter code)
├── test/                   (all tests)
├── pubspec.yaml
├── analysis_options.yaml   (linter rules)
├── .github/workflows/      (CI/CD)
├── README.md
├── CLAUDE.md              (AI reference)
├── ARCHITECTURE.md        (design docs)
└── docs/                  (architecture, guides)

Backend → separate repository (architecture-hub-backend)
```

### Implementation Status
🟢 **APPROVED** - Create new repository for Flutter code

---

## Summary of All Decisions

| # | Decision | Status | Blocker? |
|---|----------|--------|----------|
| 1 | Clean Architecture (6-layer) | ✅ Approved | No |
| 2 | Riverpod state management | ✅ Approved | No |
| 3 | GoRouter navigation | ✅ Approved | No |
| 4 | Freezed immutability | ✅ Approved | No |
| 5 | Dio HTTP client | ✅ Approved | No |
| 6 | Drift + Hive persistence | ✅ Approved | No |
| 7 | Either pattern (error handling) | ✅ Approved | No |
| 8 | Material 3 design system | ✅ Approved | No |
| 9 | 80%+ test coverage | ✅ Approved | No |
| 10 | Single Flutter repository | ✅ Approved | No |

**All decisions approved. No blockers. Ready to proceed with Phase 1.**

---
