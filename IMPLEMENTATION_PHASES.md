# IMPLEMENTATION_PHASES.md - Complete 12-Phase Migration Plan

## Overview

Structured 12-phase migration from React Native to Flutter, with ~3-4 weeks per phase. Total timeline: 8-12 weeks for full MVP + additional features. Each phase includes specific screens, data models, and integration tasks.

---

## Phase Summary Table

| Phase | Name | Duration | Tasks | Screens | Status | Go/No-Go |
|-------|------|----------|-------|---------|--------|----------|
| 1 | Foundation & Auth | 3 weeks | 8 | Login, Dashboard | ⬜ TODO | Required |
| 2 | Projects Core | 3 weeks | 12 | Projects List/Detail | ⬜ TODO | Required |
| 3 | Data Persistence | 2 weeks | 6 | Database setup | ⬜ TODO | Required |
| 4 | Tasks & Maintenance | 3 weeks | 11 | Tasks, Maintenance screens | ⬜ TODO | Required |
| 5 | Quality & Analytics | 3 weeks | 9 | Quality, Analytics screens | ⬜ TODO | Required |
| 6 | Maps Integration | 2 weeks | 5 | Map screen | ⬜ TODO | MVP Complete |
| 7 | Backend Integration | 2 weeks | 8 | API calls | ⬜ TODO | Core +1 |
| 8 | Testing & Polish | 2 weeks | 10 | Tests, bug fixes | ⬜ TODO | Core +2 |
| 9 | Performance & Optimization | 1 week | 5 | Caching, lazy loading | ⬜ TODO | Optional |
| 10 | Advanced Features | 2 weeks | 8 | Notifications, offline | ⬜ TODO | Optional |
| 11 | Security & Auth | 1 week | 4 | 2FA, encryption | ⬜ TODO | Optional |
| 12 | Release & Deployment | 1 week | 5 | Beta testing, store setup | ⬜ TODO | Release |

**Total**: 86 tasks across 12 phases  
**MVP (Phase 6)**: Full working app with all 6 core screens  
**Production (Phase 8)**: All tests passing, performance optimized

---

## PHASE 1: Foundation & Auth (3 weeks)

### Progress Update - 2026-03-16

- Phase 1 foundation setup has started and the repository is now on the Flutter architecture scaffold instead of the default template.
- Completed in this pass: dependency wiring, `lib/` architecture folders, Riverpod bootstrap, GoRouter shell, Material 3 theme scaffold, Dio client scaffold, Hive preferences bootstrap, Drift database bootstrap, generated-code pipeline, and placeholder Phase 1 screens/routes.
- Still pending inside Phase 1: auth flows, login form implementation, route guards, dashboard content, full 12-route matrix, CI, and pre-commit automation.

### Objectives
- Set up Flutter project structure (Clean Architecture)
- Implement authentication system (JWT-based)
- Create login screen
- Build dashboard with hardcoded data
- Complete Riverpod + GoRouter setup

### Tasks

**[1-A] Flutter Project Setup**
- [x] Create new Flutter project
- [x] Configure pubspec.yaml dependencies (Riverpod, GoRouter, Freezed, Drift, Dio, etc.)
- [x] Organization: lib/ folder structure (domain/, data/, presentation/, core/)
- [x] Set up code generation (build_runner, freezed, json_serializable)
- [ ] GitHub workflow for CI/CD
- [ ] Pre-commit hooks (dart format, dart analyze)
- Progress note: The foundation scaffold and approved package stack are initialized in the repo.
- **Block**: On: Any blocking issue  
- **Est. Time**: 3 days

**[1-B] Auth Provider & JWT Setup**
- [ ] Create JWT token storage (Hive)
- [ ] Implement token refresh mechanism
- [ ] Create auth exception types and error handling
- [ ] Riverpod auth provider (currentUserProvider)
- [ ] Session timeout handling
- [ ] Re-auth flow when token expired
- **Est. Time**: 5 days

**[1-C] Login Screen UI**
- [ ] Build login form (email + password)
- [ ] Form validation (email format, password length)
- [ ] Loading state during login
- [ ] Error message display
- [ ] Remember me checkbox
- [ ] Responsive layout (mobile + tablet)
- **Est. Time**: 4 days

**[1-D] Login Backend Integration**
- [ ] Create AuthRemoteDatasource (Dio client)
- [ ] POST /auth/login endpoint
- [ ] JWT token extraction and storage
- [ ] Handle auth errors (invalid creds, network error)
- [ ] Automatic token refresh
- **Est. Time**: 3 days

