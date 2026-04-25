import 'package:flutter_test/flutter_test.dart';
import 'package:link_downloading/core/utils/url_validator.dart';
import 'package:link_downloading/core/utils/platform_detector.dart';
import 'package:link_downloading/core/utils/file_utils.dart';

void main() {
  group('UrlValidator', () {
    test('validates correct URLs', () {
      expect(UrlValidator.isValidUrl('https://instagram.com/reel/123'), true);
      expect(UrlValidator.isValidUrl('https://www.tiktok.com/@user/video/123'), true);
      expect(UrlValidator.isValidUrl('https://x.com/user/status/123'), true);
    });

    test('rejects invalid URLs', () {
      expect(UrlValidator.isValidUrl(''), false);
      expect(UrlValidator.isValidUrl('not a url'), false);
      expect(UrlValidator.isValidUrl('ftp://invalid.com'), false);
    });
  });

  group('PlatformDetector', () {
    test('detects Instagram', () {
      expect(PlatformDetector.detect('https://www.instagram.com/reel/123'), 'instagram');
    });

    test('detects TikTok', () {
      expect(PlatformDetector.detect('https://www.tiktok.com/@user/video/123'), 'tiktok');
      expect(PlatformDetector.detect('https://vm.tiktok.com/abc'), 'tiktok');
    });

    test('detects Twitter/X', () {
      expect(PlatformDetector.detect('https://twitter.com/user/status/123'), 'twitter');
      expect(PlatformDetector.detect('https://x.com/user/status/123'), 'twitter');
    });

    test('returns unknown for unsupported URLs', () {
      expect(PlatformDetector.detect('https://example.com/video'), 'unknown');
    });
  });

  group('FileUtils', () {
    test('formats file sizes correctly', () {
      expect(FileUtils.formatFileSize(0), '0 B');
      expect(FileUtils.formatFileSize(1024), '1.0 KB');
      expect(FileUtils.formatFileSize(1048576), '1.0 MB');
      expect(FileUtils.formatFileSize(1073741824), '1.0 GB');
    });

    test('builds file names correctly', () {
      final name = FileUtils.buildFileName(platform: 'instagram', quality: '1080');
      expect(name, contains('instagram_'));
      expect(name, endsWith('_1080p.mp4'));
    });

    test('builds audio file names', () {
      final name = FileUtils.buildFileName(platform: 'tiktok', quality: '720', isAudioOnly: true);
      expect(name, endsWith('.mp3'));
    });
  });
}
