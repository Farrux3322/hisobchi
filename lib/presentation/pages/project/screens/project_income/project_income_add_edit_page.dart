import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/application/project_income/project_income_bloc.dart';
import 'package:hisobchi/application/project_income/project_income_event.dart';
import 'package:hisobchi/application/project_income/project_income_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/currency/currency_model.dart' as currency;
import 'package:hisobchi/infrastructure/models/project_income_model.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:image_picker/image_picker.dart';

class ProjectIncomeAddEditPage extends StatefulWidget {
  final int projectId;
  final ProjectIncomeModel? income;

  const ProjectIncomeAddEditPage({
    super.key,
    required this.projectId,
    this.income,
  });

  @override
  State<ProjectIncomeAddEditPage> createState() => _ProjectIncomeAddEditPageState();
}

class _ProjectIncomeAddEditPageState extends State<ProjectIncomeAddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _summaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  currency.Result? _selectedCurrency;
  final List<ImageData> _images = [
    ImageData(),
    ImageData(),
    ImageData(),
  ];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.income != null;

    if (_isEditing) {
      _summaController.text = widget.income!.summa ?? '';
      _descriptionController.text = widget.income!.description ?? '';

      if (widget.income!.currencyTypeId != null) {
        _selectedCurrency = currency.Result(
          id: widget.income!.currencyTypeId,
          name: widget.income!.currencyTypeName,
        );
      }
    }

    // Load currencies
    context.read<CurrencyBloc>().add(const GetCurrency());
  }

  @override
  void dispose() {
    _summaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCurrency == null) {
        Toast.showErrorToast(message: 'Valyuta turini tanlang');
        return;
      }

      if (_images.any((img) => img.isUploading)) {
        Toast.showErrorToast(message: 'Rasmlar yuklanishini kuting');
        return;
      }

      final double summa = double.tryParse(_summaController.text.replaceAll(',', '').replaceAll(' ', '')) ?? 0;
      final fileIds = _images
          .where((img) => img.fileId != null)
          .map((img) => img.fileId!)
          .toList();

      if (_isEditing) {
        context.read<ProjectIncomeBloc>().add(
              UpdateProjectIncomeEvent(
                projectIncomeId: widget.income!.id!,
                currencyTypeId: _selectedCurrency!.id!,
                summa: summa,
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                fileId: fileIds.isEmpty ? null : fileIds,
                projectId: widget.projectId,
              ),
            );
      } else {
        context.read<ProjectIncomeBloc>().add(
              CreateProjectIncomeEvent(
                currencyTypeId: _selectedCurrency!.id!,
                summa: summa,
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                fileId: fileIds.isEmpty ? null : fileIds,
                projectId: widget.projectId,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Kirimni tahrirlash' : 'Yangi kirim',
          style: const TextStyle(
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
            BlocListener<ProjectIncomeBloc, ProjectIncomeState>(
              listenWhen: (previous, current) {
                // Faqat statusAction o'zgarganda va success yoki error bo'lganda listen qilish
                return previous.statusAction != current.statusAction &&
                    (current.statusAction == Status.success ||
                     current.statusAction == Status.error);
              },
              listener: (context, state) {
                if (state.statusAction == Status.success) {
                  Toast.showSuccessToast(
                    message: _isEditing ? 'Kirim yangilandi' : 'Kirim yaratildi',
                  );
                  Navigator.pop(context, true);
                }
                if (state.statusAction == Status.error) {
                  Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
                }
              },
            ),
          ],
          child: BlocBuilder<ProjectIncomeBloc, ProjectIncomeState>(
            builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCurrencySelector(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _summaController,
                          label: 'Summa*',
                          hint: 'Miqdorni kiriting',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Summani kiriting';
                            }
                            final number = double.tryParse(value.replaceAll(',', '').replaceAll(' ', ''));
                            if (number == null || number <= 0) {
                              return 'To\'g\'ri summa kiriting';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Izoh',
                          hint: 'Qo\'shimcha ma\'lumot',
                          icon: Icons.description_outlined,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Rasmlar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildImagePickers(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state.statusAction == Status.loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B4FFF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _isEditing ? 'Saqlash' : 'Yaratish',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.statusAction == Status.loading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: Loading()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            filled: true,
            fillColor: Colors.white,
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
              borderSide: const BorderSide(color: Color(0xFF5B4FFF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector() {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, currencyState) {
        final currencies = currencyState.currencyModel?.result ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Valyuta*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<currency.Result>(
                  value: _selectedCurrency,
                  isExpanded: true,
                  hint: const Row(
                    children: [
                      Icon(Icons.currency_exchange, color: Color(0xFF64748B), size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Valyutani tanlang',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      ),
                    ],
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                  items: currencies.map((currency.Result currencyItem) {
                    return DropdownMenuItem<currency.Result>(
                      value: currencyItem,
                      child: Row(
                        children: [
                          const Icon(Icons.currency_exchange, color: Color(0xFF64748B), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            currencyItem.name ?? '',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (currency.Result? value) {
                    setState(() {
                      _selectedCurrency = value;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
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

  Widget _buildImagePickers() {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
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
        final hasImage = imageData.file != null;
        final canAddImage = index == 0 || _images[index - 1].file != null;

        return GestureDetector(
          onTap: canAddImage && !hasImage ? () => _showImageSourceDialog(index) : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage
                    ? const Color(0xFF5B4FFF).withValues(alpha: 0.2)
                    : const Color(0xFFE2E8F0),
                width: hasImage ? 2 : 1,
              ),
            ),
            child: hasImage
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          imageData.file!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (imageData.isUploading) ...[
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    value: imageData.progress / 100,
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${imageData.progress.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10,
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
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: canAddImage
                              ? const Color(0xFF5B4FFF)
                              : const Color(0xFF94A3B8),
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          canAddImage ? 'Rasm' : 'Kutish',
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

  Future<void> _pickImage(ImageSource source, int index) async {
    if (index > 0 && _images[index - 1].file == null) {
      Toast.showErrorToast(message: 'Avval $index-rasmni yuklang');
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
              UploadFileEvent(file: imageFile, type: 'project_income'),
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
}

class ImageData {
  final File? file;
  final int? fileId;
  final bool isUploading;
  final double progress;

  ImageData({
    this.file,
    this.fileId,
    this.isUploading = false,
    this.progress = 0,
  });
}