**[1-E] Dashboard Screen V1**
- [ ] Dashboard layout (header, cards, lists)
- [ ] Static data (5 projects, 4 tasks)
- [ ] Project summary card (count by status)
- [ ] Task summary (count by priority)
- [ ] Team member grid (4 static members)
- [ ] Recent activities list
- **Est. Time**: 4 days

**[1-F] Theme & Design Tokens**
- [ ] Implement Material 3 theme
- [ ] Color palette from React Native
- [ ] Typography system (8 text styles)
- [ ] Spacing constants (8-point grid)
- [ ] AppBar styling
- Progress note: Material 3 theme, documented palette, and spacing constants are now scaffolded.
- **Est. Time**: 2 days

**[1-G] Navigation Setup**
- [ ] GoRouter configuration with 12+ routes
- [ ] Tab navigation (6 bottom tabs)
- [ ] Modal push behavior
- [ ] Route guards (only authenticated users)
- [ ] Deep linking setup
- Progress note: A minimal bottom-tab app shell exists for dashboard, projects, tasks, maintenance, quality, and login placeholder flows.
- **Est. Time**: 3 days

**[1-H] Error Handling & Logging**
- [ ] AppException hierarchy
- [ ] Dio error interceptor
- [ ] App-wide logger
- [ ] Error UI (SnackBar, dialogs)
- [ ] Firebase Crashlytics (optional)
- Progress note: Exception, logger, and HTTP interceptor scaffolds are in place; user-facing error flows remain for a later Phase 1 step.
- **Est. Time**: 2 days

### Deliverables
- ✅ Login screen (working)
- ✅ Dashboard screen (static data)
- ✅ Complete folder structure
- ✅ All 12 routes configured
- ✅ Auth token storage & refresh

### Go/No-Go Criteria
- ✅ User can login with test account
- ✅ Dashboard displays after login
- ✅ Logout clears session
- ✅ All 6 bottom tabs visible
- ✅ No build errors (dart analyze clean)

---

## PHASE 2: Projects Core (3 weeks)

### Objectives
- Display projects list with search/filter
- Show project details with tabs
- Create/edit projects (forms)
- Implement Zustand-like state management (Riverpod)

### Tasks

**[2-A] Project Entity & Models**
- [ ] Domain entity: Project (Freezed)
- [ ] API model: ProjectModel (JSON serializable)
- [ ] ProjectStatus enum (pending, in_progress, completed)
- [ ] ProjectType enum (residential, commercial, industrial)
- [ ] Mapper: ProjectModel → Project
- **Est. Time**: 2 days

**[2-B] Project Remote Datasource**
- [ ] GET /projects (list with pagination)
- [ ] GET /projects/:id (detail)
- [ ] POST /projects (create)
- [ ] PUT /projects/:id (update)
- [ ] DELETE /projects/:id (delete)
- [ ] Search: GET /projects?search=term
- [ ] Filter: GET /projects?type=residential
- **Est. Time**: 3 days

**[2-C] Project Local Datasource (Drift)**
- [ ] Projects table schema (Drift)
- [ ] Cache operations (insert, update, delete, query)
- [ ] Index on status and type for fast filtering
- **Est. Time**: 2 days

**[2-D] Project Repository**
- [ ] ProjectRepository interface (domain/)
- [ ] ProjectRepositoryImpl (data/)
- [ ] Fallback to cache on network error
- **Est. Time**: 2 days

**[2-E] Project Use Cases**
- [ ] GetAllProjectsUsecase
- [ ] GetProjectByIdUsecase
- [ ] SearchProjectsUsecase
- [ ] CreateProjectUsecase
- [ ] UpdateProjectUsecase
- [ ] DeleteProjectUsecase
- **Est. Time**: 3 days

**[2-F] Project Riverpod Providers**
- [ ] projectsProvider (FutureProvider, list all)
- [ ] projectDetailProvider (FamilyFutureProvider, by id)
- [ ] projectSearchProvider (search state)
- [ ] projectFilterProvider (filter state)
- **Est. Time**: 2 days

**[2-G] Projects List Screen**
- [ ] Display project list cards
- [ ] Search bar with debounce (200ms)
- [ ] Filter chips (All, Residential, Commercial, Industrial)
- [ ] Sort dropdown
- [ ] Loading skeleton
- [ ] Empty state
- [ ] Pull-to-refresh
- [ ] Pagination (load more)
- **Est. Time**: 5 days

