# DATA_MODEL_MAP.md - Complete Data Models & API Contracts

## Overview

Comprehensive mapping of all data entities from React Native to Flutter, including domain entities (Freezed), API models, Drift database schema, and API contracts.

---

## Entity 1: Project

### Domain Entity (Freezed)

```dart
// domain/entities/project.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
class Project with _$Project {
  const factory Project({
    required String id,
    required String name,
    required ProjectType type,
    required ProjectStatus status,
    required String location,
    required double budget,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Project;

  factory Project.fromJson(Map<String, Object?> json) =>
      _$ProjectFromJson(json);
}

enum ProjectType {
  @JsonValue('residential')
  residential,
  @JsonValue('commercial')
  commercial,
  @JsonValue('industrial')
  industrial,
}

enum ProjectStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
}
```

### API Model (JSON Serializable)

```dart
// data/models/project_model.dart
@JsonSerializable()
class ProjectModel {
  final String id;
  final String name;
  final String type; // 'residential', 'commercial', 'industrial'
  final String status; // 'pending', 'in_progress', 'completed'
  final String location;
  final double budget;
  final String? description;
  final String createdAt; // ISO 8601
  final String updatedAt; // ISO 8601

  ProjectModel({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.location,
    required this.budget,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
}
```

### Drift Database Table

```dart
// data/local/app_database.dart
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'residential', 'commercial', 'industrial'
  TextColumn get status => text()(); // 'pending', 'in_progress', 'completed'
  TextColumn get location => text()();
  RealColumn get budget => real()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### API Contract

```
GET /projects
Query params: 
  - search: String (optional)
  - type: String (optional, 'residential'|'commercial'|'industrial')
  - status: String (optional, 'pending'|'in_progress'|'completed')
  - page: int (default 1)
  - limit: int (default 20)

Response (200):
{
  "data": [
    {
      "id": "1",
      "name": "Downtown Tower",
      "type": "commercial",
      "status": "in_progress",
      "location": "123 Main St, City, State",
      "budget": 2500000.00,
      "description": "High-rise office building",
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-03-16T14:22:00Z"
    }
  ],
  "pagination": {
    "total": 45,
    "page": 1,
    "limit": 20,
    "pages": 3
  }
}

POST /projects
Body:
{
  "name": "New Project",
  "type": "residential",
  "status": "pending",
  "location": "456 Oak Ave",
  "budget": 1200000.00,
  "description": "Community housing project"
}

Response (201):
{
  "id": "123",
  "name": "New Project",
  "type": "residential",
  "status": "pending",
  "location": "456 Oak Ave",
  "budget": 1200000.00,
  "description": "Community housing project",
  "createdAt": "2024-03-16T15:00:00Z",
  "updatedAt": "2024-03-16T15:00:00Z"
}

PUT /projects/:id
Body: Same as POST

DELETE /projects/:id
Response (204): No content
```

---

## Entity 2: Task

### Domain Entity

```dart
@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required String projectId,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
    String? assignedTo, // User ID
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, Object?> json) => _$TaskFromJson(json);
}

enum TaskPriority {
  @JsonValue('high')
  high,
  @JsonValue('medium')
  medium,
  @JsonValue('low')
  low,
}

enum TaskStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
}
```

### Drift Table

```dart
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get projectId => text()();
  TextColumn get priority => text()(); // 'high', 'medium', 'low'
  TextColumn get status => text()(); // 'pending', 'in_progress', 'completed'
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get assignedTo => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### API Contract

```
GET /projects/:projectId/tasks
GET /tasks (all tasks)

POST /tasks
{
  "title": "Install flooring",
  "projectId": "1",
  "priority": "high",
  "dueDate": "2024-04-15T23:59:59Z",
  "description": "Install hardwood in 3rd floor"
}

PUT /tasks/:id
PATCH /tasks/:id/complete
DELETE /tasks/:id
```

---

## Entity 3: Maintenance

```dart
@freezed
class Maintenance with _$Maintenance {
  const factory Maintenance({
    required String id,
    required String projectId,
    required String name,
    required MaintenanceStatus status,
    required DateTime dueDate,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Maintenance;

  factory Maintenance.fromJson(Map<String, Object?> json) =>
      _$MaintenanceFromJson(json);
}

enum MaintenanceStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
}
```

### Drift Table

```dart
class MaintenanceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get projectId => text()();
  TextColumn get name => text()();
  TextColumn get status => text()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
```

---

## Entity 4: Quality Checklist Item

