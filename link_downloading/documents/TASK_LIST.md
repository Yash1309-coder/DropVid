# TASK_LIST.md
## App: DropVid — Build Order & Progress Tracker
**Version:** 1.0

> ✅ = Done | 🔄 = In Progress | ⬜ = Not Started
> Complete tasks in order. Do not skip phases.

---

## Phase 0 — Project Setup

| # | Task | Notes | Status |
|---|------|-------|--------|
| 0.1 | Create Flutter project: `flutter create dropvid` | Min SDK: 26 | ⬜ |
| 0.2 | Set up folder structure as defined in TRD section 2.2 | Create all empty folders | ⬜ |
| 0.3 | Add all dependencies to `pubspec.yaml` | Use versions from TRD section 13 | ⬜ |
| 0.4 | Run `flutter pub get` and verify no conflicts | Fix any version conflicts | ⬜ |
| 0.5 | Add Inter font files to `assets/fonts/` | Download from Google Fonts | ⬜ |
| 0.6 | Add placeholder Lottie JSON files to `assets/animations/` | Use free Lottiefiles animations | ⬜ |
| 0.7 | Add platform SVG icons to `assets/icons/` | Instagram, TikTok, Twitter, etc. | ⬜ |
| 0.8 | Create `app_colors.dart` from DESIGN_SYSTEM.md | All color constants | ⬜ |
| 0.9 | Create `app_typography.dart` from DESIGN_SYSTEM.md | All text styles | ⬜ |
| 0.10 | Create `app_spacing.dart` and `app_radius.dart` | Spacing + radius constants | ⬜ |
| 0.11 | Create `app_theme.dart` with dark ThemeData | Wire up colors + typography | ⬜ |
| 0.12 | Create `app_strings.dart` with all hardcoded strings | No strings in widget files | ⬜ |
| 0.13 | Set up `main.dart` with ProviderScope + MaterialApp | GoRouter + theme | ⬜ |
| 0.14 | Configure `AndroidManifest.xml` | All permissions from TRD section 12 | ⬜ |
| 0.15 | Create `app_config.dart` with feature flags | `kYouTubeEnabled` flag | ⬜ |
| 0.16 | Create `api_constants.dart` | URLs, timeouts, product IDs | ⬜ |

---

## Phase 1 — Data Layer

| # | Task | Notes | Status |
|---|------|-------|--------|
| 1.1 | Create `DownloadStatus` enum | 5 values from DATA_MODELS.md | ⬜ |
| 1.2 | Create `DownloadItem` entity class | Domain layer, all fields | ⬜ |
| 1.3 | Create `QueueItem` entity class | Domain layer | ⬜ |
| 1.4 | Create `AppSettings` entity class | Domain layer + copyWith | ⬜ |
| 1.5 | Create `CobaltResponse` model + fromJson | Data layer | ⬜ |
| 1.6 | Create `PickerItem` model + fromJson | Part of CobaltResponse | ⬜ |
| 1.7 | Create `DownloadItemHive` Hive model | All @HiveField annotations | ⬜ |
| 1.8 | Create `DownloadItemMapper` extensions | Hive ↔ Entity conversions | ⬜ |
| 1.9 | Run `build_runner` to generate Hive adapters | `dart run build_runner build` | ⬜ |
| 1.10 | Create `hive_service.dart` — init and open boxes | Run on app start | ⬜ |
| 1.11 | Create `download_dao.dart` — CRUD operations | save, getAll, delete, checkUrl | ⬜ |
| 1.12 | Create `DownloadRepository` abstract interface | Domain layer | ⬜ |
| 1.13 | Create `DownloadRepositoryImpl` | Implements abstract interface | ⬜ |

---

## Phase 2 — API Layer

| # | Task | Notes | Status |
|---|------|-------|--------|
| 2.1 | Create Dio instance with base options | Timeout + base URL from constants | ⬜ |
| 2.2 | Create `cobalt_api_service.dart` | POST request + response parsing | ⬜ |
| 2.3 | Handle all 4 Cobalt response statuses | stream, redirect, picker, error | ⬜ |
| 2.4 | Add Dio interceptor for logging (debug only) | Print request + response | ⬜ |
| 2.5 | Create `connectivity_utils.dart` | Check internet before API call | ⬜ |
| 2.6 | Create `app_exceptions.dart` | Custom exception classes | ⬜ |
| 2.7 | Write `url_validator.dart` with regex | Validate URL format locally | ⬜ |
| 2.8 | Write `platform_detector.dart` | Detect platform from URL domain | ⬜ |
| 2.9 | Test Cobalt API with 3 real URLs (Instagram, TikTok, Twitter) | Verify responses manually | ⬜ |

---

## Phase 3 — Download Engine

| # | Task | Notes | Status |
|---|------|-------|--------|
| 3.1 | Create `file_utils.dart` — build file save path + name | Follow naming convention in TRD | ⬜ |
| 3.2 | Implement Dio file download with progress stream | `onReceiveProgress` callback | ⬜ |
| 3.3 | Implement `start_download.dart` use case | Full 12-step flow from TRD 4.1 | ⬜ |
| 3.4 | Implement `check_duplicate.dart` use case | Query Hive by URL | ⬜ |
| 3.5 | Implement `get_history.dart` use case | Return all items, sorted by date | ⬜ |
| 3.6 | Implement `delete_history_item.dart` use case | Option: record only / file + record | ⬜ |
| 3.7 | Implement download queue logic (Dart Queue) | Max 2 concurrent | ⬜ |
| 3.8 | Implement `video_thumbnail` generation after download | Save thumbnail path to Hive | ⬜ |
| 3.9 | Implement permission request flow (storage + notifications) | `permission_handler` | ⬜ |
| 3.10 | Implement file download error handling (retry, corrupt check) | From TRD section 4 | ⬜ |

---

## Phase 4 — State Management

| # | Task | Notes | Status |
|---|------|-------|--------|
| 4.1 | Create `DownloadState` class + `DownloadPhase` enum | All fields + copyWith | ⬜ |
| 4.2 | Create `DownloadNotifier` (StateNotifier) | Manages download state machine | ⬜ |
| 4.3 | Create `downloadProvider` | Expose DownloadNotifier | ⬜ |
| 4.4 | Create `QueueNotifier` + `downloadQueueProvider` | Queue state management | ⬜ |
| 4.5 | Create `historyProvider` (FutureProvider) | Load all DownloadItems from Hive | ⬜ |
| 4.6 | Create `SettingsNotifier` + `settingsProvider