**[2-H] Project Detail Screen**
- [ ] Tab navigation (Overview, Timeline, Team, History)
- [ ] Overview: project info, status, budget, description
- [ ] Timeline: dates, progress bar
- [ ] Team: assigned members
- [ ] History: recent changes
- [ ] Edit button (navigate to edit form)
- [ ] Delete button (with confirmation)
- **Est. Time**: 5 days

**[2-I] Add/Edit Project Form Screen**
- [ ] Form fields (name, type, status, location, budget, dates, description)
- [ ] Form validation
- [ ] Date picker for start/end dates
- [ ] Dropdown for type and status
- [ ] Keyboard handling
- [ ] Save and Cancel buttons
- [ ] Success/error messages
- **Est. Time**: 4 days

**[2-J] Project Reusable Widgets**
- [ ] ProjectCard widget (list item)
- [ ] ProjectBadge (status/type display)
- [ ] ProjectFilterChips (filter row)
- **Est. Time**: 2 days

**[2-K] Integration Tests**
- [ ] Projects list displays correctly
- [ ] Search filters projects
- [ ] Create new project works
- [ ] Edit project works
- [ ] Delete project works
- [ ] Navigation works (tap card → detail)
- **Est. Time**: 3 days

**[2-L] Mock Backend (if no real API)**
- [ ] Create mock_server.dart with 5 hardcoded projects
- [ ] Simulate network delays (200-500ms)
- [ ] Handle create/update/delete locally
- **Est. Time**: 2 days

### Deliverables
- ✅ Projects list screen (working + filtering)
- ✅ Project detail screen (tabs working)
- ✅ Create/edit project forms (validation working)
- ✅ Riverpod providers for projects
- ✅ Drift database schema for projects

### Go/No-Go Criteria
- ✅ List displays 5+ projects with search/filter
- ✅ Tap project → detail view opens
- ✅ Can create new project via form
- ✅ Can edit existing project
- ✅ Can delete project with confirmation
- ✅ Offline cache works (show cached data if no internet)

---

## PHASE 3: Data Persistence & Caching (2 weeks)

### Objectives
- Implement complete Drift database schema (9 tables)
- Set up Hive for app preferences/cache
- Implement offline-first caching strategy
- Test data sync and conflict resolution

### Tasks

**[3-A] Drift Database Schema**
- [ ] Projects table (with indexes)
- [ ] Tasks table
- [ ] Maintenance table
- [ ] QualityChecklistItems table
- [ ] Users table
- [ ] Teams table
- [ ] Create indexes for fast queries
- [ ] Set up migration strategy (versioning)
- **Est. Time**: 3 days

**[3-B] Hive Setup for Preferences**
- [ ] User preferences (language, theme, notifications)
- [ ] App settings (last sync time, offline mode)
- [ ] Token storage (JWT)
- **Est. Time**: 1 day

**[3-C] Offline-First Caching**
- [ ] Implement cache-then-network strategy
- [ ] Timestamp tracking for cached data
- [ ] Stale data detection (24-hour TTL)
- [ ] Cache invalidation on update
- **Est. Time**: 3 days

**[3-D] Data Sync Strategy**
- [ ] Queue system for offline mutations
- [ ] Sync queue on network reconnection
- [ ] Conflict resolution (server wins)
- [ ] Retry logic with exponential backoff
- **Est. Time**: 3 days

**[3-E] Migration from Phase 2 Hardcoded Data**
- [ ] Migrate 5 hardcoded projects to Drift
- [ ] Migrate 4 hardcoded tasks
- [ ] Migrate team data
- [ ] Data seed script for local testing
- **Est. Time**: 1 day

**[3-F] Testing Data Layer**
- [ ] Unit tests for repository
- [ ] Integration tests for Drift
- [ ] Cache invalidation tests
- [ ] Offline mode tests
- **Est. Time**: 3 days

### Deliverables
- ✅ Drift database with 9 tables
- ✅ Hive preferences storage
- ✅ Offline caching working
- ✅ Data sync on reconnect
- ✅ Migration scripts

### Go/No-Go Criteria
- ✅ App works offline (shows cached data)
- ✅ Creates queue for new projects while offline
- ✅ Syncs on network reconnect
- ✅ No data loss during offline period
- ✅ No duplicate data after sync

