# PRD — Product Requirements Document
## App Name: DropVid
**Version:** 1.0 | **Platform:** Android | **Distribution:** Google Play Store + Direct APK

---

## 1. Product Overview

### 1.1 Product Vision
DropVid is a free Android application that allows users to download videos from any major social media platform by simply pasting a link. It is designed to be fast, clean, and reliable — solving the core pain points found in existing competitors like BlackHole.

### 1.2 Problem Statement
Existing video downloader apps on the Play Store suffer from:
- Ads interrupting or blocking the download flow
- Same video downloading multiple times
- App consuming excessive internal storage
- Poor feedback during download (no progress, no errors)
- Confusing UI with too many steps

### 1.3 Product Goals

| Goal | Description |
|------|-------------|
| Simplicity | Paste a link, tap download — done |
| Reliability | Downloads complete without interruption |
| Storage-friendly | Videos go to public gallery, not app storage |
| Monetization | Sustainable via ads + one-time IAP |
| Play Store safe | Fully compliant, no YouTube on Play Store version |

### 1.4 Target Audience
- Age 16–35
- Heavy social media users
- Users who want to save videos for offline viewing
- Users in regions with limited internet — download once, watch forever

---

## 2. Scope

### 2.1 In Scope — Version 1.0
- Link-based video downloading
- Supported platforms: Instagram, TikTok, Facebook, Twitter/X, Reddit, Pinterest, Snapchat, Vimeo, Dailymotion
- Global quality setting
- Download history
- AdMob banner + interstitial ads
- One-time IAP to remove ads
- Background downloading with notifications
- Duplicate URL detection
- Download queue (multiple links)
- Retry on failure

### 2.2 Out of Scope — Version 1.0
- YouTube support *(Play Store version only — will be in APK version)*
- WhatsApp status saver *(planned for v1.1)*
- Video editing or trimming
- Cloud backup of downloaded videos
- iOS version
- User accounts or login

---

## 3. Features & Requirements

### 3.1 Feature 1 — Home Screen (Core Download Flow)

**Description:**
The main screen of the app. Users paste a video link and tap download. No extra steps.

**User Stories:**
- As a user, I want to paste a link and download the video in as few taps as possible
- As a user, I want to see clear progress so I know the download is working
- As a user, I want to be warned if I already downloaded the same video

**Functional Requirements:**

| ID | Requirement |
|----|-------------|
| FR-001 | App shall provide a text input field to paste a URL |
| FR-002 | App shall have a clearly visible "Download" button |
| FR-003 | On tapping Download, app shall validate the URL format |
| FR-004 | App shall check download history for duplicate URLs before starting |
| FR-005 | If duplicate found, app shall show a dialog: *"Already downloaded. Download again?"* |
| FR-006 | Download button shall be disabled and show a spinner once tapped |
| FR-007 | App shall show a progress bar with percentage during download |
| FR-008 | App shall show estimated time remaining during download |
| FR-009 | On download complete, app shall show a bottom sheet with Open, Share, Go to History options |
| FR-010 | On download failure, app shall show a snackbar with a Retry button |
| FR-011 | User shall be able to paste another link while a download is in progress (queue) |
| FR-012 | App shall display a queue indicator showing how many downloads are pending |

**Non-Functional Requirements:**
- Download initiation response time < 2 seconds after tapping button
- URL validation must happen locally, before any API call

---

### 3.2 Feature 2 — Download History Screen

**Description:**
A log of all completed, failed, and in-progress downloads.

**User Stories:**
- As a user, I want to see all my past downloads in one place
- As a user, I want to re-download or share a previously downloaded video
- As a user, I want to delete videos I no longer need

**Functional Requirements:**

| ID | Requirement |
|----|-------------|
| FR-013 | App shall maintain a persistent local list of all download attempts |
| FR-014 | Each history item shall show: thumbnail, platform icon, file name, file size, download date, status |
| FR-015 | Status shall be one of: Completed, Failed, In Progress |
| FR-016 | User shall be able to tap a completed item to open/play the video |
| FR-017 | User shall be able to long-press an item to get options: Share, Delete, Re-download |
| FR-018 | User shall be able to swipe-to-delete a history item |
| FR-019 | Deleting a history item shall ask: *"Delete record only or delete video file too?"* |
| FR-020 | App shall show an empty state illustration when history is empty |
| FR-021 | History shall be searchable by file name or platform |

