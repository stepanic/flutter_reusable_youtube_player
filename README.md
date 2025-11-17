# flutter_reusable_youtube_player

A customizable and reusable YouTube player widget for Flutter applications. Easy to integrate, feature-rich, and production-ready.

**✨ FlutterFlow Compatible**: Drop-in replacement for FlutterFlow's custom YouTube player with improved reliability!

## Features

- Easy integration with just a few lines of code
- **FlutterFlow API compatibility** - seamless migration from FlutterFlow custom player
- Customizable player controls with external control support
- Support for various YouTube URL formats
- Video ID extraction helper utilities
- Thumbnail generation
- Configurable player options (autoplay, mute, loop, etc.)
- Custom controls overlay
- Responsive aspect ratio
- **Callbacks for duration and current time** (FlutterFlow compatible)
- **Reliable playback** - no infinite loading spinners
- Comprehensive test coverage

## Installation

### Using the fork with CSS injection (Recommended for hiding controls)

This package uses a forked version of `youtube_player_flutter` that includes CSS injection to hide YouTube player controls.

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_reusable_youtube_player: ^0.0.1
  youtube_player_flutter:
    git:
      url: https://github.com/stepanic/youtube_player_flutter.git
      path: packages/youtube_player_flutter
```

Then run:

```bash
flutter pub get
```

### Standard installation (without control hiding)

```yaml
dependencies:
  flutter_reusable_youtube_player: ^0.0.1
```

**Note**: The standard installation will show brief flashes of YouTube controls during play/pause transitions. Use the fork for optimal experience.

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_reusable_youtube_player/flutter_reusable_youtube_player.dart';

class MyPlayerPage extends StatefulWidget {
  @override
  State<MyPlayerPage> createState() => _MyPlayerPageState();
}

class _MyPlayerPageState extends State<MyPlayerPage> {
  late ReusableYoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReusableYoutubePlayerController(
      videoId: 'dQw4w9WgXcQ',
      config: PlayerConfig(
        autoPlay: false,
        showCustomControls: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReusableYoutubePlayer(
        controller: _controller,
        showCustomControls: true,
      ),
    );
  }
}
```

### Loading Videos from URL

```dart
// Extract video ID from various URL formats
final videoId = YoutubeHelpers.extractVideoId('https://www.youtube.com/watch?v=dQw4w9WgXcQ');

// Validate video ID
if (YoutubeHelpers.isValidVideoId(videoId)) {
  _controller.loadVideo(videoId);
}
```

### Configuration Options

```dart
PlayerConfig(
  showControls: true,           // Show native YouTube controls
  showFullscreenButton: true,   // Show fullscreen button
  mute: false,                  // Mute by default
  loop: false,                  // Loop video
  enableCaption: true,          // Enable captions
  strictRelatedVideos: true,    // Only show related videos from same channel
  aspectRatio: 16 / 9,         // Player aspect ratio
  showCustomControls: false,    // Show custom overlay controls
  autoPlay: false,              // Autoplay video
  hideYouTubeUI: false,         // Hide YouTube UI elements (play button, thumbnails)
  preventControlsFlash: true,   // Prevent flash of YouTube controls during play/pause (default: false)
)
```

**Note on `preventControlsFlash`**: When enabled, this feature shows a brief (500ms) black overlay during play/pause transitions to hide the flash of native YouTube controls.

**For best results**: Use the forked version of `youtube_player_flutter` (see Installation section) which includes JavaScript that continuously attempts to inject CSS into YouTube's iframe to hide controls like `#player-controls`, `.ytp-chrome-top`, `.ytp-title`, and `.ytp-gradient-top`.

**How it works**:
1. The fork includes JavaScript that runs every 100ms attempting to inject CSS into the YouTube iframe
2. The overlay provides additional protection during state transitions
3. Due to Cross-Origin policies, the CSS injection may or may not work depending on browser security settings, but the overlay ensures controls are always hidden during transitions

Set to `false` (default) to allow YouTube's native control animations.

### Helper Utilities

```dart
// Get video thumbnail
final thumbnailUrl = YoutubeHelpers.getThumbnailUrl(
  'dQw4w9WgXcQ',
  quality: ThumbnailQuality.high,
);

// Format duration
final formatted = YoutubeHelpers.formatDuration(Duration(minutes: 3, seconds: 45));
// Output: "03:45"

// Parse duration string
final duration = YoutubeHelpers.parseDuration('1:23:45');
// Output: Duration(hours: 1, minutes: 23, seconds: 45)
```

### Playback Controls

```dart
// Play/Pause
await _controller.play();
await _controller.pause();
await _controller.togglePlayPause();

// Mute/Unmute
await _controller.mute();
await _controller.unMute();
await _controller.toggleMute();

// Seek
await _controller.seekTo(Duration(seconds: 30));

// Volume
await _controller.setVolume(50);

// Load new video
await _controller.loadVideo('newVideoId');
```

## FlutterFlow Migration

**Migrating from FlutterFlow's custom YouTube player?** See the [FlutterFlow Migration Guide](FLUTTERFLOW_MIGRATION.md) for step-by-step instructions.

### FlutterFlow-Compatible Example

```dart
// Create controller with video ID
final videoId = YoutubeHelpers.extractVideoId(videoUrl);
final controller = ReusableYoutubePlayerController(
  videoId: videoId,
  config: PlayerConfig(
    autoPlay: true,
    showControls: false,
  ),
);

// Use with callbacks (like FlutterFlow)
ReusableYoutubePlayer(
  controller: controller,
  onDurationFetched: (durationInSeconds) async {
    setState(() {
      _durationInSeconds = durationInSeconds;
    });
  },
  onCurrentTimeFetched: (currentTimeInSeconds) async {
    setState(() {
      _currentTimeInSeconds = currentTimeInSeconds;
    });
  },
);

// Control playback (FlutterFlow API)
controller.playVideo();
controller.pauseVideo();
controller.seekVideoTo(30.0);  // Seek to 30 seconds
controller.seekVideoSecondsFromCurrentTime(-10);  // Go back 10 seconds
```

See `example/lib/flutterflow_example.dart` for a complete working example with custom controls, slider, and time display.

## Example App

Check out the [example](example/) directory for a complete demo application showing all features.

To run the example:

```bash
cd example
flutter pub get
flutter run
```

The example app includes:
- Basic player usage
- FlutterFlow-compatible implementation with custom controls
- Video selection from multiple sources
- External playback controls

## Supported URL Formats

The package can extract video IDs from:

- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `https://www.youtube.com/embed/VIDEO_ID`
- `https://www.youtube.com/v/VIDEO_ID`
- Direct video ID: `VIDEO_ID`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

This package uses [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter) for the core YouTube player functionality.
