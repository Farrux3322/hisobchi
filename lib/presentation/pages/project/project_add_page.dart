import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ProjectAddPage extends StatefulWidget {
  const ProjectAddPage({super.key});

  @override
  State<ProjectAddPage> createState() => _ProjectAddPageState();
}

class _ProjectAddPageState extends State<ProjectAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+998 ');
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  File? _selectedImage;
  int? _uploadedImageId;
  final _maskFormatter = MaskTextInputFormatter(
    mask: '+998 (##) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );




  @override
  void dispose() {
    _projectNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog(BuildContext blocContext) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
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
                    title: const Text(
                      'Kamera',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Yangi rasm olish',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _pickImage(ImageSource.camera, blocContext);
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
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    title: const Text(
                      'Galereya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Mavjud rasmdan tanlash',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _pickImage(ImageSource.gallery, blocContext);
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
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      title: const Text(
                        'Rasmni o\'chirish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(dialogContext);
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

  Future<void> _pickImage(ImageSource source, BuildContext blocContext) async {
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

        // Darhol yuklashni boshlash
        if (mounted) {
          blocContext.read<FileUploadBloc>().add(UploadFileEvent(file: imageFile, type: 'project'));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final digitsOnly = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

      final data = {
        'project_name': _projectNameController.text,
        'project_owner': _ownerNameController.text,
        'phone': digitsOnly,
        'address': _addressController.text,
        'location': _locationController.text,
        if (_uploadedImageId != null) 'file_id': [_uploadedImageId],
      };

      context.read<ProjectBloc>().add(CreateProjectEvent(data: data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FileUploadBloc(
        repository: FileUploadRepository(),
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<FileUploadBloc, FileUploadState>(
            listener: (context, state) {
              if (state.status == FileUploadStatus.success) {
                setState(() {
                  _uploadedImageId = state.uploadedFileId;
                  _isLoading = false;
                });
              } else if (state.status == FileUploadStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Rasm yuklashda xatolik: ${state.errorMessage ?? "Noma'lum xatolik"}',
                    ),
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
          ),
          BlocListener<ProjectBloc, ProjectState>(
            listener: (context, state) {
              if (state.statusAdd == Status.success) {
                Navigator.pop(context, true);
              } else if (state.statusAdd == Status.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'Xatolik yuz berdi'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
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

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Loyiha qo\'shish',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: EdgeInsets.all(20.w).copyWith(bottom: MediaQuery.of(context).padding.bottom),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: ListView(
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10.h),

                                // Loyiha nomi input
                                RichText(
                            text: const TextSpan(
                              text: 'Loyiha nomi ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: _projectNameController,
                            decoration: const InputDecoration(
                              hintText: 'Loyiha nomi',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Iltimos, loyiha nomini kiriting';
                              }
                              if (value.length < 3) {
                                return 'Loyiha nomi kamida 3 ta belgidan iborat bo\'lishi kerak';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),

                          // Loyiha egasi input
                          RichText(
                            text: const TextSpan(
                              text: 'Loyiha egasi ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: _ownerNameController,
                            decoration: const InputDecoration(
                              hintText: 'Masalan: Alisher Navoiy',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Iltimos, loyiha egasining ismini kiriting';
                              }
                              if (value.length < 2) {
                                return 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),

                          // Telefon raqami input
                          RichText(
                            text: const TextSpan(
                              text: 'Telefon raqami ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_maskFormatter],
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
                          SizedBox(height: 20.h),

                          // Manzil input
                          RichText(
                            text: const TextSpan(
                              text: 'Manzil ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: _addressController,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              hintText: 'Masalan: Toshkent sh.',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Iltimos, manzilni kiriting';
                              }
                              if (value.length < 5) {
                                return 'Manzil kamida 5 ta belgidan iborat bo\'lishi kerak';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),

                          // Lokatsiya input
                          const Text(
                            'Lokatsiya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              hintText: 'Lokatsiya havolasini kiriting...',
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Rasm yuklash
                          Center(
                            child: GestureDetector(
                              onTap: isUploading ? null : () => _showImageSourceDialog(context),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 2,
                                      ),
                                    ),
                                    child: _selectedImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(18),
                                            child: Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(35),
                                            child: SvgPicture.asset(AppIcons.photo),
                                          ),
                                  ),

                                  // Upload Progress Overlay
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
                                                valueColor: const AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                                strokeWidth: 3,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${uploadState.progress.toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Yuklanmoqda...',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.colors.primary,
                                            AppTheme.colors.primary.withOpacity(0.8),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.colors.primary.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _selectedImage != null
                                            ? Icons.edit_rounded
                                            : Icons.add_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52.h,
                                    child: ElevatedButton(
                                      onPressed: _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.colors.primary,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: AppTheme.colors.gray,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Loyiha qo\'shish',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ));
                  }
                }

// Telefon raqam formatter
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    String formatted = '+998';

    if (digitsOnly.length > 3) {
      formatted +=
          ' (${digitsOnly.substring(3, digitsOnly.length > 5 ? 5 : digitsOnly.length)}';
      if (digitsOnly.length >= 5) {
        formatted += ')';
      }
    }

    if (digitsOnly.length > 5) {
      formatted +=
          ' ${digitsOnly.substring(5, digitsOnly.length > 8 ? 8 : digitsOnly.length)}';
    }

    if (digitsOnly.length > 8) {
      formatted +=
          '-${digitsOnly.substring(8, digitsOnly.length > 10 ? 10 : digitsOnly.length)}';
    }

    if (digitsOnly.length > 10) {
      formatted +=
          '-${digitsOnly.substring(10, digitsOnly.length > 12 ? 12 : digitsOnly.length)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}