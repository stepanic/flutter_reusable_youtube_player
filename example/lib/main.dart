import 'package:flutter/material.dart';
import 'package:flutter_reusable_youtube_player/flutter_reusable_youtube_player.dart';
import 'flutterflow_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reusable YouTube Player Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const PlayerDemoPage(),
    );
  }
}

class PlayerDemoPage extends StatefulWidget {
  const PlayerDemoPage({super.key});

  @override
  State<PlayerDemoPage> createState() => _PlayerDemoPageState();
}

class _PlayerDemoPageState extends State<PlayerDemoPage> {
  late ReusableYoutubePlayerController _controller;
  final TextEditingController _urlController = TextEditingController();

  // Sample video IDs for testing
  final List<Map<String, String>> _sampleVideos = [
    {
      'id': 'YVjxNq2vCC4',
      'title': 'Test Unlisted Video',
    },
    {
      'id': 'dQw4w9WgXcQ',
      'title': 'Rick Astley - Never Gonna Give You Up',
    },
    {
      'id': 'jNQXAC9IVRw',
      'title': 'Me at the zoo',
    },
    {
      'id': 'kJQP7kiw5Fk',
      'title': 'Luis Fonsi - Despacito',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = ReusableYoutubePlayerController(
      videoId: _sampleVideos[0]['id']!,
      config: PlayerConfig(
        autoPlay: false,
        showCustomControls: true,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _loadVideo(String videoId) {
    _controller.loadVideo(videoId);
  }

  void _loadVideoFromUrl() {
    final url = _urlController.text.trim();
    final videoId = YoutubeHelpers.extractVideoId(url);

    if (videoId != null && YoutubeHelpers.isValidVideoId(videoId)) {
      _loadVideo(videoId);
      _urlController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loading video: $videoId')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid YouTube URL or video ID')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reusable YouTube Player Demo'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          // Button to open FlutterFlow example
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'FlutterFlow Example',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FlutterFlowExamplePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // YouTube Player
            ReusableYoutubePlayer(
              controller: _controller,
              showCustomControls: true,
            ),

            const SizedBox(height: 16),

            // URL Input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Load Video by URL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            hintText: 'Enter YouTube URL or video ID',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _loadVideoFromUrl,
                        child: const Text('Load'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sample Videos
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Sample Videos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._sampleVideos.map((video) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Image.network(
                          YoutubeHelpers.getThumbnailUrl(
                            video['id']!,
                            quality: ThumbnailQuality.medium,
                          ),
                          width: 120,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                        title: Text(video['title']!),
                        subtitle: Text('ID: ${video['id']}'),
                        trailing: const Icon(Icons.play_arrow),
                        onTap: () => _loadVideo(video['id']!),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Player Controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Player Controls',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _controller.play(),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _controller.pause(),
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _controller.toggleMute(),
                        icon: Icon(
                          _controller.isMuted
                              ? Icons.volume_off
                              : Icons.volume_up,
                        ),
                        label: Text(_controller.isMuted ? 'Unmute' : 'Mute'),
                      ),
                    ],
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
