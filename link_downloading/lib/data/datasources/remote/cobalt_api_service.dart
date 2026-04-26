import 'package:dio/dio.dart';
import '../../models/cobalt_response.dart';
import '../../../core/constants/api_constants.dart';

/// Cobalt API Service with multi-instance fallback
/// Supports both v7 and v11 API formats
class CobaltApiService {
  /// Resolve a video URL to a direct download link
  Future<CobaltResponse> resolveUrl({
    required String url,
    String quality = '1080',
    bool isAudioOnly = false,
  }) async {
    String lastError = 'All servers are unavailable. Try again later.';

    for (final instance in ApiConstants.cobaltInstances) {
      final baseUrl = instance['url']!;
      final endpoint = instance['endpoint'] ?? '/';
      final version = instance['version'] ?? '11';

      try {
        final dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(seconds: ApiConstants.connectTimeoutSec),
          receiveTimeout: Duration(minutes: ApiConstants.receiveTimeoutMin),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

        // Build request body based on API version
        final Map<String, dynamic> body;
        if (version == '7') {
          body = CobaltRequestV7(
            url: url,
            vQuality: quality,
            isAudioOnly: isAudioOnly,
          ).toJson();
        } else {
          body = CobaltRequestV11(
            url: url,
            videoQuality: quality,
            downloadMode: isAudioOnly ? 'audio' : 'auto',
          ).toJson();
        }

        final response = await dio.post(endpoint, data: body);

        if (response.statusCode == 200 && response.data != null) {
          final parsed = CobaltResponse.fromJson(
            response.data as Map<String, dynamic>,
          );

          // If auth error, try next instance
          if (parsed.isError &&
              (parsed.error?.contains('auth') == true ||
               parsed.error?.contains('jwt') == true)) {
            lastError = parsed.error ?? lastError;
            continue;
          }

          return parsed;
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 401 ||
            (e.response?.statusCode == 400 && _isAuthError(e.response?.data))) {
          lastError = 'Server requires authentication';
          continue;
        }

        // Non-auth 400 = bad URL/unsupported — return error
        if (e.response?.statusCode == 400) {
          final errorMsg = _extractError(e.response?.data);
          return CobaltResponse(
            status: 'error',
            error: errorMsg ?? 'This link is not supported.',
          );
        }

        if (e.response?.statusCode == 429) {
          lastError = 'Too many requests. Please wait a moment.';
          continue;
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          lastError = 'Server timed out, trying another...';
          continue;
        }

        lastError = e.message ?? 'Connection failed';
        continue;
      } catch (_) {
        lastError = 'Connection failed';
        continue;
      }
    }

    return CobaltResponse(status: 'error', error: lastError);
  }

  /// Check if an error response is an auth error
  bool _isAuthError(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map) {
        final code = error['code']?.toString() ?? '';
        return code.contains('auth') || code.contains('jwt');
      }
      if (error is String) {
        return error.contains('auth') || error.contains('jwt');
      }
    }
    return false;
  }

  /// Extract a user-friendly error message from response data
  String? _extractError(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map) return error['code']?.toString();
      if (error is String) return error;
      final text = data['text'];
      if (text is String) return text;
    }
    return null;
  }
}