---

## PHASE 4: Tasks & Maintenance (3 weeks)

### Objectives
- Complete tasks feature (list, detail, create, mark complete)
- Implement maintenance tracking
- Task + maintenance API integration
- Task assignment and priority

### Tasks

**[4-A] Task Entity & Models** (2 days)
- [ ] Task Freezed entity
- [ ] TaskModel API model
- [ ] Priority enum (high, medium, low)
- [ ] TaskStatus enum
- [ ] Mapper

**[4-B] Task Use Cases** (2 days)
- [ ] GetAllTasksUsecase
- [ ] GetTaskByIdUsecase
- [ ] CreateTaskUsecase
- [ ] UpdateTaskUsecase
- [ ] CompleteTaskUsecase
- [ ] DeleteTaskUsecase

**[4-C] Task Screens** (5 days)
- [ ] Tasks list (with priority badges)
- [ ] Task detail screen
- [ ] Create task form
- [ ] Edit task form
- [ ] Mark complete button

**[4-D] Maintenance Entity & Models** (2 days)
- [ ] Maintenance Freezed entity
- [ ] MaintenanceModel API model
- [ ] MaintenanceStatus enum
- [ ] Mapper

**[4-E] Maintenance Use Cases** (2 days)
- [ ] GetAllMaintenanceUsecase
- [ ] CreateMaintenanceUsecase
- [ ] UpdateMaintenanceUsecase
- [ ] CompleteMaintenanceUsecase

**[4-F] Maintenance Screens** (4 days)
- [ ] Maintenance list
- [ ] Maintenance detail
- [ ] Schedule maintenance form
- [ ] Maintenance history

**[4-G] Task Assignment** (2 days)
- [ ] Assign task to team member
- [ ] Show assigned user in task card
- [ ] Filter tasks by assigned user

**[4-H] Integration Tests** (3 days)
- [ ] Tasks list displays
- [ ] Create task works
- [ ] Mark complete works
- [ ] Maintenance works same as tasks

**[4-I] Dashboard Update** (2 days)
- [ ] Update dashboard to use real tasks (not hardcoded)
- [ ] Update task summary counts
- [ ] Show recent tasks in dashboard

**[4-J] Riverpod Providers** (2 days)
- [ ] tasksProvider
- [ ] maintenanceProvider
- [ ] Task and maintenance state management

**[4-K] Reusable Widgets** (2 days)
- [ ] TaskCard widget
- [ ] TaskPriorityBadge
- [ ] MaintenanceCard
- [ ] MaintenanceStatusBadge

**[4-L] API Integration** (2 days)
- [ ] Task endpoints
- [ ] Maintenance endpoints
- [ ] Pagination for both

### Deliverables
- ✅ Tasks list + detail screens
- ✅ Maintenance list + detail screens
- ✅ Create/edit/delete for both
- ✅ Mark complete functionality
- ✅ Real data instead of hardcoded

### Go/No-Go Criteria
- ✅ Tasks display correctly
- ✅ Can create new task
- ✅ Can mark task complete
- ✅ Maintenance works same as tasks
- ✅ Dashboard reflects real data

---

## PHASE 5: Quality Checklist & Analytics (3 weeks)

### Objectives
- Implement quality checklist with categories
- Analytics screens with charts
- Implement fl_chart for visualizations
- Generate reports

### Tasks

**[5-A] Quality Checklist Backend** (2 days)
- [ ] QC item entity (Freezed)
- [ ] Store QC item state in Drift
- [ ] Save completed checklist instances

**[5-B] Quality Checklist Screen** (3 days)
- [ ] Display 26 items in 4 categories
- [ ] Checkbox toggle UI (persists on API call)
- [ ] Category tabs
- [ ] Calculate completion %
- [ ] Save QC session button

**[5-C] QC History & Reports** (2 days)
- [ ] Store QC instances with timestamps
- [ ] Display past QC sessions
- [ ] Basic report generation

**[5-D] Analytics Data Model** (1 day)
- [ ] Analytics entity with aggregated metrics
- [ ] API endpoint for analytics data

**[5-E] Chart Library Setup** (1 day)
- [ ] Add fl_chart to pubspec.yaml
- [ ] Configure chart styles

**[5-F] Analytics Screens** (4 days)
- [ ] Revenue chart (line chart)
- [ ] Performance metrics (bar chart)
- [ ] Budget tracking (progress bar)
- [ ] Resource utilization (gauge)

