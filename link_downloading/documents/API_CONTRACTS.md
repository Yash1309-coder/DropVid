# API_CONTRACTS.md
## App: DropVid
**Version:** 1.0

---

## 1. Cobalt API

### 1.1 Overview
| Property | Value |
|----------|-------|
| Base URL | `https://api.cobalt.tools/api/json` |
| Method | POST |
| Auth | None required for basic use |
| Rate limit | ~10 requests/minute per IP (approximate) |
| Timeout | 10 seconds |

---

### 1.2 Request — Fetch Download URL

**Endpoint:** `POST https://api.cobalt.tools/api/json`

**Headers:**
Content-Type: application/json
Accept: application/json

text

**Request Body:**
```json
{
  "url": "string",              // Required. The social media URL to download
  "vQuality": "string",         // Required. "360" | "480" | "720" | "1080" | "max"
  "filenamePattern": "string",  // Optional. "basic" | "pretty" | "nerdy" | "classic"
  "isAudioOnly": boolean,       // Optional. true = download audio only (MP3)
  "isNoTTWatermark": boolean,   // Optional. true = remove TikTok watermark
  "isTTFullAudio": boolean,     // Optional. TikTok: include original audio
  "isAudioMuted": boolean,      // Optional. Mute audio in video
  "dubLang": boolean            // Optional. Prefer dubbed language
}
Default Request (app sends):

json
{
  "url": "<user pasted URL>",
  "vQuality": "<from settings: 360|480|720|1080|max>",
  "filenamePattern": "basic",
  "isAudioOnly": false,
  "isNoTTWatermark": true
}
1.3 Response — Status: stream (Success)
HTTP Status: 200

json
{
  "status": "stream",
  "url": "string"   // Direct URL to download the video file
}
App action: Begin file download via Dio using the returned url.

1.4 Response — Status: redirect
HTTP Status: 200

json
{
  "status": "redirect",
  "url": "string"   // URL to follow for the actual file
}
App action: Follow the redirect URL to start download.

1.5 Response — Status: picker (Multiple Media Items)
HTTP Status: 200

json
{
  "status": "picker",
  "audio": "string",      // Optional. Background audio URL
  "picker": [
    {
      "type": "photo | video",
      "url": "string",    // URL for this media item
      "thumb": "string"   // Optional. Thumbnail URL
    }
  ]
}
App action: Show PickerSheet bottom sheet with all items. User selects one to download.

1.6 Response — Status: error
HTTP Status: 200 (Cobalt returns 200 even for errors)

json
{
  "status": "error",
  "text": "string"   // Error message from Cobalt
}
Common error texts and app responses:

Cobalt text	App Response
"link is invalid"	Snackbar: "Invalid link. Please check the URL."
"this service is not supported"	Snackbar: "This platform isn't supported yet."
"couldn't get video info"	Snackbar: "Couldn't fetch video. Try again."
"rate limit reached"	Snackbar: "Too many requests. Please wait a moment."
Any other	Snackbar: "Something went wrong. Please retry."
1.7 Network / Client-Side Errors
Scenario	Detection	App Response
No internet	connectivity_plus check before request	Snackbar: "No internet connection."
Request timeout (>10s)	Dio connectTimeout / receiveTimeout	Snackbar: "Request timed out. Retry?"
HTTP 429	Dio response code check	Snackbar: "Too many requests. Try again in a moment."
HTTP 500+	Dio response code check	Snackbar: "Server error. Please try again later."
SSL error	DioException type check	Snackbar: "Connection error. Please try again."
2. File Download (Dio)
2.1 Overview
After receiving the download URL from Cobalt, the app downloads the file directly via Dio.

Property	Value
Method	GET
Source	URL from Cobalt API response
Destination	/storage/emulated/0/Downloads/DropVid/{filename}
Progress	Stream via Dio onReceiveProgress
2.2 Dio Download Request
dart
await dio.download(
  downloadUrl,                    // From Cobalt response
  savePath,                       // Local file path
  onReceiveProgress: (received, total) {
    if (total != -1) {
      double progress = received / total;
      // Update progress state
    }
  },
  options: Options(
    responseType: ResponseType.bytes,
    followRedirects: true,
    receiveTimeout: const Duration(minutes: 10),
    headers: {
      'User-Agent': 'Mozilla/5.0',
    },
  ),
);
2.3 Download Error Handling
Error	Detection	Recovery
Network drops mid-download	DioException	Auto-retry once, then show Retry snackbar
Insufficient storage	FileSystemException	Snackbar: "Not enough storage space."
File write permission denied	FileSystemException	Navigate to permission flow
Corrupted file (0 bytes)	File size check after download	Delete file, show Retry option
3. Google AdMob
3.1 Ad Unit IDs
Ad Type	Environment	Ad Unit ID
Banner	Test	ca-app-pub-3940256099942544/6300978111
Banner	Production	<your production ID from AdMob console>
Interstitial	Test	ca-app-pub-3940256099942544/1033173712
Interstitial	Production	<your production ID from AdMob console>
Use test IDs during development. Replace with production IDs before Play Store submission.

3.2 Banner Ad Load Request
dart
BannerAd(
  adUnitId: AppConfig.bannerAdUnitId,
  size: AdSize.banner,
  request: const AdRequest(),
  listener: BannerAdListener(
    onAdLoaded: (_) => // Show ad widget,
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      // Hide ad container, do not show error to user
    },
  ),
)..load();
3.3 Interstitial Ad Load & Show
dart
// Load (do this before needed):
InterstitialAd.load(
  adUnitId: AppConfig.interstitialAdUnitId,
  request: const AdRequest(),
  adLoadCallback: InterstitialAdLoadCallback(
    onAdLoaded: (ad) => _interstitialAd = ad,
    onAdFailedToLoad: (error) => _interstitialAd = null,
  ),
);

// Show (after every 3rd download complete):
if (_interstitialAd != null && !adsRemoved) {
  _interstitialAd!.show();
  _interstitialAd = null;
  // Pre-load next one immediately
}
4. Google Play Billing (IAP)
4.1 Product Details
Property	Value
Product ID	remove_ads_lifetime
Type	One-time (non-consumable)
Plugin	in_app_purchase: ^3.1.0
4.2 Query Product
dart
const Set<String> kIds = {'remove_ads_lifetime'};
final ProductDetailsResponse response =
    await InAppPurchase.instance.queryProductDetails(kIds);

if (response.notFoundIDs.isNotEmpty) {
  // Product not found in Play Console — check product ID
}

ProductDetails product = response.productDetails.first;
// Use product.price to display to user
4.3 Initiate Purchase
dart
final PurchaseParam purchaseParam = PurchaseParam(
  productDetails: product,
);
InAppPurchase.instance.buyNonConsumable(
  purchaseParam: purchaseParam,
);
4.4 Purchase Stream Listener
dart
// Listen in main.dart or top-level provider:
InAppPurchase.instance.purchaseStream.listen((purchases) {
  for (final purchase in purchases) {
    if (purchase.productID == 'remove_ads_lifetime') {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Verify and deliver
        InAppPurchase.instance.completePurchase(purchase);
        prefs.setBool('ads_removed', true);
        // Update adsRemovedProvider
      }
      if (purchase.status == PurchaseStatus.error) {
        // Show error snackbar
      }
    }
  }
});
4.5 Restore Purchase
dart
await InAppPurchase.instance.restorePurchases();
// Restored purchases come through the purchaseStream
// Same listener above handles them (status == PurchaseStatus.restored)
5. API Configuration Constants
dart
// lib/core/constants/api_constants.dart

class ApiConstants {
  // Cobalt
  static const String cobaltBaseUrl     = 'https://api.cobalt.tools/api/json';
  static const int    connectTimeoutSec = 10;
  static const int    receiveTimeoutMin = 10;

  // AdMob
  static const String bannerAdUnitId = String.fromEnvironment(
    'BANNER_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111', // test
  );
  static const String interstitialAdUnitId = String.fromEnvironment(
    'INTERSTITIAL_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712', // test
  );

  // IAP
  static const String removeAdsProductId = 'remove_ads_lifetime';
}