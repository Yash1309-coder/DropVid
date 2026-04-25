```markdown
# APP_FLOW.md
## App: DropVid
**Version:** 1.0

---

## 1. Screen Inventory

| Screen ID | Screen Name | File Path |
|-----------|-------------|-----------|
| S-01 | Splash Screen | `screens/splash/splash_screen.dart` |
| S-02 | Onboarding Screen | `screens/onboarding/onboarding_screen.dart` |
| S-03 | Home Screen | `screens/home/home_screen.dart` |
| S-04 | History Screen | `screens/history/history_screen.dart` |
| S-05 | Settings Screen | `screens/settings/settings_screen.dart` |
| S-06 | Remove Ads Screen | `screens/paywall/remove_ads_screen.dart` |
| S-07 | Download Progress (overlay) | `screens/home/widgets/progress_card.dart` |
| S-08 | Download Complete (bottom sheet) | `screens/home/widgets/download_complete_sheet.dart` |
| S-09 | Picker Sheet (bottom sheet) | `widgets/picker_sheet.dart` |

---

## 2. App Entry Flow

### 2.1 First Launch
App opens
→ S-01 Splash Screen (2 seconds)
→ Check: onboarding_complete == false
→ S-02 Onboarding Screen
→ User taps "Get Started" or "Skip"
→ S-03 Home Screen (default tab)

text

### 2.2 Returning User
App opens
→ S-01 Splash Screen (2 seconds)
→ Check: onboarding_complete == true
→ S-03 Home Screen (default tab)

text

### 2.3 Deep Link — Notification Tap (Download Complete)
User taps download complete notification
→ App opens / comes to foreground
→ Navigate directly to downloaded video file (open with system player)

text

---

## 3. Bottom Navigation Flow
Bottom Nav Bar (always visible on S-03, S-04, S-05)

Tab 0: History → S-04 History Screen
Tab 1: Home → S-03 Home Screen ← default
Tab 2: Settings → S-05 Settings Screen

Rules:

Switching tabs does NOT reset their scroll position
Back button on any tab goes to Home tab (not exits app)
Back button on Home tab shows "Exit app?" dialog
text

---

## 4. Home Screen Flow (Core)

### 4.1 Happy Path
S-03 Home Screen
→ User pastes URL into input field
→ Tap "Download" button
→ [Local] URL format validated
→ [Local] Duplicate URL check
→ No duplicate:
→ POST to Cobalt API
→ Response: "stream"
→ Dio starts file download
→ S-07 Progress Card appears on Home
→ Download completes
→ S-08 Download Complete Sheet appears
→ Tap "Open" → System video player opens
→ Tap "Share" → System share sheet opens
→ Tap "History" → Navigate to S-04

text

### 4.2 Duplicate URL Detected
Tap "Download"
→ Duplicate found in DB
→ Show dialog: "Already Downloaded. Download again?"
→ Tap "Cancel" → Dismiss dialog, stay on Home
→ Tap "Download Again" → Proceed with download (same as happy path)

text

### 4.3 Cobalt Returns Picker (Multiple Videos)
POST to Cobalt API
→ Response: "picker"
→ S-09 Picker Sheet slides up
→ User taps one video
→ Download starts for selected video
→ S-07 Progress Card appears

text

### 4.4 Invalid URL
Tap "Download"
→ URL regex fails
→ Input field border turns red
→ Error text below field: "That doesn't look like a valid link"
→ No API call made

text

### 4.5 Download Failure
Download fails (network drop / API error / timeout)
→ S-07 Progress Card shows error state
→ Snackbar: "Download failed. Retry?"
→ Tap "Retry" → Retry same download (max 2 auto-retries)
→ Auto-dismiss after 5s → Failure recorded in history

text

### 4.6 Multiple Downloads (Queue)
While S-07 Progress Card is showing:
→ User pastes new URL and taps Download
→ Second download added to queue
→ Queue Indicator shows: "1 video in queue"
→ When active download completes:
→ Next in queue starts automatically
→ Progress Card updates for new download

text

---

## 5. History Screen Flow
S-04 History Screen
→ Shows list of all DownloadItems

→ Tap item (status: completed)
→ System video player opens file

→ Tap item (status: failed)
→ Snackbar: "This download failed. Retry?"

→ Long press item
→ Bottom sheet with options:
[Share] → System share sheet
[Re-download] → Adds to download queue on Home
[Delete] → Dialog: "Delete record only / File + Record"

→ Swipe left on item
→ Delete confirmation dialog appears

→ Search bar (top)
→ Filters list in real-time by filename or platform

→ Empty list
→ S-EmptyHistory empty state shown

text

---

## 6. Settings Screen Flow
S-05 Settings Screen
→ Tap "Video Quality"
→ Bottom sheet with options: 360p / 480p / 720p / 1080p / Best Available
→ Selection saved to SharedPreferences immediately

→ Toggle "Audio Only"
→ Saved to SharedPreferences immediately

→ Tap "Download Folder"
→ System folder picker opens
→ Selected path saved to SharedPreferences

→ Tap "Clear Cache"
→ Dialog: "Clear temporary files? This won't delete your videos."
→ Tap "Clear" → Deletes /cache/dropvid/ folder

→ Tap "Remove Ads"
→ Navigate to S-06 Remove Ads Screen

→ Tap "Privacy Policy"
→ Opens URL in system browser

→ Tap "Terms of Service"
→ Opens URL in system browser

→ Tap app version (hidden: 7 taps)
→ Easter egg / debug info (dev builds only)

text

---

## 7. Remove Ads Screen Flow
S-06 Remove Ads Screen
→ Shows price fetched from Google Play

→ Tap "Remove Ads for $X.XX"
→ Google Play Billing sheet appears (system UI)
→ Purchase successful
→ ads_removed = true saved to SharedPreferences
→ All ad widgets hidden immediately
→ Snackbar: "Ads removed! Thank you ❤️"
→ Navigate back to Settings

text
    → Purchase cancelled / failed
        → Stay on Remove Ads screen
        → Snackbar: "Purchase cancelled"
→ Tap "Restore Purchase"
→ Queries Play Store for existing purchase
→ Found → ads_removed = true, same as success above
→ Not found → Snackbar: "No previous purchase found"

Back button → Return to Settings

text

---

## 8. Back Button Behavior

| Screen | Back Button Action |
|--------|-------------------|
| S-01 Splash | No back (disabled) |
| S-02 Onboarding | No back (disabled) |
| S-03 Home | "Exit app?" dialog |
| S-04 History | Switch to Home tab |
| S-05 Settings | Switch to Home tab |
| S-06 Remove Ads | Pop back to Settings |
| S-08 Complete Sheet | Dismiss sheet |
| S-09 Picker Sheet | Dismiss sheet |

---

## 9. Permission Flow

### 9.1 Storage Permission
User taps "Download" for the first time
→ Check storage permission status
→ Granted → Proceed with download
→ Not requested → Show system permission dialog
→ Granted → Proceed with download
→ Denied → Show AppDialog: explain why it's needed
→ Tap "Open Settings" → Android app settings
→ Tap "Not Now" → Show snackbar: "Permission required to save videos"
→ Permanently denied → Show AppDialog with "Open Settings" button

text

### 9.2 Notification Permission (Android 13+)
User starts first download
→ Check notification permission
→ Not granted → Show system permission dialog (one time)
→ Denied → Download continues, just no notification shown

text

---

## 10. GoRouter Route Definitions

```dart
// File: lib/presentation/navigation/app_router.dart

Routes:
  /splash          → SplashScreen
  /onboarding      → OnboardingScreen
  /                → MainShell (bottom nav wrapper)
    /home          → HomeScreen        (index 1 — default)
    /history       → HistoryScreen     (index 0)
    /settings      → SettingsScreen    (index 2)
  /remove-ads      → RemoveAdsScreen

Deep links:
  dropvid://home          → HomeScreen
  dropvid://history       → HistoryScreen