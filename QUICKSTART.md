# 🚀 Quick Start Guide - ArchitectHub

## Welcome to ArchitectHub!

ArchitectHub is a comprehensive mobile application designed for architects and construction professionals to manage, track, and monitor their projects efficiently.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

- **Node.js** (version 18 or higher)
  - Download: https://nodejs.org/
  - Verify: `node --version`
- **npm** or **yarn** (comes with Node.js)
  - Verify: `npm --version`

- **React Native CLI**
  ```bash
  npm install -g react-native-cli
  ```

### For Android Development

- **Android Studio**
  - Download: https://developer.android.com/studio
  - Install Android SDK (API level 31 or higher)
  - Set up Android Virtual Device (AVD)
- **Java Development Kit (JDK 11)**
  - Download: https://www.oracle.com/java/technologies/downloads/

### For iOS Development (Mac only)

- **Xcode** (version 14 or higher)
  - Download from Mac App Store
  - Install Xcode Command Line Tools:
    ```bash
    xcode-select --install
    ```
- **CocoaPods**
  ```bash
  sudo gem install cocoapods
  ```

## 📦 Installation Steps

### 1. Navigate to Project Directory

```bash
cd "C:\Users\malak_tkw20pj\OneDrive\Desktop\NewProject"
```

### 2. Install Dependencies

```bash
npm install
```

This will install all required packages including:

- React Native and React
- Navigation libraries
- UI components (React Native Paper)
- State management (Zustand)
- Maps, charts, and other utilities

### 3. iOS Setup (Mac only)

```bash
cd ios
pod install
cd ..
```

This installs native iOS dependencies using CocoaPods.

## 🎯 Running the Application

### Option 1: Run on Android

#### Start Metro Bundler

```bash
npm start
```

#### In a New Terminal, Run Android

```bash
npm run android
```

Or manually:

```bash
npx react-native run-android
```

**Note**: Make sure you have:

- Android emulator running, OR
- Physical Android device connected via USB with USB debugging enabled

### Option 2: Run on iOS (Mac only)

#### Start Metro Bundler

```bash
npm start
```

#### In a New Terminal, Run iOS

```bash
npm run ios
```

Or manually:

```bash
npx react-native run-ios
```

**Note**: This will launch the iOS Simulator automatically.

### Option 3: Run on Specific Device/Emulator

#### Android - Specific Emulator

```bash
npx react-native run-android --deviceId=DEVICE_ID
```

To list devices:

```bash
adb devices
```

#### iOS - Specific Simulator

```bash
npx react-native run-ios --simulator="iPhone 15 Pro"
```

To list simulators:

```bash
xcrun simctl list devices
```

## 🔧 Troubleshooting

### Metro Bundler Issues

**Cache Problems**

```bash
npm start -- --reset-cache
```

**Port Already in Use**

```bash
npx react-native start --port 8082
```

### Android Issues

**Build Failed**

```bash
cd android
./gradlew clean
cd ..
npm run android
```

**SDK Not Found**

- Open Android Studio
- Go to Tools > SDK Manager
- Install Android SDK Platform 31+ and Build Tools 31+
- Set ANDROID_HOME environment variable

**Emulator Not Starting**

- Open Android Studio
- Tools > AVD Manager
- Create or start an existing AVD

### iOS Issues (Mac)

**Pod Install Failed**

```bash
cd ios
pod deintegrate
pod install
cd ..
```

**Build Failed**

```bash
cd ios
xcodebuild clean
cd ..
npm run ios
```

**Simulator Issues**

- Open Xcode
- Window > Devices and Simulators
- Check simulator status
- Try resetting simulator: Device > Erase All Content and Settings

### Common Errors

#### Error: "Unable to resolve module"

```bash
npm install
npm start -- --reset-cache
```

#### Error: "Task :app:installDebug FAILED"

```bash
cd android
./gradlew clean
cd ..
```

#### Error: "No bundle URL present"

```bash
npm start
# Wait for bundler to load
# Then run the app again
```

## 📱 App Features Overview

### Main Screens

1. **Dashboard** 📊
   - Project statistics
   - Quick actions
   - Recent projects
   - Alerts

2. **Projects** 🏢
   - All projects list
   - Search and filter
   - Add new projects
   - View details

3. **Map** 🗺️
   - Project locations
   - Interactive markers
   - Location info

4. **Maintenance** 🔧
   - Maintenance tasks
   - Priority management
   - Status tracking

5. **Analytics** 📈
   - Project metrics
   - Charts and graphs
   - Performance data
   - Export reports

6. **Profile** 👤
   - User information
   - Settings
   - Preferences
   - Support

### Additional Features

- **Project Details**: Complete project information with tabs
- **Tasks**: Task management with assignments
- **Security**: Security monitoring and alerts
- **Landscape**: Landscape planning and plant management

## 🎨 Customization

### Changing Colors

Edit `src/theme/theme.ts`:

```typescript
export const colors = {
  primary: '#2563EB', // Change to your brand color
  secondary: '#10B981',
  // ... more colors
};
```

### Adding New Screens

1. Create screen file in `src/screens/`
2. Add to navigation in `src/navigation/AppNavigator.tsx`
3. Update types in navigation file

### Modifying Data

Sample data is in `src/store/projectStore.ts`. Modify the initial projects array to customize sample data.

## 📚 Documentation

- **README.md** - Project overview and features
- **DEVELOPMENT_GUIDE.md** - Detailed development instructions
- **DESIGN_SYSTEM.md** - UI/UX specifications
- **FEATURES.md** - Complete feature list

## 🔄 Next Steps

### 1. Explore the App

- Launch the app and navigate through all screens
- Test different features
- Check out the sample projects

### 2. Customize Sample Data

- Edit `src/store/projectStore.ts`
- Add your own projects
- Modify project properties

### 3. Connect to Backend (Future)

- Create API service in `src/services/`
- Replace mock data with API calls
- Implement authentication

### 4. Add Your Features

- Follow the existing patterns
- Use the design system
- Maintain code quality

## 🌟 Tips for Success

### Development

- Use TypeScript for type safety
- Follow the established design patterns
- Keep components modular and reusable
- Comment complex logic

### Testing

- Test on both iOS and Android
- Test on different screen sizes
- Check performance on older devices
- Test offline scenarios

### Performance

- Optimize images and assets
- Use FlatList for long lists
- Implement lazy loading
- Monitor memory usage

### Best Practices

- Follow React Native best practices
- Keep dependencies updated
- Use meaningful commit messages
- Document your code

## 📞 Getting Help

### Resources

- **React Native Docs**: https://reactnative.dev/
- **React Navigation**: https://reactnavigation.org/
- **React Native Paper**: https://callstack.github.io/react-native-paper/

### Common Commands

```bash
# Install dependencies
npm install

# Start Metro bundler
npm start

# Run on Android
npm run android

# Run on iOS
npm run ios

# Run tests
npm test

# Lint code
npm run lint

# Clear cache
npm start -- --reset-cache
```

## 🎉 You're Ready!

Your ArchitectHub mobile application is now set up and ready to run. Start building amazing features and customize it to fit your company's needs!

### Quick Start Checklist

- [ ] Node.js installed
- [ ] Dependencies installed (`npm install`)
- [ ] iOS pods installed (Mac only)
- [ ] Emulator/Simulator running
- [ ] App launched successfully
- [ ] Explored main features
- [ ] Read documentation

---

**Need Help?** Check the troubleshooting section or refer to the development guide.

**Ready to Develop?** Start by exploring the code structure and modifying the sample data.

**Happy Coding!** 🚀
