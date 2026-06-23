# Hospital App Project Overview

This document provides a summary of the project's core systems, specifically the theme and network architecture, to help developers understand and maintain the codebase.

---

## 🎨 Theme System

The theme system is designed to be modern, clean, and calming—tailored for healthcare applications. It leverages Material 3 and centralized text/color/design tokens. Typography is configured in `AppTextTheme` with **Plus Jakarta Sans** family names; the app no longer depends on the `google_fonts` package.

### 1. Color Tokens (`AppColors`)
The project uses a centralized color palette defined in `lib/core/theme/app_colors.dart`.

- **Primary (Medical Blue):** `#0A6DC2` - Conveys trust, professionalism, and calm.
- **Secondary (Health Green):** `#0E8A6D` - Conveys health, vitality, and positive outcomes.
- **Semantic Colors:**
    - `success`: `#27AE60`
    - `warning`: `#F39C12`
    - `error`: `#E74C3C`
    - `info`: `#0A6DC2`
- **Neutral Colors:** Separate sets for light and dark modes, including background, surface, border, and text colors.
- **Status & Department Colors:** Specialized colors for appointment statuses (Available, In Consultation, Waiting, Emergency, Offline) and department-specific accents (Cardiology, Neurology, Orthopedics, Pediatrics, Dermatology, General).

### 2. Design Tokens
- **Spacing (`AppSpacing`):** Predefined spacing from `xs` (4px) to `xxxl` (48px), including standard page and card padding.
- **Radius (`AppRadius`):** Border radius tokens from `sm` (8px) to `full` (999px).
- **Shadows (`AppShadows`):** Subtle shadows for cards, elevated elements (modals/dropdowns), and bottom navigation bars.

### 3. Theme Data (`HospitalTheme`)
The main `HospitalTheme` class provides `light` and `dark` `ThemeData` configurations. It handles the styling for:
- **AppBar, BottomNavigationBar, NavigationBar**
- **Buttons** (Elevated, Outlined, Text, FAB)
- **Input Fields** (InputDecoration)
- **Cards, Chips, Dialogs, Bottom Sheets**
- **Snackbars, Dividers, ListTiles, TabBars**
- **Switches, Checkboxes, Progress Indicators**

### 4. Extensions & Usage Examples
A `BuildContextThemeX` extension in `lib/core/theme/hospital_theme.dart` provides convenient access to theme data.

#### Accessing Theme & Colors
```dart
// Using the extension to get colors
final primaryColor = context.colorScheme.primary;
final isDark = context.isDarkMode;

// Using design tokens
return Container(
  padding: AppSpacing.cardPadding,
  decoration: BoxDecoration(
    color: context.colorScheme.surface,
    borderRadius: AppRadius.borderMd,
    boxShadow: AppShadows.card,
  ),
  child: Text(
    'Patient Record',
    style: context.textTheme.titleMedium?.copyWith(
      color: AppColors.primary,
    ),
  ),
);
```

---

## 🌐 Network Architecture

The network layer is built using **Dio** and follows a centralized, interceptor-based approach.

### 1. ApiClient (`ApiClient`)
A singleton Dio instance located in `lib/core/network/api_client.dart`. It is pre-configured with:
- **Base URL:** Loaded from `AppConfig`.
- **Timeouts:** Configurable connection and send/receive timeouts.
- **Interceptors:** `AuthInterceptor` and `ErrorInterceptor` are added by default.

#### Usage Example
```dart
Future<void> fetchPatients() async {
  try {
    final response = await ApiClient.instance.get(ApiEndpoints.patients);
    // Data is automatically handled, and Auth token is injected by interceptor
    final data = response.data;
  } on DioException catch (e) {
    // ErrorInterceptor has already mapped the error message
    print(e.message); 
  }
}
```

### 2. ApiEndpoints (`ApiEndpoints`)
A central registry for all API path constants. Always use these instead of hardcoded strings.

### 3. Token Management (`TokenRepository`)
Uses `flutter_secure_storage` to handle JWT tokens securely.

#### Usage Example
```dart
// Saving a token after login
await TokenRepository.saveToken(loginResponse.token);

// Checking if user is logged in
bool isLoggedIn = await TokenRepository.hasToken();
```
### 4. Interceptors
- **AuthInterceptor (`AuthInterceptor`):** Automatically injects the `Authorization: Bearer <token>` header into outgoing requests if a token exists in the `TokenRepository`.
- **ErrorInterceptor (`ErrorInterceptor`):**
    - **Unified Error Handling:** Catches all `DioException` types and maps them to user-friendly messages.
    - **Global Status Handling:** Detects specific status codes like 401 (Unauthorized), 403 (Forbidden), and 500 (Internal Server Error) to trigger global logic (e.g., logout for 401).

---

