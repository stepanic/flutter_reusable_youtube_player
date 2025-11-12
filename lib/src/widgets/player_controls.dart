import 'package:flutter/material.dart';
import '../controllers/youtube_player_controller.dart';

/// Custom player controls overlay widget
class PlayerControls extends StatefulWidget {
  final ReusableYoutubePlayerController controller;

  const PlayerControls({
    super.key,
    required this.controller,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPlayerStateChanged);
    super.dispose();
  }

  void _onPlayerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _toggleControls,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showControls,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top bar (could add title, etc.)
                const SizedBox(height: 8),

                // Center play/pause button
                Center(
                  child: IconButton(
                    onPressed: widget.controller.togglePlayPause,
                    icon: Icon(
                      widget.controller.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Play/Pause button
                      IconButton(
                        onPressed: widget.controller.togglePlayPause,
                        icon: Icon(
                          widget.controller.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),

                      // Progress indicator (simplified)
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Mute button
                      IconButton(
                        onPressed: widget.controller.toggleMute,
                        icon: Icon(
                          widget.controller.isMuted
                              ? Icons.volume_off
                              : Icons.volume_up,
                          color: Colors.white,
                        ),
                      ),

                      // Fullscreen button
                      IconButton(
                        onPressed: () {
                          // TODO: Implement fullscreen
                        },
                        icon: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
