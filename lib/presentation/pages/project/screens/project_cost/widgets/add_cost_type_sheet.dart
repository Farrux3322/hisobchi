import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/infrastructure/models/cost_type_model.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';

class AddCostTypeSheet extends StatefulWidget {
  final CostTypeModel? costType;

  const AddCostTypeSheet({super.key, this.costType});

  @override
  State<AddCostTypeSheet> createState() => _AddCostTypeSheetState();
}

class _AddCostTypeSheetState extends State<AddCostTypeSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.costType?.name);
    _descriptionController = TextEditingController(text: widget.costType?.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(20),

            // Header
            Row(
              children: [
                Text(
                  widget.costType == null ? 'Yangi chiqim turi' : 'Chiqim turini tahrirlash',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const Gap(16),

            // Name Field
            TextFormField(
              controller: _nameController,
              autofocus: true,
              
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Chiqim turi nomi*',
                hintText: 'Masalan: Transport xarajatlari',
                labelStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomni kiriting';
                }
                return null;
              },
            ),
            const Gap(16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              maxLines: null,
              maxLength: 100,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: 'Izoh',
                counter: SizedBox(),
                hintText: 'Qo\'shimcha ma\'lumot',
                labelStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
                ),
              ),
            ),
            const Gap(24),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, {
                    'name': _nameController.text.trim(),
                    'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                widget.costType == null ? 'Yaratish' : 'Saqlash',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            Gap(MediaQuery.of(context).padding.bottom)
          ],
        ),
      ),
    );
  }
}
