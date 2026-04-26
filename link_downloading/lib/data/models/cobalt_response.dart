/// Downlo Cobalt API Response Model
/// Supports both v7 and v11 response formats
class CobaltResponse {
  final String status;
  final String? url; // Direct download URL
  final String? filename;
  final String? error;
  final List<CobaltPicker>? picker; // Multiple format options

  const CobaltResponse({
    required this.status,
    this.url,
    this.filename,
    this.error,
    this.picker,
  });

  /// Whether the response is ready to download
  bool get isReady =>
      status == 'redirect' || status == 'tunnel' || status == 'stream';

  /// Whether the response returned an error
  bool get isError => status == 'error';

  /// Whether the response returned a picker (multiple options)
  bool get hasPicker =>
      status == 'picker' && picker != null && picker!.isNotEmpty;

  /// Get the best download URL (handles both direct and picker responses)
  String? get downloadUrl {
    if (url != null) return url;
    if (hasPicker) return picker!.first.url;
    return null;
  }

  factory CobaltResponse.fromJson(Map<String, dynamic> json) {
    // Handle error — v7 returns string, v11 returns object
    String? errorMsg;
    final rawError = json['error'];
    if (rawError is Map) {
      errorMsg = rawError['code']?.toString() ?? 'Unknown error';
    } else if (rawError is String) {
      errorMsg = rawError;
    }

    return CobaltResponse(
      status: json['status'] as String? ?? 'error',
      url: json['url'] as String?,
      filename: json['filename'] as String?,
      error: errorMsg,
      picker: json['picker'] != null
          ? (json['picker'] as List)
              .map((e) => CobaltPicker.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

/// Represents a single option in the Cobalt picker response
class CobaltPicker {
  final String type; // "video" or "audio" or "photo"
  final String url;
  final String? thumb; // thumbnail URL

  const CobaltPicker({
    required this.type,
    required this.url,
    this.thumb,
  });

  factory CobaltPicker.fromJson(Map<String, dynamic> json) {
    return CobaltPicker(
      type: json['type'] as String? ?? 'video',
      url: json['url'] as String? ?? '',
      thumb: json['thumb'] as String?,
    );
  }
}

/// Request body for Cobalt API v7 (/api/json)
class CobaltRequestV7 {
  final String url;
  final String vQuality;
  final bool isAudioOnly;
  final String filenamePattern;

  const CobaltRequestV7({
    required this.url,
    this.vQuality = '1080',
    this.isAudioOnly = false,
    this.filenamePattern = 'basic',
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'vQuality': vQuality,
      'isAudioOnly': isAudioOnly,
      'filenamePattern': filenamePattern,
    };
  }
}

/// Request body for Cobalt API v11+ (POST /)
class CobaltRequestV11 {
  final String url;
  final String videoQuality;
  final String downloadMode;
  final String filenameStyle;

  const CobaltRequestV11({
    required this.url,
    this.videoQuality = '1080',
    this.downloadMode = 'auto',
    this.filenameStyle = 'classic',
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'videoQuality': videoQuality,
      'downloadMode': downloadMode,
      'filenameStyle': filenameStyle,
    };
  }
}
