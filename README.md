# Hospital System - Indoor Navigation & Management

> A comprehensive multi-platform hospital management and indoor navigation system developed as a graduation project at Hanoi University of Science and Technology (HUST). This system addresses the complexity of navigating large hospital campuses where GPS is unreliable, while integrating critical medical and asset management  workflows.

## Project Overview

The Hospital System is an integrated ecosystem designed to coordinate traffic flow, provide turn-by-turn indoor navigation, and manage medical services. It consists of **Mobile Client** Developed with Flutter for patients and staff (iOS/Android).

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- Android Studio or VS Code with Flutter extension
- An Android Emulator, iOS Simulator, or a physical device

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd hospital_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App
To run the app in debug mode on your connected device/emulator:
```bash
flutter run
```

### Building for Production
- **Android:**
  ```bash
  flutter build apk --release
  ```
- **iOS:**
  ```bash
  flutter build ios --release
  ```

# Project Rule
---
## Define Name
---
### File Naming
 
```
✓ snake_case for all files
  user_model.dart
  auth_repository.dart
  login_page.dart
  app_colors.dart
 
❌ NEVER use camelCase or PascalCase for files
  userModel.dart       ← Wrong
  AuthRepository.dart  ← Wrong
```
 
### Class Naming
 
```dart
// ✓ PascalCase for classes
class UserModel {}
class AuthRepository {}
class LoginPage {}
 
// ✓ Suffix pattern for clarity
class UserModel {}                  // Model (data layer)
class User {}                       // Entity (domain layer)
class AuthRepository {}              // Abstract repository
class AuthRepositoryImpl {}          // Implementation
class LoginUseCase {}                // Use case
class AuthBloc {}                    // Bloc
class AuthState {}                   // State
class AuthEvent {}                   // Event
class LoginPage {}                   // Full-screen page
class LoginForm {}                   // Reusable widget
class AuthRemoteDataSource {}        // Data source
class AuthRemoteDataSourceImpl {}    // Implementation
```
 
### Variable & Function Naming
 
```dart
// ✓ camelCase
final userName = 'John';
void fetchUserData() {}
bool get isAuthenticated => _token != null;
 
// ✓ Private with underscore prefix
String _token = '';
void _handleLogin() {}
 
// ✓ Constants: upper case + snake_case (Dart convention)
const DEFAULT_PADDING = 16.0;
const API_TIMEOUT = Duration(seconds: 30);
```

## Project Structure
The project follows a feature-first architecture:
- `lib/app/`: App-level configuration (root widget, routing).
- `lib/core/`: Shared constants, utilities, and common widgets.
- `lib/features/`: Independent modules (Auth, Home, Map, etc.), each containing its own Data, Domain, and Presentation layers.
