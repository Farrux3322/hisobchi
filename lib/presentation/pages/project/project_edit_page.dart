import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/application/project/project_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/project/project_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
  final _maskFormatter = MaskTextInputFormatter(mask: '+998 (##) ###-##-##', filter: {"#": RegExp(r'[0-9]')}, type: MaskAutoCompletionType.lazy);

  File? _selectedImage;
  String? _initialImageUrl;
  int? _uploadedImageId;

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController(text: widget.projectModel.projectName);
    _ownerNameController = TextEditingController(text: widget.projectModel.projectOwner);
    _addressController = TextEditingController(text: widget.projectModel.address);
    _locationController = TextEditingController(text: widget.projectModel.location);

    final phone = widget.projectModel.phone ?? '';
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneDigits = digitsOnly.startsWith('998') && digitsOnly.length == 12 ? digitsOnly.substring(3) : digitsOnly;
    _phoneController = TextEditingController(text: _maskFormatter.maskText(phoneDigits));

    if (widget.projectModel.files != null && widget.projectModel.files!.isNotEmpty) {
      _initialImageUrl = widget.projectModel.files!.first.url;
      _uploadedImageId = widget.projectModel.files!.first.id;
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

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
          _initialImageUrl = null;
        });
        if (context.mounted) context.read<FileUploadBloc>().add(UploadFileEvent(file: imageFile, type: 'project'));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final digitsOnly = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final data = {
        'project_name': _projectNameController.text,
        'project_owner': _ownerNameController.text,
        'phone': digitsOnly,
        'address': _addressController.text,
        'location': _locationController.text,
        if (_uploadedImageId != null) 'file_id': [_uploadedImageId],
        if (_uploadedImageId == null && _selectedImage == null && _initialImageUrl == null && widget.projectModel.files?.isNotEmpty == true) 'file_id': [],
      };
      context.read<ProjectBloc>().add(UpdateProjectEvent(data: data, id: widget.projectModel.id!));
    }
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
        BlocListener<ProjectBloc, ProjectState>(
          listener: (context, state) {
            if (state.statusAdd == Status.success) Navigator.pop(context, true);
            if (state.statusAdd == Status.error) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Error'), backgroundColor: Colors.red));
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
                  const BoxShadow(color: Color.fromRGBO(255, 255, 255, 0.1), blurRadius: 1, spreadRadius: 0, offset: Offset(0, 1)),
                  const BoxShadow(color: Color.fromRGBO(50, 50, 93, 0.25), blurRadius: 100, spreadRadius: -20, offset: Offset(0, 50)),
                  const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 60, spreadRadius: -30, offset: Offset(0, 30)),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          centerTitle: true,
          title: const Text(
            'Tahrirlash',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          actions: [
            if (widget.projectModel.deletedAt == null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                onPressed: _showDeleteDialog,
              )
            else
              _buildDeletedProjectMenu(),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildDeletedProjectMenu() {
    return PopupMenuButton<String>(
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
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.restore, color: Color(0xFF10B981), size: 20),
              ),
              const Gap(12),
              const Text('Tiklash', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'force_delete',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.delete_forever, color: Color(0xFFEF4444), size: 20),
              ),
              const Gap(12),
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
        } else if (value == 'force_delete')
          _showForceDeleteDialog();
      },
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, projectState) {
        return BlocBuilder<FileUploadBloc, FileUploadState>(
          builder: (context, uploadState) {
            final isUploading = uploadState.status == FileUploadStatus.uploading;
            final isSaving = projectState.statusAdd == Status.loading;

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
                          const Gap(40),
                          _buildMinimalInput(
                            controller: _projectNameController,
                            hint: 'Loyiha nomi',
                            icon: Icons.business_center_outlined,
                            validator: (v) => (v == null || v.isEmpty) ? 'Loyiha nomi kiritilmagan' : null,
                          ),
                          const Gap(12),
                          _buildMinimalInput(
                            controller: _ownerNameController,
                            hint: 'Loyiha egasi',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.isEmpty) ? 'Loyiha egasi kiritilmagan' : null,
                          ),
                          const Gap(12),
                          _buildMinimalInput(
                            controller: _phoneController,
                            hint: 'Telefon raqami',
                            icon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                            formatters: [_maskFormatter],
                            validator: (v) {
                              final digits = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                              return digits.length != 12 ? 'Telefon raqam to\'liq emas' : null;
                            },
                          ),
                          const Gap(12),
                          _buildMinimalInput(
                            controller: _addressController,
                            hint: 'Manzil',
                            icon: Icons.location_on_outlined,
                            validator: (v) => (v == null || v.isEmpty) ? 'Manzil kiritilmagan' : null,
                          ),
                          const Gap(12),
                          _buildMinimalInput(controller: _locationController, hint: 'Lokatsiya (ixtiyoriy)', icon: Icons.map_outlined),
                          const Gap(12),
                          _buildSubmitButton(isSaving, isUploading),
                          const Gap(32),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isSaving) const Loading(),
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
        onTap: isUploading ? null : () => _showImageSourceDialog(context),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Stack(
            children: [
              _buildImagePreview(),
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
                  child: Icon(_selectedImage == null && _initialImageUrl == null ? Icons.add_rounded : Icons.edit_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return ClipOval(child: Image.file(_selectedImage!, width: 100, height: 100, fit: BoxFit.cover));
    } else if (_initialImageUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _initialImageUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CupertinoActivityIndicator()),
          errorWidget: (context, url, error) => Center(child: SvgPicture.asset(AppIcons.photo, width: 32, height: 32, colorFilter: const ColorFilter.mode(Color(0xFF94A3B8), BlendMode.srcIn))),
        ),
      );
    } else {
      return Center(child: SvgPicture.asset(AppIcons.photo, width: 32, height: 32, colorFilter: const ColorFilter.mode(Color(0xFF94A3B8), BlendMode.srcIn)));
    }
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
          borderSide: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
        errorStyle: TextStyle(fontSize: 12.sp),
      ),
    );
  }

  Widget _buildSubmitButton(bool isSaving, bool isUploading) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: (isSaving || isUploading) ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: (isSaving || isUploading)
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Saqlash', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
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
            const Gap(32),
            _buildSourceItem(Icons.camera_alt_rounded, 'Kamera', const Color(0xFF6366F1), () {
              Navigator.pop(builderContext);
              _pickImage(ImageSource.camera, context);
            }),
            const Gap(12),
            _buildSourceItem(Icons.photo_library_rounded, 'Galereya', const Color(0xFF10B981), () {
              Navigator.pop(builderContext);
              _pickImage(ImageSource.gallery, context);
            }),
            if (_selectedImage != null || _initialImageUrl != null) ...[
              const Gap(12),
              _buildSourceItem(Icons.delete_outline_rounded, 'O\'chirish', Colors.redAccent, () {
                Navigator.pop(builderContext);
                setState(() {
                  _selectedImage = null;
                  _initialImageUrl = null;
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

  Future<void> _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ManagementActionDialog(
        title: 'Loyihani o\'chirish',
        message: '${widget.projectModel.projectName} loyihasini o\'chirishni xohlaysizmi?',
        confirmText: 'O\'chirish',
        warningText: 'Loyihani keyinchalik qayta tiklash mumkin',
        gradientColors: const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        icon: Icons.delete_outline,
        onConfirm: () => context.read<ProjectBloc>().add(DeleteProjectEvent(id: widget.projectModel.id!)),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context, {'action': 'delete'});
    }
  }

  Future<void> _showRestoreDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ManagementActionDialog(
        title: 'Loyihani tiklash',
        message: '${widget.projectModel.projectName} loyihasini tiklashni xohlaysizmi?',
        confirmText: 'Tiklash',
        warningText: 'Loyiha barcha ma\'lumotlari bilan tiklanadi',
        gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
        icon: Icons.restore,
        onConfirm: () => context.read<ProjectBloc>().add(RestoreProjectEvent(id: widget.projectModel.id!)),
      ),
    );
    if (result == true && mounted) Navigator.pop(context, {'action': 'restore'});
  }

  Future<void> _showForceDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ManagementActionDialog(
        title: 'Butunlay o\'chirish',
        message: '${widget.projectModel.projectName} loyihasini butunlay o\'chirishni xohlaysizmi?',
        confirmText: 'O\'chirish',
        warningText: 'Bu amal qaytarib bo\'lmaydi!\nBarcha ma\'lumotlar butunlay yo\'qoladi',
        gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
        icon: Icons.delete_forever,
        isForce: true,
        onConfirm: () => context.read<ProjectBloc>().add(ForceDeleteProjectEvent(id: widget.projectModel.id!)),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context, {'action': 'force_delete'});
    }
  }
}

class _ManagementActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String warningText;
  final List<Color> gradientColors;
  final IconData icon;
  final VoidCallback onConfirm;
  final bool isForce;

  const _ManagementActionDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.warningText,
    required this.gradientColors,
    required this.icon,
    required this.onConfirm,
    this.isForce = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state.statusAction == Status.success) {
          HapticFeedback.mediumImpact();
          Toast.showSuccessToast(message: 'Muvaffaqiyatli bajarildi');
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).maybePop(true);
          }
        } else if (state.statusAction == Status.error) {
          Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).maybePop(false);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state.statusAction == Status.loading;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : Icon(icon, color: Colors.white, size: 40),
                ),
                const Gap(24),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                  textAlign: TextAlign.center,
                ),
                const Gap(12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: gradientColors.first.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    warningText,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: gradientColors.last),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'Bekor qilish',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                onConfirm();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: gradientColors.last,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(confirmText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
  }
}
