import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyVideoWidget extends StatefulWidget {
  final String assetPath; // Pass the video asset path to the widget

  const MyVideoWidget({super.key, required this.assetPath});

  @override
  State<MyVideoWidget> createState() => _MyVideoWidgetState();
}

class _MyVideoWidgetState extends State<MyVideoWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, VideoPlayerValue value, child) {
                      return Text(
                        _formatDuration(value.position) +
                            ' / ' +
                            _formatDuration(value.duration),
                        style: const TextStyle(fontSize: 14),
                      );
                    },
                  ),
                ],
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }

  String _formatDuration(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(position.inMinutes.remainder(60));
    final seconds = twoDigits(position.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
