import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/project/project_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/widgets/project_delete_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProjectEditPage extends StatefulWidget {
  final ProjectModel projectModel;

  const ProjectEditPage({super.key, required this.projectModel});

  @override
  State<ProjectEditPage> createState() => _ProjectEditPageState();
}

class _ProjectEditPageState extends State<ProjectEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _projectNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _locationController;
  final ImagePicker _picker = ImagePicker();
  late final MaskTextInputFormatter _maskFormatter;

  File? _selectedImage;
  String? _initialImageUrl; // Boshlang'ich rasm URL

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController(text: widget.projectModel.projectName);
    _ownerNameController = TextEditingController(text: widget.projectModel.projectOwner);
    _addressController = TextEditingController(text: widget.projectModel.address);
    _locationController = TextEditingController(text: widget.projectModel.location);

    // Initialize mask formatter
    _maskFormatter = MaskTextInputFormatter(
      mask: '+998 (##) ###-##-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

    // Format phone number
    final phone = widget.projectModel.phone ?? '';
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    // Remove leading 998 if present (since mask already has +998)
    final phoneDigits = digitsOnly.startsWith('998') && digitsOnly.length == 12
        ? digitsOnly.substring(3)
        : digitsOnly;
    final formattedPhone = _maskFormatter.maskText(phoneDigits);
    _phoneController = TextEditingController(text: formattedPhone);

    // Initial image URL ni olish
    if (widget.projectModel.files != null && widget.projectModel.files!.isNotEmpty) {
      _initialImageUrl = widget.projectModel.files!.first;
    }
  }

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
                  if (_selectedImage != null || _initialImageUrl != null) ...[
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
                          _initialImageUrl = null;
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
          _initialImageUrl = null; // Clear initial image
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
        if (_selectedImage != null) 'files': [],
      };

      context.read<ProjectBloc>().add(UpdateProjectEvent(data: data, id: widget.projectModel.id!));
      // Navigator.pop(context);
    }
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Loyihani o\'chirish',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.projectModel.projectName} loyihasini o\'chirishni xohlaysizmi?',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Loyihani keyinchalik qayta tiklash mumkin',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFF59E0B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: const Text(
                          'Bekor qilish',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFFBBF24),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'O\'chirish',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && mounted) {
      HapticFeedback.mediumImpact();
      context.read<ProjectBloc>().add(DeleteProjectEvent(id: widget.projectModel.id!));
      Toast.showSuccessToast(message: 'Loyiha o\'chirildi');
      Navigator.pop(context, true);
    }
  }

  /// Show restore confirmation dialog
  Future<void> _showRestoreDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(Icons.restore, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Loyihani tiklash',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.projectModel.projectName} loyihasini tiklashni xohlaysizmi?',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Loyiha barcha ma\'lumotlari bilan tiklanadi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF059669),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: const Text(
                          'Bekor qilish',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tiklash',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && mounted) {
      HapticFeedback.mediumImpact();
      context.read<ProjectBloc>().add(RestoreProjectEvent(id: widget.projectModel.id!));
      Toast.showSuccessToast(message: 'Loyiha tiklandi');
      Navigator.pop(context, true);
    }
  }

  /// Show force delete confirmation dialog
  Future<void> _showForceDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Butunlay o\'chirish',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.projectModel.projectName} loyihasini butunlay o\'chirishni xohlaysizmi?',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '⚠️ DIQQAT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Bu amal qaytarib bo\'lmaydi!\nBarcha ma\'lumotlar butunlay yo\'qoladi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFDC2626),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: const Text(
                          'Bekor qilish',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'O\'chirish',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && mounted) {
      HapticFeedback.heavyImpact();
      context.read<ProjectBloc>().add(ForceDeleteProjectEvent(id: widget.projectModel.id!));
      Toast.showSuccessToast(message: 'Loyiha butunlay o\'chirildi');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FileUploadBloc(
        repository: FileUploadRepository(),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Loyihani tahrirlash',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.projectModel.deletedAt == null)
            // Normal project - show delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              onPressed: () => _showDeleteDialog(),
              tooltip: 'O\'chirish',
            )
          else
            // Deleted project - show popup menu with restore and force delete
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF1E293B)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              offset: const Offset(0, 50),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.restore, color: Color(0xFF10B981), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tiklash',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'force_delete',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_forever, color: Color(0xFFEF4444), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Butunlay o\'chirish',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'restore') {
                  _showRestoreDialog();
                } else if (value == 'force_delete') {
                  _showForceDeleteDialog();
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w).copyWith(bottom: MediaQuery
            .of(context)
            .padding
            .bottom),
        child: BlocConsumer<ProjectBloc, ProjectState>(
          listener: (context, state) {
           if(state.statusAdd==Status.success){
             Navigator.pop(context,true);
           }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Column(
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
                                      hintText: 'Masalan: Chilonzor-10 turar joy majmuasi',
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
                                    decoration: const InputDecoration(
                                      hintText: '+998 (00) 000-00-00',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Iltimos, telefon raqamni kiriting';
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
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: 'Masalan: Toshkent sh., Chilonzor tumani, Bunyodkor ko\'chasi, 10-uy',
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
                                  BlocBuilder<FileUploadBloc, FileUploadState>(
                                    builder: (context, uploadState) {
                                      return Center(
                                        child: GestureDetector(
                                          onTap: () => _showImageSourceDialog(context),
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
                                                    : _initialImageUrl != null
                                                    ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(18),
                                                  child: CachedNetworkImage(
                                                    imageUrl: _initialImageUrl!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) =>  Center(
                                                      child: CupertinoActivityIndicator(color: AppTheme.colors.primary),
                                                    ),
                                                    errorWidget: (context, url, error) => Padding(
                                                      padding: const EdgeInsets.all(35),
                                                      child: SvgPicture.asset(AppIcons.photo),
                                                    ),
                                                  ),
                                                )
                                                    : Padding(
                                                  padding: const EdgeInsets.all(35),
                                                  child: SvgPicture.asset(AppIcons.photo),
                                                ),
                                              ),
                                              if (uploadState.status == FileUploadStatus.uploading && _selectedImage != null)
                                                Positioned.fill(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(18),
                                                    child: Container(
                                                      color: Colors.black.withValues(alpha: 0.5),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            SizedBox(
                                                              width: 40,
                                                              height: 40,
                                                              child: CircularProgressIndicator(
                                                                value: uploadState.progress,
                                                                strokeWidth: 3,
                                                                backgroundColor: Colors.white.withValues(alpha: 0.3),
                                                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Text(
                                                              '${(uploadState.progress * 100).toInt()}%',
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
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
                          'Loyihani saqlash',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if(state.statusAdd==Status.loading)Loading()
              ],
            );
          },
        ),
      ),
      ),
    );
  }
}