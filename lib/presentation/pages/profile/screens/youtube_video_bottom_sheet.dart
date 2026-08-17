import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../routes/entity/routes.dart';

class YouTubeVideoBottomSheet extends StatefulWidget {
  final String videoId;
  final String title;

  const YouTubeVideoBottomSheet({super.key, required this.videoId, required this.title});

  static Future<void> show(BuildContext context, {required String videoId, required String title}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => YouTubeVideoBottomSheet(videoId: videoId, title: title),
    );
  }

  @override
  State<YouTubeVideoBottomSheet> createState() => _YouTubeVideoBottomSheetState();
}

class _YouTubeVideoBottomSheetState extends State<YouTubeVideoBottomSheet> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: true,
        enableCaption: true,
        showLiveFullscreenButton: true, // Enable button to intercept it
      ),
    )..addListener(() {
        if (_controller.value.isReady && !_isPlayerReady) {
          if (mounted) setState(() => _isPlayerReady = true);
        }
        
        // Intercept fullscreen button and navigate to separate page
        if (_controller.value.isFullScreen) {
          final currentPosition = _controller.value.position;
          _controller.pause();
          _controller.toggleFullScreenMode(); // Revert internal state

          context
              .pushNamed<Duration>(
                Routes.videoPlayer.name,
                extra: {'videoId': widget.videoId, 'startAt': currentPosition},
              )
              .then((newPosition) {
                if (newPosition != null) {
                  _controller.seekTo(newPosition);
                  _controller.play();
                }
              });
        }
      });
  }

  @override
  void dispose() {
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(12),
          _buildHandle(),
          _buildHeader(),
          _buildPlayer(),
          const Gap(24),
          _buildInfoSection(),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(color: AppTheme.colors.gray.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video qo\'llanma',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: AppTheme.colors.black.withValues(alpha: 0.5), letterSpacing: 1),
                ),
                const Gap(4),
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: AppTheme.colors.gray),
            style: IconButton.styleFrom(backgroundColor: AppTheme.colors.gray.withValues(alpha: 0.1), padding: const EdgeInsets.all(8)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppTheme.colors.primary,
                progressColors: ProgressBarColors(playedColor: AppTheme.colors.primary, handleColor: AppTheme.colors.primary),
              ),
              if (!_isPlayerReady)
                Container(
                  color: const Color(0xFFF1F5F9),
                  child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary), strokeWidth: 2)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.colors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.colors.primary, size: 20.sp),
            const Gap(12),
            Expanded(
              child: Text(
                'Video darslik orqali ilovaning barcha imkoniyatlarini o\'rganishingiz mumkin.',
                style: TextStyle(fontSize: 11.sp, color: AppTheme.colors.black.withValues(alpha: 0.7), fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
