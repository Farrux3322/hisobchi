import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:image_picker/image_picker.dart';

// ─── Formatters ─────────────────────────────────────────────────────────────

class _DecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String base = newValue.text.replaceAll(' ', '');
    if (base.split('.').length > 2) base = oldValue.text.replaceAll(' ', '');
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(base)) return oldValue;
    final parts = base.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(' ');
      buf.write(intPart[i]);
    }
    final result = decPart != null ? '${buf.toString()}.$decPart' : buf.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// ─── Models ──────────────────────────────────────────────────────────────────

class _TovarItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  _TovarItem();

  double get subtotal {
    final price = double.tryParse(priceController.text.replaceAll(' ', '')) ?? 0;
    final qty = double.tryParse(qtyController.text.replaceAll(' ', '')) ?? 1;
    return price * qty;
  }

  Map<String, dynamic> toMap() => {'name': nameController.text.trim(), 'price': priceController.text.replaceAll(' ', ''), 'qty': qtyController.text.replaceAll(' ', '')};

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    qtyController.dispose();
  }
}

class _ImageUploadItem {
  File? file;
  int? uploadedId;
  bool isUploading;
  double progress;

  _ImageUploadItem({this.file, this.uploadedId, this.isUploading = false, this.progress = 0});
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class ChiqimPage extends StatefulWidget {
  final int partnerId;
  final String currencySymbol;
  final PartnerModel partnerModel;

  const ChiqimPage({super.key, required this.partnerId, required this.currencySymbol, required this.partnerModel});

  @override
  State<ChiqimPage> createState() => _ChiqimPageState();
}

class _ChiqimPageState extends State<ChiqimPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _selectedCurrencyId = 1;
  DateTime? _selectedDate;

  // Tovar section
  bool _tovarExpanded = false;
  final List<_TovarItem> _tovarItems = [];

  // Image upload
  final List<_ImageUploadItem> _images = [_ImageUploadItem(), _ImageUploadItem(), _ImageUploadItem()];
  int? _currentUploadingIndex;

  // ─── Computed ──────────────────────────────────────────────────────────────

  bool get _itemsMode => _tovarExpanded && _tovarItems.isNotEmpty;

  double get _tovarTotal => _tovarItems.fold(0.0, (sum, item) => sum + item.subtotal);

