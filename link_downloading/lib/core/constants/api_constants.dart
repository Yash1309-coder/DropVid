/// Downlo API Configuration Constants
/// Cobalt API, AdMob, and IAP product IDs
class ApiConstants {
  ApiConstants._();

  // ─── Cobalt API ────────────────────────────────────
  // v7 instance (no auth required) + v11 fallbacks
  static const List<Map<String, String>> cobaltInstances = [
    // v7 — no auth, uses /api/json
    {'url': 'https://downloadapi.stuff.solutions', 'endpoint': '/api/json', 'version': '7'},
  ];
  static const int connectTimeoutSec = 60;
  static const int receiveTimeoutMin = 10;

  // ─── AdMob ─────────────────────────────────────────
  static const String bannerAdUnitId = String.fromEnvironment(
    'BANNER_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111', // test ID
  );
  static const String interstitialAdUnitId = String.fromEnvironment(
    'INTERSTITIAL_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712', // test ID
  );

  // ─── IAP ───────────────────────────────────────────
  static const String removeAdsProductId = 'remove_ads_lifetime';

  // ─── Notification Channel ──────────────────────────
  static const String notificationChannelId = 'downlo_downloads';
  static const String notificationChannelName = 'Downloads';

  // ─── yt-dlp Backend ─────────────────────────────────
  /// Self-hosted backend for YouTube downloads (quality selection, audio extraction).
  /// Override via --dart-define=YTDLP_BACKEND_URL=https://your-server.com
  static const String ytdlpBackendUrl = String.fromEnvironment(
    'YTDLP_BACKEND_URL',
    defaultValue: 'http://172.16.189.98:8000', // Local network IP — works on physical devices
  );

  // ─── Supabase ──────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dxwxrfzsqfqrgagmtpkr.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '', // Set via --dart-define or .env
  );
}
