import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/widgets/project_income_currency_selector.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/widgets/project_income_header.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/widgets/project_income_image_picker.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/widgets/project_income_inputs.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_income/widgets/project_income_submit_button.dart';
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

class _ProjectIncomeAddEditPageState extends State<ProjectIncomeAddEditPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _summaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  currency.Result? _selectedCurrency;
  final List<ImageData> _images = [
    ImageData(),
    ImageData(),
    ImageData(),
  ];
  bool _isEditing = false;
  final FocusNode _summaFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');
    if (cleanValue.isEmpty) return '';

    final reversed = cleanValue.split('').reversed.join();
    final chunks = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      chunks.add(reversed.substring(i, end > reversed.length ? reversed.length : end));
    }
    return chunks.join(' ').split('').reversed.join();
  }

  @override
  void initState() {
    super.initState();
    _isEditing = widget.income != null;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();

    if (_isEditing) {
      final summa = widget.income!.summa ?? '';
      _summaController.text = _formatNumber(summa);
      _descriptionController.text = widget.income!.description ?? '';

      if (widget.income!.currencyTypeId != null) {
        _selectedCurrency = currency.Result(
          id: widget.income!.currencyTypeId,
          name: widget.income!.currencyTypeName,
        );
      }

      if (widget.income!.files != null && widget.income!.files!.isNotEmpty) {
        for (int i = 0; i < widget.income!.files!.length && i < 3; i++) {
          final file = widget.income!.files![i];
          _images[i] = ImageData(existingUrl: file.url, existingId: file.id);
        }
      }
    }

    context.read<CurrencyBloc>().add(const GetCurrency());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _summaController.dispose();
    _descriptionController.dispose();
    _summaFocusNode.dispose();
    _descriptionFocusNode.dispose();
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
      final fileIds = _images.map((img) => img.fileId ?? img.existingId).whereType<int>().toList();

      if (_isEditing) {
        context.read<ProjectIncomeBloc>().add(
              UpdateProjectIncomeEvent(
                projectIncomeId: widget.income!.id!,
                currencyTypeId: _selectedCurrency!.id!,
                summa: summa,
                description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                fileId: fileIds.isEmpty ? [] : fileIds,
                projectId: widget.projectId,
              ),
            );
      } else {
        context.read<ProjectIncomeBloc>().add(
              CreateProjectIncomeEvent(
                currencyTypeId: _selectedCurrency!.id!,
                summa: summa,
                description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                fileId: fileIds.isEmpty ? [] : fileIds,
                projectId: widget.projectId,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProjectIncomeHeader(
        title: _isEditing ? 'Kirimni tahrirlash' : 'Yangi kirim',
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FileUploadBloc, FileUploadState>(
            listener: _handleFileUploadState,
          ),
          BlocListener<ProjectIncomeBloc, ProjectIncomeState>(
            listenWhen: (previous, current) =>
                previous.statusAction != current.statusAction &&
                (current.statusAction == Status.success || current.statusAction == Status.error),
            listener: (context, state) {
              if (state.statusAction == Status.success) {
                HapticFeedback.mediumImpact();
                Toast.showSuccessToast(message: _isEditing ? 'Kirim yangilandi' : 'Kirim yaratildi');
                Navigator.pop(context, true);
              }
              if (state.statusAction == Status.error) {
                HapticFeedback.heavyImpact();
                Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
              }
            },
          ),
        ],
        child: BlocBuilder<ProjectIncomeBloc, ProjectIncomeState>(
          builder: (context, state) {
            return Stack(
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProjectIncomeInputs(
                              summaController: _summaController,
                              descriptionController: _descriptionController,
                              summaFocusNode: _summaFocusNode,
                              descriptionFocusNode: _descriptionFocusNode,
                              currencySelector: ProjectIncomeCurrencySelector(
                                selectedCurrency: _selectedCurrency,
                                onCurrencySelected: (currency) {
                                  setState(() {
                                    _selectedCurrency = currency;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 32.h),
                            ProjectIncomeImagePicker(
                              images: _images,
                              onAddImage: (index) => _showImageSourceDialog(index),
                              onRemoveImage: (index) => _removeImage(index),
                              onUpdateImage: (index) => _showImageSourceDialog(index),
                            ),
                            SizedBox(height: 32.h),
                            ProjectIncomeSubmitButton(
                              onPressed: _submit,
                              isLoading: state.statusAction == Status.loading,
                              isEditing: _isEditing,
                            ),
                            SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (state.statusAction == Status.loading) _buildLoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Loading(),
            SizedBox(height: 16.h),
            Text(
              'Yuklanmoqda...',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFileUploadState(BuildContext context, FileUploadState state) {
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
      Toast.showErrorToast(message: 'Rasm yuklashda xatolik: ${state.errorMessage}');
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
      for (int i = index; i < _images.length - 1; i++) {
        _images[i] = _images[i + 1];
      }
      _images[_images.length - 1] = ImageData();
    });
    context.read<FileUploadBloc>().add(ResetUploadEvent());
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Rasm tanlash',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colors.black,
                    ),
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
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                      ),
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
}