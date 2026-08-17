import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeFullScreenPlayerPage extends StatefulWidget {
  final String videoId;
  final Duration startAt;

  const YouTubeFullScreenPlayerPage({super.key, required this.videoId, this.startAt = Duration.zero});

  @override
  State<YouTubeFullScreenPlayerPage> createState() => _YouTubeFullScreenPlayerPageState();
}

class _YouTubeFullScreenPlayerPageState extends State<YouTubeFullScreenPlayerPage> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    // Force portrait for vertical video experience
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: true,
        enableCaption: true,
        startAt: widget.startAt.inSeconds,
        hideControls: false,
        controlsVisibleAtStart: true,
      ),
    )..addListener(() {
        if (_controller.value.isReady && !_isPlayerReady) {
          if (mounted) setState(() => _isPlayerReady = true);
        }
      });
  }

  @override
  void dispose() {
    // Restore default orientations when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 9 / 16, // Force vertical aspect ratio like Shorts
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppTheme.colors.primary,
              progressColors: ProgressBarColors(
                playedColor: AppTheme.colors.primary,
                handleColor: AppTheme.colors.primary,
              ),
              onEnded: (metaData) {
                Navigator.pop(context);
              },
            ),
          ),
          
          // Immersive overlay for close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _controller.value.position),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),

          if (!_isPlayerReady)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
