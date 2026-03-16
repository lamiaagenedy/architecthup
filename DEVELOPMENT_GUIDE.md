# ArchitectHub - Development Guide

## 📁 Project Structure

```
ArchitectHub/
├── src/
│   ├── screens/              # All application screens
│   │   ├── DashboardScreen.tsx
│   │   ├── ProjectsScreen.tsx
│   │   ├── ProjectDetailScreen.tsx
│   │   ├── MapScreen.tsx
│   │   ├── MaintenanceScreen.tsx
│   │   ├── AnalyticsScreen.tsx
│   │   ├── ProfileScreen.tsx
│   │   ├── AddProjectScreen.tsx
│   │   ├── TasksScreen.tsx
│   │   ├── SecurityScreen.tsx
│   │   └── LandscapeScreen.tsx
│   │
│   ├── navigation/           # Navigation configuration
│   │   └── AppNavigator.tsx
│   │
│   ├── store/               # State management (Zustand)
│   │   └── projectStore.ts
│   │
│   ├── theme/               # Design system & theming
│   │   └── theme.ts
│   │
│   └── assets/              # Images, fonts, icons
│
├── App.tsx                  # Root component
├── index.js                 # Entry point
├── package.json             # Dependencies
└── tsconfig.json           # TypeScript config
```

## 🎨 Design System

### Color Palette

```typescript
Primary: #2563EB (Blue)
Secondary: #10B981 (Green)
Accent: #F59E0B (Amber)
Background: #F8FAFC
Surface: #FFFFFF
Text: #1E293B
Text Secondary: #64748B
```

### Status Colors

- **In Progress**: #3B82F6 (Blue)
- **Completed**: #10B981 (Green)
- **Pending**: #F59E0B (Amber)
- **On Hold**: #EF4444 (Red)

### Spacing System

Based on 8px grid:

- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px

### Typography

- **H1**: 32px / Bold
- **H2**: 24px / SemiBold
- **H3**: 20px / SemiBold
- **H4**: 18px / SemiBold
- **Body**: 16px / Regular
- **Body Small**: 14px / Regular
- **Caption**: 12px / Regular

## 🧩 Key Features Implementation

### 1. Dashboard Screen

- **Features**: Project overview, quick actions, statistics, recent alerts
- **Components**: StatCard, QuickAction, ProjectCard, AlertCard
- **Navigation**: Links to all major sections

### 2. Projects Screen

- **Features**: Search, filter by status, project cards with progress
- **State Management**: Uses Zustand store for project data
- **Actions**: View details, add new project, manage tasks

### 3. Project Detail Screen

- **Features**: Tabbed interface (Overview, Tasks, Team, Files)
- **Quick Actions**: Access to Tasks, Security, Landscape, Location
- **Info Display**: Status, progress, dates, budget, team members

### 4. Map Screen

- **Features**: Interactive map with project markers
- **Libraries**: react-native-maps
- **Functionality**: View all project locations, select for details

### 5. Maintenance Screen

- **Features**: Task tracking, priority management, status filters
- **Categories**: Pending, Scheduled, In Progress, Completed
- **Actions**: Add new maintenance tasks

### 6. Analytics Screen

- **Features**: Charts, metrics, performance tracking
- **Libraries**: react-native-chart-kit
- **Visualizations**: Line charts, bar charts, progress bars

### 7. Security Screen

- **Features**: Camera monitoring, alerts, guard status
- **Real-time**: System status updates
- **Actions**: Emergency alerts, call guard

### 8. Landscape Screen

- **Features**: Design preview, plant management, maintenance schedule
- **Tabs**: Design, Plants, Maintenance
- **Tracking**: Area coverage, completion status

## 🔧 State Management

### Zustand Store (projectStore.ts)

```typescript
interface Project {
  id: string;
  name: string;
  location: string;
  type: string;
  status: 'in-progress' | 'completed' | 'pending' | 'on-hold';
  progress: number;
  startDate: string;
  endDate: string;
  owner: string;
  budget: string;
}
```

**Actions:**

