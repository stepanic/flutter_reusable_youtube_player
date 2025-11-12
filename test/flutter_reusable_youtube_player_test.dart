import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_reusable_youtube_player/flutter_reusable_youtube_player.dart';

void main() {
  group('YoutubeHelpers', () {
    test('extracts video ID from standard YouTube URL', () {
      final videoId = YoutubeHelpers.extractVideoId(
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(videoId, 'dQw4w9WgXcQ');
    });

    test('extracts video ID from youtu.be URL', () {
      final videoId = YoutubeHelpers.extractVideoId(
        'https://youtu.be/dQw4w9WgXcQ',
      );
      expect(videoId, 'dQw4w9WgXcQ');
    });

    test('extracts video ID from embed URL', () {
      final videoId = YoutubeHelpers.extractVideoId(
        'https://www.youtube.com/embed/dQw4w9WgXcQ',
      );
      expect(videoId, 'dQw4w9WgXcQ');
    });

    test('returns null for invalid URL', () {
      final videoId = YoutubeHelpers.extractVideoId('not a url');
      expect(videoId, null);
    });

    test('validates correct video ID', () {
      expect(YoutubeHelpers.isValidVideoId('dQw4w9WgXcQ'), true);
    });

    test('rejects invalid video ID', () {
      expect(YoutubeHelpers.isValidVideoId('invalid'), false);
      expect(YoutubeHelpers.isValidVideoId(''), false);
      expect(YoutubeHelpers.isValidVideoId(null), false);
    });

    test('generates thumbnail URL', () {
      final url = YoutubeHelpers.getThumbnailUrl(
        'dQw4w9WgXcQ',
        quality: ThumbnailQuality.high,
      );
      expect(url, 'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg');
    });

    test('formats duration correctly (MM:SS)', () {
      final duration = Duration(minutes: 3, seconds: 45);
      expect(YoutubeHelpers.formatDuration(duration), '03:45');
    });

    test('formats duration correctly (HH:MM:SS)', () {
      final duration = Duration(hours: 1, minutes: 23, seconds: 45);
      expect(YoutubeHelpers.formatDuration(duration), '1:23:45');
    });

    test('parses duration string (MM:SS)', () {
      final duration = YoutubeHelpers.parseDuration('03:45');
      expect(duration, Duration(minutes: 3, seconds: 45));
    });

    test('parses duration string (HH:MM:SS)', () {
      final duration = YoutubeHelpers.parseDuration('1:23:45');
      expect(duration, Duration(hours: 1, minutes: 23, seconds: 45));
    });
  });

  group('PlayerConfig', () {
    test('creates default config', () {
      final config = PlayerConfig();
      expect(config.showControls, true);
      expect(config.autoPlay, false);
      expect(config.mute, false);
    });

    test('creates config with custom values', () {
      final config = PlayerConfig(
        showControls: false,
        autoPlay: true,
        mute: true,
      );
      expect(config.showControls, false);
      expect(config.autoPlay, true);
      expect(config.mute, true);
    });

    test('copyWith updates values correctly', () {
      final config = PlayerConfig(autoPlay: false);
      final updated = config.copyWith(autoPlay: true);
      expect(updated.autoPlay, true);
      expect(updated.showControls, config.showControls);
    });
  });
}
