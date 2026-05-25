# Hospital System - Indoor Navigation & Management

> A Flutter-based hospital management and indoor navigation app for patients and staff. It focuses on indoor wayfinding where GPS is unreliable, while also exposing hospital utility workflows in one place.

## Overview

The app is organized as a feature-first Flutter codebase with Riverpod state management and GoRouter navigation. Current user-facing features include:

- Authentication with signup, login, and OTP verification
- Home dashboard with utility shortcuts
- SOS entry point
- Weather and parking utility cards
- Cross-platform support for mobile and macOS development

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) on the stable channel
- Android Studio or VS Code with the Flutter extension
- An Android emulator, iOS simulator, or connected physical device

### Setup

```bash
git clone <repository-url>
cd hospital-app
flutter pub get
```

### Run

```bash
flutter run
```

To target a specific platform:

```bash
flutter run -d macos
flutter run -d android
flutter run -d ios
```

### Build

```bash
flutter build apk --release
flutter build ios --release
flutter build macos
```

### Test and Analyze

```bash
flutter test
dart analyze lib test
```

## Project Structure

- `lib/app/`: App-level configuration, root widget, and routing
- `lib/core/`: Shared constants, utilities, networking, and theming
- `lib/features/`: Feature modules such as auth, home, SOS, and utilities

## Code Style

- Use `snake_case` for file names
- Use `PascalCase` for classes
- Use `camelCase` for variables and functions

Keep generated files in sync with `build_runner` when editing Freezed/json_serializable models.
