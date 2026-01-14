import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/income_history_model.dart';
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/components/full_screen_photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'edit_kirim_components/edit_kirim_header.dart';
import 'edit_kirim_components/edit_kirim_inputs.dart';
import 'edit_kirim_components/edit_kirim_image_picker.dart';
import 'edit_kirim_components/edit_kirim_footer.dart';

/// Edit mode enum for better state management
enum EditMode {
  viewing, // Read-only mode
  editing, // Edit mode
}

class EditKirimBottomSheetContent extends StatefulWidget {
  final Result transaction;
  final ScrollController scrollController;

  const EditKirimBottomSheetContent({super.key, required this.transaction, required this.scrollController});

  @override
  State<EditKirimBottomSheetContent> createState() => _EditKirimBottomSheetContentState();
}


class _EditKirimBottomSheetContentState extends State<EditKirimBottomSheetContent> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // State management
  EditMode _currentMode = EditMode.viewing;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _selectedCurrencyId = 1; // 1 = UZS, 2 = USD
  DateTime? _selectedDate;

  bool get isKirim => widget.transaction.type == 'debt';

  bool get isViewing => _currentMode == EditMode.viewing;

  bool get isEditing => _currentMode == EditMode.editing;

  // 3 tagacha rasm uchun list
  final List<ImageUploadItem> _images = [ImageUploadItem(), ImageUploadItem(), ImageUploadItem()];

  int? _currentUploadingIndex;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialValues();
  }

  /// Initialize animations for smooth transitions
  void _initializeAnimations() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  /// Toggle between viewing and editing modes
  void _toggleEditMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_currentMode == EditMode.viewing) {
        _currentMode = EditMode.editing;
        _animationController.forward();
      } else {
        _currentMode = EditMode.viewing;
        _animationController.reverse();
        // Unfocus any active text fields
        FocusScope.of(context).unfocus();
        // Reset to original values when canceling
        _loadInitialValues();
      }
    });
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final cleanValue = value.replaceAll(' ', '');
    final parts = cleanValue.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : null;

    final reversed = integerPart.split('').reversed.join();
    final chunks = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      chunks.add(reversed.substring(i, end > reversed.length ? reversed.length : end));
    }
    String formattedInteger = chunks.join(' ').split('').reversed.join();

    return decimalPart != null ? '$formattedInteger.$decimalPart' : formattedInteger;
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
      _images[i] = ImageUploadItem(
        existingUrl: existingFiles[i].url,
        id: existingFiles[i].id, // Use existing file ID
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2.r)),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Rasm tanlash',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
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


  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _images.add(ImageUploadItem());

      // Update uploading index if needed
      if (_currentUploadingIndex == index) {
        _currentUploadingIndex = null;
      } else if (_currentUploadingIndex != null && _currentUploadingIndex! > index) {
        _currentUploadingIndex = _currentUploadingIndex! - 1;
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
          _images[index].id = null; // Clear old ID
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

  void _showFullScreenImage(int initialIndex) {
    // Collect all valid images (either local file or existing URL)
    final List<ImageItem> imageItems = [];
    final Map<int, int> listToSlotIndex = {};

    for (int i = 0; i < _images.length; i++) {
      final img = _images[i];
      if (img.file != null) {
        listToSlotIndex[imageItems.length] = i;
        imageItems.add(ImageItem(path: img.file!.path, isNetwork: false));
      } else if (img.existingUrl != null) {
        listToSlotIndex[imageItems.length] = i;
        imageItems.add(ImageItem(path: img.existingUrl!, isNetwork: true));
      }
    }

    if (imageItems.isEmpty) return;

    // Find the current index in the filtered list
    int filteredInitialIndex = 0;
    for (var entry in listToSlotIndex.entries) {
      if (entry.value == initialIndex) {
        filteredInitialIndex = entry.key;
        break;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ImageViewerPage(
          images: imageItems,
          initialIndex: filteredInitialIndex,
          onDelete: (index, item) {
            final slotIndex = listToSlotIndex[index];
            if (slotIndex != null) {
              if (!isEditing) {
                setState(() => _currentMode = EditMode.editing);
              }
              _removeImage(slotIndex);
              Navigator.of(context).pop();
            }
          },
          onUpdate: (index, item) {
            final slotIndex = listToSlotIndex[index];
            if (slotIndex != null) {
              if (!isEditing) {
                setState(() => _currentMode = EditMode.editing);
              }
              Navigator.of(context).pop();
              _showImageSourceDialog(slotIndex);
            }
          },
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    // Yuklangan rasmlar ID larini olish
    final uploadedImageIds = _images.where((img) => img.id != null).map((img) => img.id!).toList();

    // Remove spaces from amount before sending
    final cleanAmount = _amountController.text.replaceAll(' ', '');

    final data = {
      'partner_id': widget.transaction.partnerId,
      'currency_type_id': _selectedCurrencyId,
      'summa': cleanAmount,
      'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
      'file_id': uploadedImageIds.isEmpty ? [] : uploadedImageIds,
      'return_date': _selectedDate?.toIso8601String(),
      'type': isKirim ? 'debt' : 'credit',
    };

    context.read<PartnerBloc>().add(UpdateKirim(data: data, id: widget.transaction.id ?? 0));
  }

  bool _canPickImage(int index) {
    // Birinchi rasmni doim tanlash mumkin
    if (index == 0) return true;
    // Keyingi rasmlarni faqat oldingisi yuklangan yoki mavjud bo'lsa tanlash mumkin
    return _images[index - 1].id != null || _images[index - 1].existingUrl != null;
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
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14.r)),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<FileUploadBloc, FileUploadState>(
      listener: (context, state) {
        if (state.status == FileUploadStatus.success && _currentUploadingIndex != null) {
          setState(() {
            _images[_currentUploadingIndex!].id = state.uploadedFileId;
            _images[_currentUploadingIndex!].isUploading = false;
            _images[_currentUploadingIndex!].progress = 100;
            _currentUploadingIndex = null;
          });
        } else if (state.status == FileUploadStatus.failure && _currentUploadingIndex != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Rasm yuklashda xatolik: ${state.errorMessage ?? "Noma\'lum xatolik"}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
          setState(() {
            _images[_currentUploadingIndex!] = ImageUploadItem();
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
              decoration: BoxDecoration(
                color: AppTheme.colors.background,
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
                                EditKirimHeader(
                                  isKirim: isKirim,
                                  isEditing: isEditing,
                                  onToggleEdit: _toggleEditMode,
                                ),
                                const SizedBox(height: 24),
                                EditKirimInputs(
                                  isEditing: isEditing,
                                  isKirim: isKirim,
                                  amountController: _amountController,
                                  descriptionController: _descriptionController,
                                  selectedCurrencyId: _selectedCurrencyId,
                                  onCurrencyChanged: (val) {
                                    if (val != null) setState(() => _selectedCurrencyId = val);
                                  },
                                  selectedDate: _selectedDate,
                                  onSelectDate: _selectDate,
                                ),
                                const SizedBox(height: 20),
                                EditKirimImagePicker(
                                  images: _images,
                                  isEditing: isEditing,
                                  onAddImage: _showImageSourceDialog,
                                  onViewImage: _showFullScreenImage,
                                ),
                                EditKirimFooter(
                                  isEditing: isEditing,
                                  isKirim: isKirim,
                                  onSubmit: _handleSubmit,
                                ),
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