**[5-G] Date Range Filter** (2 days)
- [ ] Date range picker for analytics
- [ ] Filter charts by date range

**[5-H] Offline Support** (1 day)
- [ ] Quality checklist works offline
- [ ] Syncs when online

**[5-I] Testing** (3 days)
- [ ] Checklist items toggle correctly
- [ ] Charts render with mock data
- [ ] Reports generate correctly

### Deliverables
- ✅ Quality checklist screen (working)
- ✅ Analytics with charts
- ✅ QC history tracking
- ✅ Report generation

### Go/No-Go Criteria
- ✅ Checklist displays 26 items correct
- ✅ Can check/uncheck items
- ✅ Save persists data
- ✅ Charts display (with mock data initially)
- ✅ Date range filter works

---

## PHASE 6: Maps Integration (2 weeks) ⭐ MVP Complete

### Objectives
- Integrate Google Maps Flutter
- Display project locations on map
- Implement marker tapping and navigation
- **MVP Release After This Phase**

### Tasks

**[6-A] Google Maps Setup** (2 days)
- [ ] Add google_maps_flutter to pubspec
- [ ] Configure Google Maps API keys (Android + iOS)
- [ ] Platform-specific setup

**[6-B] Map Screen UI** (2 days)
- [ ] GoogleMap widget
- [ ] Marker creation for projects
- [ ] Marker info windows
- [ ] List of locations below map

**[6-C] Tap Handlers** (2 days)
- [ ] Tap marker → show project details
- [ ] Tap location in list → highlight marker
- [ ] Navigate to project detail screen

**[6-D] Location Data** (1 day)
- [ ] Add location field to projects
- [ ] Latitude/longitude storage
- [ ] Geocoding (future enhancement)

**[6-E] Marker Clustering** (1 day)
- [ ] Cluster markers when zoomed out (if 10+)

**[6-F] Testing** (2 days)
- [ ] Map displays correctly
- [ ] Markers show
- [ ] Tap navigation works

### Deliverables
- ✅ Working map screen
- ✅ Interactive markers
- ✅ Location navigation

### Go/No-Go Decision 🚀 MVP RELEASE
- ✅ All 6 core screens working
- ✅ Full CRUD for projects, tasks, maintenance
- ✅ Quality checklist functional
- ✅ Analytics with charts
- ✅ Maps with navigation
- ✅ Offline caching
- ✅ 90%+ code coverage

**FULL FEATURE-COMPLETE MVP RELEASE** → Do Beta Testing & Gather Feedback

---

## PHASE 7: Backend Integration & API (2 weeks)

### Objectives
- Replace all mock APIs with real backend
- Implement proper error handling
- API contract testing
- Performance optimization

### Tasks

**[7-A] API Contract Finalization** (2 days)
- [ ] Define all endpoints
- [ ] Request/response formats
- [ ] Error code standards
- [ ] Pagination format

**[7-B] Implement All Remote Datasources** (4 days)
- [ ] ProjectRemoteDatasource (full CRUD)
- [ ] TaskRemoteDatasource
- [ ] MaintenanceRemoteDatasource
- [ ] QCRemoteDatasource
- [ ] AnalyticsRemoteDatasource

**[7-C] Error Interceptor** (2 days)
- [ ] Handle 400, 401, 403, 404, 500 errors
- [ ] Refresh token on 401
- [ ] Show user-friendly error messages

**[7-D] Request/Response Logging** (1 day)
- [ ] Log all API calls (development only)
- [ ] Log response times

**[7-E] Mock Server → Real Backend** (1 day)
- [ ] Remove mock datasources
- [ ] Switch to real API endpoints

**[7-F] Testing Real API** (3 days)
- [ ] Test all CRUD operations
- [ ] Test error cases
- [ ] Performance testing

**[7-G] Data Migration** (1 day)
- [ ] Migrate existing cached data to new format (if needed)

**[7-H] Documentation** (1 day)
- [ ] API integration guide
- [ ] Error handling documentation

### Deliverables
- ✅ All APIs functional
- ✅ Real data flowing through app
- ✅ Error handling complete
- ✅ Performance acceptable

### Go/No-Go Criteria
- ✅ All CRUD operations work with real API
- ✅ Error messages user-friendly
- ✅ No crashes on network errors
- ✅ Response times < 3 seconds

---

