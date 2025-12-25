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

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    context.read<PartnerBloc>().add(IncomeStatementEvent(id: widget.partnerModel.id ?? 0));
    super.initState();
  }

  Widget _iconButton(String icon, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppTheme.colors.colorE1EOEE, borderRadius: BorderRadius.circular(10)),
        child: SvgPicture.asset(icon, height: 24, width: 24, colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)),
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
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
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
                                        decoration: BoxDecoration(color: AppTheme.colors.colorE1EOEE, borderRadius: BorderRadius.circular(10)),
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

                          const SizedBox(height: 8),

                          // Quick toggle buttons (Kirim / Chiqim)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    showKirimBottomSheet(context, widget.partnerModel.id ?? 0, true);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(AppIcons.income),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Kirim',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showKirimBottomSheet(context, widget.partnerModel.id ?? 0, false);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF8B5CF6),

                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(AppIcons.chiqim),

                                        const SizedBox(width: 8),
                                        Text(
                                          'Chiqim',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[200]!, width: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6))],
                            ),
                            child: state.statusIncomeStatement == Status.success
                                ? Column(
                                    children: [
                                      _transactionRow(
                                        title: 'Chiqim',
                                        amountUzs: '${PriceFormatter.priceFormat('${state.incomeStatementModel?.result?.credit?.uZS ?? 0}')} UZS',
                                        amountUsd: '${PriceFormatter.priceFormat('${state.incomeStatementModel?.result?.credit?.uSD ?? 0}')} USD',
                                        bgColor: Color(0xFF8B5CF6).withValues(alpha: 0.2),
                                        textColor: Colors.black,
                                        icon: AppIcons.chiqim,
                                      ),
                                      const SizedBox(height: 12),
                                      // Kirim card (green)
                                      _transactionRow(
                                        title: 'Kirim',
                                        amountUzs: '${PriceFormatter.priceFormat('${state.incomeStatementModel?.result?.debt?.uZS ?? 0}')} UZS',
                                        amountUsd: '${PriceFormatter.priceFormat('${state.incomeStatementModel?.result?.credit?.uSD ?? 0}')} USD',
                                        bgColor: Color(0xFFF59E0B).withValues(alpha: 0.2),
                                        textColor: Colors.black,
                                        icon: AppIcons.income,
                                      ),
                                      const SizedBox(height: 6),
                                      Divider(color: Colors.grey[200], thickness: 0.5),
                                      const SizedBox(height: 6),
                                      // Balans card (simple)
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.grey[200]!),
                                        ),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(AppIcons.balance),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Text('Balans', style: TextStyle(fontWeight: FontWeight.w600)),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${PriceFormatter.priceFormat('${state.incomeStatementModel?.result?.balance?.uZS ?? 0}')} USD',
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '${PriceFormatter.priceFormat('${state.incomeStatementModel?.result?.balance?.uSD ?? 0}')} \$',
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : _buildShimmerCards(),
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

  Widget _transactionRow({required String title, required String amountUzs, required String amountUsd, required Color bgColor, required Color textColor, required String icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          SvgPicture.asset(icon, colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountUsd,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                amountUzs,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
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
