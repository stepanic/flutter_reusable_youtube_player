# FlutterFlow Migration Guide

This guide explains how to migrate from FlutterFlow's `youtube_player_iframe` custom implementation to this reusable YouTube player package.

## Why Migrate?

- **Better Reliability**: Uses `youtube_player_flutter` instead of `youtube_player_iframe`, which has better Android compatibility
- **No Infinite Spinner**: Properly handles player state and loading indicators
- **Video Visibility**: Fixed issues where video was blocked by overlays
- **Same API**: Drop-in replacement with the same FlutterFlow custom player API

## API Compatibility

The package provides 100% API compatibility with FlutterFlow's custom YouTube player:

### Controller Methods

```dart
// FlutterFlow custom player
FlutterFlowYoutubePlayerCustomController controller;

controller.playVideo();
controller.pauseVideo();
controller.seekVideoTo(double seconds);
controller.seekVideoSecondsFromCurrentTime(double seconds);

// Reusable YouTube player - IDENTICAL API
ReusableYoutubePlayerController controller;

controller.playVideo();
controller.pauseVideo();
controller.seekVideoTo(double seconds);
controller.seekVideoSecondsFromCurrentTime(double seconds);
```

### Widget Callbacks

```dart
// FlutterFlow custom player
FlutterFlowYoutubePlayerCustom(
  url: videoUrl,
  autoPlay: true,
  showControls: false,
  onDurationFetched: (durationInSeconds) async {
    // Handle duration
  },
  onCurrentTimeFetched: (currentTimeInSeconds) async {
    // Handle current time
  },
  controller: customController,
);

// Reusable YouTube player - IDENTICAL API
ReusableYoutubePlayer(
  controller: customController,
  onDurationFetched: (durationInSeconds) async {
    // Handle duration
  },
  onCurrentTimeFetched: (currentTimeInSeconds) async {
    // Handle current time
  },
);
```

## Migration Steps

### Step 1: Update Dependencies

In your `pubspec.yaml`, replace:

```yaml
dependencies:
  youtube_player_iframe: ^5.2.2
```

With:

```yaml
dependencies:
  flutter_reusable_youtube_player:
    git:
      url: https://github.com/stepanic/flutter_reusable_youtube_player.git
```

### Step 2: Update Imports

Replace:

```dart
import '/flutter_flow/flutter_flow_youtube_player_custom.dart';
```

With:

```dart
import 'package:flutter_reusable_youtube_player/flutter_reusable_youtube_player.dart';
```

### Step 3: Update Controller Declaration

Replace:

```dart
FlutterFlowYoutubePlayerCustomController _customPlayerController =
    FlutterFlowYoutubePlayerCustomController();
```

With:

```dart
late ReusableYoutubePlayerController _customPlayerController;

@override
void initState() {
  super.initState();

  final videoId = YoutubeHelpers.extractVideoId(videoUrl) ?? '';

  _customPlayerController = ReusableYoutubePlayerController(
    videoId: videoId,
    config: PlayerConfig(
      autoPlay: true,
      showControls: false,
      showCustomControls: false,
    ),
  );
}
```

### Step 4: Update Widget

Replace:

```dart
FlutterFlowYoutubePlayerCustom(
  url: containerVideosRecord.youtubeUrl,
  width: double.infinity,
  autoPlay: true,
  looping: true,
  mute: false,
  showControls: false,
  showFullScreen: false,
  lang: FFLocalizations.of(context).languageCode,
  onDurationFetched: (durationInSeconds) async {
    if (durationInSeconds > 0) {
      if (_model.durationTimeInSeconds == 0) {
        safeSetState(() {
          _model.durationTimeInSeconds = durationInSeconds;
        });
      }
    }
  },
  onCurrentTimeFetched: (currentTimeInSeconds) async {
    if (currentTimeInSeconds > 0) {
      safeSetState(() {
        _model.currentTimeInSeconds = currentTimeInSeconds;
      });

      if (_model.isSliderChangeInProgress == false) {
        setState(() {
          _model.videoTimeSliderValue = currentTimeInSeconds.toDouble();
        });
      }
    }
  },
  controller: _customPlayerController,
)
```

With:

```dart
ReusableYoutubePlayer(
  controller: _customPlayerController,
  showCustomControls: false,
  onDurationFetched: (durationInSeconds) async {
    if (durationInSeconds > 0) {
      if (_model.durationTimeInSeconds == 0) {
        safeSetState(() {
          _model.durationTimeInSeconds = durationInSeconds;
        });
      }
    }
  },
  onCurrentTimeFetched: (currentTimeInSeconds) async {
    if (currentTimeInSeconds > 0) {
      safeSetState(() {
        _model.currentTimeInSeconds = currentTimeInSeconds;
      });

      if (_model.isSliderChangeInProgress == false) {
        setState(() {
          _model.videoTimeSliderValue = currentTimeInSeconds.toDouble();
        });
      }
    }
  },
)
```

### Step 5: Update Helper Functions

The package includes FlutterFlow-compatible helper functions:

```dart
// Format seconds to MM:SS
YoutubeHelpers.formatSecondsToMinutesAndSeconds(seconds);

// Extract video ID from URL
YoutubeHelpers.extractVideoId(url);

// Validate video ID
YoutubeHelpers.isValidVideoId(videoId);
```

## Complete Example

See `example/lib/flutterflow_example.dart` for a complete working example that demonstrates:

- External custom controls (play, pause, forward/backward 10s)
- Slider for seeking
- Current time and duration display
- All FlutterFlow-compatible callbacks

## Key Differences from FlutterFlow Implementation

### Improvements

1. **No Loading Issues**: Player initializes correctly and removes loading spinner when ready
2. **Video Visibility**: No transparent overlays blocking the video
3. **Better State Management**: Uses ChangeNotifier for reactive updates

### Configuration Differences

The `PlayerConfig` replaces individual boolean parameters:

```dart
// Old FlutterFlow way
FlutterFlowYoutubePlayerCustom(
  autoPlay: true,
  looping: true,
  mute: false,
  showControls: false,
  showFullScreen: false,
)

// New way
ReusableYoutubePlayerController(
  videoId: videoId,
  config: PlayerConfig(
    autoPlay: true,
    loop: true,
    mute: false,
    showControls: false,
    showFullscreenButton: false,
  ),
)
```

## Testing

After migration:

1. Run `flutter pub get`
2. Test video playback
3. Test custom controls (play, pause, seek)
4. Test callbacks are being called
5. Verify slider updates with video progress

## Troubleshooting

### Videos not playing

Make sure you're extracting the video ID correctly:

```dart
final videoId = YoutubeHelpers.extractVideoId(url);
if (videoId == null) {
  print('Invalid YouTube URL: $url');
}
```

### Callbacks not firing

Ensure the widget has both callbacks defined:

```dart
ReusableYoutubePlayer(
  controller: controller,
  onDurationFetched: (duration) async { /* ... */ },
  onCurrentTimeFetched: (currentTime) async { /* ... */ },
)
```

### Spinner not disappearing

The widget automatically handles loading states. If the spinner persists:

1. Check that the video ID is valid
2. Verify network connectivity
3. Check device logs for YouTube player errors

## Support

For issues or questions, please open an issue on GitHub.
