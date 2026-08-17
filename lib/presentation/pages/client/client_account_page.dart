import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ehisob/application/file_upload/file_upload_bloc.dart';
import 'package:ehisob/application/partner/partner_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/features/payment_schedule/data/models/payment_partner_model.dart';
import 'package:ehisob/infrastructure/dto/models/partner/partner_model.dart';
import 'package:ehisob/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/full_screen_photo.dart';
import 'package:ehisob/presentation/components/utils/phone_formatter.dart';
import 'package:ehisob/presentation/components/utils/price_extension.dart';
import 'package:ehisob/presentation/pages/client/client_xisob_kitob.dart';
import 'package:ehisob/presentation/pages/client/report/report_client_show_page.dart';
import 'package:ehisob/presentation/pages/client/widgets/client_delete_dialog.dart';
import 'package:ehisob/presentation/pages/client/sms_menu_page.dart';
import 'package:ehisob/presentation/pages/client/widgets/kirim_bottom_sheet.dart';
import 'package:ehisob/presentation/components/subscription/subscription_guard.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ehisob/domain/common/data/user_data.dart';
import 'package:ehisob/presentation/components/toast/toast.dart';
import 'package:ehisob/infrastructure/services/permission_extension.dart';

import '../../../features/payment_schedule/presentation/pages/installment_list_page.dart';
import 'client_edit_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.partnerModel});

  final PartnerModel partnerModel;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasChanges = false;

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    // main_currency_type_id: 1 = UZS (index 0), 2 = USD (index 1)
    final int initialIndex = (widget.partnerModel.mainCurrencyTypeId == 1) ? 0 : 1;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() => setState(() {}));
    context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.partnerModel.id ?? 0));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 16;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: BlocConsumer<PartnerBloc, PartnerState>(
        listener: (context, state) {
          if (state.statusAdd == Status.success) {
            context.pop(true);
          }
          if (state.statusKirim == Status.success) {
            _markAsChanged();
            context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.partnerModel.id ?? 0));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.colors.white,
              elevation: 0,
              leading: Center(
                child: InkWell(
                  onTap: () => Navigator.pop(context, _hasChanges),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: AppTheme.colors.primary),
                  onPressed: () {
                    if (UserData.isWorkerMode) {
                      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SmsMenuPage(
                          partnerId: widget.partnerModel.id ?? 0,
                          partnerName: widget.partnerModel.name ?? '',
                        ),
                      ),
                    ).then((v) {
                      if (v == true && context.mounted) {
                        _markAsChanged();
                      }
                    });
                  },
                ),
                Gap(10.w),
              ],
              title: Text(
                'Mijoz balansi va hisobi',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.partnerModel.id ?? 0));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                child: Column(
                  children: [
                    // Profile & Client Info Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.colors.primary.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if ((widget.partnerModel.files ?? []).isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageViewerPage(
                                          images: widget.partnerModel.files!
                                              .map((e) => ImageItem(path: e.url ?? '', isNetwork: true))
                                              .toList(),
                                          initialIndex: 0,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Hero(
                                  tag: (widget.partnerModel.files ?? []).isNotEmpty
                                      ? widget.partnerModel.files!.first.url ?? ''
                                      : 'profile_image_${widget.partnerModel.id}',
                                  child: Container(
                                    width: 54.r,
                                    height: 54.r,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.r),
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.colors.primary.withValues(alpha: 0.15),
                                          const Color(0xFF6366F1).withValues(alpha: 0.2),
                                        ],
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: (widget.partnerModel.files ?? []).isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: widget.partnerModel.files!.first.url ?? '',
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const Center(child: CupertinoActivityIndicator(radius: 10)),
                                              errorWidget: (context, url, error) => Center(
                                                child: Text(
                                                  _getInitials(widget.partnerModel.name ?? ''),
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppTheme.colors.primary,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: Text(
                                                _getInitials(widget.partnerModel.name ?? ''),
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.colors.primary,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.partnerModel.name ?? 'Noma\'lum mijoz',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E293B),
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      PhoneFormatter.formatPhoneNumber(widget.partnerModel.phone ?? ''),
                                      style: TextStyle(
                                        fontSize: 12.5.sp,
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit & delete icons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SubscriptionGuard(
                                    child: IconButton(
                                      onPressed: () {
                                        if (!context.hasPermission('partners.edit')) {
                                          Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MultiBlocProvider(
                                              providers: [
                                                BlocProvider(create: (context) => FileUploadBloc(repository: FileUploadRepository())),
                                              ],
                                              child: ClientEditPage(partnerModel: widget.partnerModel),
                                            ),
                                          ),
                                        ).then((v) {
                                          if (v == true && context.mounted) {
                                            _markAsChanged();
                                            context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.partnerModel.id ?? 0));
                                          }
                                        });
                                      },
                                      icon: SvgPicture.asset(AppIcons.edit, width: 20.sp),
                                    ),
                                  ),
                                  if (widget.partnerModel.deletedAt != null)
                                    SubscriptionGuard(
                                      child: IconButton(
                                        onPressed: () {
                                          if (UserData.isWorkerMode) {
                                            Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                                            return;
                                          }
                                          showDeleteDialog(
                                            context,
                                            isDelete: false,
                                            onConfirm: () {
                                              context.read<PartnerBloc>().add(RestoreEvent(id: widget.partnerModel.id ?? 0));
                                              _markAsChanged();
                                            },
                                          );
                                        },
                                        icon: Icon(Icons.restore, color: AppTheme.colors.color9E97FF, size: 22.sp),
                                      ),
                                    ),
                                  SubscriptionGuard(
                                    child: IconButton(
                                      onPressed: () {
                                        final bool isSoftDelete = widget.partnerModel.deletedAt != null;

                                        if (isSoftDelete) {
                                          if (UserData.isWorkerMode) {
                                            Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                                            return;
                                          }
                                        } else {
                                          if (!context.hasPermission('partners.delete')) {
                                            Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                                            return;
                                          }
                                        }

                                        showDeleteDialog(
                                          context,
                                          isDelete: true,
                                          onConfirm: () {
                                            if (widget.partnerModel.deletedAt == null) {
                                              context.read<PartnerBloc>().add(DeleteEvent(id: widget.partnerModel.id ?? 0));
                                            } else {
                                              context.read<PartnerBloc>().add(ForceDeleteEvent(id: widget.partnerModel.id ?? 0));
                                            }
                                            _markAsChanged();
                                          },
                                        );
                                      },
                                      icon: SvgPicture.asset(AppIcons.delete, width: 20.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 14.h),

                          // Quick Action Buttons (Hisobot + Muddatli to'lov)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (!context.hasPermission('report_partner.view')) {
                                      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReportClientShowPage(partnerModel: widget.partnerModel, initialTabIndex: 0),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14.r),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(AppIcons.report, width: 18.sp, height: 18.sp),
                                        SizedBox(width: 8.w),
                                        Flexible(
                                          child: Text(
                                            'Hisobot',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13.5.sp,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (!context.hasPermission('installments.view')) {
                                      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                                      return;
                                    }
                                    final partner = PaymentPartnerModel(
                                      id: widget.partnerModel.id?.toString() ?? '',
                                      name: widget.partnerModel.name ?? '',
                                      phone: widget.partnerModel.phone,
                                    );
                                    pushScreen(context, screen: InstallmentListPage(partner: partner));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFBEB),
                                      borderRadius: BorderRadius.circular(14.r),
                                      border: Border.all(color: const Color(0xFFFDE68A)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.calendar_month_outlined, size: 18.sp, color: const Color(0xFFD97706)),
                                        SizedBox(width: 6.w),
                                        Flexible(
                                          child: Text(
                                            "Muddatli to'lov",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13.5.sp,
                                              color: const Color(0xFF92400E),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Currency TabBar - Modern iOS Segmented Toggle
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _tabController.animateTo(0);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: _tabController.index == 0 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: _tabController.index == 0
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.06),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'UZS Hisob',
                                    style: TextStyle(
                                      color: _tabController.index == 0 ? AppTheme.colors.primary : const Color(0xFF64748B),
                                      fontSize: 13.5.sp,
                                      fontWeight: _tabController.index == 0 ? FontWeight.w800 : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _tabController.animateTo(1);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: _tabController.index == 1 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: _tabController.index == 1
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.06),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'USD Hisob',
                                    style: TextStyle(
                                      color: _tabController.index == 1 ? AppTheme.colors.primary : const Color(0xFF64748B),
                                      fontSize: 13.5.sp,
                                      fontWeight: _tabController.index == 1 ? FontWeight.w800 : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // TabBarView with Currency Data
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final screenHeight = MediaQuery.of(context).size.height;
                        final availableHeight = screenHeight * 0.42;

                        return Container(
                          width: double.infinity,
                          height: availableHeight.clamp(330, 530),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.colors.primary.withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: state.statusIncomeStatement == Status.success
                                ? TabBarView(
                                    controller: _tabController,
                                    children: [
                                      // UZS Tab Content
                                      _buildCurrencyContent(
                                        state: state,
                                        debt: state.incomeStatementModel?.result?.uzsAccount?.debt ?? 0,
                                        credit: state.incomeStatementModel?.result?.uzsAccount?.credit ?? 0,
                                        balance: state.incomeStatementModel?.result?.uzsAccount?.balance ?? 0,
                                        balanceWithInstallment: state.incomeStatementModel?.result?.uzsAccount?.balanceWithInstallment ?? 0,
                                        currencySymbol: 'UZS',
                                        currencyId: 1,
                                      ),
                                      // USD Tab Content
                                      _buildCurrencyContent(
                                        state: state,
                                        debt: state.incomeStatementModel?.result?.usdAccount?.debt ?? 0,
                                        credit: state.incomeStatementModel?.result?.usdAccount?.credit ?? 0,
                                        balance: state.incomeStatementModel?.result?.usdAccount?.balance ?? 0,
                                        balanceWithInstallment: state.incomeStatementModel?.result?.usdAccount?.balanceWithInstallment ?? 0,
                                        currencySymbol: 'USD',
                                        currencyId: 2,
                                      ),
                                    ],
                                  )
                                : _buildShimmerCards(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 12.h),

                    // Bottom action outlined button: Barcha operatsiyalar tarixi
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<PartnerBloc>(),
                                  child: HisobKitobTarixPage(id: widget.partnerModel.id ?? 0, partnerPhone: widget.partnerModel.phone),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_rounded, color: AppTheme.colors.primary, size: 20.sp),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    'Barcha operatsiyalar tarixi',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppTheme.colors.primary,
                                      fontSize: 14.5.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.colors.primary, size: 14.sp),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build Currency Content - Modern & Clean iOS Design
  Widget _buildCurrencyContent({
    required PartnerState state,
    required num debt,
    required num credit,
    required num balance,
    required num balanceWithInstallment,
    required String currencySymbol,
    required int currencyId,
  }) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(14.r),
      child: Column(
        children: [
          // Kirim & Chiqim Cards - Modern Horizontal Row
          Row(
            children: [
              // Kirim Card
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _navigateToHistory(type: 'debt', currencyId: currencyId);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(7.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: SvgPicture.asset(
                                AppIcons.income,
                                width: 16.sp,
                                height: 16.sp,
                                colorFilter: const ColorFilter.mode(Color(0xFF10B981), BlendMode.srcIn),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Kirim',
                              style: TextStyle(
                                color: const Color(0xFF047857),
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                PriceFormatter.priceFormat('$debt'),
                                style: TextStyle(
                                  color: const Color(0xFF065F46),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              currencySymbol,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              // Chiqim Card
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _navigateToHistory(type: 'credit', currencyId: currencyId);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(7.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: SvgPicture.asset(
                                AppIcons.chiqim,
                                width: 16.sp,
                                height: 16.sp,
                                colorFilter: const ColorFilter.mode(Color(0xFFEF4444), BlendMode.srcIn),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Chiqim',
                              style: TextStyle(
                                color: const Color(0xFFB91C1C),
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                PriceFormatter.priceFormat('$credit'),
                                style: TextStyle(
                                  color: const Color(0xFF991B1B),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              currencySymbol,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Qoldiq Card - Hero Balance Container
          (() {
            final Color balanceColor = balance < 0
                ? const Color(0xFFEF4444)
                : (balance == 0 ? const Color(0xFF64748B) : const Color(0xFF10B981));
            final String statusLabel = balance < 0
                ? 'Mijoz qarzdor'
                : (balance > 0 ? 'Mijoz haqdori' : 'Hisob teng');
            final Color statusBg = balance < 0
                ? const Color(0xFFFEF2F2)
                : (balance > 0 ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9));
            final String sign = balance < 0 ? '-' : (balance > 0 ? '+' : '');
            final num bwi = balanceWithInstallment;
            final String bwiSign = bwi < 0 ? '-' : '';

            return Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7.r),
                            decoration: BoxDecoration(
                              color: balanceColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: SvgPicture.asset(
                              AppIcons.balance,
                              width: 16.sp,
                              height: 16.sp,
                              colorFilter: ColorFilter.mode(balanceColor, BlendMode.srcIn),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Joriy qoldiq',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: balanceColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$sign${PriceFormatter.priceFormat('${balance.abs()}')}',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: balanceColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        currencySymbol,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(height: 1, color: const Color(0xFFE2E8F0)),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 14.sp, color: const Color(0xFFD97706)),
                      SizedBox(width: 5.w),
                      Text(
                        "Bo'lib to'lash bilan qoldiq:",
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$bwiSign${PriceFormatter.priceFormat('${bwi.abs()}')} $currencySymbol',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          })(),

          SizedBox(height: 14.h),

          // Primary Actions: + Kirim qilish / - Chiqim qilish
          Row(
            children: [
              Expanded(
                child: SubscriptionGuard(
                  child: GestureDetector(
                    onTap: () async {
                      if (!context.hasPermission('wallets_debt.create')) {
                        Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                        return;
                      }
                      HapticFeedback.mediumImpact();
                      showKirimBottomSheet(context, widget.partnerModel.id ?? 0, true, currencySymbol, widget.partnerModel);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.income,
                            width: 17.sp,
                            height: 17.sp,
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              '+ Kirim ($currencySymbol)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SubscriptionGuard(
                  child: GestureDetector(
                    onTap: () {
                      if (!context.hasPermission('wallets_credit.create')) {
                        Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                        return;
                      }
                      HapticFeedback.mediumImpact();
                      showKirimBottomSheet(context, widget.partnerModel.id ?? 0, false, currencySymbol, widget.partnerModel);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.chiqim,
                            width: 17.sp,
                            height: 17.sp,
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              '- Chiqim ($currencySymbol)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            // Chiqim shimmer card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 100,
                        height: 18,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Kirim shimmer card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 100,
                        height: 18,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Divider(color: Colors.grey[200], thickness: 0.5),
            const SizedBox(height: 6),
            // Balans shimmer card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 100,
                        height: 18,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Divider(color: Colors.grey[200], thickness: 0.5),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  void _navigateToHistory({required String type, required int currencyId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PartnerBloc>(),
          child: HisobKitobTarixPage(id: widget.partnerModel.id ?? 0, initialType: type, initialCurrencyId: currencyId, partnerPhone: widget.partnerModel.phone),
        ),
      ),
    );
  }
}
