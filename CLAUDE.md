# CLAUDE.md - AI Assistant Master Reference for Flutter Development

## Purpose

This document defines patterns, conventions, and best practices for Claude AI to assist with ArchitectHub Flutter development. Use this as the reference for all coding decisions and architectural questions.

---

## Architecture Rules

### 1. Always Use Clean Architecture

```
Presentation Layer (UI/screens) 
   ↓ (depends on)
Application Layer (use cases, providers)
   ↓ (depends on)
Domain Layer (entities, interfaces)
   ↓ (depends on)
Data Layer (repositories, datasources)
   ↓ (depends on)
Core Layer (utilities, constants)
```

**Rule**: Presentation layer NEVER imports Data layer directly. Always go through Domain.

### 2. Dependency Injection via Riverpod

All dependencies provided through Riverpod providers. NO service locators (GetIt).

**Bad** ❌:
```dart
final dio = Dio(); // Direct instantiation
```

**Good** ✅:
```dart
final dioProvider = Provider((ref) => Dio()); // Riverpod provider
```

### 3. Immutability First

All entities and models MUST be immutable (use Freezed).

**Bad** ❌:
```dart
class Project {
  String name;
  Project(this.name);
}
```

**Good** ✅:
```dart
@freezed
class Project with _$Project {
  const factory Project({required String name}) = _Project;
}
```

---

## Dart Coding Standards

### 1. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | PascalCase | `ProjectDetail`, `DioClient` |
| Functions | camelCase | `getProjectById()`, `calculateBudget()` |
| Variables | camelCase | `projectName`, `isLoading` |
| Constants | camelCase | `kDefaultTimeout`, `kMaxRetries` |
| Private | Leading underscore | `_privateMethod()`, `_internalState` |
| Files | snake_case | `project_repository.dart`, `dio_client.dart` |
| Enums | PascalCase | `ProjectStatus.pending` |
| Type parameters | Single letter or PascalCase | `T`, `Repository<T>` |

### 2. Null Safety

**Always** use null safety (`--enable-null-safety`).

**Bad** ❌:
```dart
String? name = null;
name.length; // ❌ Error: possible null reference
```

**Good** ✅:
```dart
String? name = null;
name?.length; // ✅ Null-aware operator
```

### 3. Documentation

Every **public** class, function, and complex logic needs documentation.

```dart
/// Fetches all projects for the current user.
///
/// Returns a list of projects sorted by creation date (newest first).
/// Throws [NetworkException] if the API call fails.
/// 
/// Example:
/// ```dart
/// final projects = await getProjects();
/// ```
Future<List<Project>> getProjects() async {
  // Implementation
}
```

### 4. Code Organization

Keep files under 300 lines. Split large files:

```
project_repository.dart (interface) → 50 lines
project_repository_impl.dart (implementation) → 200 lines
project_remote_datasource.dart (API calls) → 100 lines
project_local_datasource.dart (Drift DB) → 100 lines
```

---

## Riverpod Patterns

### 1. Provider Types

**Use the RIGHT provider type**:

| Type | Use Case | Example |
|------|----------|---------|
| `Provider<T>` | Sync computation, constants | `themeProvider` |
| `FutureProvider<T>` | Async operations, read-only | `projectsProvider` |
| `StreamProvider<T>` | Real-time data (rare) | — |
| `StateProvider<T>` | Simple mutable state | `searchQueryProvider` |
| `StateNotifierProvider<N, T>` | Complex state logic | `dashboardProvider` |
| `FamilyProvider` | Parameterized (e.g., by ID) | `projectDetailProvider.family()` |

### 2. FutureProvider (Most Common)

```dart
// List all projects
final projectsProvider = FutureProvider((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getAllProjects();
});

// Detail view with ID parameter
final projectDetailProvider = FutureProvider.family(
  (ref, String projectId) {
    final repo = ref.watch(projectRepositoryProvider);
    return repo.getProjectById(projectId);
  },
);

