import 'package:flutter/material.dart';
import 'package:flutter_reusable_youtube_player/flutter_reusable_youtube_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Player Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const SimplePlayerPage(),
    );
  }
}

class SimplePlayerPage extends StatefulWidget {
  const SimplePlayerPage({super.key});

  @override
  State<SimplePlayerPage> createState() => _SimplePlayerPageState();
}

class _SimplePlayerPageState extends State<SimplePlayerPage> {
  late ReusableYoutubePlayerController _controller;

  // State variables for external controls
  int _durationTimeInSeconds = 0;
  int _currentTimeInSeconds = 0;
  double _videoTimeSliderValue = 0;
  bool _isSliderChangeInProgress = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    const autoPlay = true; // Change this to false to start paused

    _controller = ReusableYoutubePlayerController(
      videoId: 'YVjxNq2vCC4',
      config: PlayerConfig(
        autoPlay: autoPlay,
        showControls: false,        // Hide native YouTube controls
        showCustomControls: false,  // Hide our custom overlay controls
        hideYouTubeUI: true,        // Hide YouTube big play button, thumbnails, pause overlay
      ),
    );

    // Set initial playing state based on autoPlay
    _isPlaying = autoPlay;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // YouTube Player
            Align(
              alignment: Alignment.center,
              child: ReusableYoutubePlayer(
                controller: _controller,
                showCustomControls: false,
                // Callbacks for tracking time
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

                    // Update slider if not being dragged
                    if (!_isSliderChangeInProgress) {
                      setState(() {
                        _videoTimeSliderValue = currentTimeInSeconds.toDouble();
                      });
                    }
                  }
                },
              ),
            ),

            // Transparent overlay to block YouTube player controls
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Absorb taps to prevent YouTube controls from showing
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

            // External controls at bottom
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
                            _controller.seekVideoSecondsFromCurrentTime(-10);
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
                            _controller.playVideo();
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
                            _controller.pauseVideo();
                          },
                        ),

                      // Forward 10 seconds
                      if (_isPlaying)
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 32),
                          onPressed: () {
                            _controller.seekVideoSecondsFromCurrentTime(10);
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
                                  _controller.seekVideoTo(value);

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
