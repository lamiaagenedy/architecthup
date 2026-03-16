# SCREEN_INVENTORY.md - Complete Screen Specifications

## Overview

Complete inventory of 16 screens with detailed specifications, navigation flow, and build priority.

---

## Screen Specifications

### 1. Authentication (Not in RN, Must Create)

**Status**: ❌ MISSING - MUST CREATE FOR FLUTTER

#### Login Screen
- **Path**: `/login`
- **Type**: Entry point screen
- **Components**:
  - App logo (centered)
  - Email input (with validation)
  - Password input (masked)
  - "Remember me" checkbox
  - "Login" button (primary)
  - "Forgot password" link
  - "Sign up" link (if registration supported)

**Input/Output**:
- Input: Email, Password
- Output: JWT token (saved to storage)
- Error states: Invalid credentials, network error, validation errors

**Dependencies**: Authentication provider, Network

**Build Priority**: 1 (Phase 1, Prerequisite)

---

### 2. Dashboard Screen

**Path**: `/`  
**Type**: Home/landing screen  
**Navigation**: Tab 0 (leftmost)

#### Components
- App bar with date and settings icon
- Project summary card (total count, status breakdown)
- Task summary (count by priority)
- Team member grid (4 team members with avatars)
- Recent activities (hardcoded list, scrollable)
- Refresh button or pull-to-refresh

**Data Flow**:
1. Load projects from ProjectsProvider
2. Load tasks from TasksProvider
3. Compute stats (count, average, status distribution)
4. Display with loading skeleton

**Build Priority**: 2 (Phase 1)

---

### 3. Projects List Screen

**Path**: `/projects`  
**Type**: List/grid screen  
**Navigation**: Tab 1

#### Components
- Search bar (search by name)
- Filter chips (All, Residential, Commercial, Industrial)
- Project cards (name, location, status badge, progress bar)
- Floating action button (+) for create new
- Empty state (if no projects)

**Features**:
- Search with debounce (200ms)
- Filter by type (multi-select or radio)
- Sort by name/status/date
- Pagination (20 items per page)

**Navigation**:
- Tap card → Project Detail Screen
- Tap + → Create Project Modal

**Build Priority**: 2 (Phase 1)

---

### 4. Project Detail Screen

**Path**: `/projects/:projectId`  
**Type**: Detail/form screen  
**Navigation**: Pushed from Projects List

#### Tabs
1. **Overview Tab**
   - Project name (H2)
   - Status badge
   - Type badge
   - Location
   - Budget (budget used / total)
   - Description
   - Edit button

2. **Timeline Tab**
   - Start date
   - End date
   - Current status
   - Progress bar
   - Key milestones (if any)

3. **Team Tab**
   - Team members assigned to project
   - Role per member
   - Contact info

4. **History Tab**
   - Recent activities
   - Changes log
   - Timestamps

#### Actions
- Edit button (opens edit form)
- Delete button (with confirmation)
- Export button (future)
- Share button (future)

**Build Priority**: 2 (Phase 1)

---

### 5. Add/Edit Project Screen

**Path**: `/projects/new` or `/projects/:projectId/edit`  
**Type**: Modal form screen  
**Navigation**: Bottom sheet or full screen modal

#### Form Fields
- Project name (required, text)
- Type (required, dropdown: Residential, Commercial, Industrial)
- Status (required, dropdown: Pending, In Progress, Completed)
- Location (required, text)
- Budget (required, currency input)
- Description (optional, multiline text)
- Start date (required, date picker)
- End date (required, date picker)

**Validation Rules**:
- All required fields must be filled
- Budget must be positive number
- End date must be after start date
- Project name 3-100 characters

**Actions**:
- Save button (enabled only if form valid)
- Cancel button (dismiss without saving)

**Build Priority**: 2 (Phase 1)

---

### 6. Tasks List Screen

**Path**: `/tasks`  
**Type**: List screen  
**Navigation**: Tab 2

#### Components
- Display 4 task types (All, High Priority, Medium Priority, Low Priority)
- Task cards (title, project, priority badge, due date, status)
- Filter by priority
- Floating action button (+) for create new

