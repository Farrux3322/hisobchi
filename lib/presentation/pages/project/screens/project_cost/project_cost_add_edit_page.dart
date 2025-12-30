import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/application/cost_type/cost_type_bloc.dart';
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
import 'package:hisobchi/infrastructure/repository/cost_type/cost_type_repository.dart';
import 'package:hisobchi/infrastructure/repository/worker/worker_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/project_cost/cost_type_bottom_sheet.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/worker_selection_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';

class ProjectCostAddEditPage extends StatefulWidget {
  final int projectId;
  final ProjectCostModel? cost;

  const ProjectCostAddEditPage({
    super.key,
    required this.projectId,
    this.cost,
  });

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
    // Remove all non-digits first
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');
    if (cleanValue.isEmpty) return '';

    // Format with spaces every 3 digits from right
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

    // Animation setup
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
      // Format summa with spaces
      final summa = widget.cost!.summa ?? '';
      _summaController.text = _formatNumber(summa);
      _descriptionController.text = widget.cost!.description ?? '';

      // Set selected values from existing cost
      if (widget.cost!.costTypeId != null) {
        _selectedCostType = CostTypeModel(
          id: widget.cost!.costTypeId,
          name: widget.cost!.costTypeName,
        );
      }

      if (widget.cost!.workerId != null) {
        _selectedWorker = WorkerModel(
          id: widget.cost!.workerId,
          name: widget.cost!.workerName,
        );
      }

