import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

import 'add_client_components/add_client_header.dart';
import 'add_client_components/add_client_image_picker.dart';
import 'add_client_components/add_client_form_fields.dart';
import 'add_client_components/add_client_currency_selector.dart';
import 'add_client_components/add_client_submit_button.dart';
import 'add_client_components/add_client_dialogs.dart';

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
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (builderContext) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.grey.shade50]),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        padding: EdgeInsets.fromLTRB(24, 12, 24, 32 + MediaQuery.of(builderContext).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // // Drag Handle with glow effect
            // Container(
            //   width: 48,
            //   height: 5,
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         const Color(0xFFE2E8F0),
            //         Colors.grey.shade300,
            //       ],
            //     ),
            //     borderRadius: BorderRadius.circular(3),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.shade300.withOpacity(0.5),
            //         blurRadius: 4,
            //         offset: const Offset(0, 2),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 32),
            //
            // // Camera Option
            // _buildSourceItem(
            //   Icons.camera_alt_rounded,
            //   'Kamera',
            //   const LinearGradient(
            //     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            //   ),
            //   () {
            //     Navigator.pop(builderContext);
            //     _pickImage(ImageSource.camera);
            //   },
            // ),
            // const SizedBox(height: 12),
            //
            // // Gallery Option
            // _buildSourceItem(
            //   Icons.photo_library_rounded,
            //   'Galereya',
            //   const LinearGradient(
            //     colors: [Color(0xFF10B981), Color(0xFF059669)],
            //   ),
            //   () {
            //     Navigator.pop(builderContext);
            //     _pickImage(ImageSource.gallery);
            //   },
            // ),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2.5)),
            ),
            const Gap(32),
            _buildSourceItem(Icons.camera_alt_rounded, 'Kamera', const Color(0xFF6366F1), () {
              Navigator.pop(builderContext);
              _pickImage(ImageSource.camera);
            }),
            const Gap(12),
            _buildSourceItem(Icons.photo_library_rounded, 'Galereya', const Color(0xFF10B981), () {
              Navigator.pop(builderContext);
              _pickImage(ImageSource.gallery);
            }),

            // Delete Option (only if image selected)
            if (_selectedImage != null) ...[
              const SizedBox(height: 12),
              _buildSourceItem(Icons.delete_outline_rounded, 'O\'chirish', Colors.redAccent, () {
                Navigator.pop(builderContext);
                setState(() {
                  _selectedImage = null;
                  _uploadedImageId = null;
                });
              }),
            ],
            SizedBox(height: MediaQuery.of(builderContext).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const Gap(16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
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
    if (_selectedCurrency == null) {
      AddClientDialogs.showErrorDialog(context, title: 'Valyuta tanlanmagan', message: 'Iltimos, asosiy valyutani tanlang', icon: Icons.currency_exchange_rounded);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text,
      'phone': maskFormatter1.getUnmaskedText(),
      'additional_phone': maskFormatter2.getUnmaskedText(),
      if (_uploadedImageId != null) 'file_id': [_uploadedImageId],
      'currency_type_id': _selectedCurrency!.id,
    };

    context.read<PartnerBloc>().add(CreateEvent(data: data));
  }

  void _handleValidationError(BuildContext context, String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      AddClientDialogs.showErrorDialog(context, title: 'Xatolik', message: 'Kutilmagan xatolik yuz berdi', icon: Icons.error_outline_rounded);
      return;
    }

    try {
      final decoded = jsonDecode(errorMessage);
      if (decoded is Map<String, dynamic>) {
        final errors = decoded['errors'] as Map<String, dynamic>?;

        if (errors != null && errors.isNotEmpty) {
          final validationErrors = <String, String>{};
          errors.forEach((field, messages) {
            final fieldName = _getFieldNameInUzbek(field);
            String message = (messages is List && messages.isNotEmpty) ? messages.first.toString() : messages.toString();
            validationErrors[fieldName] = _translateErrorMessage(field, message);
          });

          if (validationErrors.isNotEmpty) {
            AddClientDialogs.showValidationErrorDialog(context, validationErrors);
            return;
          }
        }

        if (decoded.containsKey('message')) {
          final msg = decoded['message'].toString();
          AddClientDialogs.showErrorDialog(context, title: 'Xatolik', message: _translateErrorMessage('', msg), icon: Icons.error_outline_rounded);
          return;
        }
      }
      AddClientDialogs.showErrorDialog(context, title: 'Xatolik', message: errorMessage, icon: Icons.error_outline_rounded);
    } catch (e) {
      AddClientDialogs.showErrorDialog(context, title: 'Xatolik', message: errorMessage, icon: Icons.error_outline_rounded);
    }
  }

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

  String _translateErrorMessage(String field, String message) {
    final msg = message.toLowerCase();
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
    if (msg.contains('required') || msg.contains('field is required')) {
      return 'Bu maydon to\'ldirilishi shart.';
    }
    if (msg.contains('invalid')) {
      if (msg.contains('phone')) return 'Telefon raqam formati noto\'g\'ri.';
      return 'Kiritilgan ma\'lumot noto\'g\'ri.';
    }
    if (msg.contains('the phone has already been taken')) {
      return 'Bu telefon raqam allaqachon ro\'yxatdan o\'tgan.';
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FileUploadBloc, FileUploadState>(
      listener: (context, state) {
        if (state.status == FileUploadStatus.success) {
          setState(() {
            _uploadedImageId = state.uploadedFileId;
            _isLoading = false;
          });
        } else if (state.status == FileUploadStatus.failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Rasm yuklashda xatolik: ${state.errorMessage ?? "Noma\'lum xatolik"}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
          setState(() {
            _isLoading = false;
            _selectedImage = null;
          });
        }
      },
      child: BlocBuilder<FileUploadBloc, FileUploadState>(
        builder: (context, uploadState) {
          final isUploading = uploadState.status == FileUploadStatus.uploading;

          if (isUploading && !_isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _isLoading = true);
            });
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.8,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) FocusScope.of(context).unfocus();
                },
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
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
                        return Stack(
                          children: [
                            SingleChildScrollView(
                              controller: scrollController,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const AddClientHeader(),
                                      AddClientImagePicker(
                                        selectedImage: _selectedImage,
                                        isUploading: isUploading,
                                        uploadProgress: uploadState.progress,
                                        onTap: () {
                                          if (_selectedImage != null) {
                                            _showFullScreenImage(context);
                                          } else {
                                            _showImageSourceDialog();
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      AddClientFormFields(
                                        nameController: _nameController,
                                        phoneController: _phoneController,
                                        additionalPhoneController: _additionalPhoneController,
                                        maskFormatter1: maskFormatter1,
                                        maskFormatter2: maskFormatter2,
                                      ),
                                      const SizedBox(height: 20),
                                      AddClientCurrencySelector(
                                        selectedCurrency: _selectedCurrency,
                                        onTap: () {
                                          final currencies = context.read<CurrencyBloc>().state.currencyModel?.result ?? [];
                                          AddClientDialogs.showCurrencySelection(
                                            context: context,
                                            currencies: currencies,
                                            selectedCurrency: _selectedCurrency,
                                            onSelected: (currency) => setState(() => _selectedCurrency = currency),
                                          );
                                        },
                                      ),
                                      AddClientSubmitButton(onSubmit: _handleSubmit),
                                      // Bottom padding to ensure content is not hidden by the keyboard or system bottom bar
                                      SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (state.statusAdd == Status.loading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  child: Center(child: Loading()),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
