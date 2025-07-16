# TrackFi

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-In_Development-yellow?style=for-the-badge)
![License](https://img.shields.io/badge/License-Educational-blue?style=for-the-badge)

## 🏦 Modern Personal Finance Management

A secure, feature-rich Flutter application for tracking and analyzing your financial data with bank-grade security and intelligent insights.

---

## ✨ Features

### 🔐 Security First

- **PIN Authentication** - Secure 4-6 digit PIN protection
- **Biometric Authentication** - Face ID, Fingerprint, and Iris support
- **Local Data Storage** - All data stored securely on device
- **Encrypted Database** - SQLite with encryption for sensitive data
- **Auto-lockout Protection** - Prevents brute force attacks

### 💰 Financial Management

- **Account Management** - Multiple account support (checking, savings, credit)
- **Transaction Tracking** - Comprehensive transaction history
- **Category System** - Smart categorization with custom categories
- **Balance Overview** - Real-time balance tracking across accounts
- **Sync Status** - Track data synchronization state

### 🎨 Modern UI/UX

- **Adaptive Themes** - Light, dark, and system-adaptive modes
- **Premium Design** - Clean, modern interface with smooth animations
- **Responsive Layout** - Optimized for various screen sizes
- **Accessibility** - Full accessibility support

### 🧠 Smart Features (Planned)

- **AI-Powered Insights** - Spending pattern analysis
- **Financial Summaries** - Intelligent spending reports
- **Smart Suggestions** - Personalized financial recommendations

---

## 🏗️ Architecture

TrackFi follows **Clean Architecture** principles with a feature-driven folder structure:

```text
lib/
├── app/                    # App configuration and theming
├── core/                   # Core business logic and infrastructure
│   ├── config/            # Environment and app configuration
│   ├── contracts/         # Interface definitions (repositories, services)
│   ├── models/            # Core data models
│   ├── providers/         # Riverpod providers for dependency injection
│   ├── services/          # Core services (auth, database, storage)
│   ├── theme/             # Design system and theming
│   └── router/            # Navigation and routing
├── features/              # Feature modules
│   ├── auth/              # Authentication flow
│   ├── dashboard/         # Main dashboard
│   └── onboarding/        # User onboarding
└── shared/                # Shared widgets and utilities
```

### 🔧 Key Technologies

- **State Management**: Riverpod 2.6+ with code generation
- **Database**: SQLite with encrypted storage
- **Security**: Flutter Secure Storage + Biometric authentication
- **UI**: Material 3 with FlexColorScheme
- **Navigation**: GoRouter with declarative routing
- **Animations**: Flutter Animate for smooth transitions

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK 3.0+
- Android Studio / VS Code with Flutter extensions
- iOS development: Xcode 14+ (for iOS builds)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/punkrock34/trackfi.git
   cd trackfi
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Set up environment configuration**

   ```bash
   # Copy the environment template
   cp lib/core/config/.env.development.ini lib/core/config/.env.ini
   ```

4. **Generate code** (for Riverpod providers)

   ```bash
   dart run build_runner build
   ```

5. **Run the application**

   ```bash
   flutter run
   ```

---

## 📱 App Flow

### 1. **First Launch**

- Welcome screen with feature highlights
- PIN setup (4-6 digits)
- Biometric authentication setup (optional)
- Theme customization
- Onboarding completion

### 2. **Authentication**

- Biometric authentication (if enabled)
- PIN fallback with attempt limiting
- Auto-lockout protection after failed attempts

### 3. **Dashboard**

- Account balance overview
- Recent transactions
- Quick actions
- Spending insights

---

## 🔒 Security Features

### Data Protection

- **Local-first approach** - No cloud storage of sensitive data
- **SQLite encryption** - Database-level encryption
- **Secure key storage** - Platform-specific secure storage
- **PIN hashing** - Salted SHA-256 hashing

### Authentication Security

- **Biometric integration** - Native platform biometric APIs
- **Failed attempt tracking** - Progressive lockout system
- **Session management** - Automatic session expiration
- **Background protection** - App content hiding in app switcher

---

## 🎨 Design System

TrackFi implements a comprehensive design system with:

- **Design Tokens** - Consistent spacing, colors, and typography
- **Component Library** - Reusable UI components
- **Adaptive Theming** - Light/dark mode support
- **Responsive Design** - Mobile-first with tablet support
- **Accessibility** - WCAG 2.1 compliance

### Color Palette

- **Premium Black**: `#0A0A0A` - Primary brand color
- **Premium White**: `#FAFAFA` - Light theme background
- **Accent Gold**: `#D4AF37` - Premium accent color
- **Success Green**: `#10B981` - Success states
- **Error Red**: `#EF4444` - Error states

---

## 🧪 Development

### Code Generation

The app uses code generation for Riverpod providers:

```bash
# Watch for changes and regenerate code
dart run build_runner watch

# One-time generation
dart run build_runner build --delete-conflicting-outputs
```

### Environment Configuration

Different configurations for development and production:

- `lib/core/config/.env.development.ini` - Development settings
- `lib/core/config/.env.production.ini` - Production settings

### Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

---

## 📦 Build & Release

### Android Build

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

### iOS Build

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

---

## 🐛 Known Issues & Limitations

- **Beta Status**: App is in active development
- **Local Storage Only**: No cloud synchronization yet
- **Limited Banking Integration**: Manual data entry required
- **AI Features**: Planned for future releases

---

## 🛣️ Roadmap

### v2.0 - Enhanced Features

- [ ] Bank API integrations (Open Banking)
- [ ] Export functionality (PDF, CSV)
- [ ] Advanced analytics and reporting
- [ ] Budget planning and tracking

### v3.0 - AI Integration

- [ ] Machine learning spending insights
- [ ] Predictive financial modeling
- [ ] Personalized financial advice
- [ ] Smart transaction categorization

### v4.0 - Multi-platform

- [ ] Web application
- [ ] Desktop applications (Windows, macOS, Linux)
- [ ] Apple Watch companion app

---

## 🤝 Contributing

This is currently a university project and not open for external contributions. However, feedback and suggestions are welcome!

### Reporting Issues

If you encounter any bugs or have feature suggestions:

1. Check existing issues first
2. Provide detailed reproduction steps
3. Include device/platform information
4. Attach logs if relevant

---

## 📄 License

This project is developed for educational purposes as part of a university course. All rights reserved.

**Not licensed for commercial use or redistribution.**

---

## 👨‍🎓 About

**TrackFi** is developed by **Popus Razvan Adrian** as part of a university mobile development course project.

- **GitHub**: [@punkrock34](https://github.com/punkrock34)
- **Focus**: Modern mobile architecture and secure financial applications
- **University Project**: Exploring Flutter development and mobile security

---

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **Riverpod** - For excellent state management
- **Material Design** - For design system inspiration
- **Open Source Community** - For the incredible packages and tools

---

## TrackFi - Your Financial Command Center

### Built with ❤️ using Flutter
