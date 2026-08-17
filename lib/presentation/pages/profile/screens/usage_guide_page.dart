import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/tutorial/tutorial_bloc.dart';
import 'package:ehisob/application/tutorial/tutorial_event.dart';
import 'package:ehisob/application/tutorial/tutorial_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/back_button.dart';
import 'package:ehisob/presentation/pages/profile/screens/youtube_video_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class UsageGuidePage extends StatefulWidget {
  const UsageGuidePage({super.key});

  @override
  State<UsageGuidePage> createState() => _UsageGuidePageState();
}

class _UsageGuidePageState extends State<UsageGuidePage> {
  @override
  void initState() {
    super.initState();
    context.read<TutorialBloc>().add(GetTutorialsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foydalanish qo\'llanmasi'), centerTitle: true, leading: BackArrowButton(), backgroundColor: Colors.white),
      body: BlocBuilder<TutorialBloc, TutorialState>(
        builder: (context, state) {
          if (state.status == Status.loading) {
            return const _UsageGuideSkeleton();
          }
          if (state.isNotFound == true) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.colors.red.withValues(alpha: 0.5)),
                    const Gap(16),
                    Text(
                      'Bunday sahifa topilmadi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.colors.black),
                    ),

                  ],
                ),
              ),
            );
          }
          if (state.status == Status.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.colors.red.withValues(alpha: 0.5)),
                    const Gap(16),
                    Text(
                      'Xatolik yuz berdi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.colors.black),
                    ),
                    const Gap(8),
                    Text(
                      state.errorMessage ?? 'Ma\'lumotlarni yuklashda muammo yuzaga keldi',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.colors.gray),
                    ),
                    const Gap(24),
                    ElevatedButton(onPressed: () => context.read<TutorialBloc>().add(GetTutorialsEvent()), child: const Text('Qayta urinish')),
                  ],
                ),
              ),
            );
          }


          if (state.status == Status.success && state.tutorials.isEmpty) {
            return const Center(child: Text('Hozircha qo\'llanmalar mavjud emas'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...state.tutorials.map(
                  (tutorial) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildVideoItem(
                      title: tutorial.title,
                      onTap: () {
                        final videoId = YoutubePlayer.convertUrlToId(tutorial.url);
                        if (videoId != null) {
                          YouTubeVideoBottomSheet.show(context, videoId: videoId, title: tutorial.title);
                        } else {
                          launchUrl(Uri.parse(tutorial.url), mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ),
                ),
                const Gap(24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoItem({required String title, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.colors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                    ),
                    Icon(Icons.play_circle_fill_rounded, color: AppTheme.colors.primary, size: 32),
                  ],
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                      ),
                      const Gap(4),
                      Text(
                        'Video qo\'llanmani ko\'rish',
                        style: TextStyle(fontSize: 13, color: AppTheme.colors.gray, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.colors.gray.withValues(alpha: 0.3), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UsageGuideSkeleton extends StatelessWidget {
  const _UsageGuideSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 4,
        separatorBuilder: (context, index) => const Gap(16),
        itemBuilder: (context, index) => Container(
          height: 92,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
