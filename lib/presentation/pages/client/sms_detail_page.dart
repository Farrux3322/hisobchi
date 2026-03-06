import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/application/sent_sms/sent_sms_bloc.dart';
import 'package:hisobchi/application/sent_sms/sent_sms_event.dart';
import 'package:hisobchi/application/sent_sms/sent_sms_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/sent_sms_model.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:shimmer/shimmer.dart';

class SmsDetailPage extends StatefulWidget {
  final int partnerId;
  final String partnerName;

  const SmsDetailPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<SmsDetailPage> createState() => _SmsDetailPageState();
}

class _SmsDetailPageState extends State<SmsDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SentSmsBloc>().add(FetchSentSmsEvent(partnerId: widget.partnerId, isRefresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<SentSmsBloc>().add(FetchSentSmsEvent(partnerId: widget.partnerId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Yuborilgan xabarlar tarixi'),
        leading: BackArrowButton()
      ),
      body: BlocBuilder<SentSmsBloc, SentSmsState>(
        builder: (context, state) {
          if (state.status == Status.loading && state.smsList.isEmpty) {
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: 6,
              separatorBuilder: (context, index) => Gap(12.h),
              itemBuilder: (context, index) => const _SmsShimmer(),
            );
          }

          if (state.status == Status.error && state.smsList.isEmpty) {
            return Center(child: Text(state.errorMessage ?? 'Xatolik yuz berdi'));
          }

          if (state.smsList.isEmpty) {
            return const Center(child: Text('SMSlar topilmadi'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SentSmsBloc>().add(FetchSentSmsEvent(partnerId: widget.partnerId, isRefresh: true));
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w).copyWith(bottom: MediaQuery.of(context).padding.bottom+10),
              itemCount: state.smsList.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (context, index) => Gap(12.h),
              itemBuilder: (context, index) {
                if (index == state.smsList.length) {
                  return const _SmsShimmer();
                }
                final sms = state.smsList[index];
                return _SmsCard(sms: sms);
              },
            ),
          );
        },
      ),
    );
  }
}

class _SmsShimmer extends StatelessWidget {
  const _SmsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                Container(
                  width: 100.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
            Gap(12.h),
            Container(
              width: double.infinity,
              height: 14.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            Gap(6.h),
            Container(
              width: 0.7.sw,
              height: 14.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmsCard extends StatelessWidget {

  final SentSmsModel sms;

  const _SmsCard({required this.sms});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: sms.status == 'success' 
                      ? Colors.green.withValues(alpha:  0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  sms.status == 'success' ? 'Yuborildi': 'Xatolik bo\'ldi',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: sms.status == 'success' ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              Text(
                sms.sentAt,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.colors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Gap(12.h),
          Text(
            sms.message,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.colors.black,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
