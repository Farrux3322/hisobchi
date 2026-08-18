import 'package:flutter/material.dart';
import 'package:ehisob/application/dashboard/dashboard_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/domain/common/data/user_data.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';

class DashboardWelcomeCard extends StatelessWidget {
  final DashboardState state;

  const DashboardWelcomeCard({super.key, required this.state});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Xayrli tong';
    } else if (hour >= 11 && hour < 17) {
      return 'Xayrli kun';
    } else if (hour >= 17 && hour < 22) {
      return 'Xayrli kech';
    } else {
      return 'Xayrli tun';
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'EH';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final result = state.dashboardModel?.result;
    final hasStats = state.status == Status.success && result != null;
    final partnersCount = result?.partners?.partnersCount ?? 0;
    final projectsCount = result?.projects?.projectsCount ?? 0;
    final userName = UserData.name.trim();
    final greeting = _getGreeting();
    final primaryColor = AppTheme.colors.primary;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            const Color(0xFF4F46E5),
            const Color(0xFF2563EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background ambient circular light accents
          Positioned(
            right: -25.w,
            top: -25.h,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -30.w,
            bottom: -30.h,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting & Avatar Row
              Row(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getInitials(userName),
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName.isNotEmpty
                                    ? '$greeting, $userName!'
                                    : 'Xush kelibsiz!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '👋',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Biznesingizning umumiy holati',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (hasStats) ...[
                SizedBox(height: 16.h),
                Divider(
                  color: Colors.white.withValues(alpha: 0.15),
                  height: 1,
                ),
                SizedBox(height: 14.h),

                // Glass Stats Chips Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_alt_rounded,
                        count: '$partnersCount',
                        label: 'Mijozlar',
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.folder_copy_rounded,
                        count: '$projectsCount',
                        label: 'Loyihalar',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14.sp, color: Colors.white),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