---

### 3.3 Feature 3 — Settings Screen

**Description:**
Global preferences that affect all downloads.

**Functional Requirements:**

| ID | Requirement |
|----|-------------|
| FR-022 | App shall allow user to set global video quality: 360p, 480p, 720p, 1080p, Best Available |
| FR-023 | If selected quality is unavailable for a video, app shall download the next best available quality |
| FR-024 | App shall allow user to toggle Audio Only mode (downloads MP3 instead of video) |
| FR-025 | App shall show storage usage of downloaded videos |
| FR-026 | App shall provide a "Clear Cache" button (clears temp files only, not downloaded videos) |
| FR-027 | App shall show a "Remove Ads" option that navigates to the paywall |
| FR-028 | App shall show app version, privacy policy link, and terms of service link |
| FR-029 | App shall allow user to choose download folder (default: public Downloads folder) |

---

### 3.4 Feature 4 — Ads & Monetization

**Description:**
Ad-supported free tier with a one-time purchase to go ad-free.

**Functional Requirements:**

| ID | Requirement |
|----|-------------|
| FR-030 | Free users shall see a banner ad at the bottom of Home and History screens |
| FR-031 | An interstitial ad shall show after every 3rd completed download |
| FR-032 | Interstitial ad shall only show after download is complete — never during |
| FR-033 | App shall provide a one-time IAP "Remove Ads" purchase |
| FR-034 | After purchase, all ads shall be permanently removed |
| FR-035 | Purchase status shall persist across app reinstalls (Google Play restore) |
| FR-036 | App shall show a "Remove Ads" prompt (non-intrusive) after 5th download |

---

### 3.5 Feature 5 — Background Download & Notifications

**Description:**
Downloads continue even when the app is minimized.

**Functional Requirements:**

| ID | Requirement |
|----|-------------|
| FR-037 | Downloads shall continue when the app is backgrounded |
| FR-038 | A persistent notification shall show during active downloads with progress percentage |
| FR-039 | A completion notification shall appear when a download finishes |
| FR-040 | Tapping the completion notification shall open the video directly |
| FR-041 | User shall be able to cancel a download from the notification |

---

### 3.6 Feature 6 — Splash Screen & Onboarding

**Functional Requirements:**

| ID | Requirement |
|----|-------------|
| FR-042 | App shall show a branded splash screen on launch (max 2 seconds) |
| FR-043 | On first launch, app shall show a 3-step onboarding: How to use / Supported platforms / Ad-free option |
| FR-044 | Onboarding shall be skippable |
| FR-045 | App shall request storage permission on first download attempt, not on launch |

---

## 4. User Flows

### 4.1 Happy Path — Download a Video

Open App → Home Screen → Paste Link → Tap Download
→ Progress shown → Download Complete Bottom Sheet
→ Tap "Open" → Video plays


### 4.2 Duplicate Link Flow
Paste Link → Tap Download → Duplicate detected
→ Dialog shown → User taps "Download Again" → Proceeds normally

text

### 4.3 Failed Download Flow
Paste Link → Tap Download → API fails
→ Snackbar: "Download failed. Retry?" → Tap Retry → Retries once

text

### 4.4 Remove Ads Flow
Settings → Remove Ads → Paywall Screen
→ Tap "Remove Ads for $X" → Google Play Billing → Success → Ads gone

text

---

## 5. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| Performance | App launch time < 2 seconds on mid-range device |
| Performance | Download start (API response) < 3 seconds |
| Reliability | App shall not crash if network drops mid-download |
| Storage | Downloaded files saved to public /Downloads or /Movies folder |
| Compatibility | Support Android 8.0 (API 26) and above |
| Offline | App shall work offline for History browsing |
| Accessibility | All buttons shall have content descriptions for screen readers |
| Privacy | No user data collected beyond what AdMob requires |

---

## 6. Platform & Legal Compliance

| Item | Detail |
|------|--------|
| YouTube | NOT supported in Play Store version |
| Copyright disclaimer | App shall display: *"Only download content you own or have rights to"* |
| Affiliate disclaimer | *"Not affiliated with Instagram, TikTok, or any other platform"* |
| Privacy Policy | Required for AdMob — must be hosted on a website |
| Terms of Service | Must state acceptable use |
| Play Store metadata | App description must avoid phrases like "YouTube downloader" |