**Features**:
- Priority color coding (high=red, medium=amber, low=gray)
- Sort by due date or priority
- Mark complete (checkbox click = API call)
- Pagination (20 per page)

**Navigation**:
- Tap card → Task Detail Screen
- Tap + → Create Task Modal
- Tap checkbox → Mark complete (with loading state)

**Build Priority**: 3 (Phase 1)

---

### 7. Task Detail Screen

**Path**: `/tasks/:taskId`  
**Type**: Detail/form screen  
**Navigation**: Pushed from Tasks List

#### Components
- Task title (H2)
- Priority badge (color-coded)
- Due date
- Project name (tap to go to project)
- Assigned to (user)
- Status (dropdown: Pending, In Progress, Completed)
- Description
- Comments section (future, empty for now)

#### Actions
- Edit button
- Delete button
- Mark complete button
- Assign to user (future)

**Build Priority**: 3 (Phase 2)

---

### 8. Maintenance Screen

**Path**: `/maintenance`  
**Type**: List screen  
**Navigation**: Tab 3

#### Components
- Maintenance item cards (name, due date, status badge)
- Status indicators (upcoming, overdue, completed)
- Filter by status
- Floating action button (+) for schedule new

**Features**:
- Calendar view (future)
- Maintenance history (future)
- Equipment tracking (future)

**Navigation**:
- Tap card → Maintenance Detail Screen
- Tap + → Schedule Maintenance Modal

**Build Priority**: 3 (Phase 1)

---

### 9. Quality Checklist Screen

**Path**: `/quality`  
**Type**: Checklist screen  
**Navigation**: Tab 4

#### Components
- Category tabs (Housekeeping, Maintenance, Security, Landscape)
- Checklist items per category (26 total in Arabic)
- Checkbox for each item
- Notes textarea (below checklist)
- Save button

**Features**:
- Toggle all items for category
- Calculate completion percentage
- Timestamps when each item checked
- Historical data (view past inspections)

**Build Priority**: 2 (Phase 1)

---

### 10. Analytics Screen

**Path**: `/analytics`  
**Type**: Dashboard/charts screen  
**Navigation**: Tab 5

#### Components
- Date range picker (for filtering)
- Revenue chart (placeholder for Phase 1)
- Performance metrics cards
- Budget tracking bar
- Resource utilization gauge

**Features**:
- Hardcoded data for Phase 1
- Real data in Phase 3

**Build Priority**: 4 (Phase 2)

---

### 11. Map Screen

**Path**: `/map`  
**Type**: Map screen  
**Navigation**: Tab 6 OR Drawer option

#### Components
- Interactive map (Google Maps Flutter)
- Project location markers (pins)
- Marker details (tap shows project name)
- List of locations below map (scrollable)

**Features**:
- Tap marker → Show project details
- Tap list item → Go to Project Detail
- Real-time location tracking (future)

**Build Priority**: 3 (Phase 2)

---

### 12. Security Screen

**Path**: `/security`  
**Type**: Settings screen  
**Navigation**: Drawer option

**BLOCKER**: Cannot implement without auth system

#### Components
- User permissions matrix (future)
- Audit logs (future)
- Access control settings (future)

**Build Priority**: 5 (Phase 3, requires auth)

---

### 13. Profile Screen

**Path**: `/profile`  
**Type**: Settings screen  
**Navigation**: Drawer option OR Tab 7

#### Components
- User avatar (static for now)
- User name
- Email
- Phone (if available)
- Edit button (opens form)
- Change password button
- Language preference (English/Arabic toggle)
- Logout button

**Features**:
- Edit profile form (future)
- Change password flow (future)
- Language switcher (works, switches app language)

**Build Priority**: 3 (Phase 1, depends on auth)

---

### 14. Settings Screen

**Path**: `/settings`  
**Type**: Settings screen  
**Navigation**: Drawer option or AppBar menu

#### Components
- Notification settings (future)
- Data sync settings (future)
- Offline mode toggle (future)
- Dark mode toggle (future)
- About section (app version, feedback)

