import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/player_config.dart';

/// Controller for managing YouTube player state and playback
/// Compatible with FlutterFlow custom player API
class ReusableYoutubePlayerController extends ChangeNotifier {
  late YoutubePlayerController _youtubeController;
  final PlayerConfig config;

  Timer? _timer;
  bool _isPlayerReady = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  ReusableYoutubePlayerController({
    required String videoId,
    PlayerConfig? config,
  }) : config = config ?? PlayerConfig() {
    _initializePlayer(videoId);
  }

  /// Getters
  YoutubePlayerController get youtubeController => _youtubeController;
  bool get isPlayerReady => _isPlayerReady;
  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  /// Get current time in seconds (FlutterFlow compatible)
  Future<double> get currentTime async => _currentPosition.inSeconds.toDouble();

  /// Get duration in seconds (FlutterFlow compatible)
  Future<double> get duration async => _totalDuration.inSeconds.toDouble();

  void _initializePlayer(String videoId) {
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: config.autoPlay,
        mute: config.mute,
        loop: config.loop,
        showLiveFullscreenButton: config.showFullscreenButton,
        controlsVisibleAtStart: config.showControls,
        enableCaption: config.enableCaption,
      ),
    );

    _setupListeners();
  }

  void _setupListeners() {
    _youtubeController.addListener(() {
      final value = _youtubeController.value;

      // Update ready state
      if (value.isReady && !_isPlayerReady) {
        _isPlayerReady = true;
      }

      // Update playing state
      _isPlaying = value.playerState == PlayerState.playing;

      // Update position
      _currentPosition = value.position;

      // Update total duration if available
      if (value.metaData.duration > Duration.zero) {
        _totalDuration = value.metaData.duration;
      }

      notifyListeners();
    });
  }

  /// Playback controls
  Future<void> play() async {
    _youtubeController.play();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pause() async {
    _youtubeController.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekTo(Duration position) async {
    _youtubeController.seekTo(position);
    _currentPosition = position;
    notifyListeners();
  }

  // FlutterFlow compatible methods

  /// Play video (FlutterFlow API)
  void playVideo() {
    _youtubeController.play();
    _isPlaying = true;
    notifyListeners();
  }

  /// Pause video (FlutterFlow API)
  void pauseVideo() {
    _youtubeController.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// Seek to specific time in seconds (FlutterFlow API)
  void seekVideoTo(double seconds) {
    final position = Duration(milliseconds: (seconds * 1000).toInt());
    _youtubeController.seekTo(position);
    _currentPosition = position;
    _youtubeController.play();
    notifyListeners();
  }

  /// Seek relative to current time (FlutterFlow API)
  Future<void> seekVideoSecondsFromCurrentTime(double howManySecondsFromCurrentTimeInSeconds) async {
    final currentTimeInSeconds = _currentPosition.inSeconds.toDouble();
    final durationInSeconds = _totalDuration.inSeconds.toDouble();

    if (howManySecondsFromCurrentTimeInSeconds > 0) {
      // Forward seek
      final newForwardSeekInSeconds = currentTimeInSeconds + howManySecondsFromCurrentTimeInSeconds;
      if (newForwardSeekInSeconds < durationInSeconds) {
        seekVideoTo(newForwardSeekInSeconds);
      }
    } else {
      // Backward seek
      final newBackwardSeekInSeconds = currentTimeInSeconds + howManySecondsFromCurrentTimeInSeconds;
      if (newBackwardSeekInSeconds > 0) {
        seekVideoTo(newBackwardSeekInSeconds);
      }
    }
  }

  Future<void> mute() async {
    _youtubeController.mute();
    _isMuted = true;
    notifyListeners();
  }

  Future<void> unMute() async {
    _youtubeController.unMute();
    _isMuted = false;
    notifyListeners();
  }

  Future<void> toggleMute() async {
    if (_isMuted) {
      await unMute();
    } else {
      await mute();
    }
  }

  Future<void> setVolume(int volume) async {
    _youtubeController.setVolume(volume);
    notifyListeners();
  }

  /// Load a new video
  Future<void> loadVideo(String videoId) async {
    _isPlayerReady = false;
    _youtubeController.load(videoId);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _youtubeController.dispose();
    super.dispose();
  }
}
