---
id: dependencies
title: Dependencies
sidebar_position: 6
---

# Key Dependencies

The `hospital-app` relies on several major community packages to accelerate development and ensure stability.

## State Management & Architecture
- **`flutter_riverpod: ^2.5.1`**: Core state management. Compile-safe provider system.

## UI & Navigation
- **`go_router: ^14.2.1`**: Declarative routing system capable of handling deep links and complex nested navigation shells (like our Bottom Navigation bar).
- **`cupertino_icons: ^1.0.8`**: iOS style icons.
- **`top_snackbar_flutter: ^3.3.0`**: Utility for in-app alert banners and toasts.

## Network & Storage
- **`dio: ^5.4.0`**: Powerful HTTP client for Dart, supporting interceptors, global configuration, and form data.
- **`flutter_secure_storage: ^9.0.0`**: Encrypted storage solution used to persist JWT tokens securely on the device.
- **`flutter_dotenv: ^5.1.0`**: Loads environment variables from a `.env` file to separate configuration from code.

## Data Models & Generation
- **`freezed_annotation: ^2.4.4`** & **`freezed: ^2.5.2`**: Code generation for immutable classes and unions. Essential for creating predictable state objects.
- **`json_annotation: ^4.9.0`** & **`json_serializable: ^6.8.0`**: Automated JSON serialization/deserialization for API models.

## Hardware & Utils
- **`mobile_scanner: ^5.2.3`**: Used in the Map module to scan QR codes for positioning ("I am here").
- **`image_picker: ^1.2.0`**: Handles native gallery and camera access.
- **`url_launcher: ^6.2.0`**: Used to open external links and trigger phone calls (e.g., SOS dial).
- **`firebase_core` / `firebase_messaging` / `flutter_local_notifications`**: Optional push-notification stack, disabled unless configured.
- **`web_socket_channel: ^3.0.1`**: Used by the Chat module for per-room realtime messages.
- **`package_info_plus: ^8.0.0`**: Reads the installed build number for the startup update check.
