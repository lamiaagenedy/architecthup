# MIGRATION_PLAN.md - React Native to Flutter Migration Strategy

## Overview

Detailed migration strategy from React Native ArchitectHub to Flutter, including entity mapping, breaking changes, and migration timeline.

---

## Migration Approach: Big Bang (Not Gradual)

**Type**: Complete rewrite in Flutter (not hybrid approach)

**Rationale**:
- ✅ Clean architecture opportunity
- ✅ No legacy React Native code to maintain
- ✅ Simpler team onboarding (single codebase)
- ✅ Better performance (Flutter native)
- ❌ RN app kept available during migration (dual support 6-12 weeks)

**Timeline**: 
- Week 0-6: RN app still active
- Week 6-8: Beta testing with both apps available
- Week 8+: Flutter app replaces RN (RN deprecated)

---

## Entity Mapping: React Native → Flutter

### Zustand Store → Riverpod Providers

**React Native** (Zustand):
```javascript
// projectStore.ts
const useProjectStore = create((set) => ({
  projects: [ /* 5 hardcoded projects */ ],
  setProjects: (projects) => set({ projects }),
}));
```

**Flutter** (Riverpod):
```dart
// presentation/providers/project_providers.dart
final projectsProvider = FutureProvider((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getAllProjects();
});

final projectDetailProvider = FutureProvider.family(
  (ref, String id) => ref.watch(projectRepositoryProvider).getProjectById(id),
);
```

**Mapping**:
| React Native | Flutter | Location |
|-------------|---------|----------|
| `useProjectStore()` | `ref.watch(projectsProvider)` | presentation/providers/ |
| `setProjects()` | `ref.invalidate(projectsProvider)` | Screen |
| Zustand state | Riverpod AsyncValue<T> | State management layer |

### Component → Screen/Widget

**React Native**:
```javascript
// screens/ProjectsScreen.tsx
function ProjectsScreen() { ... }
```

**Flutter**:
```dart
// presentation/screens/projects/projects_list_screen.dart
class ProjectsListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) { ... }
}
```

**Key Differences**:
- React: Functional component with hooks
- Flutter: ConsumerWidget with WidgetRef for Riverpod access
- No need for custom hooks (Riverpod providers do this)

### Navigation Props → GoRouter Parameters

**React Native**:
```javascript
// Stack.Navigator
<Stack.Screen name="ProjectDetail" 
  component={ProjectDetailScreen}
  initialParams={{ projectId: '123' }}
/>
```

**Flutter**:
```dart
// GoRouter
GoRoute(
  path: '/projects/:projectId',
  builder: (context, state) {
    final projectId = state.pathParameters['projectId']!;
    return ProjectDetailScreen(projectId: projectId);
  },
),
```

---

## Data Migration Strategy

### Phase 0: Data Inventory

**Currently in React Native**:
- ✅ 5 projects (hardcoded in Zustand)
- ✅ 4 tasks (hardcoded in TasksScreen)
- ✅ 4 maintenance items (hardcoded in MaintenanceScreen)
- ✅ 26 QC checklist items (hardcoded, Arabic)
- ✅ 4 team members (static avatars/names)

**Migration Plan**:
```
RN Zustand Store
    ↓
    Export JSON
    ↓
Flutter Drift Database
    ↓
    Seed on first launch (only once)
```

### JSON Export Script (React Native)

Create utility to export Zustand data:

```javascript
// scripts/exportData.js
import projectStore from '@/store/projectStore';

const data = {
  projects: projectStore.getState().projects,
  tasks: [/* from TasksScreen */],
  maintenance: [/* from MaintenanceScreen */],
  qcItems: [/* from QualityChecklistScreen */],
};

console.log(JSON.stringify(data, null, 2));
// Copy-paste into Flutter seed data
```

### Flutter Seed Script

```dart
// data/local/seed_data.dart
class SeedData {
  static Future<void> seedDatabase(AppDatabase db) async {
    // Check if already seeded
    final existingCount = await db.select(db.projects).get().then((it) => it.length);
    if (existingCount > 0) return; // Already seeded
    
    // Insert projects (migrated from RN)
    await db.into(db.projects).insertAll([
      ProjectsCompanion.insert(
        name: 'Downtown Tower',
        type: 'commercial',
        status: 'in_progress',
        location: '123 Main St',
        budget: 2500000.0,
      ),
      // ... 4 more projects
    ]);
  }
}

// Called in main():
void main() async {
  final db = AppDatabase();
  await SeedData.seedDatabase(db);
  runApp(const ArchitectHubApp());
}
```