// Usage in widget:
@override
Widget build(BuildContext context, WidgetRef ref) {
  final projects = ref.watch(projectsProvider);
  
  return projects.when(
    data: (list) => ProjectList(projects: list),
    loading: () => const SkeletonLoader(),
    error: (error, stack) => ErrorWidget(error: error.toString()),
  );
}
```

### 3. StateNotifierProvider (Complex State)

```dart
class ScreenState {
  final AsyncValue<List<Project>> projects;
  final String searchQuery;
  final ProjectType? filter;
  
  ScreenState({
    required this.projects,
    required this.searchQuery,
    required this.filter,
  });
  
  ScreenState copyWith({
    AsyncValue<List<Project>>? projects,
    String? searchQuery,
    ProjectType? filter,
  }) {
    return ScreenState(
      projects: projects ?? this.projects,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }
}

class ScreenNotifier extends StateNotifier<ScreenState> {
  ScreenNotifier(this._repo) : super(
    ScreenState(
      projects: const AsyncValue.loading(),
      searchQuery: '',
      filter: null,
    ),
  );
  
  final Repository _repo;
  
  Future<void> loadProjects() async {
    final result = await _repo.getAllProjects();
    result.fold(
      (error) => state = state.copyWith(
        projects: AsyncValue.error(error, StackTrace.current),
      ),
      (data) => state = state.copyWith(projects: AsyncValue.data(data)),
    );
  }
  
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final screenProvider = StateNotifierProvider<ScreenNotifier, ScreenState>(
  (ref) => ScreenNotifier(ref.watch(repositoryProvider)),
);
```

### 4. Invalidation & Refresh

Invalidate provider to re-fetch data:

```dart
// Refresh projects list after creating new project
Future<void> createProject(CreateProjectParams params) async {
  final result = await ref.read(createProjectUsecaseProvider).call(params);
  
  result.fold(
    (error) => showError(error),
    (newProject) {
      // Invalidate and refetch
      ref.invalidate(projectsProvider);
      showSuccess('Project created!');
    },
  );
}
```

---

## Error Handling (Either Pattern)

### 1. Custom Exceptions

```dart
// core/exceptions/app_exception.dart

abstract class AppException implements Exception {
  final String message;
  AppException({required this.message});
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({required String message}) : super(message: message);
}

class ValidationException extends AppException {
  ValidationException({required String message}) : super(message: message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException() : super(message: 'Unauthorized');
}
```

### 2. Either Pattern for Results

```dart
import 'package:dartz/dartz.dart';

// Use case
class GetProjectsUsecase {
  GetProjectsUsecase(this._repo);
  final Repository _repo;
  
