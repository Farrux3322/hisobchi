import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/application/partner/partner_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class EditClientBottomSheet extends StatefulWidget {
  final Function(String name, String phone, String? additionalPhone, int? imageId)? onSubmit;
  final PartnerModel partnerModel;

  const EditClientBottomSheet({
    super.key,
    this.onSubmit,
   required this.partnerModel,
  });

  @override
  State<EditClientBottomSheet> createState() => _AddClientBottomSheetState();

  static Future<void> show(
      BuildContext context, {
        required PartnerModel partnerModel,
        Function(String name, String phone, String? additionalPhone, int? imageId)? onSubmit,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => FileUploadBloc(
          repository: FileUploadRepository(),
        ),
        child: EditClientBottomSheet(
          partnerModel: partnerModel,
          onSubmit: onSubmit,
        ),
      ),
    );
  }
}

class _AddClientBottomSheetState extends State<EditClientBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _additionalPhoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late var maskFormatter1 = MaskTextInputFormatter(
    mask: '+998 (##) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    initialText: widget.partnerModel.phone ?? "+998",
    type: MaskAutoCompletionType.lazy,
  );
  late var maskFormatter2 = MaskTextInputFormatter(
    mask: '+998 (##) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    initialText: widget.partnerModel.additionalPhone ?? "+998",
    type: MaskAutoCompletionType.lazy,
  );
  bool _isLoading = false;
  File? _selectedImage;
  int? _uploadedImageId;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _additionalPhoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _nameController.text = widget.partnerModel.name ?? '';
    _phoneController.text = widget.partnerModel.phone ?? '';
    _additionalPhoneController.text = widget.partnerModel.additionalPhone ?? '';
    super.initState();
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
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Rasm tanlash',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    title: const Text('Kamera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: const Text('Yangi rasm olish', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981)),
                    ),
                    title: const Text('Galereya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: const Text('Mavjud rasmdan tanlash', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                      ),
                      title: const Text('Rasmni o\'chirish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFEF4444))),
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
        });

        if (mounted) {
          context.read<FileUploadBloc>().add(UploadFileEvent(file: imageFile,type: 'client'));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final additionalPhone = _additionalPhoneController.text.trim().isEmpty
        ? null
        : _additionalPhoneController.text;

    _submitClient(additionalPhone, _uploadedImageId);
  }

  void _submitClient(String? additionalPhone, int? imageId) {
    final data = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'additional_phone': additionalPhone,
      if (imageId != null) 'file_id': [imageId],
    };

    context.read<PartnerBloc>().add(
      UpdateEvent(
        data: data,
        id: widget.partnerModel.id ?? 0,
      ),
    );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rasm yuklashda xatolik: ${state.errorMessage ?? "Noma'lum xatolik"}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
                    Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
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
                                Center(
                                  child: Container(
                                    width: 62,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppTheme.colors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text('Mijoz tahrirlash', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                                const SizedBox(height: 24),

                                // Camera/Avatar with Image Preview
                                Center(
                                  child: GestureDetector(
                                    onTap: isUploading ? null : _showImageSourceDialog,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(18),
                                            child: _selectedImage != null
                                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                                : (widget.partnerModel.files != null && widget.partnerModel.files!.isNotEmpty)
                                                ? CachedNetworkImage(
                                              imageUrl: widget.partnerModel.files!.first,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const Center(
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                              errorWidget: (context, url, error) => Padding(
                                                padding: const EdgeInsets.all(35),
                                                child: SvgPicture.asset(AppIcons.photo),
                                              ),
                                            )
                                                : Padding(
                                              padding: const EdgeInsets.all(35),
                                              child: SvgPicture.asset(AppIcons.photo),
                                            ),
                                          ),
                                        ),
                                        if (isUploading)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: CircularProgressIndicator(
                                                      value: uploadState.progress / 100,
                                                      backgroundColor: Colors.white.withOpacity(0.3),
                                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                                      strokeWidth: 3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text('${uploadState.progress.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
                                RichText(text: const TextSpan(text: 'Ism ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)), children: [TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Mijozni ismini kiriting...',
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Iltimos, ism kiriting';
                                    if (value.length < 2) return 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Tel raqami input
                                RichText(text: const TextSpan(text: 'Tel raqami ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)), children: [TextSpan(text: '*', style: TextStyle(color: Colors.red))])),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [maskFormatter1],
                                  decoration: InputDecoration(
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Iltimos, telefon raqam kiriting';
                                    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                                    if (digitsOnly.length != 12) return 'Telefon raqam to\'liq emas';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Qo'shimcha tel raqami input (optional)
                                const Text('Qo\'shimcha tel raqami', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _additionalPhoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [maskFormatter2],
                                  decoration: InputDecoration(
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
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
                                      disabledBackgroundColor: const Color(0xFF6366F1).withOpacity(0.6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: const Text('Mijoz tahrirlash', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                            if (state.statusAdd == Status.loading) Padding(
                              padding:  EdgeInsets.only(top: (MediaQuery.of(context).size.height/3)),
                              child: Loading(),
                            )

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