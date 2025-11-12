import 'package:flutter/material.dart';
import 'package:flutter_reusable_youtube_player/flutter_reusable_youtube_player.dart';

/// Example showing FlutterFlow-compatible usage
/// This demonstrates how to use the reusable YouTube player
/// with the same API as FlutterFlow's custom player
class FlutterFlowExamplePage extends StatefulWidget {
  const FlutterFlowExamplePage({super.key});

  @override
  State<FlutterFlowExamplePage> createState() => _FlutterFlowExamplePageState();
}

class _FlutterFlowExamplePageState extends State<FlutterFlowExamplePage> {
  late ReusableYoutubePlayerController _customPlayerController;

  // State variables (like in FlutterFlow)
  int _durationTimeInSeconds = 0;
  int _currentTimeInSeconds = 0;
  double _videoTimeSliderValue = 0;
  bool _isSliderChangeInProgress = false;
  bool _isPlaying = false;

  final String _videoUrl = 'https://www.youtube.com/watch?v=YVjxNq2vCC4';

  @override
  void initState() {
    super.initState();

    final videoId = YoutubeHelpers.extractVideoId(_videoUrl) ?? 'YVjxNq2vCC4';

    _customPlayerController = ReusableYoutubePlayerController(
      videoId: videoId,
      config: PlayerConfig(
        autoPlay: true,
        showCustomControls: false,
        showControls: false,
      ),
    );
  }

  @override
  void dispose() {
    _customPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // YouTube Player (similar to FlutterFlow)
            Align(
              alignment: Alignment.center,
              child: ReusableYoutubePlayer(
                controller: _customPlayerController,
                showCustomControls: false,
                // FlutterFlow compatible callbacks
                onDurationFetched: (durationInSeconds) async {
                  if (durationInSeconds > 0 && _durationTimeInSeconds == 0) {
                    setState(() {
                      _durationTimeInSeconds = durationInSeconds;
                    });
                  }
                },
                onCurrentTimeFetched: (currentTimeInSeconds) async {
                  if (currentTimeInSeconds > 0) {
                    setState(() {
                      _currentTimeInSeconds = currentTimeInSeconds;
                    });

                    // Update slider value if not being dragged
                    if (!_isSliderChangeInProgress) {
                      setState(() {
                        _videoTimeSliderValue = currentTimeInSeconds.toDouble();
                      });
                    }
                  }
                },
              ),
            ),

            // Close button (top left)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Custom controls (bottom)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play/Pause and Seek buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Backward 10 seconds
                      if (_isPlaying)
                        IconButton(
                          icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 32),
                          onPressed: () {
                            _customPlayerController.seekVideoSecondsFromCurrentTime(-10);
                          },
                        ),

                      // Play button
                      if (!_isPlaying)
                        IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
                          onPressed: () {
                            setState(() {
                              _isPlaying = true;
                            });
                            _customPlayerController.playVideo();
                          },
                        ),

                      // Pause button
                      if (_isPlaying)
                        IconButton(
                          icon: const Icon(Icons.pause, color: Colors.white, size: 48),
                          onPressed: () {
                            setState(() {
                              _isPlaying = false;
                            });
                            _customPlayerController.pauseVideo();
                          },
                        ),

                      // Forward 10 seconds
                      if (_isPlaying)
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 32),
                          onPressed: () {
                            _customPlayerController.seekVideoSecondsFromCurrentTime(10);
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Time and slider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // Current time
                        Text(
                          YoutubeHelpers.formatSecondsToMinutesAndSeconds(_currentTimeInSeconds),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),

                        const SizedBox(width: 8),

                        // Slider
                        if (_durationTimeInSeconds > 0)
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Colors.red,
                                inactiveTrackColor: Colors.red.withOpacity(0.3),
                                thumbColor: Colors.red,
                                overlayColor: Colors.red.withOpacity(0.2),
                              ),
                              child: Slider(
                                min: 0.0,
                                max: _durationTimeInSeconds.toDouble(),
                                value: _videoTimeSliderValue.clamp(0.0, _durationTimeInSeconds.toDouble()),
                                onChanged: (newValue) {
                                  setState(() {
                                    _videoTimeSliderValue = newValue;
                                  });
                                },
                                onChangeStart: (value) {
                                  _isSliderChangeInProgress = true;
                                },
                                onChangeEnd: (value) {
                                  _isSliderChangeInProgress = false;

                                  // Seek video to specific seconds
                                  _customPlayerController.seekVideoTo(value);

                                  // Update current time
                                  setState(() {
                                    _currentTimeInSeconds = value.toInt();
                                  });
                                },
                              ),
                            ),
                          ),

                        const SizedBox(width: 8),

                        // Duration
                        Text(
                          YoutubeHelpers.formatSecondsToMinutesAndSeconds(_durationTimeInSeconds),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
