``markdown
# COMPONENT_LIBRARY.md
## App: DropVid
**Version:** 1.0

---

## 1. Buttons

### 1.1 Primary Button (Gradient)
**Used for:** Main CTA — Download button

```dart
// Widget: PrimaryButton
// File: lib/presentation/widgets/buttons/primary_button.dart

Properties:
  String label          // Button text
  VoidCallback? onTap   // null = disabled state
  bool isLoading        // Shows spinner, disables tap
  double? width         // Default: full width

Visual:
  Background:   LinearGradient (primary → accent)
  Height:       56px
  Border radius: 28px (full pill)
  Text style:   labelLarge, white
  Shadow:       buttonShadow
  Loading:      CircularProgressIndicator (white, size 20px) replaces text
  Disabled:     Opacity 0.4, no shadow

Example usage:
  PrimaryButton(
    label: 'Download',
    onTap: isLoading ? null : () => _startDownload(),
    isLoading: isLoading,
  )
1.2 Secondary Button (Outlined)
Used for: Cancel, Skip, secondary actions

dart
// Widget: SecondaryButton
// File: lib/presentation/widgets/buttons/secondary_button.dart

Properties:
  String label
  VoidCallback? onTap
  Color? borderColor     // Default: AppColors.grey600

Visual:
  Background:   Transparent
  Border:       1.5px solid grey600
  Height:       56px
  Border radius: 28px
  Text style:   labelLarge, grey200
1.3 Ghost Button (Text only)
Used for: "Skip", "Cancel", "View History"

dart
// Widget: GhostButton
// File: lib/presentation/widgets/buttons/ghost_button.dart

Properties:
  String label
  VoidCallback? onTap
  Color? textColor       // Default: AppColors.primary

Visual:
  Background:   Transparent
  No border
  Text style:   labelMedium, primary color
  Underline:    none
1.4 Icon Button
Used for: Toolbar actions, clear input

dart
// Widget: AppIconButton
// File: lib/presentation/widgets/buttons/app_icon_button.dart

Properties:
  IconData icon
  VoidCallback? onTap
  Color? iconColor       // Default: grey200
  double size            // Default: 24px
  Color? backgroundColor // Default: transparent

Visual:
  Hit area: 44x44px minimum
  Background: grey800 (when backgroundColor provided)
  Border radius: full
2. Input Fields
2.1 URL Input Field
Used for: Paste link on Home screen

dart
// Widget: UrlInputField
// File: lib/presentation/screens/home/widgets/url_input_field.dart

Properties:
  TextEditingController controller
  VoidCallback onClear
  bool isError
  String? errorText

Visual:
  Background:   grey700
  Border:       1px solid grey600 (default)
                1px solid primary (focused)
                1px solid error (error state)
  Border radius: 12px
  Height:       56px
  Padding:      horizontal 16px
  Prefix icon:  link icon, grey400, 20px
  Suffix icon:  X (clear) icon, grey400, 20px — only visible when text exists
  Placeholder:  "Paste video link here..." — bodyMedium, grey400
  Text style:   bodyLarge, white
  Cursor color: primary
3. Cards
3.1 Download History Card
Used for: Each item in History screen

dart
// Widget: HistoryItemCard
// File: lib/presentation/screens/history/widgets/history_item_card.dart

Properties:
  DownloadItem item
  VoidCallback onTap
  VoidCallback onLongPress

Visual:
  Background:   grey800
  Border radius: 16px
  Padding:      12px
  Shadow:       cardShadow
  Height:       80px

Layout (left to right):
  [Thumbnail 64x64px rounded-12] [16px gap] [
    [Platform badge + filename - labelMedium white]
    [4px gap]
    [File size · Date - bodySmall grey400]
    [8px gap]
    [Status chip]
  ]

Thumbnail:
  Size: 64x64px
  Border radius: 12px
  Fallback: grey700 background + platform icon centered

Status Chip:
  Completed → background: success/10%, text: success, "Completed"
  Failed    → background: error/10%,   text: error,   "Failed"
  Progress  → background: primary/10%, text: primary,  "X%"
3.2 Download Progress Card
Used for: Active download on Home screen

dart
// Widget: ProgressCard
// File: lib/presentation/screens/home/widgets/progress_card.dart

Properties:
  String fileName
  String platform
  double progress        // 0.0 to 1.0
  String timeRemaining
  VoidCallback onCancel

Visual:
  Background:   grey800
  Border radius: 16px
  Padding:      16px
  Border:       1px solid primary (animated glow)

Layout:
  Row: [Platform icon 20px] [8px] [fileName - labelMedium]  [cancel icon]
  12px gap
  Progress bar (full width, height 6px, gradient, rounded)
  8px gap
  Row: [X% - bodySmall primary] [spacer] [time remaining - bodySmall grey400]
3.3 Queue Indicator Card
Used for: Showing pending downloads

dart
// Widget: QueueIndicator
// File: lib/presentation/screens/home/widgets/queue_indicator.dart

Properties:
  int queueCount

Visual:
  Background:   grey800
  Border radius: 12px
  Padding:      horizontal 16px, vertical 10px
  Content:      "⏳ X videos in queue" — bodySmall, grey200
4. Bottom Sheets
4.1 Download Complete Sheet
Used for: After download finishes

dart
// Widget: DownloadCompleteSheet
// File: lib/presentation/screens/home/widgets/download_complete_sheet.dart

Properties:
  DownloadItem item
  VoidCallback onOpen
  VoidCallback onShare
  VoidCallback onGoToHistory

Visual:
  Background:     grey800
  Top border radius: 20px
  Padding:        24px
  Drag handle:    grey600, 4x40px, centered at top

Layout (top to bottom):
  Lottie animation (download_complete.json) — 80x80px centered
  16px gap
  "Download Complete!" — headlineSmall, white, centered
  8px gap
  filename — bodyMedium, grey400, centered
  24px gap
  PrimaryButton "Open Video"
  12px gap
  Row: [SecondaryButton "Share"] [12px] [SecondaryButton "History"]
4.2 Picker Sheet (Multiple Media)
Used for: When Cobalt returns multiple items (e.g. Instagram carousel)

dart
// Widget: PickerSheet
// File: lib/presentation/widgets/picker_sheet.dart

Properties:
  List<String> mediaUrls
  Function(String url) onSelect

Visual:
  Background:   grey800
  Top border radius: 20px
  Title:        "Select a video to download" — headlineSmall
  Grid:         2-column grid of video thumbnails
  Each item:    Tap to download, numbered badge overlay
5. Dialogs
5.1 Duplicate Download Dialog
dart
Title:    "Already Downloaded"
Body:     "You've already downloaded this video. Download again?"
Buttons:  [Ghost "Cancel"] [Primary "Download Again"]
5.2 Delete History Dialog
dart
Title:    "Delete Download"
Body:     "What would you like to remove?"
Buttons:  [Ghost "Cancel"] [Secondary "Record Only"] [Primary "File + Record"]
5.3 Permission Denied Dialog
dart
Title:    "Storage Permission Required"
Body:     "DropVid needs storage access to save videos to your device."
Buttons:  [Ghost "Not Now"] [Primary "Open Settings"]
6. Snackbars & Toasts
dart
// Widget: AppSnackbar
// File: lib/presentation/widgets/app_snackbar.dart

Types:
  success → left accent bar color: success
  error   → left accent bar color: error
  info    → left accent bar color: primary
  warning → left accent bar color: warning

Visual:
  Background:   grey800
  Border radius: 12px
  Left border:  3px solid [type color]
  Padding:      16px
  Duration:     3 seconds (error: 5 seconds)
  Position:     Bottom, above ad banner / nav bar

With action (Retry):
  Row: [Icon 20px] [8px] [message - bodyMedium] [spacer] [GhostButton "Retry"]
7. Loading States
7.1 Shimmer Loading (History List)
dart
// Use shimmer package
// Show 5 shimmer cards when history is loading
// Card shape matches HistoryItemCard dimensions
// Colors: grey800 → grey700 shimmer
7.2 Full Screen Loading
dart
// Used during: initial app load only
// Center of screen
// Lottie animation: downloading.json OR CircularProgressIndicator
// Color: primary
7.3 Button Loading
dart
// Inline within button
// CircularProgressIndicator, size 20px, color white, strokeWidth 2
8. Empty States
8.1 Empty History
dart
// Widget: EmptyHistoryView
// File: lib/presentation/screens/history/widgets/empty_history_view.dart

Visual:
  Lottie animation: empty_state.json — 160x160px
  16px gap
  "No downloads yet" — headlineSmall, white, centered
  8px gap
  "Paste a link on the home screen to get started" — bodyMedium, grey400, centered
  24px gap
  PrimaryButton "Go to Home" — width 200px
9. Navigation Bar
dart
// Bottom navigation — 3 tabs
// File: lib/presentation/navigation/app_router.dart

Items:
  0. History  — icon: clock (outlined → filled)
  1. Home     — icon: download (outlined → filled)  ← default selected
  2. Settings — icon: settings (outlined → filled)

Visual:
  Background:    grey800
  Height:        64px + bottom safe area
  Border top:    1px solid grey600
  Active color:  primary
  Inactive color: grey400
  Label style:   caption, 10px
  Indicator:     none (color change only)
10. Ads Placement
10.1 Banner Ad Widget
dart
// Widget: BannerAdWidget
// File: lib/presentation/widgets/ads/banner_ad_widget.dart

// Wraps Google AdMob BannerAd
// Size: AdSize.banner (320x50)
// Placement: pinned to bottom ABOVE the nav bar
// Visible only when !adsRemoved
// Shows grey800 placeholder while ad loads
11. Platform Badge
dart
// Widget: PlatformBadge
// File: lib/presentation/widgets/platform_badge.dart

Properties:
  String platform   // "instagram", "tiktok", etc.

Visual:
  SVG icon for the platform — 16x16px
  Colored per platform color map
  Used in: HistoryItemCard, ProgressCard