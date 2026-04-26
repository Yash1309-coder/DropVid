import 'package:dio/dio.dart';
import '../../models/cobalt_response.dart';

/// Downlo self-hosted backend API service
/// Used for YouTube downloads (quality selection, audio extraction)
/// Falls back to Cobalt for other platforms
class YtDlpApiService {
  final String baseUrl;
  late final Dio _dio;

  YtDlpApiService({required this.baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(minutes: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  /// Submit a download job to the backend.
  /// Returns a job ID for status polling.
  Future<YtDlpJobResponse> submitDownload({
    required String url,
    String quality = '1080',
    String format = 'video',
  }) async {
    try {
      final response = await _dio.post('/download', data: {
        'url': url,
        'quality': quality,
        'format': format,
      });

      if (response.statusCode == 200 && response.data != null) {
        return YtDlpJobResponse.fromJson(response.data as Map<String, dynamic>);
      }

      return YtDlpJobResponse(
        jobId: '',
        status: 'failed',
        message: 'Server returned status ${response.statusCode}',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return YtDlpJobResponse(
          jobId: '',
          status: 'failed',
          message: 'Too many requests. Please wait a moment.',
        );
      }
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        final msg = data is Map ? (data['message'] ?? 'Invalid URL') : 'Invalid URL';
        return YtDlpJobResponse(jobId: '', status: 'failed', message: msg.toString());
      }
      return YtDlpJobResponse(
        jobId: '',
        status: 'failed',
        message: e.message ?? 'Connection failed',
      );
    }
  }

  /// Poll the status of a download job.
  Future<YtDlpStatusResponse> getStatus(String jobId) async {
    try {
      final response = await _dio.get('/status/$jobId');
      if (response.statusCode == 200 && response.data != null) {
        return YtDlpStatusResponse.fromJson(response.data as Map<String, dynamic>);
      }
      return YtDlpStatusResponse(jobId: jobId, status: 'failed');
    } on DioException {
      return YtDlpStatusResponse(jobId: jobId, status: 'failed');
    }
  }

  /// Get the direct download URL for a completed file.
  String getFileUrl(String fileId) => '$baseUrl/file/$fileId';

  /// Resolve a YouTube URL to a direct download link.
  /// This polls until the download completes, then returns a CobaltResponse
  /// compatible with the existing download pipeline.
  Future<CobaltResponse> resolveUrl({
    required String url,
    String quality = '1080',
    bool isAudioOnly = false,
  }) async {
    // Submit the download job
    final job = await submitDownload(
      url: url,
      quality: quality,
      format: isAudioOnly ? 'audio' : 'video',
    );

    if (job.status == 'failed') {
      return CobaltResponse(status: 'error', error: job.message);
    }

    // If cache hit, the job is already completed
    if (job.status == 'completed' && job.message.contains('File ID:')) {
      final fileId = job.message.split('File ID: ').last.trim();
      return CobaltResponse(
        status: 'redirect',
        url: getFileUrl(fileId),
      );
    }

    // Poll for completion
    final jobId = job.jobId;
    int attempts = 0;
    const maxAttempts = 360; // 30 minutes at 5s intervals

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));
      attempts++;

      final status = await getStatus(jobId);

      if (status.status == 'completed' && status.fileId != null) {
        return CobaltResponse(
          status: 'redirect',
          url: getFileUrl(status.fileId!),
        );
      }

      if (status.status == 'failed') {
        return CobaltResponse(
          status: 'error',
          error: status.error ?? 'Download failed',
        );
      }

      // Still downloading/merging — continue polling
    }

    return CobaltResponse(status: 'error', error: 'Download timed out');
  }
}


/// Response from POST /download
class YtDlpJobResponse {
  final String jobId;
  final String status;
  final String message;

  YtDlpJobResponse({
    required this.jobId,
    required this.status,
    this.message = '',
  });

  factory YtDlpJobResponse.fromJson(Map<String, dynamic> json) {
    return YtDlpJobResponse(
      jobId: json['job_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'failed',
      message: json['message']?.toString() ?? '',
    );
  }
}


/// Response from GET /status/{jobId}
class YtDlpStatusResponse {
  final String jobId;
  final String status;
  final double progress;
  final String? title;
  final int? fileSize;
  final String? fileId;
  final String? downloadUrl;
  final String? error;

  YtDlpStatusResponse({
    required this.jobId,
    required this.status,
    this.progress = 0.0,
    this.title,
    this.fileSize,
    this.fileId,
    this.downloadUrl,
    this.error,
  });

  factory YtDlpStatusResponse.fromJson(Map<String, dynamic> json) {
    return YtDlpStatusResponse(
      jobId: json['job_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'failed',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      title: json['title']?.toString(),
      fileSize: json['file_size'] as int?,
      fileId: json['file_id']?.toString(),
      downloadUrl: json['download_url']?.toString(),
      error: json['error']?.toString(),
    );
  }
}