      if (widget.cost!.currencyTypeId != null) {
        _selectedCurrency = currency.Result(
          id: widget.cost!.currencyTypeId,
          name: widget.cost!.currencyTypeName,
        );
      }
    }

    // Load currencies
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
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => CostTypeBloc(repository: CostTypeRepository()),
        child: const CostTypeBottomSheet(),
      ),
    );

    if (result != null && result is CostTypeModel && mounted) {
      setState(() {
        _selectedCostType = result;
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
        child: WorkerSelectionBottomSheet(projectId: widget.projectId, isSelectionMode: true),
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
      if (_selectedWorker == null) {
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
      final fileIds = _images.where((img) => img.fileId != null).map((img) => img.fileId!).toList();

      if (_isEditing) {
        context.read<ProjectCostBloc>().add(
              UpdateProjectCostEvent(
                projectCostId: widget.cost!.id!,
                costTypeId: _selectedCostType!.id!,
                workerId: _selectedWorker!.id!,
                currencyTypeId: _selectedCurrency!.id!,
                summa: summa,
                description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                fileId: fileIds.isEmpty ? null : fileIds,
                projectId: widget.projectId,
              ),
            );
      } else {
        context.read<ProjectCostBloc>().add(
              CreateProjectCostEvent(
                costTypeId: _selectedCostType!.id!,
                workerId: _selectedWorker!.id!,
                currencyTypeId: _selectedCurrency!.id!,
                summa: summa,
                description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FileUploadBloc, FileUploadState>(
            listener: _handleFileUploadState,
          ),
          BlocListener<ProjectCostBloc, ProjectCostState>(
            listenWhen: (previous, current) =>
                previous.statusAction != current.statusAction &&
                (current.statusAction == Status.success || current.statusAction == Status.error),
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
                            _buildCostTypeSelector(),
                            SizedBox(height: 10.h),
                            _buildWorkerSelector(),
                            SizedBox(height: 10.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildPriceTextField(
                                    controller: _summaController,
                                    focusNode: _summaFocusNode,
                                    label: 'Miqdor',
                                    hint: 'Summani kiriting',
                                    icon: Icons.payments_outlined,
                                    isRequired: true,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  flex: 2,
                                  child: _buildCurrencySelector(),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            _buildTextField(
                              controller: _descriptionController,
                              focusNode: _descriptionFocusNode,
                              label: 'Izoh',
                              hint: 'Qo\'shimcha ma\'lumot (ixtiyoriy)',
                              icon: Icons.description_outlined,
                              maxLines: 1,
                            ),
                            SizedBox(height: 12.h),
                            _buildSectionHeader('Hujjat rasmlari', Icons.image_outlined),
                            SizedBox(height: 12.h),
                            _buildImagePickers(),
                            SizedBox(height: 12.h),
                            _buildSubmitButton(state),
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
      leading: Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: AppTheme.colors.black, size: 18.sp),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Column(
        children: [
          Text(
            _isEditing ? 'Chiqimni tahrirlash' : 'Yangi chiqim',
            style: TextStyle(
              color: AppTheme.colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_isEditing)
            Text(
              'ID: ${widget.cost?.id}',
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.sp, color: AppTheme.colors.primary),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCostTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Chiqim turi',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.black,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _selectCostType,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _selectedCostType != null ? AppTheme.colors.primary : const Color(0xFFE2E8F0),
                  width: _selectedCostType != null ? 2 : 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.category_outlined, color: AppTheme.colors.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _selectedCostType?.name ?? 'Chiqim turini tanlang',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: _selectedCostType != null ? FontWeight.w500 : FontWeight.w400,
                        color: _selectedCostType == null ? const Color(0xFF94A3B8) : AppTheme.colors.black,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18.sp, color: const Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ishchi',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.black,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _selectWorker,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _selectedWorker != null ? AppTheme.colors.primary : const Color(0xFFE2E8F0),
                  width: _selectedWorker != null ? 2 : 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: AppTheme.colors.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _selectedWorker?.name ?? 'Ishchini tanlang',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: _selectedWorker != null ? FontWeight.w500 : FontWeight.w400,
                        color: _selectedWorker == null ? const Color(0xFF94A3B8) : AppTheme.colors.black,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18.sp, color: const Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [
            _NumberInputFormatter(),
          ],
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
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.only(right: 12.w, left: 12.w),
              child: Icon(icon, color: AppTheme.colors.primary, size: 22.sp),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 44.w),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.only(right: 12.w, left: 12.w),
              child: Icon(icon, color: AppTheme.colors.primary, size: 22.sp),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 44.w),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
            Row(
              children: [
                Text(
                  'Valyuta',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors.black,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _selectedCurrency != null ? AppTheme.colors.primary : const Color(0xFFE2E8F0),
                  width: _selectedCurrency != null ? 2 : 1.5,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<currency.Result>(
                  value: _selectedCurrency,
                  isExpanded: true,
                  hint: Text(
                    'Tanlang',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.colors.primary, size: 20.sp),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  elevation: 8,
                  itemHeight: 56.h,
                  menuMaxHeight: 300.h,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.colors.black,
                  ),
                  items: currencies.map((currency.Result currencyItem) {
                    return DropdownMenuItem<currency.Result>(
                      value: currencyItem,
                      child: Text(
                        currencyItem.name ?? '',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (currency.Result? value) {
                    setState(() {
                      _selectedCurrency = value;
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePickers() {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        final imageData = _images[index];
        final hasImage = imageData.file != null;
        final canAddImage = index == 0 || _images[index - 1].file != null;

        return GestureDetector(
          onTap: canAddImage && !hasImage
              ? () {
                  HapticFeedback.lightImpact();
                  _showImageSourceDialog(index);
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: hasImage ? Colors.white : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: hasImage ? AppTheme.colors.primary.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                width: hasImage ? 2 : 1.5,
              ),
              boxShadow: hasImage
                  ? [
                      BoxShadow(
                        color: AppTheme.colors.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: hasImage ? _buildImagePreview(imageData, index) : _buildImagePlaceholder(canAddImage, index),
          ),
        );
      },
    );
  }

  Widget _buildImagePreview(ImageData imageData, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Image.file(
            imageData.file!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        if (imageData.isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32.w,
                    height: 32.h,
                    child: CircularProgressIndicator(
                      value: imageData.progress / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${imageData.progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Positioned(
            top: 6.h,
            right: 6.w,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _removeImage(index);
              },
              child: Container(
                padding: EdgeInsets.all(6.w),
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
                child: Icon(Icons.close, color: Colors.white, size: 14.sp),
              ),
            ),
          ),
          Positioned(
            bottom: 6.h,
            right: 6.w,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.check, color: Colors.white, size: 12.sp),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePlaceholder(bool canAddImage, int index) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            canAddImage ? Icons.add_photo_alternate_outlined : Icons.image_outlined,
            color: canAddImage ? AppTheme.colors.primary : const Color(0xFF94A3B8),
            size: 32.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'Rasm ${index + 1}',
            style: TextStyle(
              fontSize: 11.sp,
              color: canAddImage ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildSubmitButton(ProjectCostState state) {
    final isLoading = state.statusAction == Status.loading;

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: AppTheme.colors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Text(
                isLoading ? 'Yuklanmoqda...' : (_isEditing ? 'Saqlash' : 'Yaratish'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Loading(),
              SizedBox(height: 16.h),
              Text(
                'Yuklanmoqda...',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.colors.black,
                ),
              ),
            ],
          ),
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
              UploadFileEvent(file: imageFile, type: 'project_cost'),
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

class _NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-digits
    final cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    // Format with spaces every 3 digits from right
    final reversed = cleanText.split('').reversed.join();
    final chunks = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      chunks.add(reversed.substring(i, end > reversed.length ? reversed.length : end));
    }
    final formatted = chunks.join(' ').split('').reversed.join();

    // Keep cursor at end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