---

## Breaking Changes & Concerns

### 1. No Real API (Migration Risk)

**Problem**: React Native has NO backend integration. All data hardcoded.

**Impact**: 
- Flutter team can't immediately call real API
- Must use mock server until Phase 7
- Potential API mismatch discovery in Phase 7

**Mitigation**:
- ✅ Phase 1-6: Use mock server with hardcoded data
- ✅ Phase 7: Real API integration (backend validates contract)
- ✅ DATA_MODEL_MAP.md is API specification

```dart
// Phase 1-6: Mock datasource
class ProjectRemoteDatasource {
  Future<List<ProjectModel>> getProjects() async {
    // Return hardcoded mock data
    return [
      ProjectModel(name: 'Downtown Tower', ...),
    ];
  }
}

// Phase 7: Real datasource
class ProjectRemoteDatasource {
  Future<List<ProjectModel>> getProjects() async {
    // Real API call via Dio
    final response = await _dio.get('/projects');
    return (response.data as List)
        .map((p) => ProjectModel.fromJson(p))
        .toList();
  }
}
```

### 2. No Auth System (Critical Risk)

**Problem**: React Native has NO login/authentication.

**Impact**:
- Must design JWT strategy from scratch
- Security decisions needed immediately
- Phase 1 blocker

**Mitigation**:
- ✅ Proposed JWT + refresh token (OPEN_QUESTIONS.md Q2)
- ✅ Secure storage in Hive
- ✅ Dio interceptor for automatic refresh
- ✅ Backend must provide `/auth/login` endpoint

### 3. No Data Persistence (Complete Rewrite)

**Problem**: React Native loses all data on app restart.

**Impact**:
- Flutter must implement Drift database
- More code than React Native (good design)
- Phase 3 full focus

**Mitigation**:
- ✅ Allocate Phase 3 fully to Drift setup
- ✅ Offline-first caching strategy
- ✅ Sync queue for mutations when offline

### 4. Async Storage vs Hive

**React Native** (planned, not implemented):
```javascript
import AsyncStorage from '@react-native-async-storage/async-storage';
```

**Flutter** (Hive, better option):
```dart
import 'package:hive_flutter/hive_flutter.dart';
```

**Differences**:
- AsyncStorage: Simple key-value (string-only)
- Hive: Type-safe, encrypts, supports objects

---

## Technical Debt & Lessons from React Native

### What to Keep ✅

1. **Design System** (Colors, Typography, Spacing)
   - React Native design tokens preserved in Flutter
   - Material 3 adds modern polish on top

2. **Screen Layouts** (UI/UX patterns)
   - Bottom tab navigation (great UX)
   - Modal dialogs for forms
   - Card-based layouts

3. **Data Model Structure**
   - Projects, Tasks, Maintenance, QC entities are sound
   - Enums (status, priority, type) well-designed

### What to Improve ⚡

1. **State Management**
   - React Native: Only partial (Zustand for projects)
   - Flutter: Complete (Riverpod for everything, with tests)

2. **Error Handling**
   - React Native: Try-catch mess, no user-friendly errors
   - Flutter: Either<Error, Success> pattern, clear error messages

3. **Data Persistence**
   - React Native: None (data lost on restart)
   - Flutter: Full Drift database + offline sync queue

4. **Testing**
   - React Native: No unit tests
   - Flutter: 80%+ coverage target (Domain + Data layers)

5. **Code Organization**
   - React Native: Flat folder structure
   - Flutter: Clean Architecture (6 layers, clear separation)

---

## File Structure Comparison

### React Native (Current)

```
src/
├── screens/ (12 files, all UI)
├── store/ (1 file, Zustand only)
├── data/ (1 file, hardcoded)
├── theme/ (1 file, design tokens)
└── navigation/ (1 file, navigation config)
```

**Issues**:
- ❌ No data layer (fetch/cache/sync logic)
- ❌ No domain layer (entities/use cases)
- ❌ No error handling structure
- ❌ All state in Zustand (incomplete)

### Flutter (Proposed)

```
lib/
├── presentation/ (screens, widgets, providers)
├── application/ (use cases)
├── domain/ (entities, interfaces)
├── data/ (repositories, datasources)
├── core/ (exceptions, logger, extensions)
└── generated/ (Freezed, JSON serialization)
```