```dart
@freezed
class QCItem with _$QCItem {
  const factory QCItem({
    required String id,
    required String category, // 'housekeeping', 'maintenance', 'security', 'landscape'
    required String description,
    required String arabicDescription,
    bool isChecked = false,
    required DateTime createdAt,
  }) = _QCItem;

  factory QCItem.fromJson(Map<String, Object?> json) =>
      _$QCItemFromJson(json);
}
```

### Drift Table

```dart
class QCItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()(); // 'housekeeping', 'maintenance', 'security', 'landscape'
  TextColumn get description => text()();
  TextColumn get arabicDescription => text()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class QCChecklistInstances extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get projectId => text()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get completedCount => integer()();
  DateTimeColumn get createdAt => dateTime()();
}
```

---

## Entity 5: User

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? phone,
    String? role, // 'admin', 'manager', 'worker'
    String? avatarUrl,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
```

### Drift Table

```dart
class Users extends Table {
  TextColumn get id => text().primary()();
  TextColumn get email => text().unique()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get role => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
```

### API Contract (Auth)

```
POST /auth/login
{
  "email": "user@example.com",
  "password": "securePassword123"
}

Response (200):
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "user1",
    "email": "user@example.com",
    "name": "John Smith",
    "role": "manager",
    "avatarUrl": "https://..."
  }
}

POST /auth/refresh
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}

Response (200):
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}

POST /auth/logout
Response (204): No content
```

---

## Entity 6: Team

```dart
@freezed
class Team with _$Team {
  const factory Team({
    required String id,
    required String projectId,
    required List<String> memberIds, // User IDs
    required String name,
  }) = _Team;

  factory Team.fromJson(Map<String, Object?> json) => _$TeamFromJson(json);
}
```

### Drift Table

```dart
class Teams extends Table {
  TextColumn get id => text().primary()();
  TextColumn get projectId => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class TeamMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get teamId => text().references(Teams, #id)();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get role => text()(); // 'lead', 'member'
  
  @override
  Set<Column> get primaryKey => {teamId, userId};
}
```

---

## Entity 7: Analytics

```dart
@freezed
class Analytics with _$Analytics {
  const factory Analytics({
    required int totalProjects,
    required int completedProjects,
    required int inProgressProjects,
    required int totalTasks,
    required int completedTasks,
    required double totalBudget,
    required double spentBudget,
    required List<DailyMetric> dailyMetrics, // for charts
  }) = _Analytics;

  factory Analytics.fromJson(Map<String, Object?> json) =>
      _$AnalyticsFromJson(json);
}

@freezed
class DailyMetric with _$DailyMetric {
  const factory DailyMetric({
    required DateTime date,
    required int projectsCompleted,
    required double spending,
  }) = _DailyMetric;

  factory DailyMetric.fromJson(Map<String, Object?> json) =>
      _$DailyMetricFromJson(json);
}
```

### API Contract

```
GET /analytics?dateFrom=2024-01-01&dateTo=2024-12-31

Response (200):
{
  "totalProjects": 45,
  "completedProjects": 12,
  "inProgressProjects": 28,
  "totalTasks": 340,
  "completedTasks": 210,
  "totalBudget": 5400000.00,
  "spentBudget": 2850000.00,
  "dailyMetrics": [
    {
      "date": "2024-01-01T00:00:00Z",
      "projectsCompleted": 0,
      "spending": 2500.00
    }
  ]
}
```

---

## Summary Table

| Entity | Drift Tables | API Endpoints | Uses Auth | Offline Support |
|--------|--------------|---------------|-----------|-----------------|
| Project | 1 | 5 (CRUD) | ✅ | ✅ Cached |
| Task | 1 | 5 (CRUD) | ✅ | ✅ Cached |
| Maintenance | 1 | 5 (CRUD) | ✅ | ✅ Cached |
| QC Item | 2 | 4 (CRUD) | ✅ | ✅ Cached |
| User | 1 | 3 (Auth) | ✅ | ❌ Online only |
| Team | 2 | 3 (CRUD) | ✅ | ✅ Cached |
| Analytics | 0 | 1 (GET) | ✅ | ✅ Cached |

**Total**: 9 tables across 2 databases (Drift + cache)

---

## Migration Notes

1. **From React Native**: Only Projects stored in Zustand. All other entities hardcoded.
2. **Tasks**: Currently 4 hardcoded in TasksScreen. Migrate to Drift + API.
3. **Maintenance**: 4 hardcoded items. Move to Drift + API.
4. **QC Items**: 26 static items in Arabic. Store in Drift (populate from seed).
5. **Users**: Currently static team data. Build auth system + User table.
6. **Analytics**: All hardcoded mock data. Connect to backend aggregations.

---
