import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyVideoWidget extends StatefulWidget {
  final String assetPath;
  final VoidCallback? onVideoCompleted;

  const MyVideoWidget({
    super.key,
    required this.assetPath,
    this.onVideoCompleted,
  });

  @override
  State<MyVideoWidget> createState() => _MyVideoWidgetState();
}

class _MyVideoWidgetState extends State<MyVideoWidget> {
  late VideoPlayerController _controller;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      })
      ..addListener(() {
        if (_controller.value.position >= _controller.value.duration && !_isCompleted) {
          _isCompleted = true;
          if (widget.onVideoCompleted != null) {
            widget.onVideoCompleted!();
          }
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }
}
