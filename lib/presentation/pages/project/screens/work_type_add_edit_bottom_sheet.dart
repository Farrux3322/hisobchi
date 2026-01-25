import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/work_type/work_type_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/work_type_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';

class WorkTypeAddEditBottomSheet extends StatefulWidget {
  final WorkTypeModel? workType;

  const WorkTypeAddEditBottomSheet({super.key, this.workType});

  @override
  State<WorkTypeAddEditBottomSheet> createState() => _WorkTypeAddEditBottomSheetState();
}

class _WorkTypeAddEditBottomSheetState extends State<WorkTypeAddEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get isEditMode => widget.workType != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.workType!.name ?? '';
      _descriptionController.text = widget.workType!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final data = {'name': _nameController.text.trim(), 'description': _descriptionController.text.trim()};

    if (isEditMode) {
      context.read<WorkTypeBloc>().add(UpdateWorkTypeEvent(data: data, id: widget.workType!.id!));
    } else {
      context.read<WorkTypeBloc>().add(CreateWorkTypeEvent(data: data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: BlocConsumer<WorkTypeBloc, WorkTypeState>(
          listener: (context, state) {
            if (state.statusAdd == Status.success) {
              Toast.showSuccessToast(message: isEditMode ? 'Ish turi muvaffaqiyatli tahrirlandi' : 'Ish turi muvaffaqiyatli qo\'shildi');
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
                          // Handle
                          Center(
                            child: Container(
                              width: 62,
                              height: 8,
                              decoration: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          Text(
                            isEditMode ? 'Ish turini tahrirlash' : 'Ish turini qo\'shish',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 24),

                          // Name input
                          RichText(
                            text: const TextSpan(
                              text: 'Ish turi nomi ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            maxLength: 30,
                            decoration: InputDecoration(
                              counter: SizedBox(),
                              hintText: 'Masalan: Santexnika ishlari',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
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
                                borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Iltimos, ish turi nomini kiriting';
                              }
                              if (value.trim().length < 2) {
                                return 'Ish turi nomi kamida 2 ta belgidan iborat bo\'lishi kerak';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Description input
                          const Text(
                            'Tavsif',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            maxLength: 60,
                            decoration: InputDecoration(
                              hintText: 'Ish turi haqida qo\'shimcha ma\'lumot (ixtiyoriy)',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                              counter: SizedBox(),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
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
                                borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: state.statusAdd == Status.loading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.colors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppTheme.colors.primary.withOpacity(0.6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text(isEditMode ? 'Saqlash' : 'Qo\'shish', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                      if (state.statusAdd == Status.loading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.8),
                            child: const Center(child: Loading()),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
