/// Downlo Supported Platforms
/// Defines which social media platforms are supported for download
class SupportedPlatforms {
  SupportedPlatforms._();

  static const List<String> all = [
    'instagram',
    'tiktok',
    'twitter',
    'facebook',
    'reddit',
    'pinterest',
    'snapchat',
    'vimeo',
    'dailymotion',
  ];

  /// Domain-to-platform mapping for URL detection
  static const Map<String, String> domainMap = {
    'instagram.com': 'instagram',
    'www.instagram.com': 'instagram',
    'tiktok.com': 'tiktok',
    'www.tiktok.com': 'tiktok',
    'vm.tiktok.com': 'tiktok',
    'twitter.com': 'twitter',
    'www.twitter.com': 'twitter',
    'x.com': 'twitter',
    'www.x.com': 'twitter',
    'facebook.com': 'facebook',
    'www.facebook.com': 'facebook',
    'fb.watch': 'facebook',
    'm.facebook.com': 'facebook',
    'reddit.com': 'reddit',
    'www.reddit.com': 'reddit',
    'old.reddit.com': 'reddit',
    'pinterest.com': 'pinterest',
    'www.pinterest.com': 'pinterest',
    'pin.it': 'pinterest',
    'snapchat.com': 'snapchat',
    'www.snapchat.com': 'snapchat',
    'story.snapchat.com': 'snapchat',
    'vimeo.com': 'vimeo',
    'www.vimeo.com': 'vimeo',
    'dailymotion.com': 'dailymotion',
    'www.dailymotion.com': 'dailymotion',
    'dai.ly': 'dailymotion',
  };

  /// YouTube domains — only usable when kYouTubeEnabled is true
  static const Map<String, String> youtubeDomains = {
    'youtube.com': 'youtube',
    'www.youtube.com': 'youtube',
    'm.youtube.com': 'youtube',
    'youtu.be': 'youtube',
    'music.youtube.com': 'youtube',
  };
}
