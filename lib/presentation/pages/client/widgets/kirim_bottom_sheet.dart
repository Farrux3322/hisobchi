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
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Number formatter - raqamlarni space bilan ajratadi
class NumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Faqat raqamlarni qoldirish
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Raqamlarni 3 tadan space bilan ajratish
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && (digitsOnly.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    final formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

Future<void> showKirimBottomSheet(BuildContext context, int partnerId, bool isKirim, String currencySymbol) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => BlocProvider(
        create: (context) => FileUploadBloc(repository: FileUploadRepository()),
        child: _KirimBottomSheetContent(partnerId: partnerId, isKirim: isKirim, scrollController: scrollController, currencySymbol: currencySymbol),
      ),
    ),
  );
}

class _KirimBottomSheetContent extends StatefulWidget {
  final int partnerId;
  final bool isKirim;
  final ScrollController scrollController;
  final String currencySymbol;

  const _KirimBottomSheetContent({required this.partnerId, required this.isKirim, required this.scrollController, required this.currencySymbol});

  @override
  State<_KirimBottomSheetContent> createState() => _KirimBottomSheetContentState();
}

class _ImageUploadItem {
  File? file;
  int? uploadedId;
  bool isUploading;
  double progress;

  _ImageUploadItem({this.file, this.uploadedId, this.isUploading = false, this.progress = 0});
}

