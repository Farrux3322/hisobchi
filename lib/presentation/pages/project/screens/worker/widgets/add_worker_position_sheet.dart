import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/application/worker/worker_bloc.dart';
import 'package:hisobchi/application/worker/worker_event.dart';
import 'package:hisobchi/application/worker/worker_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/worker_model.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';

class AddWorkerPositionSheet extends StatefulWidget {
  final WorkerPositionModel? position;

  const AddWorkerPositionSheet({super.key, this.position});

  @override
  State<AddWorkerPositionSheet> createState() => _AddWorkerPositionSheetState();
}

class _AddWorkerPositionSheetState extends State<AddWorkerPositionSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.position?.name);
    _descriptionController = TextEditingController(text: widget.position?.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkerBloc, WorkerState>(
      listener: (context, state) {
        if (state.statusPositionAction == Status.success) {
          Navigator.pop(context, true);
        }
      },

      builder: (context, state) {
        final isLoading = state.statusPositionAction == Status.loading;

        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header
                  Row(
                    children: [
                      Text(
                        widget.position == null ? 'Yangi lavozim qo\'shish' : 'Lavozimni tahrirlash',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Name Field
                  Text(
                    'Lavozim nomi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    maxLength: 30,
                    enabled: !isLoading,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      counter: const SizedBox(),
                      hintText: 'Masalan: Muhandis',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      prefixIcon: const Icon(Icons.work_outline_rounded, color: Color(0xFF6366F1), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lavozim nomini kiriting';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Description Field
                  Text(
                    'Izoh (ixtiyoriy)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 100,
                    enabled: !isLoading,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    decoration: InputDecoration(
                      counter: const SizedBox(),
                      hintText: 'Qo\'shimcha ma\'lumot...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF10B981), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  InkWell(
                    onTap: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              if (widget.position == null) {
                                context.read<WorkerBloc>().add(
                                      CreateWorkerPositionEvent(
                                        name: _nameController.text.trim(),
                                        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                                      ),
                                    );
                              } else {
                                context.read<WorkerBloc>().add(
                                      UpdateWorkerPositionEvent(
                                        positionId: widget.position!.id!,
                                        name: _nameController.text.trim(),
                                        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                                      ),
                                    );
                              }
                            }
                          },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLoading
                              ? [Colors.grey.shade400, Colors.grey.shade400]
                              : [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: .9)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isLoading
                            ? []
                            : [
                                BoxShadow(
                                  color: AppTheme.colors.primary.withValues(alpha: .3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading)
                            const SizedBox(height: 20, width: 20, child: Loading())
                          else ...[
                            const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              widget.position == null ? 'Yaratish' : 'Saqlash',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const Gap(12),
                   Gap(MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