## 🛠️ Key Files
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/hospital_theme.dart`
- `lib/core/network/api_client.dart`
- `lib/core/network/token_repository.dart`
- `lib/core/network/interceptors/error_interceptor.dart`

---

## 🗺️ Map Module

The map feature (`lib/features/map/`) renders a hospital floor grid with POIs, walkable cells, and previewed routes. It is built on Riverpod providers, a single `CustomPainter`, and `InteractiveViewer` for pan/zoom.

### Layout
- **Data**: `data/map_repository.dart` plus freezed models (`map_floor`, `map_poi`, `map_edge`, etc.).
- **Providers** (`presentation/providers/map_provider.dart`):
  - Raw fetches — `mapMetaProvider`, `mapNodesProvider`, `mapEdgesProvider`.
  - Derived caches — `normalizedPoiNamesProvider`, `poiByIdProvider`, `poiByCellProvider`, `walkableCellsProvider`, `adjacencyProvider`.
  - Route state — `routeStartProvider`, `routeDestProvider`, `routeModeProvider`, `routeResultProvider`, `routeLocationsProvider`.
- **Utils**: `presentation/utils/search_utils.dart` — accent-insensitive `normalizeForSearch` with top-level `RegExp` instances (parsed once).
- **Tokens**: `presentation/theme/map_tokens.dart` — `MapMotion` durations/curves, `MapSurface` colors, `MapPoiPalette` (muted, semantically grouped POI palette + labels).
- **Painter**: `widgets/map_grid_painter.dart` — now split into two layers for large-floor performance: `MapStaticPainter` (base image / merged walkable runs + POIs, under its own `RepaintBoundary`, repaints only on data change) and `MapDynamicPainter` (route + user dot, the only per-frame layer). Both use pooled `Paint` objects, viewport culling, and an animated `routeProgress` (0–1) for route draw-on.
- **Baked base image**: large hospital floors (e.g. 300×500 = 150k cells) lagged when each frame looped every grid cell with a `drawRect`. Each map now ships a pre-baked PNG (walls + floor only) at `assets/map/{id}.png`, resolved by `mapId` via `data/map_asset_registry.dart` and drawn once with `drawImageRect`; POIs, route, and the user dot stay live vectors on top. Maps without a registry entry fall back to the optimized cell renderer (`walkableRunsProvider` collapses walkable cells into per-row runs so the fallback draws hundreds of rects instead of 150k). `tool/render_map_png.dart` rasterizes `assets/map/{id}.map` → `{id}.png` at 8 px/cell (workflow documented in `README.md`).
- **Page**: `pages/map_page.dart` — full-screen grid with collapsible overlays, floor selector, analytics panel, status cluster, route pill, and route planning sheets. The left FAB rail is **three buttons** (QR, recenter, More); legend, route history, and flow analytics fold into a **More** sheet. Search collapses to an icon by default. POI taps, route planning, route history, obstacle reporting, and the legend all open as modal bottom sheets, leaving the map unobstructed.
- **Widgets**: `map_top_bar`, `map_search_results_panel` (skeleton + suggestion chips), `map_poi_metadata_panel`, `map_route_panel`, `map_route_status`, `map_legend_sheet`, `map_navigation_sheet`, `poi_picker` (reusable `PoiPickerField` / `showPoiPicker`, shared by queue/wheelchair/staff flows), and `map_page/*` focused widgets.

### Performance notes
- `MapPage.build` scopes provider reads with `.select()` to avoid full-tree rebuilds.
- The static layer (base image + POIs) and the dynamic layer (route + dot) each sit under their own `RepaintBoundary`; only the dynamic layer repaints per animation tick, so pan/zoom and route draw-on stay smooth even on the largest floors.
- Each `CustomPaint` painter uses identity comparisons in `shouldRepaint`.
- POI tap uses `poiByCellProvider` (O(1) cell index, 3×3 neighborhood search) instead of a linear scan.
- Vietnamese search normalization is computed once per POI and cached in `normalizedPoiNamesProvider`.

### Voice guidance
Offline turn-by-turn voice cues during simulated navigation (`presentation/navigation/voice_service.dart`).
- **Clips**: 8 Vietnamese MP3s bundled as assets (`assets/voice/vi/<key>.mp3`: `turn_left`, `turn_right`, `go_straight`, `arrived`, `elevator_up/down`, `stairs_up/down`). No network — packed into the `.apk`/`.ipa` at build time.
- **Player**: a pre-warmed `AudioPlayer` pool (one per clip, preloaded into memory) plays a cue with an instant `seek`+`resume`. Playback is sequential and non-overlapping, bounded by each clip's length so a missed completion event can't stall the queue. `flutter_tts` (vi) is the fallback for any key without a bundled clip. Android uses the media stream at full volume; iOS honours the silent switch; web has autoplay-unlock + DDC/empty-src handling.
- **Decider** (`VoiceCueDecider`): announces an upcoming turn within ~6 grid blocks, otherwise the current segment ("go straight") once it changes; arrival is spoken exactly once. Maneuvers are derived from the backend `voice_text` key so turns aren't lost.
- **Wiring**: `NavigationController` feeds `StepTracker` state to `VoiceService` each tick; `voiceMutedProvider` (persisted in Hive) gates output and is toggled from the navigation sheet header. Demo speed (`navSpeedProvider`, default ×0.5) keeps the dot slow enough to hear each cue.

### Tests
- `test/features/map/presentation/utils/search_utils_test.dart` — normalization correctness.
- `test/features/map/presentation/providers/map_provider_test.dart` — search results, derived providers, route extraction.
- `test/features/map/presentation/navigation/voice_service_test.dart` — decider (turn lead / current-segment / arrival suppression / mute), voice-key resolution, and the sequential non-overlapping clip player.
- Run with `flutter test test/features/map`.
