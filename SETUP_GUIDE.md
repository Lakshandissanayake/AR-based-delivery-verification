# Quick Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.8.1 or higher)
  - Check: `flutter --version`
  - Install: https://docs.flutter.dev/get-started/install

- **Dart SDK** (3.8.1 or higher)
  - Comes with Flutter

- **Android Studio** or **VS Code**
  - Android Studio: https://developer.android.com/studio
  - VS Code: https://code.visualstudio.com/

- **Android SDK** (for Android development)
  - API Level 24 or higher

- **Xcode** (for iOS development, macOS only)
  - Version 11.0 or higher

## Step-by-Step Setup

### 1. Install Flutter Dependencies

```bash
# Navigate to project directory
cd delivery_verification_system

# Get all packages
flutter pub get
```

### 2. Verify Setup

```bash
# Check Flutter setup
flutter doctor

# Fix any issues reported
# For example:
# - Accept Android licenses: flutter doctor --android-licenses
# - Install missing components via Android Studio
```

### 3. Configure Devices

#### For Android:
```bash
# List connected devices
flutter devices

# Enable developer mode on your Android phone:
# 1. Go to Settings > About Phone
# 2. Tap "Build Number" 7 times
# 3. Go back to Settings > Developer Options
# 4. Enable "USB Debugging"
# 5. Connect phone via USB
```

#### For iOS (macOS only):
```bash
# Open iOS Simulator
open -a Simulator

# Or connect a physical iPhone
# Trust the computer when prompted on iPhone
```

### 4. Build and Run

```bash
# Run on connected device
flutter run

# Or specify device
flutter run -d <device-id>

# For release build
flutter build apk      # Android
flutter build ios      # iOS
```

## First-Time Run Checklist

When you first run the app:

- [ ] Grant camera permissions when prompted
- [ ] Grant storage permissions when prompted
- [ ] Test camera functionality on Camera screen
- [ ] Scan a test item
- [ ] View item in AR viewer
- [ ] Verify an item
- [ ] Check delivery list

## Troubleshooting

### Issue: "Camera permission denied"
**Solution:**
1. Go to device Settings
2. Apps > Delivery Verification System
3. Permissions > Enable Camera

### Issue: "AR not supported"
**Solution:**
- Android: Device must support ARCore
  - Check: https://developers.google.com/ar/devices
- iOS: Device must support ARKit
  - Requires iPhone 6S or newer

### Issue: "Build failed"
**Solution:**
```bash
# Clean build
flutter clean

# Get dependencies again
flutter pub get

# Try rebuilding
flutter run
```

### Issue: "Plugin not found"
**Solution:**
```bash
# Upgrade Flutter
flutter upgrade

# Update packages
flutter pub upgrade

# Clean and rebuild
flutter clean && flutter pub get
```

### Issue: "Gradle build failed" (Android)
**Solution:**
1. Update Android SDK via Android Studio
2. Check `android/build.gradle` - Gradle version should be compatible
3. Run: `cd android && ./gradlew clean`

### Issue: "CocoaPods error" (iOS)
**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

## Development Tips

### Hot Reload
While app is running:
- Press `r` to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Debug Mode
```bash
# Run with debug logging
flutter run --verbose

# Run in profile mode
flutter run --profile
```

### Code Generation
If you add new models with JSON serialization:
```bash
flutter pub run build_runner build
```

### Linting
```bash
# Run linter
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

## Environment Setup

### VS Code Extensions (Recommended)
- Flutter
- Dart
- Flutter Widget Snippets
- Pubspec Assist

### Android Studio Plugins (Recommended)
- Flutter
- Dart

## Next Steps

After successful setup:

1. Read `README.md` for feature overview
2. Read `ARCHITECTURE.md` for code structure
3. Explore `lib/` directory
4. Try modifying UI in `lib/views/`
5. Add custom 3D models in `assets/models/`

## Need Help?

- Flutter Documentation: https://docs.flutter.dev/
- Riverpod Documentation: https://riverpod.dev/
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

## Quick Commands Reference

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run app on device |
| `flutter clean` | Clean build files |
| `flutter analyze` | Run static analysis |
| `flutter test` | Run unit tests |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS app |
| `flutter doctor` | Check setup |
| `flutter devices` | List connected devices |
| `flutter upgrade` | Upgrade Flutter SDK |

---

**Happy Coding! 🚀**