- `addProject(project)` - Add new project
- `updateProject(id, updates)` - Update existing project
- `deleteProject(id)` - Remove project
- `getProjectById(id)` - Get single project

## 📱 Navigation Structure

```
Stack Navigator
├── MainTabs (Bottom Tabs)
│   ├── Dashboard
│   ├── Projects
│   ├── Map
│   ├── Maintenance
│   ├── Analytics
│   └── Profile
│
└── Modal Screens
    ├── ProjectDetail
    ├── AddProject
    ├── Tasks
    ├── Security
    └── Landscape
```

## 🚀 Running the Application

### Prerequisites

```bash
node >= 18
npm or yarn
React Native CLI
Android Studio (for Android)
Xcode (for iOS - Mac only)
```

### Installation Steps

1. **Install Dependencies**

```bash
npm install
```

2. **iOS Setup** (Mac only)

```bash
cd ios
pod install
cd ..
```

3. **Run on Android**

```bash
npm run android
```

4. **Run on iOS**

```bash
npm run ios
```

5. **Start Metro Bundler**

```bash
npm start
```

## 🔌 Key Dependencies

### Core

- `react-native`: ^0.73.0
- `react`: ^18.2.0
- `typescript`: ^5.0.4

### Navigation

- `@react-navigation/native`: ^6.1.9
- `@react-navigation/stack`: ^6.3.20
- `@react-navigation/bottom-tabs`: ^6.5.11

### UI Components

- `react-native-paper`: ^5.11.3
- `react-native-vector-icons`: ^10.0.3

### Maps & Location

- `react-native-maps`: ^1.10.0

### Charts

- `react-native-chart-kit`: ^6.12.0

### State Management

- `zustand`: ^4.4.7

### Utilities

- `axios`: ^1.6.2 (API calls)
- `date-fns`: ^3.0.6 (Date formatting)
- `@react-native-async-storage/async-storage`: ^1.21.0

## 📝 Adding New Features

### Creating a New Screen

1. Create screen file in `src/screens/`

```typescript
import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { colors, spacing } from '../theme/theme';

const NewScreen = () => {
  return (
    <View style={styles.container}>
      <Text>New Screen</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
});

export default NewScreen;
```

2. Add to navigation in `AppNavigator.tsx`

```typescript
<Stack.Screen
  name="NewScreen"
  component={NewScreen}
  options={{ title: 'Screen Title' }}
/>
```

### Adding to Zustand Store

```typescript
interface NewStore {
  items: Item[];
  addItem: (item: Item) => void;
}

export const useNewStore = create<NewStore>((set) => ({
  items: [],
  addItem: (item) =>
    set((state) => ({
      items: [...state.items, item],
    })),
}));
```

## 🎯 Best Practices

1. **Component Organization**
   - Keep components focused and single-purpose
   - Extract reusable components
   - Use TypeScript for type safety

2. **Styling**
   - Use theme constants for colors and spacing
   - Keep styles modular and organized
   - Utilize shadows and borderRadius from theme

3. **State Management**
   - Use Zustand for global state
   - Keep local state for UI-only concerns
   - Avoid prop drilling

4. **Performance**
   - Use FlatList for long lists
   - Memoize expensive computations
   - Optimize images and assets

5. **Navigation**
   - Use proper TypeScript types for navigation
   - Pass minimal data through navigation params
   - Handle deep linking appropriately

## 🐛 Troubleshooting

### Metro Bundler Issues

```bash
npm start -- --reset-cache
```

### iOS Build Issues

```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Android Build Issues

```bash
cd android
./gradlew clean
cd ..
```

## 📦 Building for Production

### Android

```bash
cd android
./gradlew assembleRelease
```

### iOS

1. Open `ios/ArchitectHub.xcworkspace` in Xcode
2. Select Product > Archive
3. Follow distribution wizard

## 🔐 Environment Variables

Create `.env` file:

```
API_BASE_URL=https://api.example.com
GOOGLE_MAPS_API_KEY=your_key_here
```

## 📄 License

MIT License - See LICENSE file for details

## 👥 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📞 Support

For support, email: support@architecthub.com
Visit: https://architecthub.com/docs
