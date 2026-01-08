import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/utils/phone_formatter.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:hisobchi/presentation/pages/client/client_xisob_kitob.dart';
import 'package:hisobchi/presentation/pages/client/widgets/client_delete_dialog.dart';
import 'package:hisobchi/presentation/pages/client/widgets/client_edit_bottom_sheet.dart';
import 'package:hisobchi/presentation/pages/client/widgets/kirim_bottom_sheet.dart';
import 'package:hisobchi/utils/url_louncher_util.dart';
import 'package:shimmer/shimmer.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.partnerModel});

  final PartnerModel partnerModel;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        decoration: BoxDecoration(color: AppTheme.colors.white,
            border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
            borderRadius: BorderRadius.circular(10)),        child: SvgPicture.asset(icon, height: 24, width: 24, colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 16;
    return BlocConsumer<PartnerBloc, PartnerState>(
      listener: (context, state) {
        if (state.statusAdd == Status.success) {
          context.pop(true);
        }
        if (state.statusKirim == Status.success) {
          context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.partnerModel.id ?? 0));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            leading: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Color.fromRGBO(255, 255, 255, 0.1), blurRadius: 1, spreadRadius: 0, offset: Offset(0, 1)),
                    BoxShadow(color: Color.fromRGBO(50, 50, 93, 0.25), blurRadius: 100, spreadRadius: -20, offset: Offset(0, 50)),
                    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 60, spreadRadius: -30, offset: Offset(0, 30)),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            title: Text('Hisob-kitob', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
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
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: CachedNetworkImage(
                                        imageUrl: (widget.partnerModel.files ?? []).isNotEmpty
                                            ? widget.partnerModel.files?.first ?? ''
                                            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEM7h-3_xucDg6PXVOyOxh9QOnMkS0dvydRA&s',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => CupertinoActivityIndicator(),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
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
                                        IconButton(
                                          onPressed: () {
                                            EditClientBottomSheet.show(
                                              context,
                                              partnerModel: widget.partnerModel,
                                              onSubmit: (name, phone, additionalPhone, imageId) {
                                                context.read<PartnerBloc>().add(
                                                  UpdateEvent(
                                                    data: {
                                                      'name': name,
                                                      'phone': phone,
                                                      'additional_phone': additionalPhone,
                                                      if (imageId != null) 'photo': [imageId],
                                                    },
                                                    id: widget.partnerModel.id ?? 0,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon: SvgPicture.asset(AppIcons.edit),
                                        ),
                                        if (widget.partnerModel.deletedAt != null)
                                          IconButton(
                                            onPressed: () {
                                              showDeleteDialog(
                                                context,
                                                isDelete: false,
                                                onConfirm: () {
                                                  context.read<PartnerBloc>().add(RestoreEvent(id: widget.partnerModel.id ?? 0));
                                                },
                                              );
                                            },
                                            icon: Icon(Icons.restore, color: AppTheme.colors.color9E97FF),
                                          ),
                                        IconButton(
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
                                              },
                                            );
                                          },
                                          icon: SvgPicture.asset(AppIcons.delete),
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
                                      child: Container(

                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                        decoration: BoxDecoration(color: AppTheme.colors.white,
                                            border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.5)),
                                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                                            borderRadius: BorderRadius.circular(10)),
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
                                    const SizedBox(width: 8),
                                    _iconButton(
                                      AppIcons.phoneSms,
                                      onTap: () async {
                                        try {
                                          await launchSms(widget.partnerModel.phone ?? '');
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
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
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
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
                            decoration: BoxDecoration(color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],

                                borderRadius: BorderRadius.circular(10.r)),

                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: AppTheme.colors.primary.withValues(alpha: 0.8),
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
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 2.6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
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
                                        ),
                                        // USD Tab Content
                                        _buildCurrencyContent(
                                          state: state,
                                          debt: state.incomeStatementModel?.result?.usdAccount?.debt ?? 0,
                                          credit: state.incomeStatementModel?.result?.usdAccount?.credit ?? 0,
                                          balance: state.incomeStatementModel?.result?.usdAccount?.balance ?? 0,
                                          currencySymbol: 'USD',
                                        ),
                                      ],
                                    )
                                  : _buildShimmerCards(),
                            ),
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
                                      child: HisobKitobTarixPage(id: widget.partnerModel.id ?? 0),
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: AppTheme.colors.primary, width: 1.5),
                                backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.04),
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
                ],
              ),
              if (state.statusAdd == Status.loading) Loading(),
            ],
          ),
        );
      },
    );
  }

  // Build Currency Content - Minimalist & Clean Design
  Widget _buildCurrencyContent({required PartnerState state, required num debt, required num credit, required num balance, required String currencySymbol}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      child: Column(
        children: [
          // Kirim & Chiqim Cards - Horizontal Layout
          Row(
            children: [
              // Kirim Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFF3CC293).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: SvgPicture.asset(AppIcons.income, width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF3CC293), BlendMode.srcIn)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kirim',
                            style: TextStyle(color: const Color(0xFF3CC293), fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        textAlign: TextAlign.end,
                        text: TextSpan(

                          text: PriceFormatter.priceFormat('$debt'),
                          style: TextStyle(color: Color(0xFF1E293B), fontSize: 20.sp, fontWeight: FontWeight.w700, letterSpacing: 0.2, fontFamily: 'SF Pro Display'),
                          children: [
                            TextSpan(
                              text: ' $currencySymbol',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Chiqim Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFDE5050).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: SvgPicture.asset(AppIcons.chiqim, width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFFDE5050), BlendMode.srcIn)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Chiqim',
                            style: TextStyle(color: const Color(0xFFDE5050), fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          text: PriceFormatter.priceFormat('$credit'),
                          style: TextStyle(color: Color(0xFF1E293B), fontSize: 20.sp, fontWeight: FontWeight.w700, letterSpacing: 0.2, fontFamily: 'SF Pro Display'),
                          children: [
                            TextSpan(
                              text: ' $currencySymbol',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),



          const SizedBox(height: 16),

          // Qoldiq Card - Elegant Minimalist
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withValues(alpha: 0.8),
                    // gradient:  LinearGradient(colors: [AppTheme.colors.primary.withValues(alpha: 0.9), AppTheme.colors.primary.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: SvgPicture.asset(AppIcons.balance, width: 22, height: 22, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                ),
                const SizedBox(width: 14),
                Text(
                  'Qoldiq',
                  style: TextStyle(color: AppTheme.colors.primary, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                ),
                Spacer(),
                RichText(
                  text: TextSpan(
                    text: PriceFormatter.priceFormat('$balance'),
                    style:  TextStyle(color: Color(0xFF1E293B), fontSize: 20.sp, fontWeight: FontWeight.w700, letterSpacing: 0.3, fontFamily: 'SF Pro Display'),
                    children: [
                      TextSpan(
                        text: ' $currencySymbol',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                    child: GestureDetector(
                      onTap: () async {
                        showKirimBottomSheet(context, widget.partnerModel.id ?? 0, true);
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
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3, fontFamily: 'SF Pro Display'),
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
                  SizedBox(width: constraints.maxWidth * 0.03),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showKirimBottomSheet(context, widget.partnerModel.id ?? 0, false);
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
                                child:RichText(
                                  text: TextSpan(
                                    text: 'Chiqim',
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3, fontFamily: 'SF Pro Display'),
                                    children: [
                                      TextSpan(
                                        text: ' ($currencySymbol)',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                    ],
                                  ),
                              ),
                            ),)
                          ],
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
    return Shimmer.fromColors(
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
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