**Benefits**:
- ✅ Clear layer separation
- ✅ Testable at each layer
- ✅ Scalable (add features without refactoring)
- ✅ Framework-independent (swap backend)

---

## Migration Checklist

### Pre-Migration
- [ ] Read all documentation files (2 hours)
- [ ] Answer CRITICAL blockers (OPEN_QUESTIONS.md)
- [ ] Assign Flutter lead + backend contact
- [ ] Set up Git repository
- [ ] Configure CI/CD (GitHub Actions)

### Phase 1: Foundation (Weeks 1-3)
- [ ] Flutter project created with Clean Architecture
- [ ] Riverpod + GoRouter + Freezed configured
- [ ] Authentication system designed
- [ ] Login screen implemented
- [ ] Dashboard with hardcoded data

### Phase 2: Core Features (Weeks 4-6)
- [ ] Projects CRUD (create, read, update, delete)
- [ ] Tasks management
- [ ] Quality checklist
- [ ] Maintenance tracking
- [ ] Seed data migrated from React Native

### Phase 3: Data Layer (Weeks 7-8)
- [ ] Drift database schema (9 tables)
- [ ] Offline-first caching
- [ ] Sync queue implementation
- [ ] Failed to test offline → online transitions

### Phase 4-6: Polish (Weeks 9-14)
- [ ] Maps integration
- [ ] Analytics
- [ ] Testing coverage 80%+
- [ ] MVP Release

### Phase 7-8: Production (Weeks 15-18)
- [ ] Real API integration
- [ ] Performance optimization
- [ ] Security audit
- [ ] Release to Play Store + App Store

### Phase 9-12: Post-Launch (Weeks 19-24)
- [ ] Push notifications
- [ ] Advanced features
- [ ] Post-launch bug fixes
- [ ] User feedback integration

---

## Rollback Plan (If Needed)

**Scenario**: Flutter development stalled or major problems discovered.

**Option 1: Continue with React Native**
- Duration: Additional 4-6 weeks
- Cost: ~$60K more
- Risk: Still no real API integration
- Not recommended (tech debt remains)

**Option 2: Hybrid (Keep RN for now, Flutter later)**
- Duration: 6+ months (support both)
- Cost: Highest (maintain two codebases)
- Risk: Team confusion, quality issues
- Not recommended (expensive, complex)

**Option 3: Pause & Reassess (Recommended IF needed)**
- Stop at end of Phase 2 (6 weeks)
- Evaluate progress vs. plan
- Decide: Continue vs. restart
- Risk: 6 weeks lost, but learnings valuable

**Recommendation**: Commit to Phase 1-6 fully. Decision point at Phase 6 MVP goes live (Week 6).

---

## Success Metrics for Migration

| Metric | Target | Timeline | Owner |
|--------|--------|----------|-------|
| Code Coverage | 80%+ | Phase 8 | Engineer |
| MVP Screens | 6 working | Phase 6 | Engineer |
| Test Pass Rate | 100% | Phase 8 | QA |
| API Response Time | <2s avg | Phase 7 | Infra |
| Crash Rate | <0.0001% | Phase 8 | QA |
| User Feedback | 4.0+ stars | Post-launch | Product |

---

## Post-Migration: React Native Deprecation

### Timeline

**Week 0-6 (During Flutter Phase 1-2)**
- RN app still active
- Bug fixes only (no new features)
- User message: "New app coming soon"

**Week 6-8 (During Phase 3)**
- Flutter MVP released to beta testers
- Parallel feedback: RN vs Flutter
- RN app features: Security mode (no new data)

**Week 8+ (Phase 4+)**
- Flutter production release
- RN app deprecated
- Announcement: "Migrate to new Flutter app"
- RN support: 30 days (help users transition)

**Week 10+**
- RN app removed (shut down servers)
- Full migration to Flutter complete

---

## Lessons Learned Document (Post-Migration)

After Flutter app launches, write retrospective covering:

1. **What went well**
   - Decisions that proved right (Riverpod, Freezed, etc.)
   - Time estimates accuracy
   - Team productivity

2. **What was hard**
   - Unexpected challenges (Phase TBD)
   - Bottlenecks (e.g., backend API delays)
   - Team learning curve

3. **What to avoid**
   - Mistakes made
   - Anti-patterns discovered
   - Testing gaps found

4. **Recommendations for next project**
   - Best practices validated
   - Tools/libraries to use again
   - Process improvements

---
