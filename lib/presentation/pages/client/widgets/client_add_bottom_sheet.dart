import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/full_screen_photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:hisobchi/infrastructure/dto/models/currency/currency_model.dart';

class AddClientBottomSheet extends StatefulWidget {
  final Function(String name, String phone, String? additionalPhone, int? imageId)? onSubmit;

  const AddClientBottomSheet({super.key, this.onSubmit});

  @override
  State<AddClientBottomSheet> createState() => _AddClientBottomSheetState();
}

class _AddClientBottomSheetState extends State<AddClientBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: "+998");
  final _additionalPhoneController = TextEditingController(text: "+998");
  final ImagePicker _picker = ImagePicker();
  var maskFormatter1 = MaskTextInputFormatter(mask: '+998 (##) ### ## ##', filter: {"#": RegExp(r'[0-9]')}, initialText: "+998", type: MaskAutoCompletionType.lazy);
  var maskFormatter2 = MaskTextInputFormatter(mask: '+998 (##) ### ## ##', filter: {"#": RegExp(r'[0-9]')}, initialText: "+998", type: MaskAutoCompletionType.lazy);

  bool _isLoading = false;
  File? _selectedImage;
  int? _uploadedImageId;
  Result? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    // Load currencies when widget initializes
    context.read<CurrencyBloc>().add(const GetCurrency());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _additionalPhoneController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
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
                  // Handle
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

                  // Camera option
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
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 8),

                  // Gallery option
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
                      _pickImage(ImageSource.gallery);
                    },
                  ),

                  // Remove photo option (if image exists)
                  if (_selectedImage != null) ...[
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
                          _selectedImage = null;
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

  /// Show currency selection bottom sheet with search
  Future<void> _showCurrencySelectionBottomSheet(List<Result> currencies) async {
    List<Result> filteredCurrencies = currencies.where((c) => c.deletedAt == null).toList();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header with handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
                    ),
                  ),

                  // Title and close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.colors.primary.withValues(alpha: 0.1), AppTheme.colors.primary.withValues(alpha: 0.05)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.currency_exchange_rounded, color: AppTheme.colors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Valyuta tanlash',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                              ),
                              SizedBox(height: 2),
                              Text('Asosiy valyutani tanlang', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          icon: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filteredCurrencies.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20)),
                                  child: const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Valyuta topilmadi',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 6),
                                const Text('Boshqa nom bilan qidiring', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredCurrencies.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, indent: 72, color: Color(0xFFE2E8F0)),
                            itemBuilder: (context, index) {
                              final currency = filteredCurrencies[index];
                              final isSelected = _selectedCurrency?.id == currency.id;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedCurrency = currency;
                                    });
                                    Navigator.pop(bottomSheetContext);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    child: Row(
                                      children: [
                                        // Currency name
                                        Expanded(
                                          child: Text(
                                            currency.name ?? '',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.colors.primary : const Color(0xFF1E293B)),
                                          ),
                                        ),

                                        // Selected indicator
                                        if (isSelected)
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(color: AppTheme.colors.primary, shape: BoxShape.circle),
                                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                                          )
                                        else
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
        });

        // Darhol yuklashni boshlash
        if (mounted) {
          context.read<FileUploadBloc>().add(UploadFileEvent(file: imageFile, type: 'client'));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  /// Full screen image viewer with zoom capability
  void _showFullScreenImage(BuildContext context) {
    if (_selectedImage == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ImageViewerPage(
          images: [ImageItem(path: _selectedImage!.path, isNetwork: false)],
          initialIndex: 0,
          onDelete: (index, item) {
            setState(() {
              _selectedImage = null;
              _uploadedImageId = null;
            });
            Navigator.of(context).pop();
          },
          onUpdate: (index, item) {
            Navigator.of(context).pop();
            _showImageSourceDialog();
          },
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Check if currency is selected first
    if (_selectedCurrency == null) {
      _showErrorDialog(context, title: 'Valyuta tanlanmagan', message: 'Iltimos, asosiy valyutani tanlang', icon: Icons.currency_exchange_rounded);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Get additional phone if entered
    final additionalPhone = _additionalPhoneController.text.trim().isEmpty ? null : _additionalPhoneController.text;

    _submitClient(additionalPhone, _uploadedImageId);
  }

  void _submitClient(String? additionalPhone, int? imageId) {
    final data = {
      'name': _nameController.text,
      'phone': maskFormatter1.getUnmaskedText(),
      'additional_phone': maskFormatter2.getUnmaskedText(),
      if (imageId != null) 'file_id': [imageId],
      if (_selectedCurrency?.id != null) 'currency_type_id': _selectedCurrency!.id,
    };

    context.read<PartnerBloc>().add(CreateEvent(data: data));
    // if (widget.onSubmit != null) {
    //   widget.onSubmit!(
    //     _nameController.text,
    //     _phoneController.text,
    //     additionalPhone,
    //     imageId,
    //   );
    // }

    // if (mounted) {
    //   Navigator.pop(context);
    // }
  }

  /// Validatsiya xatolarini parse qilib, chiroyli dialog ko'rsatadi
  void _handleValidationError(BuildContext context, String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      _showErrorDialog(context, title: 'Xatolik', message: 'Kutilmagan xatolik yuz berdi', icon: Icons.error_outline_rounded);
      return;
    }

    try {
      final decoded = jsonDecode(errorMessage);

      if (decoded is Map<String, dynamic>) {
        // 1. Priority: Field-level validation errors
        final errors = decoded['errors'] as Map<String, dynamic>?;

        if (errors != null && errors.isNotEmpty) {
          final validationErrors = <String, String>{};

          errors.forEach((field, messages) {
            final fieldName = _getFieldNameInUzbek(field);
            String message = '';

            if (messages is List && messages.isNotEmpty) {
              message = messages.first.toString();
            } else {
              message = messages.toString();
            }

            validationErrors[fieldName] = _translateErrorMessage(field, message);
          });

          if (validationErrors.isNotEmpty) {
            _showValidationErrorDialog(context, validationErrors);
            return;
          }
        }

        // 2. Next Priority: Top-level message
        if (decoded.containsKey('message')) {
          final msg = decoded['message'].toString();
          _showErrorDialog(context, title: 'Xatolik', message: _translateErrorMessage('', msg), icon: Icons.error_outline_rounded);
          return;
        }
      }

      _showErrorDialog(context, title: 'Xatolik', message: errorMessage, icon: Icons.error_outline_rounded);
    } catch (e) {
      _showErrorDialog(context, title: 'Xatolik', message: errorMessage, icon: Icons.error_outline_rounded);
    }
  }

  /// Maydon nomini o'zbekchaga tarjima qiladi
  String _getFieldNameInUzbek(String field) {
    switch (field.toLowerCase()) {
      case 'name':
        return 'Ism';
      case 'phone':
        return 'Telefon raqam';
      case 'additional_phone':
        return 'Qo\'shimcha telefon';
      case 'currency_type_id':
        return 'Valyuta';
      case 'file_id':
        return 'Rasm';
      default:
        return field;
    }
  }

  /// Server xabarini o'zbekchaga tarjima qiladi
  String _translateErrorMessage(String field, String message) {
    final msg = message.toLowerCase();

    // "Already taken" check
    if (msg.contains('already been taken') || msg.contains('already taken')) {
      switch (field.toLowerCase()) {
        case 'phone':
          return 'Bu telefon raqam allaqachon ro\'yxatdan o\'tgan.';
        case 'name':
          return 'Bu ism allaqachon mavjud.';
        case 'additional_phone':
          return 'Bu qo\'shimcha raqam allaqachon mavjud.';
        default:
          return 'Ushbu ma\'lumot allaqachon band qilingan.';
      }
    }

    // "Required" check
    if (msg.contains('required') || msg.contains('field is required')) {
      return 'Bu maydon to\'ldirilishi shart.';
    }

    // "Invalid" check
    if (msg.contains('invalid')) {
      if (msg.contains('phone')) return 'Telefon raqam formati noto\'g\'ri.';
      return 'Kiritilgan ma\'lumot noto\'g\'ri.';
    }

    // Default translations for common Laravel messages if field-independent
    if (msg.contains('the phone has already been taken')) {
      return 'Bu telefon raqam allaqachon ro\'yxatdan o\'tgan.';
    }

    // If no translation found, return message as is
    return message;
  }

  /// Validatsiya xatolari uchun chiroyli dialog
  void _showValidationErrorDialog(BuildContext context, Map<String, String> errors) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 32),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Ma\'lumotlarni tekshiring',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Error count subtitle
                if (errors.length > 1) Text('${errors.length} ta xatolik topildi', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 12),

                // Error messages (scrollable if many errors)
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: errors.entries.map((entry) {
                          final isLast = entry.key == errors.entries.last.key;
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(entry.value, style: const TextStyle(fontSize: 13, color: Color(0xFF7F1D1D), height: 1.4)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Tushundim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Umumiy xatolik dialog
  void _showErrorDialog(BuildContext context, {required String title, required String message, required IconData icon}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), shape: BoxShape.circle),
                  child: Icon(icon, color: const Color(0xFFEF4444), size: 32),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Yopish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FileUploadBloc, FileUploadState>(
      listener: (context, state) {
        if (state.status == FileUploadStatus.success) {
          // Upload successful, save file ID
          setState(() {
            _uploadedImageId = state.uploadedFileId;
            _isLoading = false;
          });
        } else if (state.status == FileUploadStatus.failure) {
          // Upload failed, show error
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Rasm yuklashda xatolik: ${state.errorMessage ?? "Noma'lum xatolik"}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
          setState(() {
            _isLoading = false;
            _selectedImage = null; // Rasmni o'chirish
          });
        }
      },
      child: BlocBuilder<FileUploadBloc, FileUploadState>(
        builder: (context, uploadState) {
          final isUploading = uploadState.status == FileUploadStatus.uploading;

          if (isUploading && !_isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _isLoading = true);
              }
            });
          }

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
                  if (state.statusAdd == Status.success) {
                    Navigator.pop(context, true);
                  }
                  if (state.statusAdd == Status.error) {
                    _handleValidationError(context, state.errorMessage);
                  }
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Stack(
                          children: [
                            Column(
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
                                const Text(
                                  'Mijoz qo\'shish',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 24),

                                // Camera/Avatar with Image Preview
                                Center(
                                  child: GestureDetector(
                                    onTap: isUploading
                                        ? null
                                        : () {
                                            if (_selectedImage != null) {
                                              _showFullScreenImage(context);
                                            } else {
                                              _showImageSourceDialog();
                                            }
                                          },
                                    child: Stack(
                                      children: [
                                        Hero(
                                          tag: 'client_image_preview',
                                          child: Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                                            ),
                                            child: _selectedImage != null
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(18),
                                                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                                  )
                                                : Padding(padding: const EdgeInsets.all(35), child: SvgPicture.asset(AppIcons.photo)),
                                          ),
                                        ),

                                        // Upload Progress Overlay (on image)
                                        if (isUploading)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(20)),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: CircularProgressIndicator(
                                                      value: uploadState.progress / 100,
                                                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                                      strokeWidth: 3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    '${uploadState.progress.toStringAsFixed(0)}%',
                                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Text('Yuklanmoqda...', style: TextStyle(color: Colors.white, fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Ism input
                                RichText(
                                  text: const TextSpan(
                                    text: 'Ism ',
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
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Mijozni ismini kiriting...',
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
                                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Iltimos, ism kiriting';
                                    }
                                    if (value.length < 2) {
                                      return 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Tel raqami input
                                RichText(
                                  text: const TextSpan(
                                    text: 'Tel raqami ',
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
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [maskFormatter1],
                                  decoration: InputDecoration(
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
                                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Iltimos, telefon raqam kiriting';
                                    }
                                    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                                    if (digitsOnly.length != 12) {
                                      return 'Telefon raqam to\'liq emas';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Qo'shimcha tel raqami input (optional)
                                const Text(
                                  'Qo\'shimcha tel raqami',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _additionalPhoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [maskFormatter2],
                                  decoration: InputDecoration(
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
                                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  // validator: (value) {
                                  //   // Optional field, so only validate if not empty
                                  //   if (value != null && value.isNotEmpty) {
                                  //     final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                                  //     if (digitsOnly.length != 12) {
                                  //       return 'Telefon raqam to\'liq emas';
                                  //     }
                                  //   }
                                  //   return null;
                                  // },
                                ),
                                const SizedBox(height: 20),

                                // Currency Selection
                                BlocBuilder<CurrencyBloc, CurrencyState>(
                                  builder: (context, currencyState) {
                                    final currencies = currencyState.currencyModel?.result ?? [];
                                    final isLoadingCurrencies = currencyState.status == Status.loading;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: const TextSpan(
                                            text: 'Valyuta ',
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

                                        // Currency selector card
                                        GestureDetector(
                                          onTap: isLoadingCurrencies || currencies.isEmpty ? null : () => _showCurrencySelectionBottomSheet(currencies),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFFE2E8F0)),
                                            ),
                                            child: Row(
                                              children: [
                                                if (_selectedCurrency != null) const SizedBox(width: 12),

                                                // Currency name or placeholder
                                                Expanded(
                                                  child: _selectedCurrency != null
                                                      ? Text(
                                                          _selectedCurrency!.name ?? '',
                                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                                        )
                                                      : Text(isLoadingCurrencies ? 'Yuklanmoqda...' : 'Asosiy valyutani tanlang', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                                ),

                                                // Arrow icon
                                                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _selectedCurrency != null ? AppTheme.colors.primary : const Color(0xFF64748B)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.colors.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: const Text('Mijoz qo\'shish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                            if (state.statusAdd == Status.loading)
                              Padding(
                                padding: EdgeInsets.only(top: (MediaQuery.of(context).size.height / 3)),

                                child: Loading(),
                              ),
                          ],
                        ),
                      ),
                    ),
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
