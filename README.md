# ArchitectHub Flutter Migration

This repository is initialized for Phase 1 foundation work. The stock Flutter starter has been replaced with a Clean Architecture scaffold aligned to the migration docs.

The codebase now follows a **feature-first** structure:

- `lib/app`
- `lib/core`
- `lib/shared`
- `lib/features/<feature_name>/{data,domain,presentation}`
- `lib/main.dart`

## Progress Report

Initialized in this pass:

- Approved foundation dependencies in `pubspec.yaml`
- Strict `lib/` architecture centered on `app`, `core`, `shared`, and feature-owned modules
- Riverpod bootstrap and app-wide providers
- GoRouter flow with guarded splash/login entry and an authenticated tab shell
- Material 3 theme scaffold with documented color and spacing tokens
- Dio client scaffold with logging/error interception hooks
- Hive preferences bootstrap
- Drift local database bootstrap plus generated files
- Freezed/build_runner/json_serializable pipeline verification

Added in the latest Phase 1 foundation pass:

- Environment/config scaffold via `AppConfig` and `dart-define` support
- Global error bootstrap for framework, platform, and zoned exceptions
- Auth module skeleton across datasource, repository, use case, and provider boundaries
- Splash/loading entry flow with startup-driven router redirects
- Dedicated auth session storage box separate from general preferences

Added in the current Phase 1 foundation hardening pass:

- Stronger bootstrap flow with explicit bootstrap failure wrapping
- Finalized config scaffold with environment labels, app title handling, and log toggles
- Finalized logger/error scaffolding with app logger initialization and fuller navigation/error tracing
- Finalized theme foundation with richer design tokens, button/input/snackbar styling, and text theme defaults
- Real splash flow with branded loading UI and ordered startup checks for bootstrap, config, and auth/session state
- Auth skeleton retained with mock-backed login, session restore, guarded routing, logout handling, and entry into the authenticated shell
- Modernized login experience with stronger visual hierarchy, password visibility toggle, calmer inline error treatment, and improved submit/validation states
- Router scope tightened to Phase 1 foundation paths only instead of exposing later-phase screens

Demo auth mode behavior:

- Sign-in currently uses local mock auth only; no real backend connection is required
- Valid demo credentials are `user@example.com` / `securePassword123`
- If `Keep me signed in` is enabled, the mock session is persisted and restored on next launch
- If `Keep me signed in` is disabled, sign-in still succeeds for the current app session but is not restored after relaunch

Added in the current dashboard foundation pass:

- Replaced the dashboard placeholder with a real post-auth product screen foundation inside the dashboard feature
- Added a dashboard-local mock datasource, repository abstraction, and provider for clean future backend integration
- Implemented structured dashboard sections for welcome context, project summary, active projects, quick status, upcoming work, recent updates, and quick actions
- Added dashboard loading, empty, and error states so the screen behaves like a real product surface instead of a static mock page

Added in the current projects foundation pass:

- Replaced the projects placeholder with a real mobile-first projects list screen inside the projects feature
- Added a projects-local mock datasource, repository abstraction, and provider flow for future backend connection
- Implemented searchable, filterable project cards with loading, empty, and error states
- Wired the projects screen into the authenticated shell so the list foundation is reachable

Added in the current authenticated-shell pass:

- Replaced standalone post-login dashboard entry with a real authenticated app shell in `lib/app/navigation/`
- Added bottom navigation foundation for dashboard, projects, tasks, map, and profile
- Made dashboard the default tab after login and after authenticated splash restore
- Chose `tasks` as the temporary third operations tab for now; maintenance remains a separate feature until its deeper implementation phase

Remaining next, per `IMPLEMENTATION_PHASES.md`:

1. Finish automatic refresh-token handling and 401 retry flow.
2. Expand the dashboard from static mock foundations into connected project/task data once those feature contracts are ready.
3. Build the project details foundation and connect project-card entry points once that feature starts.
4. Deepen each authenticated shell tab from foundation state into its full feature flow, starting with projects.
5. Add session timeout and re-auth behavior once backend refresh rules are confirmed.
6. Add CI and pre-commit automation once the foundation stabilizes.

## Notes

- Hive is scaffolded without `hive_generator`; it conflicts with the compatible Drift/codegen toolchain on the current Flutter/Dart setup.
- Drift is present as a foundation database shell only. Feature tables remain scheduled for later phases.
- Auth currently runs on a mock datasource by default. Use `user@example.com` / `securePassword123` for the Phase 1 login flow until backend auth is confirmed.
- The active top-level `lib/` shape is limited to `app`, `core`, `shared`, `features`, and `main.dart`.

## Suggested Next Commands

```bash
flutter analyze
flutter test
flutter run
```
