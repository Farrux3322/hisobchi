import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/contract/contract_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/application/work_type/work_type_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/contract_model.dart';
import 'package:hisobchi/infrastructure/models/work_type_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/full_screen_photo.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/work_type_list_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';

class ContractEditPage extends StatefulWidget {
  final ContractModel contract;

  const ContractEditPage({super.key, required this.contract});

  @override
  State<ContractEditPage> createState() => _ContractEditPageState();
}

class _ContractEditPageState extends State<ContractEditPage> {
  final TextEditingController _workTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<ImageData> _images = [
    ImageData(),
    ImageData(),
    ImageData(),
  ];
  bool _isAdvancePayment = false;
  WorkTypeModel? _selectedWorkType;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Set work type
    _workTypeController.text = widget.contract.workTypeName ?? '';
    _selectedWorkType = WorkTypeModel(
      id: widget.contract.workTypeId,
      name: widget.contract.workTypeName,
    );

    // Set description
    _descriptionController.text = widget.contract.description ?? '';

    // Set amount with formatting
    if (widget.contract.summa != null && widget.contract.summa!.isNotEmpty) {
      final amount = int.tryParse(widget.contract.summa!) ?? 0;
      _amountController.text = _formatNumber(amount);
    }

    // Set existing images
    if (widget.contract.files != null && widget.contract.files!.isNotEmpty) {
      for (int i = 0; i < widget.contract.files!.length && i < 3; i++) {
        _images[i] = ImageData(networkUrl: widget.contract.files![i].url);
      }
    }
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final result = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        result.write(' ');
      }
      result.write(str[i]);
    }

    return result.toString();
  }

  @override
  void dispose() {
    _workTypeController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog(int index) async {
    await showModalBottomSheet(
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
                        color: const Color(0xFF5B4FFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Color(0xFF5B4FFF),
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
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, index);
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
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
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, index);
                    },
                  ),
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
    if (index > 0 && _images[index - 1].file == null && _images[index - 1].networkUrl == null) {
      Toast.showErrorToast(message: 'Avval ${index}-rasmni yuklang');
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null && mounted) {
        final imageFile = File(image.path);
        setState(() {
          _images[index] = ImageData(file: imageFile, isUploading: true);
        });

        context.read<FileUploadBloc>().add(
              UploadFileEvent(file: imageFile, type: 'contract'),
            );
      }
    } catch (e) {
      Toast.showErrorToast(message: 'Xatolik yuz berdi: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      for (int i = index; i < _images.length; i++) {
        _images[i] = ImageData();
      }
    });
    context.read<FileUploadBloc>().add(ResetUploadEvent());
  }

  Future<void> _showWorkTypeBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<WorkTypeBloc>(),
        child: WorkTypeListBottomSheet(
          onSelect: (workType) {
            setState(() {
              _selectedWorkType = workType;
              _workTypeController.text = workType.name ?? '';
            });
          },
        ),
      ),
    );
  }

  bool _validateForm() {
    if (_workTypeController.text.trim().isEmpty) {
      Toast.showErrorToast(message: 'Ish turini tanlang');
      return false;
    }

    if (_amountController.text.trim().isEmpty) {
      Toast.showErrorToast(message: 'Kelishuv summasini kiriting');
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      Toast.showErrorToast(message: 'Kelishuv tafsilotlarini kiriting');
      return false;
    }

    if (_images.any((img) => img.isUploading)) {
      Toast.showErrorToast(message: 'Rasmlar yuklanishini kuting');
      return false;
    }

    return true;
  }

  void _updateContract() {
    if (!_validateForm()) return;

    // Collect file IDs (both new uploads and existing network images)
    final List<int> fileIds = [];

    for (var img in _images) {
      if (img.fileId != null) {
        // New uploaded image
        fileIds.add(img.fileId!);
      } else if (img.networkUrl != null && widget.contract.files != null) {
        // Existing image - find ID by URL
        for (var f in widget.contract.files!) {
          if (f.url == img.networkUrl) {
            if (f.id != null) fileIds.add(f.id!);
            break;
          }
        }
      }
    }

    // If no new files uploaded, use empty array (API will keep existing ones)
    final contractData = {
      'work_type_id': _selectedWorkType?.id,
      'description': _descriptionController.text.trim(),
      'summa': _amountController.text.trim().replaceAll(' ', ''),
      'file_id': fileIds,
      'project_id': widget.contract.projectId,
    };

    context.read<ContractBloc>().add(
          UpdateContractEvent(
            data: contractData,
            id: widget.contract.id!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: BackArrowButton(),
        title: const Text(
          'Shartnomani tahrirlash',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FileUploadBloc, FileUploadState>(
            listener: (context, state) {
              if (state.status == FileUploadStatus.success) {
                final uploadingIndex = _images.indexWhere((img) => img.isUploading);
                if (uploadingIndex != -1) {
                  setState(() {
                    _images[uploadingIndex] = ImageData(
                      file: _images[uploadingIndex].file,
                      fileId: state.uploadedFileId,
                      isUploading: false,
                      progress: 100,
                    );
                  });
                }
              } else if (state.status == FileUploadStatus.failure) {
                final uploadingIndex = _images.indexWhere((img) => img.isUploading);
                if (uploadingIndex != -1) {
                  setState(() {
                    _images[uploadingIndex] = ImageData();
                  });
                }
                Toast.showErrorToast(
                  message: 'Rasm yuklashda xatolik: ${state.errorMessage}',
                );
              } else if (state.status == FileUploadStatus.uploading) {
                final uploadingIndex = _images.indexWhere((img) => img.isUploading);
                if (uploadingIndex != -1) {
                  setState(() {
                    _images[uploadingIndex] = ImageData(
                      file: _images[uploadingIndex].file,
                      isUploading: true,
                      progress: state.progress,
                    );
                  });
                }
              }
            },
          ),
          BlocListener<ContractBloc, ContractState>(
            listener: (context, state) {
              if (state.statusAction == Status.success) {
                Toast.showSuccessToast(message: 'Shartnoma muvaffaqiyatli yangilandi');
                Navigator.pop(context, true);
              } else if (state.statusAction == Status.error) {
                Toast.showErrorToast(
                  message: state.errorMessage ?? 'Shartnoma yangilanmadi',
                );
              }
            },
          ),
        ],
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Ish turi', isRequired: true),
                    const SizedBox(height: 12),
                    _buildWorkTypeField(),
                    const SizedBox(height: 24),
                    _buildSectionTitle("O'zaro kelishuv tafsilotlari"),
                    const SizedBox(height: 12),
                    _buildDescriptionField(),
                    const SizedBox(height: 12),
                    _buildSectionTitle('Kelishuv summa', isRequired: true),
                    const SizedBox(height: 12),
                    _buildAmountField(),
                    const SizedBox(height: 12),
                    _buildSectionTitle('Shartnoma rasmlari', isRequired: true),
                    const SizedBox(height: 12),
                    _buildImagePickers(),
                    const SizedBox(height: 24),
                    _buildUpdateButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            BlocBuilder<ContractBloc, ContractState>(
              builder: (context, state) {
                if (state.statusAction == Status.loading) {
                  return Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: Loading()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWorkTypeField() {
    return GestureDetector(
      onTap: _showWorkTypeBottomSheet,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.work_outline,
              size: 20,
              color: Color(0xFF5B4FFF),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _workTypeController.text.isEmpty
                    ? 'Ish turini tanlang...'
                    : _workTypeController.text,
                style: TextStyle(
                  fontSize: 15,
                  color: _workTypeController.text.isEmpty
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                  fontWeight: _workTypeController.text.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 5,
        maxLength: 100,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1E293B),
        ),
        decoration: const InputDecoration(
          counter: SizedBox(),
          hintText: 'Shartnoma tafsilotlarini kiriting...',
          hintStyle: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,maxLength: 14,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ThousandsSeparatorFormatter(),
      ],
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
      decoration: const InputDecoration(
        hintText: '',
        counter: SizedBox(),
        hintStyle: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        suffixText: ' UZS',
        suffixStyle: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildImagePickers() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        final imageData = _images[index];
        final hasImage = imageData.file != null || imageData.networkUrl != null;
        final canAddImage = index == 0 ||
            (_images[index - 1].file != null || _images[index - 1].networkUrl != null);

        return GestureDetector(
          onTap: canAddImage && !hasImage ? () => _showImageSourceDialog(index) : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasImage
                    ? const Color(0xFF5B4FFF).withValues(alpha: 0.2)
                    : const Color(0xFFE2E8F0),
                width: hasImage ? 2 : 1,
              ),
              boxShadow: hasImage
                  ? [
                      BoxShadow(
                        color: const Color(0xFF5B4FFF).withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: hasImage
                ? Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final validImages = _images
                              .where((img) =>
                                  img.file != null || img.networkUrl != null)
                              .toList();
                          final initialIndex = validImages.indexOf(imageData);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageViewerPage(
                                images: validImages.map((img) {
                                  if (img.file != null) {
                                    return ImageItem(
                                        path: img.file!.path, isNetwork: false);
                                  } else {
                                    return ImageItem(
                                        path: img.networkUrl!, isNetwork: true);
                                  }
                                }).toList(),
                                initialIndex: initialIndex,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: imageData.file != null
                              ? Image.file(
                                  imageData.file!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: imageData.networkUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF5B4FFF),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      if (imageData.isUploading) ...[
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    value: imageData.progress / 100,
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${imageData.progress.toStringAsFixed(0)}%',
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
                      ] else ...[
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                        if (imageData.file != null || imageData.fileId != null)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: canAddImage
                                ? const Color(0xFF5B4FFF).withValues(alpha: 0.1)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: canAddImage
                                ? const Color(0xFF5B4FFF)
                                : const Color(0xFF94A3B8),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          canAddImage ? 'Rasm qo\'shish' : 'Kutilmoqda',
                          style: TextStyle(
                            fontSize: 11,
                            color: canAddImage
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.colors.primary,
        boxShadow: [
          BoxShadow(
            color:  AppTheme.colors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _updateContract,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 20),
            SizedBox(width: 8),
            Text(
              'Shartnomani yangilash',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageData {
  final File? file;
  final int? fileId;
  final String? networkUrl;
  final bool isUploading;
  final double progress;

  ImageData({
    this.file,
    this.fileId,
    this.networkUrl,
    this.isUploading = false,
    this.progress = 0,
  });
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll(' ', ''));
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatNumber(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final result = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        result.write(' ');
      }
      result.write(str[i]);
    }

    return result.toString();
  }
}