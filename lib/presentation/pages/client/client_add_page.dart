import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:hisobchi/presentation/pages/client/widgets/add_client_components/add_client_dialogs.dart';

class ClientAddPage extends StatefulWidget {
  const ClientAddPage({super.key});

  @override
  State<ClientAddPage> createState() => _ClientAddPageState();
}

class _ClientAddPageState extends State<ClientAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: "+998 ");
  final _additionalPhoneController = TextEditingController(text: "+998 ");
  final ImagePicker _picker = ImagePicker();

  final _maskFormatter1 = MaskTextInputFormatter(mask: '+998 (##) ###-##-##', filter: {"#": RegExp(r'[0-9]')}, type: MaskAutoCompletionType.lazy);
  final _maskFormatter2 = MaskTextInputFormatter(mask: '+998 (##) ###-##-##', filter: {"#": RegExp(r'[0-9]')}, type: MaskAutoCompletionType.lazy);

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

  void _showFullScreenImage() {
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (builderContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2.5)),
            ),
            const SizedBox(height: 32),
            _buildSourceItem(Icons.camera_alt_rounded, 'Kamera', const Color(0xFF6366F1), () {
              Navigator.pop(builderContext);
              _pickImage(ImageSource.camera);
            }),
            const SizedBox(height: 12),
            _buildSourceItem(Icons.photo_library_rounded, 'Galereya', const Color(0xFF10B981), () {
              Navigator.pop(builderContext);
              _pickImage(ImageSource.gallery);
            }),
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
            Gap(MediaQuery.of(context).padding.bottom),
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
            const SizedBox(width: 16),
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

  void _handleSubmit() {
    if (_selectedCurrency == null) {
      AddClientDialogs.showErrorDialog(context, title: 'Valyuta tanlanmagan', message: 'Iltimos, asosiy valyutani tanlang', icon: Icons.currency_exchange_rounded);
      return;
    }

    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _maskFormatter1.getUnmaskedText(),
        'additional_phone': _maskFormatter2.getUnmaskedText(),
        'file_id': _uploadedImageId == null ? [] : [_uploadedImageId],
        'currency_type_id': _selectedCurrency!.id,
      };
      context.read<PartnerBloc>().add(CreateEvent(data: data));
    }
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
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FileUploadBloc, FileUploadState>(
          listener: (context, state) {
            if (state.status == FileUploadStatus.success) {
              setState(() => _uploadedImageId = state.uploadedFileId);
            } else if (state.status == FileUploadStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: ${state.errorMessage}'), backgroundColor: Colors.red));
              setState(() => _selectedImage = null);
            }
          },
        ),
        BlocListener<PartnerBloc, PartnerState>(
          listener: (context, state) {
            if (state.statusAdd == Status.success) Navigator.pop(context, true);
            if (state.statusAdd == Status.error) {
              _handleValidationError(context, state.errorMessage);
            }
          },
        ),
      ],
      child: Scaffold(
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
          centerTitle: true,
          title: const Text(
            'Yangi hamkor',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<PartnerBloc, PartnerState>(
      builder: (context, partnerState) {
        return BlocBuilder<FileUploadBloc, FileUploadState>(
          builder: (context, uploadState) {
            final isUploading = uploadState.status == FileUploadStatus.uploading;
            final isSubmitting = partnerState.statusAdd == Status.loading;

            return Stack(
              children: [
                GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(isUploading, uploadState.progress.toDouble()),
                          const SizedBox(height: 40),
                          _buildMinimalInput(
                            controller: _nameController,
                            hint: 'Hamkor ismi',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.isEmpty) ? 'Ism kiritilmagan' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildMinimalInput(
                            controller: _phoneController,
                            hint: 'Telefon raqami',
                            icon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                            formatters: [_maskFormatter1],
                            validator: (v) {
                              final digits = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                              return digits.length != 12 ? 'Telefon raqam to\'liq emas' : null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMinimalInput(
                            controller: _additionalPhoneController,
                            hint: 'Qo\'shimcha telefon (ixtiyoriy)',
                            icon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                            formatters: [_maskFormatter2],
                            validator: (v) {
                              final digits = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                              if (digits.length > 3 && digits.length != 12) {
                                return 'Qo\'shimcha telefon to\'liq emas';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildCurrencySelector(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(isSubmitting),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isSubmitting) const Loading(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildImageSection(bool isUploading, double progress) {
    return Center(
      child: GestureDetector(
        onTap: isUploading
            ? null
            : () {
                if (_selectedImage != null) {
                  _showFullScreenImage();
                } else {
                  _showImageSourceDialog();
                }
              },
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Stack(
            children: [
              if (_selectedImage != null)
                ClipOval(child: Image.file(_selectedImage!, width: 100, height: 100, fit: BoxFit.cover))
              else
                Center(child: SvgPicture.asset(AppIcons.photo, width: 32, height: 32, colorFilter: const ColorFilter.mode(Color(0xFF94A3B8), BlendMode.srcIn))),
              if (isUploading)
                Container(
                  decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                  child: Center(
                    child: CircularProgressIndicator(value: progress / 100, color: Colors.white, strokeWidth: 2),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(_selectedImage == null ? Icons.add_rounded : Icons.edit_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400, fontSize: 16),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20, right: 16),
          child: Icon(icon, size: 22, color: const Color(0xFF94A3B8)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 58),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppTheme.colors.primary.withOpacity(0.5), width: 1.5),
        ),
        errorStyle: TextStyle(fontSize: 12.sp),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return InkWell(
      onTap: () {
        final currencies = context.read<CurrencyBloc>().state.currencyModel?.result ?? [];
        AddClientDialogs.showCurrencySelection(context: context, currencies: currencies, selectedCurrency: _selectedCurrency, onSelected: (currency) => setState(() => _selectedCurrency = currency));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            const Icon(Icons.currency_exchange_rounded, size: 22, color: Color(0xFF94A3B8)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedCurrency?.name ?? 'Asosiy valyuta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _selectedCurrency != null ? FontWeight.w500 : FontWeight.w400,
                  color: _selectedCurrency != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isSubmitting) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: isSubmitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Saqlash', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
    );
  }
}
