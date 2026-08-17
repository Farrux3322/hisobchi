import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ehisob/presentation/components/basic_widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../presentation/assets/asset_index.dart';
import '../../data/models/enums.dart';
import '../../data/models/payment_document_model.dart';
import '../../data/models/payment_partner_model.dart';
import '../bloc/payment_schedule_bloc.dart';
import '../bloc/payment_schedule_event.dart';
import '../bloc/payment_schedule_state.dart';
import '../widgets/common/ps_bottom_buttons.dart';
import '../widgets/common/ps_currency_selector.dart';
import '../widgets/common/ps_section_card.dart';
import '../widgets/common/ps_step_indicator.dart';

class Step1BasicInfoPage extends StatefulWidget {
  const Step1BasicInfoPage({super.key});

  @override
  State<Step1BasicInfoPage> createState() => _Step1BasicInfoPageState();
}

class _Step1BasicInfoPageState extends State<Step1BasicInfoPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentScheduleBloc, PaymentScheduleState>(
      builder: (context, state) {
        return DeFocus(
          child: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PSStepIndicator(currentStep: 0),
                        SizedBox(height: 6.h),
                        Text(
                          '1-bosqich • Asosiy ma\'lumotlar',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Partner — statik ko'rsatish
                        PSSectionCard(
                          highlighted: state.selectedPartner != null,
                          child: Row(
                            children: [
                              Container(
                                width: 44.r,
                                height: 44.r,
                                decoration: BoxDecoration(
                                  color: (state.selectedPartner != null
                                          ? AppTheme.colors.primary
                                          : AppTheme.colors.divider)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: state.selectedPartner != null
                                      ? Text(
                                          state.selectedPartner!.name[0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.colors.primaryText,
                                          ),
                                        )
                                      : Icon(Icons.person_search_rounded,
                                          color: AppTheme.colors.iconColor, size: 22.r),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mijoz',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.colors.gray,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      state.selectedPartner?.name ?? 'Mijoz tanlash',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: state.selectedPartner != null
                                            ? AppTheme.colors.black
                                            : AppTheme.colors.gray,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.validationErrors.containsKey('partner'))
                          Padding(
                            padding: EdgeInsets.only(left: 4.w, top: 6.h),
                            child: Text(
                              state.validationErrors['partner']!,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppTheme.colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        SizedBox(height: 12.h),

                        // Amount + Currency
                        PSSectionCard(
                          padding: EdgeInsets.zero,
                          highlighted: true,
                          highlightColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Miqdor va valyuta',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.colors.gray,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(Icons.account_balance_wallet_rounded,
                                            size: 20.r, color: AppTheme.colors.primary),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              _ThousandsSeparatorInputFormatter(),
                                            ],
                                            cursorColor: AppTheme.colors.primary,
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              hintStyle:
                                                  TextStyle(color: AppTheme.colors.divider),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            onChanged: (value) {
                                              final amount = double.tryParse(
                                                      value.replaceAll(' ', '')) ??
                                                  0;
                                              context
                                                  .read<PaymentScheduleBloc>()
                                                  .add(PaymentTotalAmountChanged(amount));
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                  height: 32.h,
                                  thickness: 1.h,
                                  color: AppTheme.colors.divider.withValues(alpha: 0.5)),
                              Padding(
                                padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Valyuta turi',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.colors.gray,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          state.currency == PaymentCurrency.uzs
                                              ? 'O\'zbek so\'mi'
                                              : 'AQSH Dollari',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    PSCurrencySelector(
                                      selectedCurrency: state.currency,
                                      onChanged: (currency) {
                                        context
                                            .read<PaymentScheduleBloc>()
                                            .add(PaymentCurrencyChanged(currency));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.validationErrors.containsKey('amount'))
                          Padding(
                            padding: EdgeInsets.only(left: 4.w, top: 6.h),
                            child: Text(
                              state.validationErrors['amount']!,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppTheme.colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        SizedBox(height: 12.h),

                        // Note
                        PSSectionCard(
                          label: 'Izoh (ixtiyoriy)',
                          child: TextField(
                            maxLines: 3,
                            cursorColor: AppTheme.colors.primary,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppTheme.colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Tafsilotlarni yozishingiz mumkun...',
                              hintStyle: TextStyle(
                                  color: AppTheme.colors.gray, fontSize: 13.sp),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              context
                                  .read<PaymentScheduleBloc>()
                                  .add(PaymentNoteChanged(value));
                            },
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Documents
                        _DocumentSection(
                          documents: state.documents,
                          onAddTapped: () => _showFileSourceBottomSheet(context),
                          onRemove: (doc) => context
                              .read<PaymentScheduleBloc>()
                              .add(PaymentDocumentRemoved(doc.localPath)),
                          onRetry: (doc) => context
                              .read<PaymentScheduleBloc>()
                              .add(PaymentDocumentAdded(doc.copyWith(
                                status: DocumentUploadStatus.idle,
                                progress: 0,
                              ))),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
                PSBottomButtons(
                  showBack: false,
                  onContinue: () {
                    context.read<PaymentScheduleBloc>().add(const PaymentStepChanged(1));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFileSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppTheme.colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.divider,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hujjat yuklash',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quyidagi manbalardan birini tanlang',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.colors.gray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _FileSourceTile(
                  icon: Icons.photo_library_rounded,
                  iconColor: const Color(0xFF5B8DEF),
                  iconBgColor: const Color(0xFF5B8DEF).withValues(alpha: 0.1),
                  title: 'Galereyadan',
                  subtitle: 'Rasm va videolarni tanlash',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery(context);
                  },
                ),
                SizedBox(height: 12.h),
                _FileSourceTile(
                  icon: Icons.insert_drive_file_rounded,
                  iconColor: const Color(0xFF4CAF50),
                  iconBgColor: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  title: 'Fayldan',
                  subtitle: 'PDF, Word, Excel va boshqalar',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile(context);
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isEmpty || !mounted) return;

    for (final xFile in picked) {
      final file = File(xFile.path);
      final size = await file.length();
      if (!mounted) return;
      context.read<PaymentScheduleBloc>().add(
            PaymentDocumentAdded(PaymentDocumentModel(
              localPath: xFile.path,
              fileName: xFile.name,
              isImage: true,
              sizeBytes: size,
            )),
          );
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: false,
    );
    if (result == null || !mounted) return;

    for (final f in result.files) {
      if (f.path == null) continue;
      context.read<PaymentScheduleBloc>().add(
            PaymentDocumentAdded(PaymentDocumentModel(
              localPath: f.path!,
              fileName: f.name,
              isImage: false,
              sizeBytes: f.size,
            )),
          );
    }
  }
}

// ─── Document section widget ──────────────────────────────────────────────────

class _DocumentSection extends StatelessWidget {
  final List<PaymentDocumentModel> documents;
  final VoidCallback onAddTapped;
  final void Function(PaymentDocumentModel) onRemove;
  final void Function(PaymentDocumentModel) onRetry;

  const _DocumentSection({
    required this.documents,
    required this.onAddTapped,
    required this.onRemove,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            'Hujjatlar (ixtiyoriy)',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.colors.gray,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppTheme.colors.divider, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (documents.isNotEmpty) ...[
                ...documents.asMap().entries.map((entry) {
                  final isLast = entry.key == documents.length - 1;
                  return Column(
                    children: [
                      _DocumentTile(
                        doc: entry.value,
                        onRemove: () => onRemove(entry.value),
                        onRetry: () => onRetry(entry.value),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1.h,
                          thickness: 1.h,
                          color: AppTheme.colors.divider.withValues(alpha: 0.5),
                        ),
                    ],
                  );
                }),
                Divider(
                  height: 1.h,
                  thickness: 1.h,
                  color: AppTheme.colors.divider.withValues(alpha: 0.5),
                ),
              ],
              // Add button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAddTapped,
                  borderRadius: documents.isEmpty
                      ? BorderRadius.circular(16.r)
                      : BorderRadius.vertical(bottom: Radius.circular(16.r)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    child: Row(
                      children: [
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: AppTheme.colors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.add_rounded, size: 22.r, color: AppTheme.colors.primary),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Hujjat qo\'shish',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.primary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20.r,
                          color: AppTheme.colors.primary.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final PaymentDocumentModel doc;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  const _DocumentTile({
    required this.doc,
    required this.onRemove,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Preview / icon
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: doc.isImage && doc.localPath.isNotEmpty
                ? Image.file(
                    File(doc.localPath),
                    width: 44.r,
                    height: 44.r,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _iconBox(),
                  )
                : _iconBox(),
          ),
          SizedBox(width: 12.w),
          // Name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.fileName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                if (doc.isUploading) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: doc.progress / 100,
                            minHeight: 4.h,
                            backgroundColor: AppTheme.colors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${doc.progress}%',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ] else if (doc.hasFailed) ...[
                  Row(
                    children: [
                      Icon(Icons.error_outline_rounded, size: 13.r, color: AppTheme.colors.red),
                      SizedBox(width: 4.w),
                      Text(
                        'Xatolik yuz berdi',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppTheme.colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    [
                      doc.isImage ? 'Rasm' : 'Hujjat',
                      if (doc.sizeLabel.isNotEmpty) '• ${doc.sizeLabel}',
                      if (doc.isUploaded) '• Yuklandi',
                    ].join(' '),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: doc.isUploaded ? const Color(0xFF4CAF50) : AppTheme.colors.gray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Action button
          if (doc.hasFailed)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.refresh_rounded, size: 16.r, color: AppTheme.colors.primary),
              ),
            )
          else
            GestureDetector(
              onTap: doc.isUploading ? null : onRemove,
              child: Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: doc.isUploading
                      ? AppTheme.colors.divider.withValues(alpha: 0.3)
                      : AppTheme.colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 16.r,
                  color: doc.isUploading ? AppTheme.colors.gray : AppTheme.colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _iconBox() {
    return Container(
      width: 44.r,
      height: 44.r,
      color: doc.isImage
          ? const Color(0xFF5B8DEF).withValues(alpha: 0.1)
          : const Color(0xFF4CAF50).withValues(alpha: 0.1),
      child: Icon(
        doc.isImage ? Icons.image_rounded : Icons.insert_drive_file_rounded,
        size: 22.r,
        color: doc.isImage ? const Color(0xFF5B8DEF) : const Color(0xFF4CAF50),
      ),
    );
  }
}

class _FileSourceTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FileSourceTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppTheme.colors.divider, width: 1.w),
          ),
          child: Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 24.r, color: iconColor),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.colors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.colors.gray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20.r, color: AppTheme.colors.gray),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) return oldValue;
    final formatted = _formatter.format(number).replaceAll(',', ' ');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
