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

### Map base images

Large floor maps are rendered from a pre-baked PNG (walls + floor only) instead of
painting every grid cell, so the map stays smooth even at 300×500. POIs, the route, and
the user dot are still drawn as live vectors on top of the image.

Source grids live in `assets/map/{id}.map` (octile ASCII, `@` = wall, anything else =
walkable). The tool rasterizes each one to `assets/map/{id}.png` at 8 px/cell, named by
**mapId** — the same id the backend assigns and that
`lib/features/map/data/map_asset_registry.dart` keys on.

Regenerate all base PNGs from their `.map` sources:

```bash
flutter test tool/render_map_png.dart
```

It prints one line per map, e.g. `Rendered assets/map/5.map (500 x 300) -> assets/map/5.png`.

When you add or edit a map:

1. Drop the new grid at `assets/map/{id}.map`.
2. Run the command above to (re)generate `assets/map/{id}.png`.
3. Register the id in `kMapAssets` (`map_asset_registry.dart`) with its `rows`/`cols`.

Maps with no registry entry fall back to the (still optimized) cell renderer — no PNG
required.

### Continuous Integration

GitHub Actions workflows in `.github/workflows/`:

- **`flutter_ci.yml`** — quality bot: runs on every push/PR to `main`. Generates Freezed/JSON sources, checks formatting (`dart format`), and runs `flutter analyze`.
- **`ios_build.yml`** — semver-tag triggered (`v*.*.*`) plus manual dispatch. Caches Flutter pub + CocoaPods, injects build number from CI run, produces an unsigned `Runner.xcarchive` as an artifact. **Unsigned because production code-signing is out of scope for this academic project** — the artifact is for build-pipeline verification and inspection only, not for device install. (A signed `.ipa` would require an Apple Developer certificate + provisioning profile.)

To produce a tagged iOS build:

```bash
git tag v1.0.0
git push origin v1.0.0
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
