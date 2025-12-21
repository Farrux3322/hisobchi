import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_bloc.dart';
import 'package:hisobchi/application/worker/worker_bloc.dart';
import 'package:hisobchi/application/worker/worker_event.dart';
import 'package:hisobchi/application/worker/worker_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/worker_model.dart';
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:hisobchi/infrastructure/repository/worker/worker_repository.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/project/screens/worker/worker_position_bottom_sheet.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class WorkerAddEditPage extends StatefulWidget {
  final WorkerModel? worker;

  const WorkerAddEditPage({super.key, this.worker});

  @override
  State<WorkerAddEditPage> createState() => _WorkerAddEditPageState();
}

class _WorkerAddEditPageState extends State<WorkerAddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: "+998");
  final _additionalPhoneController = TextEditingController(text: "+998");
  final _descriptionController = TextEditingController();

  late final MaskTextInputFormatter _maskFormatter1;
  late final MaskTextInputFormatter _maskFormatter2;

  WorkerPositionModel? _selectedPosition;
  List<String> _uploadedFileIds = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.worker != null;

    // Initialize mask formatters
    _maskFormatter1 = MaskTextInputFormatter(
      mask: '+998 (##) ###-##-##',
      filter: {"#": RegExp(r'[0-9]')},
      initialText: _isEditing ? (widget.worker!.phone ?? "+998") : "+998",
      type: MaskAutoCompletionType.lazy,
    );

    _maskFormatter2 = MaskTextInputFormatter(
      mask: '+998 (##) ###-##-##',
      filter: {"#": RegExp(r'[0-9]')},
      initialText: _isEditing ? (widget.worker!.additionalPhone ?? "+998") : "+998",
      type: MaskAutoCompletionType.lazy,
    );

    if (_isEditing) {
      _nameController.text = widget.worker!.name ?? '';
      _phoneController.text = widget.worker!.phone ?? '+998';
      _additionalPhoneController.text = widget.worker!.additionalPhone ?? '+998';
      _descriptionController.text = widget.worker!.description ?? '';

      // Edit holatda position ID va name dan WorkerPositionModel yaratamiz
      if (widget.worker!.workerPositionId != null) {
        _selectedPosition = WorkerPositionModel(
          id: widget.worker!.workerPositionId,
          name: widget.worker!.workerPositionName,
        );
      }

      _uploadedFileIds = widget.worker!.files ?? [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _additionalPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectPosition() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => WorkerBloc(repository: WorkerRepository()),
        child: const WorkerPositionBottomSheet(),
      ),
    );

    if (result != null && result is WorkerPositionModel && mounted) {
      setState(() {
        _selectedPosition = result;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPosition == null) {
        Toast.showErrorToast(message: 'Lavozimni tanlang');
        return;
      }

      if (_isEditing) {
        context.read<WorkerBloc>().add(
              UpdateWorkerEvent(
                workerId: widget.worker!.id!,
                name: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                additionalPhone: _additionalPhoneController.text.trim().isEmpty
                    ? null
                    : _additionalPhoneController.text.trim(),
                fileIds: _uploadedFileIds.isEmpty ? null : _uploadedFileIds,
                workerPositionId: _selectedPosition!.id!,
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
              ),
            );
      } else {
        context.read<WorkerBloc>().add(
              CreateWorkerEvent(
                name: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                additionalPhone: _additionalPhoneController.text.trim().isEmpty
                    ? null
                    : _additionalPhoneController.text.trim(),
                fileIds: _uploadedFileIds.isEmpty ? null : _uploadedFileIds,
                workerPositionId: _selectedPosition!.id!,
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
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
          _isEditing ? 'Ishchini tahrirlash' : 'Yangi ishchi',
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<WorkerBloc, WorkerState>(
        listener: (context, state) {
          if (state.statusAction == Status.success) {
            Toast.showSuccessToast(
              message: _isEditing ? 'Ishchi yangilandi' : 'Ishchi yaratildi',
            );
            Navigator.pop(context, true);
          }
          if (state.statusAction == Status.error) {
            Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
          }
        },
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
                      _buildTextField(
                        controller: _nameController,
                        label: 'Ism*',
                        hint: 'Ishchi ismini kiriting',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ismni kiriting';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Telefon raqami*',
                        hint: '+998 XX XXX XX XX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_maskFormatter1],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Telefon raqamini kiriting';
                          }
                          final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digitsOnly.length != 12) {
                            return 'Telefon raqam to\'liq emas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _additionalPhoneController,
                        label: 'Qo\'shimcha telefon',
                        hint: '+998 XX XXX XX XX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_maskFormatter2],
                      ),
                      const SizedBox(height: 16),
                      _buildPositionSelector(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Izoh',
                        hint: 'Qo\'shimcha ma\'lumot',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<MaskTextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            // prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lavozim*',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectPosition,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.work_outline, color: Color(0xFF64748B), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedPosition?.name ?? 'Lavozimni tanlang',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedPosition == null
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF64748B)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}