## PHASE 8: Testing & Polish (2 weeks)

### Objectives
- 80%+ code coverage
- Bug fixes and polish
- Performance optimization
- UX refinement

### Tasks

**[8-A] Unit Tests** (3 days)
- [ ] Entity tests
- [ ] Use case tests
- [ ] Repository tests
- [ ] Provider tests

**[8-B] Widget Tests** (3 days)
- [ ] Screen widgets
- [ ] Reusable widget components
- [ ] Form validation

**[8-C] Integration Tests** (2 days)
- [ ] Full user flows
- [ ] Offline/online transitions

**[8-D] Bug Fixes** (2 days)
- [ ] Fix reported issues
- [ ] Edge case handling

**[8-E] UX Polish** (2 days)
- [ ] Loading states consistent
- [ ] Error messages clear
- [ ] Animations smooth
- [ ] Touch targets 44×44px

**[8-F] Accessibility** (1 day)
- [ ] Screen reader support
- [ ] Color contrast
- [ ] Keyboard navigation

**[8-G] Performance Testing** (2 days)
- [ ] List scrolling smooth (60fps)
- [ ] Memory leaks check
- [ ] Battery usage check

**[8-H] Release Candidate Build** (1 day)
- [ ] Build apk + ipa
- [ ] Test on real devices

**[8-I] Documentation Update** (1 day)
- [ ] README updates
- [ ] Setup guide for devs

**[8-J] Security Review** (1 day)
- [ ] Dependency vulnerabilities
- [ ] Secure token storage
- [ ] Input validation

### Deliverables
- ✅ 80%+ test coverage
- ✅ Release candidate build
- ✅ All bugs fixed
- ✅ Performance optimized

### Go/No-Go Criteria
- ✅ 80%+ test coverage
- ✅ No crashes in 1-hour testing
- ✅ Dart analyze shows 0 issues
- ✅ Performance: list scrolls at 60fps
- ✅ Ready for production release

---

## PHASE 9: Performance & Optimization (1 week)

### Objectives
- Advanced caching strategies
- Lazy loading and pagination
- Image optimization
- Memory optimization

### Tasks (Optional - can defer)

**[9-A] Image Caching**  
- [ ] Implement CachedNetworkImage

**[9-B] Lazy Loading**  
- [ ] Lazy load projects on scroll

**[9-C] Database Optimization**  
- [ ] Query optimization

**[9-D] Build Size Optimization**  
- [ ] Tree shake unused code

**[9-E] Analytics**  
- [ ] Firebase Analytics

---

## PHASE 10-12: Advanced Features & Release

### Phase 10: Advanced Features (2 weeks)
- Push notifications (Firebase Cloud Messaging)
- Offline-first sync improvements
- Notification preferences

### Phase 11: Security & Auth Enhancement (1 week)
- Two-factor authentication
- Biometric login
- Enhanced encryption

### Phase 12: Release & Deployment (1 week)
- Beta testing
- Google Play & App Store submission
- Marketing materials
- Launch preparation

---

## Critical Path Analysis

**Must Complete In Order**:
1. Phase 1 (Auth) → ALL others depend on it
2. Phase 2 (Projects) → MVP feature
3. Phase 3 (Data) → Required before Phase 7
4. Phase 4 (Tasks) → MVP feature
5. Phase 5 (QC) → MVP feature
6. Phase 6 (Maps) → MVP release gate
7. Phase 7 (API) → Production requirement
8. Phase 8 (Testing) → Release requirement

**Can Parallelize**:
- Phase 2, 4, 5 (UI screens) - can work in parallel with different developers
- Phase 9-11 (advanced features) - can be worked on while Phase 8 testing

---

## Resource Allocation

**1 Developer**: 8-12 weeks (sequential)  
**2 Developers**: 4-6 weeks (parallel architecture + screens)  
**3 Developers**: 3-4 weeks (auth + projects + tasks simultaneous)

---

## Success Metrics

| Metric | Target | Phase | Owner |
|--------|--------|-------|-------|
| Code Coverage | 80%+ | 8 | QA |
| Test Pass Rate | 100% | 8 | Devs |
| Performance (list scroll) | 60 fps | 9 | Devs |
| Crash Rate | < 0.0001% | 8 | QA |
| API Response Time | < 2s | 7 | Backend |
| User Stories Completed | 89 features | 12 | PM |
| Security Audit | Pass | 11 | Security |

---
