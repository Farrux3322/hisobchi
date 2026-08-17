import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/notification/notification_bloc.dart';
import 'package:ehisob/domain/enums/bloc_status.dart';
import 'package:ehisob/infrastructure/dto/models/notification/notification_model.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/back_button.dart';
import 'package:ehisob/presentation/components/empty_page.dart';
import 'package:shimmer/shimmer.dart';
import 'notification_detail.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchInitial() {
    context.read<NotificationBloc>().add(const GetNotifications());
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NotificationBloc>().add(const GetNotifications(isLoadMore: true));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50
      appBar: _buildAppBar(context),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              _fetchInitial();
            },
            color: AppTheme.colors.primary,
            child: _buildBody(state),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      leadingWidth: 72.w,
      leading: BackArrowButton(),
      title: Text(
        'Bildirishnomalar',
        style: TextStyle(
          color: const Color(0xFF1E293B),
          fontWeight: FontWeight.w800,
          fontSize: 18.sp,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            final hasUnread = state.notifications.any((n) => !(n.isRead ?? true));
            return IconButton(
              onPressed: hasUnread
                  ? () {
                      context.read<NotificationBloc>().add(const ReadAllNotifications());
                    }
                  : null,
              icon: Icon(
                Icons.done_all_rounded,
                color: hasUnread ? AppTheme.colors.primary : Colors.grey.shade400,
                size: 24.sp,
              ),
              tooltip: 'Hammasini o\'qilgan deb belgilash',
            );
          },
        ),
        SizedBox(width: 12.w),
      ],
    );
  }

  Widget _buildBody(NotificationState state) {
    if (state.status == BlocStatus.loading && state.notifications.isEmpty) {
      return _buildShimmerLoading();
    } else if (state.status == BlocStatus.error && state.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48.sp, color: Colors.red.shade300),
              SizedBox(height: 16.h),
              Text(
                state.errorMessage ?? 'Xatolik yuz berdi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Colors.blueGrey.shade700),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _fetchInitial,
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      );
    } else if (state.notifications.isEmpty && state.status == BlocStatus.success) {
      return EmptyPage(
        text1: 'Bildirishnomalar yo\'q',
        text2: 'Sizda hozircha yangi bildirishnomalar mavjud emas',
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
        itemCount: state.hasReachedMax ? state.notifications.length : state.notifications.length + 1,
        itemBuilder: (context, index) {
          if (index >= state.notifications.length) {
            return _buildLoader();
          }
          final item = state.notifications[index];
          return _buildNotificationCard(item);
        },
      );
    }
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            height: 90.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationItemModel item) {
    final bool isUnread = !(item.isRead ?? true);
    final detail = item.notification;
    final createdAt = item.createdAt != null ? DateTime.parse(item.createdAt!) : DateTime.now();
    final formattedDate = DateFormat('HH:mm').format(createdAt);
    final formattedFullDate = DateFormat('dd.MM.yyyy').format(createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isUnread ? AppTheme.colors.primary.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            if (isUnread) {
              context.read<NotificationBloc>().add(ReadNotification(id: item.id ?? 0));
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetail(item: item),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIcon(isUnread),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              detail?.title ?? "Xabarnoma",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                color: const Color(0xFF1E293B),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        detail?.body ?? "",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Text(
                            formattedFullDate,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isUnread) ...[
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppTheme.colors.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'YANGI',
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isUnread) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: isUnread ? AppTheme.colors.primary.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isUnread ? AppTheme.colors.primary.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Icon(
        isUnread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
        color: isUnread ? AppTheme.colors.primary : const Color(0xFF94A3B8),
        size: 20.sp,
      ),
    );
  }

  Widget _buildLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }
}
