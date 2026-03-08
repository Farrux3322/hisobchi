import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/full_screen_photo.dart';
import 'package:hisobchi/presentation/components/utils/phone_formatter.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:hisobchi/presentation/pages/client/client_xisob_kitob.dart';
import 'package:hisobchi/presentation/pages/client/report/report_client_show_page.dart';
import 'package:hisobchi/presentation/pages/client/widgets/client_delete_dialog.dart';
import 'package:hisobchi/presentation/pages/client/sms_setting_page.dart';
import 'package:hisobchi/presentation/pages/client/sms_detail_page.dart';
import 'package:hisobchi/presentation/pages/client/widgets/kirim_bottom_sheet.dart';
import 'package:hisobchi/presentation/components/subscription/subscription_guard.dart';
import 'package:hisobchi/utils/url_louncher_util.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  void initState() {
    super.initState();
    // main_currency_type_id: 1 = UZS (index 0), 2 = USD (index 1)
    final int initialIndex = (widget.partnerModel.mainCurrencyTypeId == 1) ? 0 : 1;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.partnerModel.id ?? 0));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _iconButton(String icon, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(icon, height: 24, width: 24, colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)),
      ),
    );
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
                // IconButton(
                //   icon: SvgPicture.asset(AppIcons.smsHistory),
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => SmsDetailPage(
                //           partnerId: widget.partnerModel.id ?? 0,
                //           partnerName: widget.partnerModel.name ?? 'SMS Tarixi',
                //         ),
                //       ),
                //     );
                //   },
                // ),
                IconButton(
                  icon: Icon(Icons.settings, color: AppTheme.colors.primary),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SmsSettingPage(partnerId: widget.partnerModel.id ?? 0))).then((v) {
                      if (v == true && context.mounted) {
                        _markAsChanged();
                      }
                    });
                  },
                ),
                Gap(10.w),
              ],
              title: Text(
                'Hisob-kitob',
                style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.partnerModel.id ?? 0));
              },
              child: SingleChildScrollView(
                // physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                child: Column(
                  children: [
                    // Profile card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
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
                                        builder: (context) => ImageViewerPage(images: widget.partnerModel.files!.map((e) => ImageItem(path: e.url ?? '', isNetwork: true)).toList(), initialIndex: 0),
                                      ),
                                    );
                                  }
                                },
                                child: Hero(
                                  tag: (widget.partnerModel.files ?? []).isNotEmpty ? widget.partnerModel.files!.first.url ?? '' : 'profile_image',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: CachedNetworkImage(
                                      imageUrl: (widget.partnerModel.files ?? []).isNotEmpty
                                          ? widget.partnerModel.files?.first.url ?? ''
                                          : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEM7h-3_xucDg6PXVOyOxh9QOnMkS0dvydRA&s',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => CupertinoActivityIndicator(),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.partnerModel.name ?? 'Noma\'lum', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(PhoneFormatter.formatPhoneNumber(widget.partnerModel.phone ?? ''), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              // edit and delete icons
                              Row(
                                children: [
                                  SubscriptionGuard(
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MultiBlocProvider(
                                              providers: [
                                                BlocProvider(create: (context) => FileUploadBloc(repository: FileUploadRepository())),
                                                // We don't need to provide PartnerBloc here as it's already in the context
                                              ],
                                              child: ClientEditPage(partnerModel: widget.partnerModel),
                                            ),
                                          ),
                                        ).then((v) {
                                          if (v == true && context.mounted) {
                                            _markAsChanged();
                                            // Refresh partner data if needed
                                            context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.partnerModel.id ?? 0));
                                          }
                                        });
                                      },
                                      icon: SvgPicture.asset(AppIcons.edit),
                                    ),
                                  ),
                                  if (widget.partnerModel.deletedAt != null)
                                    SubscriptionGuard(
                                      child: IconButton(
                                        onPressed: () {
                                          showDeleteDialog(
                                            context,
                                            isDelete: false,
                                            onConfirm: () {
                                              context.read<PartnerBloc>().add(RestoreEvent(id: widget.partnerModel.id ?? 0));
                                              _markAsChanged();
                                            },
                                          );
                                        },
                                        icon: Icon(Icons.restore, color: AppTheme.colors.color9E97FF),
                                      ),
                                    ),
                                  SubscriptionGuard(
                                    child: IconButton(
                                      onPressed: () {
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
                                      icon: SvgPicture.asset(AppIcons.delete),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // small action row (Hisobot + icons)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => ReportClientShowPage(partnerModel: widget.partnerModel)));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.colors.white,
                                      border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.5)),
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(AppIcons.report),
                                        SizedBox(width: 10),
                                        Text('Hisobot', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _iconButton(
                                AppIcons.smsHistory,
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SmsDetailPage(
                                        partnerId: widget.partnerModel.id ?? 0,
                                        partnerName: widget.partnerModel.name ?? 'SMS Tarixi',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _iconButton(
                                AppIcons.phoneSms,
                                onTap: () async {
                                  try {
                                    await launchSms(widget.partnerModel.phone ?? '');
                                  } catch (e) {
                                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              _iconButton(
                                AppIcons.phone,
                                onTap: () async {
                                  try {
                                    await launchPhone(widget.partnerModel.phone ?? '');
                                  } catch (e) {
                                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Currency TabBar - Professional Design
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],

                        borderRadius: BorderRadius.circular(10.r),
                      ),

                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppTheme.colors.primary,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: AppTheme.colors.white,
                        unselectedLabelColor: const Color(0xFF64748B),
                        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                        unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                        indicatorPadding: EdgeInsets.all(4.w),
                        tabs: const [
                          Tab(child: Text('UZS Hisob')),
                          Tab(child: Text('USD Hisob')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // TabBarView with Currency Data
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final screenHeight = MediaQuery.of(context).size.height;
                        final availableHeight = screenHeight * 0.37; // Responsive height

                        return Container(
                          width: double.infinity,
                          height: availableHeight.clamp(300, 500), // Min 300, Max 500
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
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
                                        currencySymbol: 'UZS',
                                        currencyId: 1,
                                      ),
                                      // USD Tab Content
                                      _buildCurrencyContent(
                                        state: state,
                                        debt: state.incomeStatementModel?.result?.usdAccount?.debt ?? 0,
                                        credit: state.incomeStatementModel?.result?.usdAccount?.credit ?? 0,
                                        balance: state.incomeStatementModel?.result?.usdAccount?.balance ?? 0,
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

                    const SizedBox(height: 8),

                    // Bottom action outlined button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
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
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: AppTheme.colors.primary, width: .5),
                          backgroundColor: AppTheme.colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Kirim-chiqim tarixlari',
                              style: TextStyle(color: AppTheme.colors.primary, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: AppTheme.colors.primary),
                          ],
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

  // Build Currency Content - Minimalist & Clean Design
  Widget _buildCurrencyContent({required PartnerState state, required num debt, required num credit, required num balance, required String currencySymbol, required int currencyId}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = screenWidth * 0.035; // Responsive padding
    final iconPadding = screenWidth * 0.02; // Responsive icon padding
    final iconSize = screenWidth * 0.05; // Responsive icon size

    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        children: [
          // Kirim & Chiqim Cards - Horizontal Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final cardSpacing = availableWidth * 0.03;

              return Row(
                children: [
                  // Kirim Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToHistory(type: 'debt', currencyId: currencyId),
                      child: Container(
                        padding: EdgeInsets.all(cardPadding.clamp(10, 16)),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3CC293).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF3CC293).withValues(alpha: 0.25), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(iconPadding.clamp(6, 10)),
                                  decoration: BoxDecoration(color: const Color(0xFF3CC293).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                  child: SvgPicture.asset(
                                    AppIcons.income,
                                    width: iconSize.clamp(20, 26),
                                    height: iconSize.clamp(20, 26),
                                    colorFilter: const ColorFilter.mode(Color(0xFF3CC293), BlendMode.srcIn),
                                  ),
                                ),
                                SizedBox(width: availableWidth * 0.02),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Kirim',
                                      style: TextStyle(color: Color(0xFF3CC293), fontSize: 16.sp, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenWidth * 0.025),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  PriceFormatter.priceFormat('$debt'),
                                  style: TextStyle(color: debt == 0 ? Colors.black : Color(0xFF1E293B), fontSize: 16.sp, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                                Text(
                                  currencySymbol,
                                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500, color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: cardSpacing),

                  // Chiqim Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToHistory(type: 'credit', currencyId: currencyId),
                      child: Container(
                        padding: EdgeInsets.all(cardPadding.clamp(10, 16)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDE5050).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDE5050).withValues(alpha: 0.25), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(iconPadding.clamp(6, 10)),
                                  decoration: BoxDecoration(color: const Color(0xFFDE5050).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                  child: SvgPicture.asset(
                                    AppIcons.chiqim,
                                    width: iconSize.clamp(20, 26),
                                    height: iconSize.clamp(20, 26),
                                    colorFilter: const ColorFilter.mode(Color(0xFFDE5050), BlendMode.srcIn),
                                  ),
                                ),
                                SizedBox(width: availableWidth * 0.02),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Chiqim',
                                      style: TextStyle(color: Color(0xFFDE5050), fontSize: 16.sp, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenWidth * 0.025),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  PriceFormatter.priceFormat('$credit'),
                                  style: TextStyle(color: credit == 0 ? Colors.black : Color(0xFF1E293B), fontSize: 16.sp, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                                Text(
                                  currencySymbol,
                                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500, color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: screenWidth * 0.04),

          // Qoldiq Card - Elegant Minimalist
          // Senior approach: Conditional colors based on balance
          (() {
            final Color balanceColor = balance < 0 ? AppTheme.colors.colorDE5050 : (balance == 0 ? Colors.black : AppTheme.colors.color3CC293);
            final String? subtitle = balance < 0 ? 'Hamkor qarzi' : (balance > 0 ? 'Hamkor haqqi' : null);
            final String sign = balance < 0 ? '-' : (balance > 0 ? '+' : '');
            return Container(
              padding: EdgeInsets.all(cardPadding.clamp(12, 18)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: balance == 0 ? Colors.black.withValues(alpha: 0.25) : balanceColor.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(iconPadding.clamp(8, 12)),
                    decoration: BoxDecoration(
                      color: balance == 0 ? Colors.black.withValues(alpha: 0.8) : balanceColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [BoxShadow(color: balance == 0 ? Colors.black.withValues(alpha: 0.1) : balanceColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: SvgPicture.asset(AppIcons.balance, width: iconSize.clamp(20, 26), height: iconSize.clamp(20, 26), colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                  ),
                  SizedBox(width: screenWidth * 0.035),
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Qoldiq',
                              style: TextStyle(color: balanceColor, fontSize: 16.sp, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                            ),
                            if (subtitle != null) ...[
                              Gap(4.h),
                              Text(
                                subtitle,
                                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: balanceColor.withValues(alpha: 0.9)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$sign ${PriceFormatter.priceFormat('${balance.abs()}')}',
                              style: TextStyle(color: balanceColor, fontSize: 16.sp, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              currencySymbol,
                              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.black),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          })(),
          const SizedBox(height: 16),

          // Minimal Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey.withValues(alpha: 0.1), Colors.grey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.1)])),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          LayoutBuilder(
            builder: (context, constraints) {
              final buttonPadding = constraints.maxWidth * 0.04;
              final iconSize = constraints.maxWidth * 0.09;

              return Row(
                children: [
                  Expanded(
                    child: SubscriptionGuard(
                      child: GestureDetector(
                        onTap: () async {
                          showKirimBottomSheet(context, widget.partnerModel.id ?? 0, true, currencySymbol,widget.partnerModel);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.025, horizontal: buttonPadding),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF3CC293), Color(0xFF34B082)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: const Color(0xFF3CC293).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(AppIcons.income, width: iconSize.clamp(18, 22), height: iconSize.clamp(18, 22), colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                              SizedBox(width: constraints.maxWidth * 0.02),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Kirim',
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                      children: [
                                        TextSpan(
                                          text: ' ($currencySymbol)',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: constraints.maxWidth * 0.03),
                  Expanded(
                    child: SubscriptionGuard(
                      child: GestureDetector(
                        onTap: () {
                          showKirimBottomSheet(context, widget.partnerModel.id ?? 0, false, currencySymbol,widget.partnerModel);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.025, horizontal: buttonPadding),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFDE5050), Color(0xFFC54444)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: const Color(0xFFDE5050).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(AppIcons.chiqim, width: iconSize.clamp(18, 22), height: iconSize.clamp(18, 22), colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                              SizedBox(width: constraints.maxWidth * 0.02),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Chiqim',
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                      children: [
                                        TextSpan(
                                          text: ' ($currencySymbol)',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                      ],
                                    ),
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
              );
            },
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
