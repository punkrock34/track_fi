# Setup Guide

## Prerequisites

### System Requirements

#### Flutter Environment

- **Flutter SDK**: 3.7.2 or higher
- **Dart SDK**: 3.0+ (included with Flutter)
- **Git**: For version control

#### Development Tools

- **Android Studio** or **IntelliJ IDEA** with Flutter plugin
- **VS Code** with Flutter extension (alternative)
- **Xcode** (macOS only, for iOS development)

#### Platform Requirements

**For Android Development:**

- Android SDK 21+ (Android 5.0)
- Java 8 or higher
- Android Studio or Android SDK command-line tools

**For iOS Development:**

- macOS 10.14 or higher
- Xcode 14.0 or higher
- iOS 11.0+ deployment target
- CocoaPods (usually installed with Xcode)

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/punkrock34/trackfi.git
cd trackfi
```

### 2. Flutter Setup Verification

```bash
# Check Flutter installation
flutter doctor

# Ensure all checkmarks are green
# Fix any issues reported by flutter doctor
```

### 3. Install Dependencies

```bash
# Install Flutter packages
flutter pub get

# For iOS (macOS only)
cd ios && pod install && cd ..
```

## Environment Configuration

### 1. Environment Files

TrackFi uses environment-specific configuration files:

```bash
# Copy the development template
cp lib/core/config/.env.development.ini lib/core/config/.env.ini
```

### 2. Environment Variables

Edit `lib/core/config/.env.ini`:

```ini
[General]
ENVIRONMENT = development
API_BASE_URL = http://localhost:3000/api

[Security]
TRACKFI_SALT = YourCustomSaltHere

[Monitoring]
SENTRY_DSN = your_sentry_dsn_here

[Database]
SQLITE_ENCRYPTION_KEY = "YourEncryptionKeyHere"
```

**Important Security Notes:**

- **Change the default salt**: Use a unique, random string
- **Keep secrets secure**: Never commit real API keys to version control
- **Use different keys per environment**: Development vs Production

### 3. Generate Required Code

```bash
# Generate Riverpod providers and other code
dart run build_runner build

# For continuous generation during development
dart run build_runner watch
```

## Platform-Specific Setup

### Android Setup

#### 1. Android SDK Configuration

Ensure the following are installed via Android Studio SDK Manager:

- Android SDK Platform 34 (or latest)
- Android SDK Build-Tools 34.0.0 (or latest)
- Android Emulator (for testing)

#### 2. Create Virtual Device

```bash
# List available emulators
flutter emulators

# Create a new emulator (if none exist)
# Use Android Studio AVD Manager to create one
```

#### 3. Build Configuration

No additional setup required for development builds.

### iOS Setup (macOS Only)

#### 1. Xcode Configuration

```bash
# Accept Xcode license
sudo xcodebuild -license

# Install iOS Simulator
xcodebuild -downloadPlatform iOS
```

#### 2. CocoaPods Setup

```bash
# Install CocoaPods (if not already installed)
sudo gem install cocoapods

# Install iOS dependencies
cd ios
pod install
cd ..
```

#### 3. Simulator Setup

```bash
# List available iOS simulators
xcrun simctl list devices

# Boot a simulator
open -a Simulator
```

## Development Environment

### Android Studio Setup

1. Install Flutter plugin via Settings → Plugins
2. Configure Flutter SDK path
3. Enable Dart analysis

### Code Generation

TrackFi uses code generation for Riverpod providers:

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (recommended for development)
dart run build_runner watch --delete-conflicting-outputs
```

### Running the Application

#### Development Mode

```bash
# Run on connected device/emulator
flutter run

# Run with specific device
flutter devices
flutter run -d <device_id>

# Run with hot reload enabled (default)
flutter run --hot
```

#### Release Mode Testing

```bash
# Test release build performance
flutter run --release
```

## Troubleshooting

### Common Issues

#### 1. Code Generation Errors

```bash
# Clean and regenerate
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### 2. Dependency Conflicts

```bash
# Clear pub cache and reinstall
flutter pub deps
flutter pub cache repair
flutter clean
flutter pub get
```

#### 3. iOS Build Issues

```bash
# Clean iOS build
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter build ios
```

#### 4. Android Build Issues

```bash
# Clean Android build
flutter clean
cd android
./gradlew clean
cd ..
flutter build apk
```

### Platform-Specific Issues

#### Android

**Issue**: Build fails with Android SDK errors
**Solution**:

```bash
flutter doctor --android-licenses
# Accept all licenses
```

**Issue**: Emulator not starting
**Solution**:

```bash
# Check available emulators
flutter emulators
# Ensure virtualization is enabled in BIOS
```

#### iOS

**Issue**: CocoaPods errors
**Solution**:

```bash
cd ios
pod repo update
pod install
cd ..
```

**Issue**: Simulator not launching
**Solution**:

```bash
# Reset simulator
xcrun simctl erase all
```

## Development Workflow

### 1. Start Development

```bash
# Terminal 1: Start code generation watcher
dart run build_runner watch

# Terminal 2: Run the app
flutter run
```

### 2. Making Changes

- Hot reload: `r` in terminal or save file in IDE
- Hot restart: `R` in terminal
- Quit: `q` in terminal

### 3. Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/auth_test.dart

# Run with coverage
flutter test --coverage
```

## Production Build

### Build Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### Build iOS

```bash
# Build for iOS
flutter build ios --release

# Build IPA (requires Xcode)
flutter build ipa --release
```

## Performance Optimization

### Debug Tools

```bash
# Run with performance overlay
flutter run --profile

# Analyze app size
flutter build apk --analyze-size
flutter build ios --analyze-size
```

### Memory Profiling

```bash
# Run with observatory
flutter run --debug --observatory-port=8080
# Open browser to localhost:8080 for debugging tools
```

## Next Steps

After successful setup:

1. **Explore the codebase**: Start with [main.dart](../lib/main.dart)
2. **Secure Your App**:Familiarize yourself with best practices by reviewing the detailed guidelines in [SECURITY.md](security.md).
3. **Customize Your Experience**:Get started by modifying the welcome screen to see your first change in action.
4. **Run tests**: Ensure everything works correctly

For additional help, check the [Flutter documentation](https://docs.flutter.dev/) or create an issue in the repository.