  // Returns Either<Error, Success>
  Future<Either<AppException, List<Project>>> call() async {
    try {
      final projects = await _repo.getProjects();
      return Right(projects);
    } on NetworkException catch (e) {
      return Left(e);
    } on AppException catch (e) {
      return Left(e);
    }
  }
}

// Usage in UI
final result = await usecase();
result.fold(
  (error) {
    // Left: error case
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
    );
  },
  (projects) {
    // Right: success case
    setState(() => this.projects = projects);
  },
);
```

### 3. Try-Catch for HTTP

```dart
// datasource
Future<List<ProjectModel>> getProjects() async {
  try {
    final response = await _dio.get('/projects');
    return (response.data as List)
        .map((p) => ProjectModel.fromJson(p))
        .toList();
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw NetworkException(message: e.message ?? 'Network error');
  }
}
```

---

## GoRouter Navigation Patterns

### 1. Route Definition

```dart
// lib/presentation/navigation/app_router.dart

final appRouterProvider = Provider((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      // Login route (outside auth guard)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Main shell with bottom tabs
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsListScreen(),
            routes: [
              GoRoute(
                path: ':projectId',
                builder: (context, state) {
                  final projectId = state.pathParameters['projectId']!;
                  return ProjectDetailScreen(projectId: projectId);
                },
              ),
              GoRoute(
                path: 'new',
                builder: (context, state) => const AddProjectScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      // Route guards: redirect unauthenticated users
      final isLoggedIn = ref.read(authProvider).value != null;
      final isLoggingIn = state.matchedLocation == '/login';
      
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      
      return null; // No redirect needed
    },
  );
});
```

### 2. Navigation Commands

```dart
// Push (adds to stack)
context.push('/projects/123');

// Replace (replaces current route)
context.replace('/projects');

// Pop (remove from stack)
context.pop();

// Push named
context.pushNamed('projectDetail', pathParameters: {'projectId': '123'});
```

---

## Testing Guidelines

### 1. Unit Tests (Domain/Data layers)

**File**: `test/domain/usecases/get_projects_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('GetProjectsUsecase', () {
    late MockRepository mockRepository;
    late GetProjectsUsecase usecase;
    
    setUp(() {
      mockRepository = MockRepository();
      usecase = GetProjectsUsecase(mockRepository);
    });
    
    test('should return list of projects on success', () async {
      // Arrange
      final expectedProjects = [projectOne, projectTwo];
      when(mockRepository.getProjects())
          .thenAnswer((_) async => expectedProjects);
      
      // Act
      final result = await usecase();
      
      // Assert
      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Should be Right'),
        (projects) => expect(projects, equals(expectedProjects)),
      );
      verify(mockRepository.getProjects()).called(1);
    });
    
    test('should return error on network failure', () async {
      // Arrange
      when(mockRepository.getProjects())
          .thenThrow(NetworkException(message: 'No internet'));
      
      // Act
      final result = await usecase();
      
      // Assert
      expect(result, isA<Left>());
      result.fold(
        (error) => expect(error, isA<NetworkException>()),
        (_) => fail('Should be Left'),
      );
    });
  });
}
```

### 2. Widget Tests (Presentation layer)

**File**: `test/presentation/screens/projects_list_test.dart`

```dart
void main() {
  group('ProjectsListScreen', () {
    testWidgets('displays projects when data loaded', (tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          projectsProvider.overrideWithValue(
            AsyncValue.data([projectOne, projectTwo]),
          ),
        ],
      );
      
      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ProjectsListScreen()),
        ),
      );
      
      // Assert
      expect(find.byType(ProjectCard), findsWidgets);
      expect(find.byType(ProjectCard), findsNWidgets(2));
    });
    
    testWidgets('shows loading state initially', (tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          projectsProvider.overrideWithValue(
            const AsyncValue.loading(),
          ),
        ],
      );
      
      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ProjectsListScreen()),
        ),
      );
      
      // Assert
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });
  });
}
```

### 3. Integration Tests

**File**: `test/integration_test/create_project_test.dart`

```dart
void main() {
  testWidgets('User can create a new project', (tester) async {
    // Start app
    app.main();
    await tester.pumpAndSettle();
    
    // Navigate to projects
    await tester.tap(find.byIcon(Icons.folder));
    await tester.pumpAndSettle();
    
    // Tap create button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    // Fill form
    await tester.enterText(find.byType(TextField).at(0), 'New Project');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    
    // Verify
    expect(find.text('New Project'), findsOneWidget);
  });
}
```

---

## Data Persistence (Drift + Hive)

### 1. Drift Database Definition

```dart
// lib/data/local/app_database.dart

import 'package:drift/drift.dart';

part 'app_database.g.dart';

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  TextColumn get location => text()();
  RealColumn get budget => real()();
  DateTimeColumn get createdAt => dateTime()();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get projectId => integer()();
  TextColumn get priority => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
}