  String _formatAmount(double value) {
    if (value == value.toInt()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _selectedCurrencyId = widget.currencySymbol == 'UZS' ? 1 : 2;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    for (final item in _tovarItems) {
      item.dispose();
    }
    super.dispose();
  }

  // ─── Tovar helpers ─────────────────────────────────────────────────────────

  void _addTovar() {
    final item = _TovarItem();
    // rebuild when any field changes to update total
    void rebuild() => setState(() {});
    item.priceController.addListener(rebuild);
    item.qtyController.addListener(rebuild);
    setState(() => _tovarItems.add(item));
  }

  void _removeTovar(int index) {
    _tovarItems[index].dispose();
    setState(() {
      _tovarItems.removeAt(index);
      if (_tovarItems.isEmpty) {
        _amountController.clear();
      }
    });
  }

  void _toggleTovarSection() {
    setState(() {
      _tovarExpanded = !_tovarExpanded;
      if (_tovarExpanded && _tovarItems.isEmpty) {
        _addTovar();
      }
      if (!_tovarExpanded) {
        _amountController.clear();
      }
    });
  }

  // ─── Date ──────────────────────────────────────────────────────────────────

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.colors.primary, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  // ─── Image upload ──────────────────────────────────────────────────────────

  Future<void> _showImageSourceDialog(int index) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Rasm tanlash',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 20),
                _imageSourceTile(Icons.camera_alt_rounded, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), 'Kamera', 'Yangi rasm olish', () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, index);
                }),
                const SizedBox(height: 8),
                _imageSourceTile(Icons.photo_library_rounded, const Color(0xFFF0FDF4), const Color(0xFF10B981), 'Galereya', 'Mavjud rasmdan tanlash', () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, index);
                }),
                if (_images[index].file != null) ...[
                  const SizedBox(height: 8),
                  _imageSourceTile(Icons.delete_outline_rounded, const Color(0xFFFEE2E2), const Color(0xFFEF4444), 'Rasmni o\'chirish', '', () {
                    Navigator.pop(context);
                    setState(() => _images[index] = _ImageUploadItem());
                  }, textColor: const Color(0xFFEF4444)),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageSourceTile(IconData icon, Color bg, Color iconColor, String title, String subtitle, VoidCallback onTap, {Color? textColor}) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor ?? const Color(0xFF1E293B)),
      ),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))) : null,
      onTap: onTap,
    );
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (file != null) {
        final imageFile = File(file.path);
        setState(() {
          _images[index].file = imageFile;
          _images[index].isUploading = true;
          _currentUploadingIndex = index;
        });
        if (mounted) context.read<FileUploadBloc>().add(UploadFileEvent(file: imageFile, type: 'transaction'));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e'), backgroundColor: Colors.red));
    }
  }

  bool _canPickImage(int index) => index == 0 || _images[index - 1].uploadedId != null;

  // ─── Submit ────────────────────────────────────────────────────────────────

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final uploadedImageIds = _images.where((img) => img.uploadedId != null).map((img) => img.uploadedId!).toList();

    final String finalAmount;
    if (_itemsMode) {
      finalAmount = _formatAmount(_tovarTotal);
    } else {
      finalAmount = _amountController.text.replaceAll(' ', '');
    }

    // Collect items
    final List<Map<String, dynamic>> items = _itemsMode ? _tovarItems.map((e) => e.toMap()).toList() : [];

    final data = {
      'partner_id': widget.partnerId,
      'currency_type_id': _selectedCurrencyId,
      'summa': finalAmount,
      'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
      if (uploadedImageIds.isNotEmpty) 'file_id': uploadedImageIds,
      'return_date': _selectedDate?.toIso8601String(),
      'type': 'credit',
      if (items.isNotEmpty) 'items': items,
    };

    context.read<PartnerBloc>().add(CreateKirim(data: data));
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<FileUploadBloc, FileUploadState>(
      listener: (context, state) {
        if (state.status == FileUploadStatus.success && _currentUploadingIndex != null) {
          setState(() {
            _images[_currentUploadingIndex!].uploadedId = state.uploadedFileId;
            _images[_currentUploadingIndex!].isUploading = false;
            _images[_currentUploadingIndex!].progress = 100;
            _currentUploadingIndex = null;
          });
        } else if (state.status == FileUploadStatus.failure && _currentUploadingIndex != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rasm yuklashda xatolik: ${state.errorMessage ?? "Noma\'lum xatolik"}'), // ignore: unnecessary_string_escapes
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            _images[_currentUploadingIndex!] = _ImageUploadItem();
            _currentUploadingIndex = null;
          });
        } else if (state.status == FileUploadStatus.uploading && _currentUploadingIndex != null) {
          setState(() => _images[_currentUploadingIndex!].progress = state.progress);
        }
      },
      child: BlocConsumer<PartnerBloc, PartnerState>(
        listener: (context, state) {
          if (state.statusKirim == Status.success) Navigator.pop(context, true);
          if (state.statusKirim == Status.error) Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Center(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
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
                title: const Text(
                  'Chiqim qo\'shish',
                  style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).padding.bottom + 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAmountSection(),
                          const SizedBox(height: 16),
                          _buildDateSection(),
                          const SizedBox(height: 16),
                          _buildDescriptionSection(),
                          const SizedBox(height: 16),
                          _buildTovarSection(),
                          const SizedBox(height: 16),
                          _buildImagesSection(),
                          const SizedBox(height: 28),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                  if (state.statusKirim == Status.loading) Loading(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Section Widgets ───────────────────────────────────────────────────────

  Widget _buildSmsInfo() {
    final active = widget.partnerModel.sendOnChiqim == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? const Color(0xFFDE5050).withValues(alpha: 0.2) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(active ? Icons.notifications_active_outlined : Icons.notifications_off_outlined, size: 15, color: active ? const Color(0xFFDE5050) : const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              active ? "Chiqim qo'shilishi bilan mijozga avtomatik SMS yuboriladi." : "SMS o'chirilgan. Chiqim qo'shilganda mijozga SMS yuborilmaydi.",
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: active ? const Color(0xFF92400E) : const Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tovar Section ─────────────────────────────────────────────────────────

  Widget _buildTovarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle header
        GestureDetector(
          onTap: _toggleTovarSection,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _tovarExpanded ? const Color(0xFFDE5050).withValues(alpha: 0.06) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _tovarExpanded ? const Color(0xFFDE5050).withValues(alpha: 0.35) : const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: _tovarExpanded ? const Color(0xFFDE5050).withValues(alpha: 0.12) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(9)),
                  child: Icon(Icons.inventory_2_outlined, size: 18, color: _tovarExpanded ? const Color(0xFFDE5050) : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tovar qo\'shish',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color:  const Color(0xFF1E293B)),
                      ),
                      Text(
                        _itemsMode
                            ? '${_tovarItems.length} ta tovar • Jami: ${PriceFormatter.priceFormat(_formatAmount(_tovarTotal))} ${widget.currencySymbol}'
                            : 'Ixtiyoriy — tovar bo\'yicha hisoblash',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400,),
                      ),
                    ],
                  ),
                ),
                if (_tovarExpanded) ...[
                  GestureDetector(
                    onTap: _addTovar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDE5050).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children:  [
                          Icon(Icons.add_rounded, size: 14, color: AppTheme.colors.primary),
                          SizedBox(width: 3),
                          Text('Qo\'shish', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.colors.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                AnimatedRotation(
                  turns: _tovarExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded, color: _tovarExpanded ? const Color(0xFFDE5050) : const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ),

        // Expanded content
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          child: _tovarExpanded
              ? Column(
                  children: [
                    const SizedBox(height: 10),
                    // Items list
                    ..._tovarItems.asMap().entries.map((entry) => _buildTovarItem(entry.key, entry.value)),
                    // Total bar
                    // if (_itemsMode) ...[const SizedBox(height: 10), _buildTovarTotal()],
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTovarItem(int index, _TovarItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: const Color(0xFFDE5050).withValues(alpha: 0.12))),
            ),
            child: Row(
              children: [
                // Container(
                //   width: 26,
                //   height: 26,
                //   decoration: BoxDecoration(color: const Color(0xFFDE5050).withValues(alpha: 0.12), shape: BoxShape.circle),
                //   child: Center(
                //     child: Text(
                //       '${index + 1}',
                //       style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDE5050)),
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}-tovar',
                        style:  TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.colors.primary),
                      ),
                      if (item.subtotal > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDE5050).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${PriceFormatter.priceFormat(_formatAmount(item.subtotal))} ${widget.currencySymbol}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDE5050)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // const Spacer(),
                GestureDetector(
                  onTap: () => _removeTovar(index),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                    child: SvgPicture.asset(AppIcons.delete),
                  ),
                ),
              ],
            ),
          ),

          // ── Fields ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tovar nomi
                _itemLabel('Tovar nomi'),
                const SizedBox(height: 5),
                TextFormField(
                  controller: item.nameController,
                  maxLength: 25,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _fieldDecoration('Masalan: Telefon, Sumka...'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Tovar nomi kiritilmagan' : null,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),

                // Narx + Miqdor row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _itemLabel('Tovar narxi'),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: item.priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [_DecimalFormatter()],
                            maxLength: 10,
                            decoration: _fieldDecoration('0'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Narx kiritilmagan';
                              final val = double.tryParse(v.replaceAll(' ', ''));
                              if (val == null || val <= 0) return 'Noto\'g\'ri narx';
                              return null;
                            },
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _itemLabel('Tovar miqdori'),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: item.qtyController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [_DecimalFormatter()],
                            maxLength: 10,
                            decoration: _fieldDecoration('1'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Kiritilmagan';
                              final val = double.tryParse(v.replaceAll(' ', ''));
                              if (val == null || val <= 0) return 'Noto\'g\'ri';
                              return null;
                            },
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
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

  Widget _itemLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), letterSpacing: 0.1),
    );
  }

  Widget _buildTovarTotal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [BoxShadow(color: const Color(0xFFDE5050).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Jami summa',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PriceFormatter.priceFormat(_formatAmount(_tovarTotal)),
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
              ),
              Text(
                widget.currencySymbol,
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Amount Section ────────────────────────────────────────────────────────

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: 'Miqdor ',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _itemsMode ? const Color(0xFF94A3B8) : const Color(0xFF1E293B)),
                children: [
                  if (!_itemsMode)
                    const TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
            if (_itemsMode) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFDE5050).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text(
                  'Tovar summasi',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFDE5050)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _itemsMode
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDE5050).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              PriceFormatter.priceFormat(_formatAmount(_tovarTotal)),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFDE5050)),
                            ),
                          ),
                          const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    )
                  : TextFormField(
                      controller: _amountController,
                      maxLength: 14,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [_DecimalFormatter()],
                      decoration: InputDecoration(
                        hintText: 'Miqdorni kiriting',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        filled: true,
                        counter: const SizedBox(),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.colors.primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        if (_itemsMode) return null;
                        if (value == null || value.isEmpty) return 'Iltimos, miqdorni kiriting';
                        final clean = value.replaceAll(' ', '');
                        final parsed = double.tryParse(clean);
                        if (parsed == null) return 'Faqat son kiritish mumkin';
                        if (parsed <= 0) return 'Miqdor 0 dan katta bo\'lishi kerak';
                        return null;
                      },
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _buildCurrencyDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown() {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, currencyState) {
        final currencies = currencyState.currencyModel?.result ?? [];
        final items = currencies.isEmpty
            ? const [DropdownMenuItem(value: 1, child: Text('UZS')), DropdownMenuItem(value: 2, child: Text('USD'))]
            : currencies.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name ?? ''))).toList();

        return DropdownButtonFormField<int>(
          initialValue: _selectedCurrencyId,
          isExpanded: true,
          focusColor: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          icon: const Icon(Icons.lock, color: Color(0xFF94A3B8), size: 18),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          dropdownColor: Colors.white,
          items: items,
          onChanged: null,
        );
      },
    );
  }

  // ─── Date Section ──────────────────────────────────────────────────────────

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Qaytarish sanasi',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppTheme.colors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null ? 'Sanani tanlang' : DateFormat('dd MMM yyyy').format(_selectedDate!),
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedDate == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                    fontWeight: _selectedDate == null ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Description Section ───────────────────────────────────────────────────

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Izoh',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: null,
          maxLength: 100,
          decoration: InputDecoration(
            counter: const SizedBox(),
            hintText: 'Izoh qoldiring (ixtiyoriy)',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // ─── Images Section ────────────────────────────────────────────────────────

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rasmlar',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (index) {
            final img = _images[index];
            final canPick = _canPickImage(index);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (canPick && !img.isUploading) _showImageSourceDialog(index);
                },
                child: Container(
                  height: 96,
                  margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                  decoration: BoxDecoration(
                    color: canPick ? Colors.white : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: canPick ? AppTheme.colors.primary : const Color(0xFFE2E8F0), width: 1.8),
                  ),
                  child: img.file != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(img.file!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                            ),
                            if (img.isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          value: img.progress / 100,
                                          backgroundColor: Colors.white30,
                                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${img.progress.toStringAsFixed(0)}%',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (!img.isUploading && img.uploadedId != null)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 11),
                                ),
                              ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: canPick ? [SvgPicture.asset(AppIcons.photo, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn))] : [],
                        ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── Submit Button ─────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text('Chiqim qo\'shish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ─── Helper ────────────────────────────────────────────────────────────────

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      isDense: true,
      counter: SizedBox(),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.colors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      errorStyle: const TextStyle(fontSize: 10, height: 1.2),
    );
  }
}
