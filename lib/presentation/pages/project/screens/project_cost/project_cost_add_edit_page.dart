import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/application/project_cost/project_cost_bloc.dart';
import 'package:hisobchi/application/project_cost/project_cost_event.dart';
import 'package:hisobchi/application/project_cost/project_cost_state.dart';
import 'package:hisobchi/application/worker/worker_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/currency/currency_model.dart' as currency;
import 'package:hisobchi/infrastructure/models/cost_type_model.dart';
import 'package:hisobchi/infrastructure/models/project_cost_model.dart';
import 'package:hisobchi/infrastructure/models/worker_model.dart';
import 'package:hisobchi/infrastructure/repository/worker/worker_repository.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/cost_type_bottom_sheet.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/widgets/project_cost_inputs.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/widgets/project_cost_image_picker.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/widgets/project_cost_submit_button.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/widgets/project_cost_type_selector.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/widgets/project_cost_worker_selector.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/single_worker_selection_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';

class ProjectCostAddEditPage extends StatefulWidget {
  final int projectId;
  final ProjectCostModel? cost;

  const ProjectCostAddEditPage({super.key, required this.projectId, this.cost});

  @override
  State<ProjectCostAddEditPage> createState() => _ProjectCostAddEditPageState();
}

class _ProjectCostAddEditPageState extends State<ProjectCostAddEditPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _summaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  CostTypeModel? _selectedCostType;
  WorkerModel? _selectedWorker;
  currency.Result? _selectedCurrency;
  final List<ProjectCostImageData> _images = [ProjectCostImageData(), ProjectCostImageData(), ProjectCostImageData()];
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
    _isEditing = widget.cost != null;

    _animationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();

    if (_isEditing) {
      final summa = widget.cost!.summa ?? '';
      _summaController.text = _formatNumber(summa);
      _descriptionController.text = widget.cost!.description ?? '';

      if (widget.cost!.costTypeId != null) {
        _selectedCostType = CostTypeModel(id: widget.cost!.costTypeId, name: widget.cost!.costTypeName);
      }

      if (widget.cost!.workerId != null) {
        _selectedWorker = WorkerModel(id: widget.cost!.workerId, name: widget.cost!.workerName);
      }

      if (widget.cost!.currencyTypeId != null) {
        _selectedCurrency = currency.Result(id: widget.cost!.currencyTypeId, name: widget.cost!.currencyTypeName);
      }

      _loadExistingImages();
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

  Future<void> _selectCostType() async {
    final result = await showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) =>  CostTypeBottomSheet(isCreate: true,));

    if (result != null && result is CostTypeModel && mounted) {
      setState(() {
        _selectedCostType = result;
        if (result.isWorkerJoin != true) {
          _selectedWorker = null;
        }
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _selectWorker() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => WorkerBloc(repository: WorkerRepository()),
        child: SingleWorkerSelectionBottomSheet(projectId: widget.projectId),
      ),
    );

    if (result != null && result is WorkerModel && mounted) {
      setState(() {
        _selectedWorker = result;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCostType == null) {
        Toast.showErrorToast(message: 'Chiqim turini tanlang');
        return;
      }

      if (_selectedCostType!.isWorkerJoin == true && _selectedWorker == null) {
        Toast.showErrorToast(message: 'Ishchini tanlang');
        return;
      }

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
        context.read<ProjectCostBloc>().add(
          UpdateProjectCostEvent(
            projectCostId: widget.cost!.id!,
            costTypeId: _selectedCostType!.id!,
            workerId: _selectedWorker?.id,
            currencyTypeId: _selectedCurrency!.id!,
            summa: summa,
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
            fileId: fileIds.isEmpty ? [] : fileIds,
            projectId: widget.projectId,
          ),
        );
      } else {
        context.read<ProjectCostBloc>().add(
          CreateProjectCostEvent(
            costTypeId: _selectedCostType!.id!,
            workerId: _selectedWorker?.id,
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
      appBar: _buildAppBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FileUploadBloc, FileUploadState>(listener: _handleFileUploadState),
          BlocListener<ProjectCostBloc, ProjectCostState>(
            listenWhen: (previous, current) => previous.statusAction != current.statusAction && (current.statusAction == Status.success || current.statusAction == Status.error),
            listener: (context, state) {
              if (state.statusAction == Status.success) {
                HapticFeedback.mediumImpact();
                Toast.showSuccessToast(message: _isEditing ? 'Chiqim yangilandi' : 'Chiqim yaratildi');
                Navigator.pop(context, true);
              }
              if (state.statusAction == Status.error) {
                HapticFeedback.heavyImpact();
                Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
              }
            },
          ),
        ],
        child: BlocBuilder<ProjectCostBloc, ProjectCostState>(
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
                            ProjectCostTypeSelector(selectedCostType: _selectedCostType, onTap: _selectCostType),
                            SizedBox(height: 10.h),
                            if (_selectedCostType?.isWorkerJoin == true || _selectedWorker != null) ...[
                              ProjectCostWorkerSelector(selectedWorker: _selectedWorker, onTap: _selectWorker),
                              SizedBox(height: 10.h),
                            ],
                            ProjectCostInputs(
                              summaController: _summaController,
                              summaFocusNode: _summaFocusNode,
                              descriptionController: _descriptionController,
                              descriptionFocusNode: _descriptionFocusNode,
                              selectedCurrency: _selectedCurrency,
                              onCurrencySelected: (currency) {
                                setState(() {
                                  _selectedCurrency = currency;
                                });
                                HapticFeedback.selectionClick();
                              },
                            ),
                            SizedBox(height: 12.h),
                            ProjectCostImagePicker(
                              images: _images,
                              onAddImage: (index) => _showImageSourceDialog(index),
                              onRemoveImage: (index) => _removeImage(index),
                              onUpdateImage: (index) => _showImageSourceDialog(index),
                            ),
                            SizedBox(height: 12.h),
                            ProjectCostSubmitButton(state: state, isEditing: _isEditing, onPressed: _submit),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: BackArrowButton(),
      title: Text(
        _isEditing ? 'Chiqimni tahrirlash' : 'Yangi chiqim',
      ),
      centerTitle: true,
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
          _images[uploadingIndex] = ProjectCostImageData(file: _images[uploadingIndex].file, fileId: state.uploadedFileId, isUploading: false, progress: 100);
        });
      }
    } else if (state.status == FileUploadStatus.failure) {
      final uploadingIndex = _images.indexWhere((img) => img.isUploading);
      if (uploadingIndex != -1) {
        setState(() {
          _images[uploadingIndex] = ProjectCostImageData();
        });
      }
      Toast.showErrorToast(message: 'Rasm yuklashda xatolik: ${state.errorMessage}');
    } else if (state.status == FileUploadStatus.uploading) {
      final uploadingIndex = _images.indexWhere((img) => img.isUploading);
      if (uploadingIndex != -1) {
        setState(() {
          _images[uploadingIndex] = ProjectCostImageData(file: _images[uploadingIndex].file, isUploading: true, progress: state.progress);
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    if (index > 0) {
      final previousImage = _images[index - 1];
      final hasPreviousImage = previousImage.file != null || previousImage.existingUrl != null;

      if (!hasPreviousImage) {
        Toast.showErrorToast(message: 'Avval $index-rasmni yuklang');
        return;
      }
    }

    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1920, maxHeight: 1080);

      if (image != null && mounted) {
        final imageFile = File(image.path);
        setState(() {
          _images[index] = ProjectCostImageData(file: imageFile, isUploading: true);
        });

        context.read<FileUploadBloc>().add(UploadFileEvent(file: imageFile, type: 'project_cost'));
      }
    } catch (e) {
      Toast.showErrorToast(message: 'Xatolik yuz berdi: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      for (int i = index; i < _images.length; i++) {
        _images[i] = ProjectCostImageData();
      }
    });
    context.read<FileUploadBloc>().add(ResetUploadEvent());
  }

  void _loadExistingImages() {
    final cost = widget.cost;
    if (cost == null) return;

    if (cost.files != null && cost.files!.isNotEmpty) {
      for (int i = 0; i < cost.files!.length && i < 3; i++) {
        final file = cost.files![i];
        setState(() {
          _images[i] = ProjectCostImageData(existingUrl: file.url, existingId: file.id);
        });
      }
    }
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
                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2.r)),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Rasm tanlash',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
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

  Widget _buildImageSourceOption({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
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
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14.r)),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
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
