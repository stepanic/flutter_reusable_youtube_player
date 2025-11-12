/// Helper functions for YouTube video operations
class YoutubeHelpers {
  /// Extract video ID from various YouTube URL formats
  /// Supports:
  /// - https://www.youtube.com/watch?v=VIDEO_ID
  /// - https://youtu.be/VIDEO_ID
  /// - https://www.youtube.com/embed/VIDEO_ID
  static String? extractVideoId(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;

    // Handle youtu.be URLs
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    }

    // Handle youtube.com URLs
    if (uri.host.contains('youtube.com')) {
      // Handle /watch?v=VIDEO_ID
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      }
      // Handle /embed/VIDEO_ID
      if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'embed') {
        return uri.pathSegments[1];
      }
      // Handle /v/VIDEO_ID
      if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'v') {
        return uri.pathSegments[1];
      }
    }

    // If it's already just a video ID
    if (url.length == 11 && !url.contains('/') && !url.contains('?')) {
      return url;
    }

    return null;
  }

  /// Validate if a string is a valid YouTube video ID
  static bool isValidVideoId(String? videoId) {
    if (videoId == null || videoId.isEmpty) return false;
    // YouTube video IDs are typically 11 characters long
    return videoId.length == 11 && RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(videoId);
  }

  /// Generate thumbnail URL for a video ID
  static String getThumbnailUrl(String videoId, {ThumbnailQuality quality = ThumbnailQuality.high}) {
    switch (quality) {
      case ThumbnailQuality.low:
        return 'https://img.youtube.com/vi/$videoId/default.jpg';
      case ThumbnailQuality.medium:
        return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
      case ThumbnailQuality.high:
        return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      case ThumbnailQuality.max:
        return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
  }

  /// Format duration from seconds to readable string (MM:SS or HH:MM:SS)
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  /// Format seconds to minutes and seconds (FlutterFlow compatible)
  /// Returns string in format "MM:SS"
  static String formatSecondsToMinutesAndSeconds(int seconds) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${twoDigits(minutes)}:${twoDigits(remainingSeconds)}';
  }

  /// Convert timestamp string (HH:MM:SS or MM:SS) to Duration
  static Duration? parseDuration(String timestamp) {
    final parts = timestamp.split(':').map(int.tryParse).toList();

    if (parts.contains(null)) return null;

    if (parts.length == 2) {
      // MM:SS
      return Duration(minutes: parts[0]!, seconds: parts[1]!);
    } else if (parts.length == 3) {
      // HH:MM:SS
      return Duration(hours: parts[0]!, minutes: parts[1]!, seconds: parts[2]!);
    }

    return null;
  }
}

/// Enum for thumbnail quality options
enum ThumbnailQuality {
  low,    // 120x90
  medium, // 320x180
  high,   // 480x360
  max,    // 1280x720
}