class _KirimBottomSheetContentState extends State<_KirimBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _selectedCurrencyId = 1; // 1 = UZS, 2 = USD
  DateTime? _selectedDate;

  // 3 tagacha rasm uchun list
  final List<_ImageUploadItem> _images = [_ImageUploadItem(), _ImageUploadItem(), _ImageUploadItem()];

  int? _currentUploadingIndex;

  @override
  void initState() {
    super.initState();
    // Currency symbol ga asoslanib to'g'ri valyutani tanlash
    _selectedCurrencyId = widget.currencySymbol == 'UZS' ? 1 : 2;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.colors.primary, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _showImageSourceDialog(int index) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
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
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF3B82F6)),
                    ),
                    title: const Text('Kamera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: const Text('Yangi rasm olish', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, index);
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981)),
                    ),
                    title: const Text('Galereya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: const Text('Mavjud rasmdan tanlash', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, index);
                    },
                  ),
                  if (_images[index].file != null) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                      ),
                      title: const Text(
                        'Rasmni o\'chirish',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFEF4444)),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _images[index] = _ImageUploadItem();
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _images[index].file = imageFile;
          _images[index].isUploading = true;
          _currentUploadingIndex = index;
        });

        if (mounted) {
          context.read<FileUploadBloc>().add(UploadFileEvent(file: imageFile, type: 'transaction'));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    // Yuklangan rasmlar ID larini olish
    final uploadedImageIds = _images.where((img) => img.uploadedId != null).map((img) => img.uploadedId!).toList();

    // Space larni olib toza raqamni olish
    final cleanAmount = _amountController.text.replaceAll(' ', '');

    final data = {
      'partner_id': widget.partnerId,
      'currency_type_id': _selectedCurrencyId,
      'summa': cleanAmount,
      'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
      if (uploadedImageIds.isNotEmpty) 'file_id': uploadedImageIds,
      'return_date': _selectedDate?.toIso8601String(),
      'type': widget.isKirim ? 'debt' : 'credit',
    };

    context.read<PartnerBloc>().add(CreateKirim(data: data));
  }

  bool _canPickImage(int index) {
    // Birinchi rasmni doim tanlash mumkin
    if (index == 0) return true;
    // Keyingi rasmlarni faqat oldingisi yuklangan bo'lsa tanlash mumkin
    return _images[index - 1].uploadedId != null;
  }

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Rasm yuklashda xatolik: ${state.errorMessage ?? "Noma'lum xatolik"}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
          setState(() {
            _images[_currentUploadingIndex!] = _ImageUploadItem();
            _currentUploadingIndex = null;
          });
        } else if (state.status == FileUploadStatus.uploading && _currentUploadingIndex != null) {
          setState(() {
            _images[_currentUploadingIndex!].progress = state.progress;
          });
        }
      },
      child: BlocBuilder<FileUploadBloc, FileUploadState>(
        builder: (context, uploadState) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: BlocConsumer<PartnerBloc, PartnerState>(
                listener: (context, state) {
                  if (state.statusKirim == Status.success) {
                    Navigator.pop(context, true);
                  }
                  if (state.statusKirim == Status.error) {
                    Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
                  }
                },
                builder: (context, state) {
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        controller: widget.scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Handle
                                Center(
                                  child: Container(
                                    width: 62,
                                    height: 8,
                                    decoration: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Title
                                Text(
                                  widget.isKirim ? 'Kirim qo\'shish' : 'Chiqim qo\'shish',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 24),

                                // Amount and Currency
                                RichText(
                                  text: const TextSpan(
                                    text: 'Miqdor ',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                                    children: [
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Amount input and Currency dropdown in row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Amount input
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [NumberTextInputFormatter()],
                                        decoration: InputDecoration(
                                          hintText: 'Miqdorni kiriting',
                                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                          filled: true,
                                          fillColor: const Color(0xFFF8FAFC),
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
                                            borderSide: BorderSide(color:  AppTheme.colors.primary),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Colors.red),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Iltimos, miqdorni kiriting';
                                          }
                                          // Space larni olib validatsiya qilish
                                          final digitsOnly = value.replaceAll(' ', '');
                                          if (int.tryParse(digitsOnly) == null) {
                                            return 'Faqat butun sonlar';
                                          }
                                          if (int.parse(digitsOnly) <= 0) {
                                            return 'Miqdor 0 dan katta bo\'lishi kerak';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Currency dropdown - Dynamic from API
                                    Expanded(
                                      flex: 2,
                                      child: BlocBuilder<CurrencyBloc, CurrencyState>(
                                        builder: (context, currencyState) {
                                          final currencies = currencyState.currencyModel?.result ?? [];

                                          // Agar currencies bo'sh bo'lsa yoki loading bo'lsa, default qiymat
                                          if (currencies.isEmpty) {
                                            return DropdownButtonFormField<int>(
                                              value: _selectedCurrencyId,
                                              borderRadius: BorderRadius.circular(12.r),
                                              isExpanded: true,
                                              focusColor: Theme.of(context).scaffoldBackgroundColor,
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
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                              ),
                                              icon: const Icon(Icons.lock, color: Color(0xFF94A3B8), size: 18),
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                              dropdownColor: Colors.white,
                                              items: const [
                                                DropdownMenuItem(value: 1, child: Text('UZS')),
                                                DropdownMenuItem(value: 2, child: Text('USD')),
                                              ],
                                              onChanged: null, // Disabled - valyutani o'zgartirish mumkin emas
                                            );
                                          }

                                          return DropdownButtonFormField<int>(
                                            value: _selectedCurrencyId,
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
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                            ),
                                            icon: const Icon(Icons.lock, color: Color(0xFF94A3B8), size: 18),
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                            dropdownColor: Colors.white,
                                            items: currencies
                                                .map((currency) => DropdownMenuItem<int>(
                                                      value: currency.id,
                                                      child: Text(currency.name ?? ''),
                                                    ))
                                                .toList(),
                                            onChanged: null, // Disabled - valyutani o'zgartirish mumkin emas
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                if(!widget.isKirim) const SizedBox(height: 10),

                                // Return date
                               if(!widget.isKirim) const Text(
                                  'Qaytarish sanasi',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                                ),
                                if(!widget.isKirim)  const SizedBox(height: 8),
                                if(!widget.isKirim)  GestureDetector(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today_outlined, color:  AppTheme.colors.primary, size: 20),
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
                                const SizedBox(height: 20),

                                // Description
                                const Text(
                                  'Izoh',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Izoh qoldiring (ixtiyoriy)',
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
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
                                      borderSide: BorderSide(color:  AppTheme.colors.primary),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Multiple images upload
                                const Text(
                                  'Rasmlar',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 8),

                                // 3 ta rasm uchun row
                                Row(
                                  children: List.generate(3, (index) {
                                    final imageItem = _images[index];
                                    final canPick = _canPickImage(index);
                                    final isUploading = imageItem.isUploading;

                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (canPick && !isUploading) {
                                            _showImageSourceDialog(index);
                                          }
                                        },
                                        child: Container(
                                          height: 100,
                                          margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                                          decoration: BoxDecoration(
                                            color: canPick ? Colors.white : const Color(0xFFF9FAFB),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: canPick ? ( AppTheme.colors.primary) : const Color(0xFFE2E8F0), width: 2),
                                          ),
                                          child: imageItem.file != null
                                              ? Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Image.file(imageItem.file!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                                                    ),
                                                    if (isUploading)
                                                      Positioned.fill(
                                                        child: Container(
                                                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(10)),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              SizedBox(
                                                                width: 30,
                                                                height: 30,
                                                                child: CircularProgressIndicator(
                                                                  value: imageItem.progress / 100,
                                                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                                                  strokeWidth: 3,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                '${imageItem.progress.toStringAsFixed(0)}%',
                                                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    if (!isUploading && imageItem.uploadedId != null)
                                                      Positioned(
                                                        top: 4,
                                                        right: 4,
                                                        child: Container(
                                                          padding: const EdgeInsets.all(4),
                                                          decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                                          child: const Icon(Icons.check, color: Colors.white, size: 12),
                                                        ),
                                                      ),
                                                  ],
                                                )
                                              : Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: canPick
                                                      ? [SvgPicture.asset(AppIcons.photo,colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),)]
                                                      : [],
                                                ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 24),

                                // Submit button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:  AppTheme.colors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: Text(widget.isKirim ? 'Kirim qo\'shish' : 'Chiqim qo\'shish', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (state.statusKirim == Status.loading)
                        Loading(),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
