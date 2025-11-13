/// Configuration options for the YouTube player
class PlayerConfig {
  /// Whether to show player controls
  final bool showControls;

  /// Whether to show fullscreen button
  final bool showFullscreenButton;

  /// Whether to mute the video by default
  final bool mute;

  /// Whether to loop the video
  final bool loop;

  /// Whether to enable captions
  final bool enableCaption;

  /// Whether to show only related videos from the same channel
  final bool strictRelatedVideos;

  /// Aspect ratio of the player (width / height)
  final double aspectRatio;

  /// Whether to show custom controls overlay
  final bool showCustomControls;

  /// Whether to autoplay the video
  final bool autoPlay;

  /// Whether to hide YouTube player UI elements (big play button, pause overlay, thumbnails)
  final bool hideYouTubeUI;

  PlayerConfig({
    this.showControls = true,
    this.showFullscreenButton = true,
    this.mute = false,
    this.loop = false,
    this.enableCaption = true,
    this.strictRelatedVideos = true,
    this.aspectRatio = 16 / 9,
    this.showCustomControls = false,
    this.autoPlay = false,
    this.hideYouTubeUI = false,
  });

  PlayerConfig copyWith({
    bool? showControls,
    bool? showFullscreenButton,
    bool? mute,
    bool? loop,
    bool? enableCaption,
    bool? strictRelatedVideos,
    double? aspectRatio,
    bool? showCustomControls,
    bool? autoPlay,
    bool? hideYouTubeUI,
  }) {
    return PlayerConfig(
      showControls: showControls ?? this.showControls,
      showFullscreenButton: showFullscreenButton ?? this.showFullscreenButton,
      mute: mute ?? this.mute,
      loop: loop ?? this.loop,
      enableCaption: enableCaption ?? this.enableCaption,
      strictRelatedVideos: strictRelatedVideos ?? this.strictRelatedVideos,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      showCustomControls: showCustomControls ?? this.showCustomControls,
      autoPlay: autoPlay ?? this.autoPlay,
      hideYouTubeUI: hideYouTubeUI ?? this.hideYouTubeUI,
    );
  }
}
