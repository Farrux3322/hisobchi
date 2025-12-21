
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/application/notification/notification_bloc.dart';
import 'package:hisobchi/domain/enums/bloc_status.dart';
import 'package:hisobchi/infrastructure/models/notification_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/empty_page.dart';

import '../../components/basic_widgets.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      length: 2,
      initialIndex: 0,
      animationDuration: const Duration(seconds: 0),
      vsync: this,
    );

    context.read<NotificationBloc>().add(
          GetNotifications(status: tabController.index + 1),
        );

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        context.read<NotificationBloc>().add(
              GetNotifications(status: tabController.index + 1),
            );
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),

            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: Offset(0, 1),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(50, 50, 93, 0.25),
                    blurRadius: 100,
                    spreadRadius: -20,
                    offset: Offset(0, 50),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                    blurRadius: 60,
                    spreadRadius: -30,
                    offset: Offset(0, 30),
                  )
                ],
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back,color: Colors.black,),
          ),
        ),

        title: Text('Yangiliklar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16.sp, letterSpacing: 0.5)),
        centerTitle: true,
        actions: [
          // IconBgWidget(
          //     icon: AppIcons.checkReadOutlined,
          //     borderColor: Colors.white.withValues(alpha: 0.1),
          //     onTap: () {
          //       context.read<NotificationBloc>().add(ReadAllNotifications(status: tabController.index + 1));
          //     },
          //     iconColor: AppTheme.colors.white),
          Gap(15.w),
        ],
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.h),
            child: Padding(
              padding: EdgeInsets.only(left: 15.w, right: 15.w),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TabBar(
                  controller: tabController,
                  isScrollable: false,
                  physics: const BouncingScrollPhysics(),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  splashBorderRadius: BorderRadius.circular(10.r),
                  indicator: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(8.r)),
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                  labelStyle: AppTheme.data.textTheme.titleSmall?.copyWith(
                    fontSize: 14.h,
                    fontWeight: FontWeight.w400,
                  ),
                  unselectedLabelStyle: AppTheme.data.textTheme.titleSmall?.copyWith(
                    fontSize: 14.h,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: [
                    Tab(text: "Yangiliklar"),
                    Tab(text: "Shaxsiy"),
                  ],
                ),
              ),
            )),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 30.5.h, left: 15.w, right: 15.w),
        child: BlocBuilder<AppManagerCubit, AppManagerState>(
          builder: (context, appState) {
            // final isGuest = appState.isGuest;

            return TabBarView(
              controller: tabController,
              children: [
                _buildNotificationList(
                  context,
                  selector: (state) => state.newsNotifications,
                  statusSelector: (state) => state.statusGet,
                ),

                  _buildNotificationList(
                    context,
                    selector: (state) => state.personalNotifications,
                    statusSelector: (state) => state.statusGet,
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context, {
    required List<NotificationModel> Function(NotificationState) selector,
    required BlocStatus Function(NotificationState) statusSelector,
  }) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final notifications = selector(state);
        final status = statusSelector(state);
        if (status == BlocStatus.loading) {
          return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));
        }
        if (status == BlocStatus.error) {
          return Center(child: Text(state.errorMessage ?? 'errors.error'.tr()));
        }
        if (status == BlocStatus.empty) {
          return EmptyPage(
              text1: (tabController.index == 0 ? 'notifications.emptyNewsTitle'.tr() : 'notifications.emptyPersonalTitle'.tr()),
              text2: (tabController.index == 0 ? 'notifications.emptyNewsSubtitle'.tr() : 'notifications.emptyPersonalSubtitle'.tr()));
        }
        if (status == BlocStatus.success) {
          return SafeArea(
            key: ValueKey(tabController.index),
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => Gap(8.h),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return GestureDetector(
                  onTap: () {
                    if (!(notification.viewed ?? true)) {
                      context.read<NotificationBloc>().add(ReadNotification(id: notification.id ?? 0));
                    }
                    // context.push("${Routes.root.path}${Routes.home.path}${Routes.notification.path}${Routes.notificationDetails.path}", extra: notification); // Pass the specific notification object
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                    color: const Color.fromRGBO(32, 37, 48, 1),
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppTheme.colors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.r),
                              child: SvgPicture.asset(
                                AppIcons.notificationDualtone,
                                colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
                                height: 24.h,
                                width: 24.w,
                              ),
                            ),
                          ),
                          Gap(12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title ?? "",
                                  style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.white, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: 15.sp),
                                ),
                                Gap(4.h),
                                Text(
                                  notification.body ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.data.textTheme.labelSmall?.copyWith(color: AppTheme.colors.gray, fontWeight: FontWeight.w400, letterSpacing: 0.5, fontSize: 14.sp),
                                ),
                              ],
                            ),
                          ),
                          Gap(10.w),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Date Text
                              Text(
                                notification.date ?? "",
                                style: AppTheme.data.textTheme.labelLarge?.copyWith(color: AppTheme.colors.gray, fontWeight: FontWeight.w400, letterSpacing: 0.5, fontSize: 12.sp),
                              ),
                              Gap(8.h),
                              if (!(notification.viewed ?? true))
                                Container(
                                  height: 8.r,
                                  width: 8.r,
                                  decoration: BoxDecoration(
                                    color: AppTheme.colors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