**Build Priority**: 4 (Phase 2+)

---

### 15. Landscape Screen

**Path**: Not a separate screen, responsive design  
**Type**: Responsive layout  
**Description**: All screens should support landscape orientation

#### Behavior
- Cards in 2-3 column grid (landscape)
- Navigation adapts (side rail instead of bottom tabs)
- Content scales appropriately

**Build Priority**: Integrated into all screens

---

### 16. Modals & Dialogs

**Create Project Modal**:
- Bottom sheet or dialog
- Same form as Add/Edit Project Screen
- Pull handle at top

**Delete Confirmation Dialog**:
- Title: "Delete [item]?"
- Body: "This action cannot be undone."
- Red "Delete" button + "Cancel" button

**Filter Sheet**:
- Bottom sheet with filter options
- Apply and Cancel buttons

**Sort Menu**:
- Dropdown or menu with sort options

---

## Navigation Tree (GoRouter Routes)

```
/                           (Dashboard)
├── /projects                (Projects List)
│   ├── /projects/:id        (Project Detail)
│   └── /projects/new        (Add Project Modal)
├── /tasks                   (Tasks List)
│   ├── /tasks/:id           (Task Detail)
│   └── /tasks/new           (Add Task Modal)
├── /maintenance             (Maintenance List)
│   ├── /maintenance/:id     (Maintenance Detail)
│   └── /maintenance/new     (Schedule Modal)
├── /quality                 (Quality Checklist)
├── /analytics               (Analytics)
├── /map                     (Map)
├── /security                (Security Settings)
├── /profile                 (Profile)
├── /settings                (Settings)
└── /login                   (Login - entry point)
```

---

## Build Order (Phase Priority)

### Phase 1 (Mobile Core): Screens 1-6, 9, 13
1. Login Screen ✅ Required
2. Dashboard Screen ✅ Home page
3. Projects List ✅ Core feature
4. Project Detail ✅ Core feature
5. Add/Edit Project ✅ Core feature
6. Quality Checklist ✅ Core feature
7. Profile Screen ✅ User context

### Phase 2: Screens 7-8, 11, 15
8. Tasks List Screen
9. Maintenance Screen
10. Map Screen
11. Landscape Support

### Phase 3: Screens 10, 12, 14
12. Analytics Screen (with real data)
13. Security Screen (with auth)
14. Settings Screen

---

## Screen Dependency Matrix

| Screen | Depends On | Must Build Before |
|--------|-----------|------------------|
| Login | Auth system | All other screens |
| Dashboard | Projects, Tasks | Projects List |
| Projects List | Project entity | Project Detail |
| Project Detail | Project entity | Add Project Modal |
| Add Project Modal | Project entity | — |
| Tasks List | Task entity | Task Detail |
| Task Detail | Task entity | — |
| Maintenance | Maintenance entity | — |
| Quality Checklist | QC entity | — |
| Analytics | Analytics data | — |
| Map | Google Maps API | — |
| Security | Auth system | — |
| Profile | User entity, Auth | — |
| Settings | Preferences system | — |

---

## Screen Specifications Summary

| Screen | Type | Complexity | Status | Phase |
|--------|------|-----------|--------|-------|
| Login | Auth | Medium | TODO | 1 |
| Dashboard | Dashboard | Low | Convert | 1 |
| Projects List | List | Low | Convert | 1 |
| Project Detail | Detail | Medium | Convert | 1 |
| Add Project | Form | Low | Convert | 1 |
| Tasks List | List | Low | Convert | 1 |
| Task Detail | Detail | Low | New | 2 |
| Maintenance | List | Low | Convert | 1 |
| Quality Checklist | Checklist | Low | Convert | 1 |
| Analytics | Dashboard | High | TODO | 2 |
| Map | Map | High | Convert | 2 |
| Security | Settings | High | TODO | 3 |
| Profile | Settings | Low | Convert | 1 |
| Settings | Settings | Low | TODO | 2 |
| Landscape | Layout | Low | Enhance | 1+ |

---
