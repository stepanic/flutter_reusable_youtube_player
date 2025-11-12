import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controllers/youtube_player_controller.dart';
import 'player_controls.dart';

/// Reusable YouTube player widget with customizable controls
/// Compatible with FlutterFlow custom player API
class ReusableYoutubePlayer extends StatefulWidget {
  final ReusableYoutubePlayerController controller;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final bool showCustomControls;

  /// FlutterFlow compatible callbacks
  final Future Function(int durationInSeconds)? onDurationFetched;
  final Future Function(int currentTimeInSeconds)? onCurrentTimeFetched;

  const ReusableYoutubePlayer({
    super.key,
    required this.controller,
    this.loadingWidget,
    this.errorWidget,
    this.showCustomControls = false,
    this.onDurationFetched,
    this.onCurrentTimeFetched,
  });

  @override
  State<ReusableYoutubePlayer> createState() => _ReusableYoutubePlayerState();
}

class _ReusableYoutubePlayerState extends State<ReusableYoutubePlayer> {
  Timer? _callbackTimer;

  @override
  void initState() {
    super.initState();
    // Listen to controller changes
    widget.controller.addListener(_onControllerUpdate);

    // Start timer for FlutterFlow compatible callbacks
    if (widget.onDurationFetched != null || widget.onCurrentTimeFetched != null) {
      _callbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        try {
          final duration = await widget.controller.duration;
          final currentTime = await widget.controller.currentTime;

          if (duration > 0) {
            await widget.onDurationFetched?.call(duration.toInt());
          }

          if (currentTime > 0) {
            await widget.onCurrentTimeFetched?.call(currentTime.toInt());
          }
        } catch (e) {
          // Ignore errors during callback execution
        }
      });
    }
  }

  @override
  void dispose() {
    // Cancel timer
    _callbackTimer?.cancel();
    // Remove listener
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    // Rebuild widget when controller notifies
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // YouTube Player
        YoutubePlayer(
          controller: widget.controller.youtubeController,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: const ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
          bottomActions: widget.showCustomControls || widget.controller.config.showCustomControls
              ? []
              : null, // Hide default controls if custom controls are shown
        ),

        // Custom controls overlay
        if (widget.showCustomControls || widget.controller.config.showCustomControls)
          Positioned.fill(
            child: PlayerControls(
              controller: widget.controller,
            ),
          ),

        // Loading indicator
        if (!widget.controller.isPlayerReady)
          Positioned.fill(
            child: widget.loadingWidget ??
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  ),
                ),
          ),
      ],
    );
  }
}