@DriftDatabase(tables: [Projects, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Platform detection for file path
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
```

### 2. Local Datasource

```dart
class ProjectLocalDatasource {
  ProjectLocalDatasource(this._db);
  final AppDatabase _db;
  
  Future<void> cacheProjects(List<ProjectModel> projects) async {
    await _db.into(_db.projects).insertAll(
      projects.map((p) => ProjectsCompanion.insert(
        name: p.name,
        type: p.type,
        status: p.status,
        location: p.location,
        budget: p.budget,
      )),
      mode: InsertMode.insertOrReplace,
    );
  }
  
  Future<List<ProjectModel>> getCachedProjects() async {
    final data = await _db.select(_db.projects).get();
    return data.map((row) => ProjectModel(
      id: row.id.toString(),
      name: row.name,
      type: row.type,
      status: row.status,
      location: row.location,
      budget: row.budget,
    )).toList();
  }
}
```

### 3. Hive for Preferences

```dart
// Storing user preferences
class PreferencesBox {
  static const String boxName = 'preferences';
  
  late Box<dynamic> _box;
  
  Future<void> init() async {
    Hive.registerAdapter(UserPreferencesAdapter());
    _box = await Hive.openBox(boxName);
  }
  
  void saveTheme(String theme) => _box.put('theme', theme);
  String getTheme() => _box.get('theme', defaultValue: 'light');
  
  void saveLanguage(String lang) => _box.put('language', lang);
  String getLanguage() => _box.get('language', defaultValue: 'en');
}
```

---

## Logging Strategy

### 1. App Logger Setup

```dart
// core/logger/app_logger.dart

class AppLogger {
  static const String _tag = '[ArchitectHub]';
  
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('$_tag [DEBUG] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
  
  static void info(String message) {
    if (kDebugMode) debugPrint('$_tag [INFO] $message');
  }
  
  static void warning(String message, {Object? error}) {
    if (kDebugMode) {
      debugPrint('$_tag [WARNING] $message');
      if (error != null) debugPrint('Error: $error');
    }
  }
  
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('$_tag [ERROR] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }
}
```

### 2. Http Logging Interceptor

```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('→ ${options.method} ${options.path}');
    AppLogger.debug('Params: ${options.queryParameters}');
    if (options.data != null) {
      AppLogger.debug('Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info('← ${response.statusCode} ${response.requestOptions.path}');
    AppLogger.debug('Response: ${response.data}');
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('✗ ${err.requestOptions.path}', error: err);
    super.onError(err, handler);
  }
}
```

---

## Pre-Commit Checklist

Before pushing code:

- [ ] Run `dart format .` (format all files)
- [ ] Run `dart analyze` (0 warnings/errors)
- [ ] Run `flutter test` (100% tests pass)
- [ ] Run `flutter build apk --split-per-abi` (build succeeds)
- [ ] Add meaningful commit message (follow Angular convention)
- [ ] Reference issue/ticket if applicable

**Commit Message Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

Examples:
- `feat(projects): add project search functionality`
- `fix(auth): handle 401 unauthorized response`
- `refactor(themes): restructure color constants`
- `test(projects): add tests for repository`
- `docs(architecture): update diagram`
- `chore(deps): upgrade flutter sdk to 3.14`

---

## Q&A for Claude

**Q: Should I add a new class or extend existing?**  
A: If logic is >10 lines and specific to one entity, create new class. Keep files <300 lines.

**Q: Which provider type should I use?**  
A: Start with `FutureProvider` (safest). Use `StateNotifier` only for complex multi-state logic.

**Q: How do I handle null values?**  
A: Use null-aware operators (`?.`, `??`). Never force unwrap with `!` except in tests.

**Q: Should errors show to users or logs?**  
A: User-facing errors → dialog/snackbar. Technical errors → logger only.

**Q: How big can my widget be?**  
A: Extract widgets when build() > 200 lines. Keep code readable.

**Q: Does this need tests?**  
A: Domain and Data layers YES (100% coverage). Presentation layer for complex logic only.

**Q: Which branch naming?**  
A: `feature/project-search`, `fix/auth-timeout`, `refactor/theme-system`

---
