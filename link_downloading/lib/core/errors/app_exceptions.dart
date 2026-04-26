/// Downlo Custom Exceptions
/// Typed exceptions for different failure scenarios
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}

/// Thrown when the URL format is invalid
class InvalidUrlException extends AppException {
  const InvalidUrlException()
      : super("That doesn't look like a valid link", code: 'INVALID_URL');
}

/// Thrown when the platform is not supported
class UnsupportedPlatformException extends AppException {
  const UnsupportedPlatformException()
      : super("This platform isn't supported yet",
            code: 'UNSUPPORTED_PLATFORM');
}

/// Thrown when there's no internet connection
class NoInternetException extends AppException {
  const NoInternetException()
      : super('No internet connection.', code: 'NO_INTERNET');
}

/// Thrown when the API request times out
class TimeoutException extends AppException {
  const TimeoutException()
      : super('Request timed out. Retry?', code: 'TIMEOUT');
}

/// Thrown when rate limit is hit
class RateLimitException extends AppException {
  const RateLimitException()
      : super('Too many requests. Please wait a moment.',
            code: 'RATE_LIMIT');
}

/// Thrown when server returns 500+ error
class ServerException extends AppException {
  const ServerException()
      : super('Server error. Please try again later.', code: 'SERVER_ERROR');
}

/// Thrown when download fails
class DownloadFailedException extends AppException {
  const DownloadFailedException([String? detail])
      : super(detail ?? 'Download failed. Retry?',
            code: 'DOWNLOAD_FAILED');
}

/// Thrown when device storage is insufficient
class InsufficientStorageException extends AppException {
  const InsufficientStorageException()
      : super('Not enough storage space.', code: 'INSUFFICIENT_STORAGE');
}

/// Thrown when storage permission is denied
class PermissionDeniedException extends AppException {
  const PermissionDeniedException()
      : super('Storage permission required to save videos.',
            code: 'PERMISSION_DENIED');
}

/// Thrown when the downloaded file is corrupted (0 bytes)
class CorruptedFileException extends AppException {
  const CorruptedFileException()
      : super('Download failed. File may be corrupted. Retry?',
            code: 'CORRUPTED_FILE');
}

/// Generic Cobalt API error
class CobaltApiException extends AppException {
  const CobaltApiException(super.message)
      : super(code: 'COBALT_API_ERROR');
}
