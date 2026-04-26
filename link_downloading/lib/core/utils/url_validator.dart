/// Downlo URL Validator
/// Validates URL format locally before making API calls
class UrlValidator {
  UrlValidator._();

  /// Regex pattern for valid URLs
  static final RegExp _urlPattern = RegExp(
    r'^https?:\/\/'
    r'([\w-]+\.)+[\w-]+'
    r'(\/[\w\-.~:/?#\[\]@!$&()*+,;=%]*)?$',
    caseSensitive: false,
  );

  /// Check if a string is a valid URL
  static bool isValidUrl(String url) {
    if (url.trim().isEmpty) return false;
    return _urlPattern.hasMatch(url.trim());
  }

  /// Check if URL is from a supported platform
  static bool isSupportedPlatform(String url) {
    if (!isValidUrl(url)) return false;
    try {
      final uri = Uri.parse(url.trim());
      final host = uri.host.toLowerCase();
      // Check against known domains
      return _supportedDomains.any((domain) => host.contains(domain));
    } catch (_) {
      return false;
    }
  }

  static const List<String> _supportedDomains = [
    'instagram.com',
    'tiktok.com',
    'twitter.com',
    'x.com',
    'facebook.com',
    'fb.watch',
    'reddit.com',
    'pinterest.com',
    'pin.it',
    'snapchat.com',
    'vimeo.com',
    'dailymotion.com',
    'dai.ly',
    'youtube.com',
    'youtu.be',
  ];
}
