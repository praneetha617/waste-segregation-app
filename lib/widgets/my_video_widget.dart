import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _inFullscreen = false;
  bool _completionNotified = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) async {
        if (!mounted) return;
        setState(() => _initialized = true);
        await _controller.play(); // autoplay inline
      })
      ..addListener(_progressListener);
  }

  void _progressListener() {
    final v = _controller.value;
    if (!v.isInitialized) return;
    if (v.duration > Duration.zero &&
        v.position >= v.duration &&
        !_completionNotified) {
      _completionNotified = true;
      widget.onVideoCompleted?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_progressListener);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFullscreen() async {
    if (!_initialized) return;

    final wasPlaying = _controller.value.isPlaying;

    
    // Hiding the inline renderer while the fullscreen route is on top.
    setState(() => _inFullscreen = true);

    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenVideoShared(
          controller: _controller,
          wasPlaying: wasPlaying,
        ),
      ),
    );

    if (!mounted) return;

    // Show inline renderer again
    setState(() => _inFullscreen = false);

    //  pause on orientation change, nudge to resume if it was playing.
    if (wasPlaying && !_controller.value.isPlaying) {
      await _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // If in fullscreen mode, return an empty widget to avoid rendering the video inline.
    // This is to prevent the video from being displayed twice (once inline and once fullscreen).
    if (_inFullscreen) {
      return const SizedBox.expand();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        //  Render the video.
        VideoPlayer(_controller),

        // Tap anywhere to toggle play/pause
        GestureDetector(
          onTap: () {
            final playing = _controller.value.isPlaying;
            setState(() => playing ? _controller.pause() : _controller.play());
          },
          behavior: HitTestBehavior.opaque,
        ),

        // Minimal controls (bottom-right)
        Positioned(
          right: 8,
          bottom: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Play/Pause',
                onPressed: () {
                  final playing = _controller.value.isPlaying;
                  setState(() => playing ? _controller.pause() : _controller.play());
                },
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Fullscreen',
                onPressed: _openFullscreen,
                icon: const Icon(Icons.fullscreen, size: 32, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Fullscreen route that REUSES the same VideoPlayerController (instant entry).
class _FullScreenVideoShared extends StatefulWidget {
  final VideoPlayerController controller;
  final bool wasPlaying;

  const _FullScreenVideoShared({
    required this.controller,
    required this.wasPlaying,
  });

  @override
  State<_FullScreenVideoShared> createState() => _FullScreenVideoSharedState();
}

class _FullScreenVideoSharedState extends State<_FullScreenVideoShared> {
  @override
  void initState() {
    super.initState();

    // Enter true fullscreen + landscape
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // If the video was playing, resume it
    // after the fullscreen route is pushed.
    if (widget.wasPlaying) {
      // schedule after a tiny delay so orientation settles
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted && !widget.controller.value.isPlaying) {
          widget.controller.play();
        }
      });
    }
  }

  @override
  void dispose() {
    // Restore portrait + system UI
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.controller.value;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Render the video in fullscreen
          // Use FittedBox to cover the entire screen
          SizedBox.expand(
            child: v.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: v.size.width,
                      height: v.size.height,
                      child: VideoPlayer(widget.controller),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          // Close button
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

