import 'package:flutter/material.dart';
import '../controllers/youtube_player_controller.dart';
import '../models/player_config.dart';
import '../utils/youtube_helpers.dart';
import 'youtube_player_widget.dart';

/// YouTube player optimized for BottomSheet and modal presentations
/// Does not manage system orientations or Scaffold
class YoutubePlayerSheet extends StatefulWidget {
  /// YouTube video ID to play
  final String videoId;

  /// Caption language code (e.g., 'en' for English, 'es' for Spanish)
  final String? captionLanguage;

  const YoutubePlayerSheet({
    super.key,
    required this.videoId,
    this.captionLanguage,
  });

  @override
  State<YoutubePlayerSheet> createState() => _YoutubePlayerSheetState();
}

class _YoutubePlayerSheetState extends State<YoutubePlayerSheet> {
  late ReusableYoutubePlayerController _controller;

  // State variables for external controls
  int _durationTimeInSeconds = 0;
  int _currentTimeInSeconds = 0;
  double _videoTimeSliderValue = 0;
  bool _isSliderChangeInProgress = false;
  bool _isPlaying = false;
  bool _showControls = true; // Controls visibility toggle

  @override
  void initState() {
    super.initState();

    const autoPlay = true;

    _controller = ReusableYoutubePlayerController(
      videoId: widget.videoId,
      config: PlayerConfig(
        autoPlay: autoPlay,
        showControls: false,
        showCustomControls: false,
        hideYouTubeUI: true,
        captionLanguage: widget.captionLanguage,
        enableCaption: widget.captionLanguage != null,
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
    return Container(
      color: Colors.black,
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

                  // Auto-loop: seek to beginning 1 second before video ends
                  // to avoid YouTube end screen (timer fires every 1s)
                  if (_durationTimeInSeconds > 0) {
                    final remainingTimeInSeconds =
                        _durationTimeInSeconds - currentTimeInSeconds;
                    if (remainingTimeInSeconds <= 1) {
                      _controller.seekVideoTo(0);
                    }
                  }
                }
              },
            ),
          ),

          // Transparent overlay to block YouTube player controls and toggle our controls
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // Toggle external controls visibility
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // External controls at bottom
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                              icon: const Icon(Icons.replay_10_rounded,
                                  color: Colors.white, size: 32),
                              onPressed: () {
                                _controller
                                    .seekVideoSecondsFromCurrentTime(-10);
                              },
                            ),

                          // Play button
                          if (!_isPlaying)
                            IconButton(
                              icon: const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 48),
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
                              icon: const Icon(Icons.pause,
                                  color: Colors.white, size: 48),
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
                              icon: const Icon(Icons.forward_10_rounded,
                                  color: Colors.white, size: 32),
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
                              YoutubeHelpers.formatSecondsToMinutesAndSeconds(
                                  _currentTimeInSeconds),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),

                            const SizedBox(width: 8),

                            // Slider
                            if (_durationTimeInSeconds > 0)
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: Colors.red,
                                    inactiveTrackColor:
                                        Colors.red.withOpacity(0.3),
                                    thumbColor: Colors.red,
                                    overlayColor: Colors.red.withOpacity(0.2),
                                  ),
                                  child: Slider(
                                    min: 0.0,
                                    max: _durationTimeInSeconds.toDouble(),
                                    value: _videoTimeSliderValue.clamp(
                                        0.0, _durationTimeInSeconds.toDouble()),
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

                                      // Seek video to specific seconds (this auto-plays)
                                      _controller.seekVideoTo(value);

                                      // Update current time and playing state
                                      setState(() {
                                        _currentTimeInSeconds = value.toInt();
                                        _isPlaying =
                                            true; // seekVideoTo auto-plays the video
                                      });
                                    },
                                  ),
                                ),
                              ),

                            const SizedBox(width: 8),

                            // Duration
                            Text(
                              YoutubeHelpers.formatSecondsToMinutesAndSeconds(
                                  _durationTimeInSeconds),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
