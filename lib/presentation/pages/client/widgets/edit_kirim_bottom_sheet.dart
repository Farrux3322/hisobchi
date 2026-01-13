import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/income_history_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
class EditKirimBottomSheetContent extends StatefulWidget {
  final Result transaction;
  final ScrollController scrollController;

  const EditKirimBottomSheetContent({super.key, required this.transaction, required this.scrollController});

  @override
  State<EditKirimBottomSheetContent> createState() => _EditKirimBottomSheetContentState();
}

class _ImageUploadItem {
  File? file;
  int? uploadedId;
  String? existingUrl; // Mavjud rasm URL
  bool isUploading;
  double progress;

  _ImageUploadItem({this.file, this.uploadedId, this.existingUrl, this.isUploading = false, this.progress = 0});
}

class _NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-digits
    final cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    // Format with spaces every 3 digits from right
    final reversed = cleanText.split('').reversed.join();
    final chunks = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      chunks.add(reversed.substring(i, end > reversed.length ? reversed.length : end));
    }
    final formatted = chunks.join(' ').split('').reversed.join();

    // Keep cursor at end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _EditKirimBottomSheetContentState extends State<EditKirimBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _selectedCurrencyId = 1; // 1 = UZS, 2 = USD
  DateTime? _selectedDate;

  bool get isKirim => widget.transaction.type == 'debt';

  // 3 tagacha rasm uchun list
  final List<_ImageUploadItem> _images = [_ImageUploadItem(), _ImageUploadItem(), _ImageUploadItem()];

  int? _currentUploadingIndex;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    // Remove all spaces first
    final cleanValue = value.replaceAll(' ', '');
    // Format with spaces every 3 digits from right
    final reversed = cleanValue.split('').reversed.join();
    final chunks = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      chunks.add(reversed.substring(i, end > reversed.length ? reversed.length : end));
    }
    return chunks.join(' ').split('').reversed.join();
  }

  void _loadInitialValues() {
    // Miqdor
    final summa = widget.transaction.summa ?? '';
    _amountController.text = _formatNumber(summa);

    // Valyuta
    _selectedCurrencyId = widget.transaction.currencyTypeId ?? 1;

    // Izoh
    _descriptionController.text = widget.transaction.description ?? '';

    // Qaytarish sanasi
    if (widget.transaction.returnDate != null && widget.transaction.returnDate!.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(widget.transaction.returnDate!);
      } catch (e) {
        _selectedDate = null;
      }
    }

    // Mavjud rasmlar
    final existingFiles = widget.transaction.files ?? [];
    for (int i = 0; i < existingFiles.length && i < 3; i++) {
      _images[i] = _ImageUploadItem(
        existingUrl: existingFiles[i].url,
        uploadedId: null, // Existing files don't have uploadedId yet
      );
    }
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
            colorScheme: ColorScheme.light(primary: isKirim ? AppTheme.colors.color3CC293 : AppTheme.colors.colorDE5050, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
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
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Rasm tanlash',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colors.black,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildImageSourceOption(
                    icon: Icons.camera_alt_rounded,
                    title: 'Kamera',
                    subtitle: 'Yangi rasm olish',
                    color: AppTheme.colors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, index);
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    title: 'Galereya',
                    subtitle: 'Mavjud rasmdan tanlash',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, index);
                    },
                  ),
                  if (_images[index].file != null || _images[index].existingUrl != null) ...[
                    SizedBox(height: 12.h),
                    _buildImageSourceOption(
                      icon: Icons.delete_outline_rounded,
                      title: 'Rasmni o\'chirish',
                      subtitle: 'Bu rasmni o\'chirish',
                      color: const Color(0xFFEF4444),
                      onTap: () {
                        Navigator.pop(context);
                        _removeImage(index);
                      },
                    ),
                  ],
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18.sp, color: const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      for (int i = index; i < _images.length; i++) {
        _images[i] = _ImageUploadItem();
      }
    });
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _images[index].file = imageFile;
          _images[index].existingUrl = null; // Clear existing URL
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

    // Remove spaces from amount before sending
    final cleanAmount = _amountController.text.replaceAll(' ', '');

    final data = {
      'partner_id': widget.transaction.partnerId,
      'currency_type_id': _selectedCurrencyId,
      'summa': cleanAmount,
      'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
      if (uploadedImageIds.isNotEmpty) 'file_id': uploadedImageIds,
      'return_date': _selectedDate?.toIso8601String(),
      'type': isKirim ? 'debt' : 'credit',
    };

    context.read<PartnerBloc>().add(UpdateKirim(data: data, id: widget.transaction.id ?? 0));
  }

  bool _canPickImage(int index) {
    // Birinchi rasmni doim tanlash mumkin
    if (index == 0) return true;
    // Keyingi rasmlarni faqat oldingisi yuklangan yoki mavjud bo'lsa tanlash mumkin
    return _images[index - 1].uploadedId != null || _images[index - 1].existingUrl != null;
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
                  if (state.statusKirimAdd == Status.success) {
                    Navigator.pop(context, true);
                  }
                  if (state.statusKirimAdd == Status.error) {
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
                                  isKirim ? 'Kirimni tahrirlash' : 'Chiqimni tahrirlash',
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
                                      flex: 5,
                                      child: TextFormField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [_NumberInputFormatter()],
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
                                            borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
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
                                          // Remove spaces for validation
                                          final cleanValue = value.replaceAll(' ', '');
                                          if (int.tryParse(cleanValue) == null) {
                                            return 'Faqat butun sonlar';
                                          }
                                          if (int.parse(cleanValue) <= 0) {
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

                                          // Agar currencies bo'sh bo'lsa, default qiymat
                                          if (currencies.isEmpty) {
                                            return DropdownButtonFormField<int>(
                                              initialValue: _selectedCurrencyId,
                                              isExpanded: true,
                                              focusColor: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(12.r),
                                              decoration: InputDecoration(
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
                                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                              ),
                                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.colors.primary),
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                              dropdownColor: Colors.white,
                                              items: const [
                                                DropdownMenuItem(value: 1, child: Text('UZS')),
                                                DropdownMenuItem(value: 2, child: Text('USD')),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    _selectedCurrencyId = value;
                                                  });
                                                }
                                              },
                                            );
                                          }

                                          return DropdownButtonFormField<int>(
                                            initialValue: _selectedCurrencyId,
                                            isExpanded: true,
                                            focusColor: Theme.of(context).scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.circular(12.r),
                                            decoration: InputDecoration(
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
                                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                            ),
                                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.colors.primary),
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                            dropdownColor: Colors.white,
                                            items: currencies.map((currency) => DropdownMenuItem<int>(value: currency.id, child: Text(currency.name ?? ''))).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _selectedCurrencyId = value;
                                                });
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                if (!isKirim) const SizedBox(height: 10),

                                if (!isKirim)
                                  const Text(
                                    'Qaytarish sanasi',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                                  ),
                                if (!isKirim) const SizedBox(height: 8),
                                if (!isKirim)
                                  GestureDetector(
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
                                const SizedBox(height: 20),

                                // Description
                                const Text(
                                  'Izoh',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 3,
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
                                      borderSide: BorderSide(color: isKirim ? AppTheme.colors.color3CC293 : AppTheme.colors.colorDE5050, width: 2),
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
                                    final hasImage = imageItem.file != null || imageItem.existingUrl != null;

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
                                            border: Border.all(color: canPick ? AppTheme.colors.primary : const Color(0xFFE2E8F0), width: 2),
                                          ),
                                          child: hasImage
                                              ? Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: imageItem.file != null
                                                          ? Image.file(imageItem.file!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                                          : Image.network(
                                                              imageItem.existingUrl!,
                                                              fit: BoxFit.cover,
                                                              width: double.infinity,
                                                              height: double.infinity,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return const Center(child: Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8), size: 32));
                                                              },
                                                              loadingBuilder: (context, child, loadingProgress) {
                                                                if (loadingProgress == null) return child;
                                                                return Center(
                                                                  child: CircularProgressIndicator(
                                                                    color: AppTheme.colors.primary,
                                                                    value: loadingProgress.expectedTotalBytes != null
                                                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                                        : null,
                                                                    strokeWidth: 1,
                                                                  ),
                                                                );
                                                              },
                                                            ),
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
                                                    if (!isUploading && (imageItem.uploadedId != null || imageItem.existingUrl != null))
                                                      Positioned(
                                                        top: 4,
                                                        right: 4,
                                                        child: Container(
                                                          padding: const EdgeInsets.all(4),
                                                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                                          child: const Icon(Icons.check, color: Colors.white, size: 12),
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
                                const SizedBox(height: 24),

                                // Submit button
                                SizedBox(
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
                                    child: Text(isKirim ? 'Kirimni tahrirlash' : 'Chiqimni tahrirlash', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (state.statusKirimAdd == Status.loading) Loading(),
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
