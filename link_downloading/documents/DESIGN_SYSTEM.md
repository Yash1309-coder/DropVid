markdown
# DESIGN_SYSTEM.md
## App: DropVid
**Version:** 1.0 | **Platform:** Android | **Framework:** Flutter

---

## 1. Color Palette

### 1.1 Primary Colors
```dart
// app_colors.dart

// Brand
static const Color primary        = Color(0xFF6C63FF); // Purple — main CTA
static const Color primaryLight   = Color(0xFF9D97FF); // Lighter purple
static const Color primaryDark    = Color(0xFF3D35CC); // Darker purple

// Accent
static const Color accent         = Color(0xFF00D4AA); // Teal — success states
static const Color accentLight    = Color(0xFF5FFFD8);
static const Color accentDark     = Color(0xFF00A382);
1.2 Neutral Colors
dart
static const Color black          = Color(0xFF0A0A0F); // True dark background
static const Color grey900        = Color(0xFF12121A); // Screen background
static const Color grey800        = Color(0xFF1C1C28); // Card background
static const Color grey700        = Color(0xFF252535); // Input field background
static const Color grey600        = Color(0xFF3A3A50); // Borders / dividers
static const Color grey400        = Color(0xFF7A7A95); // Placeholder text
static const Color grey200        = Color(0xFFB0B0C8); // Secondary text
static const Color white          = Color(0xFFFFFFFF); // Primary text
1.3 Semantic Colors
dart
static const Color success        = Color(0xFF00D4AA); // Download complete
static const Color error          = Color(0xFFFF4D6A); // Failed download
static const Color warning        = Color(0xFFFFB340); // Duplicate warning
static const Color info           = Color(0xFF4DA6FF); // General info
1.4 Platform Colors (for platform icons/badges)
dart
static const Color instagram      = Color(0xFFE1306C);
static const Color tiktok         = Color(0xFF010101);
static const Color twitter        = Color(0xFF1DA1F2);
static const Color facebook       = Color(0xFF1877F2);
static const Color reddit         = Color(0xFFFF4500);
static const Color pinterest      = Color(0xFFE60023);
static const Color snapchat       = Color(0xFFFFFC00);
static const Color vimeo          = Color(0xFF1AB7EA);
1.5 Gradient
dart
// Used on download button and splash screen
static const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// Used on progress bar
static const LinearGradient progressGradient = LinearGradient(
  colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
2. Typography
2.1 Font Family
text
Primary Font: Inter
Fallback: System default (Roboto on Android)
Add to pubspec.yaml:

yaml
fonts:
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf    weight: 400
      - asset: assets/fonts/Inter-Medium.ttf     weight: 500
      - asset: assets/fonts/Inter-SemiBold.ttf   weight: 600
      - asset: assets/fonts/Inter-Bold.ttf       weight: 700
2.2 Type Scale
dart
// app_typography.dart

// Display
static const TextStyle displayLarge = TextStyle(
  fontFamily: 'Inter',
  fontSize: 32,
  fontWeight: FontWeight.w700,
  color: AppColors.white,
  letterSpacing: -0.5,
);

// Headlines
static const TextStyle headlineLarge = TextStyle(
  fontFamily: 'Inter',
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: AppColors.white,
  letterSpacing: -0.3,
);

static const TextStyle headlineMedium = TextStyle(
  fontFamily: 'Inter',
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: AppColors.white,
);

static const TextStyle headlineSmall = TextStyle(
  fontFamily: 'Inter',
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: AppColors.white,
);

// Body
static const TextStyle bodyLarge = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: AppColors.white,
  height: 1.5,
);

static const TextStyle bodyMedium = TextStyle(
  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: AppColors.grey200,
  height: 1.5,
);

static const TextStyle bodySmall = TextStyle(
  fontFamily: 'Inter',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: AppColors.grey400,
  height: 1.4,
);

// Labels
static const TextStyle labelLarge = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: AppColors.white,
  letterSpacing: 0.2,
);

static const TextStyle labelMedium = TextStyle(
  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: AppColors.white,
);

static const TextStyle labelSmall = TextStyle(
  fontFamily: 'Inter',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: AppColors.grey200,
  letterSpacing: 0.3,
);

// Caption
static const TextStyle caption = TextStyle(
  fontFamily: 'Inter',
  fontSize: 11,
  fontWeight: FontWeight.w400,
  color: AppColors.grey400,
);
3. Spacing System
Base unit: 4px

dart
// app_spacing.dart
static const double xs   =  4.0;   // Tight internal spacing
static const double sm   =  8.0;   // Between icon and label
static const double md   = 12.0;   // Between list items
static const double lg   = 16.0;   // Screen horizontal padding
static const double xl   = 20.0;   // Between sections
static const double xxl  = 24.0;   // Card padding
static const double xxxl = 32.0;   // Between major sections
static const double huge = 48.0;   // Empty state illustration gap
Screen padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)

4. Border Radius
dart
// app_radius.dart
static const double sm    =  8.0;  // Chips, badges
static const double md    = 12.0;  // Input fields
static const double lg    = 16.0;  // Cards
static const double xl    = 20.0;  // Bottom sheets, modals
static const double xxl   = 28.0;  // Download button
static const double full  = 999.0; // Pills, avatar
5. Elevation & Shadows
dart
// app_shadows.dart

// Card shadow
static const BoxShadow cardShadow = BoxShadow(
  color: Color(0x40000000),
  blurRadius: 12,
  offset: Offset(0, 4),
);

// Button shadow
static const BoxShadow buttonShadow = BoxShadow(
  color: Color(0x556C63FF),
  blurRadius: 16,
  offset: Offset(0, 6),
);

// Bottom sheet shadow
static const BoxShadow sheetShadow = BoxShadow(
  color: Color(0x60000000),
  blurRadius: 24,
  offset: Offset(0, -4),
);
6. Iconography
Style: Outlined (default), Filled (active/selected state)
Library: iconsax Flutter package OR Material Symbols
Size scale:
dart
static const double iconXs  = 16.0;
static const double iconSm  = 20.0;
static const double iconMd  = 24.0; // Default
static const double iconLg  = 28.0;
static const double iconXl  = 32.0;
Bottom nav icons: 24px outlined → 24px filled when active
Action icons: 20px outlined always
7. Component States
Every interactive component must handle these states:

State	Visual Treatment
Default	Base design
Pressed	Opacity 0.8 + slight scale down (0.97)
Disabled	Opacity 0.4, no interaction
Loading	Spinner replaces content, same size
Error	Red border / red tint
Success	Green border / green tint
Focus	Primary color border (2px)
8. Animation & Motion
dart
// app_animations.dart

// Durations
static const Duration fast    = Duration(milliseconds: 150);
static const Duration normal  = Duration(milliseconds: 250);
static const Duration slow    = Duration(milliseconds: 400);
static const Duration xslow   = Duration(milliseconds: 600);

// Curves
static const Curve standard   = Curves.easeInOut;
static const Curve enter      = Curves.easeOut;
static const Curve exit       = Curves.easeIn;
static const Curve spring     = Curves.elasticOut;
Rules:

Screen transitions: 250ms easeInOut
Bottom sheet: 300ms easeOut slide up
Button press: 150ms scale
Progress bar: Linear, real-time
Snackbar: 250ms slide up, auto-dismiss 3s
9. Dark Theme (Default — App is Dark Only)
DropVid uses dark mode only. No light mode in v1.0.

dart
// app_theme.dart
static ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.grey900,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: AppColors.grey900,
    surface: AppColors.grey800,
    error: AppColors.error,
    onPrimary: AppColors.white,
    onSecondary: AppColors.black,
    onBackground: AppColors.white,
    onSurface: AppColors.white,
    onError: AppColors.white,
  ),
  fontFamily: 'Inter',
  useMaterial3: true,
);
10. Assets Structure
text
assets/
├── fonts/
│   ├── Inter-Regular.ttf
│   ├── Inter-Medium.ttf
│   ├── Inter-SemiBold.ttf
│   └── Inter-Bold.ttf
├── images/
│   ├── logo.png
│   ├── splash_bg.png
│   └── onboarding/
│       ├── onboard_1.png
│       ├── onboard_2.png
│       └── onboard_3.png
├── animations/
│   ├── download_complete.json   # Lottie
│   ├── downloading.json         # Lottie
│   └── empty_state.json         # Lottie
└── icons/
    ├── ic_instagram.svg
    ├── ic_tiktok.svg
    ├── ic_twitter.svg
    ├── ic_facebook.svg
    ├── ic_reddit.svg
    ├── ic_pinterest.svg
    ├── ic_snapchat.svg
    └── ic_vimeo.svg