import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/staff/staff_bloc.dart';
import 'package:hisobchi/application/staff/staff_event.dart';
import 'package:hisobchi/application/staff/staff_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:hisobchi/presentation/components/dialog/confirmation_dialog.dart';
import '../../components/back_button.dart';
import 'staff_edit_page.dart';
import 'staff_otp_page.dart';

class StaffAddPage extends StatefulWidget {
  const StaffAddPage({super.key});

  @override
  State<StaffAddPage> createState() => _StaffAddPageState();
}

class _StaffAddPageState extends State<StaffAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final _phoneMask = MaskTextInputFormatter(mask: '+998 (##) ###-##-##', filter: {'#': RegExp(r'[0-9]')}, type: MaskAutoCompletionType.lazy);

  final Set<String> _selectedPermissions = {};

  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(StaffPermissionsFetch());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return _nameController.text.trim().isNotEmpty ||
        _passwordController.text.trim().isNotEmpty ||
        _selectedPermissions.isNotEmpty ||
        _phoneMask.getUnmaskedText().isNotEmpty;
  }

  Future<void> _handleBackRequest() async {
    if (_hasChanges()) {
      await ConfirmationDialog.show(
        context,
        title: "O'zgarishlar saqlansinmi?",
        message: "Sizda saqlanmagan ma'lumotlar bor. Orqaga qaytishni xohlaysizmi?",
        confirmLabel: "Saqlash",
        discardLabel: "Chiqish",
        onConfirm: () {
          Navigator.pop(context); // Close dialog
          _onSendOtp(); // Trigger save logic
        },
        onDiscard: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Exit page
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _onSendOtp() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPermissions.isEmpty) {
      Toast.showWarningToast(message: 'Kamida bitta ruxsat tanlang');
      return;
    }
    final rawPhone = _phoneMask.getUnmaskedText();
    context.read<StaffBloc>().add(StaffSendOtp(phone: rawPhone));
  }

  @override
  Widget build(BuildContext context) {
    return DeFocus(
      child: BlocConsumer<StaffBloc, StaffState>(
        listener: (context, state) {
          if (state.lastAction == StaffActionType.sendOtp && state.statusAction == Status.success) {
            final rawPhone = _phoneMask.getUnmaskedText();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<StaffBloc>(),
                  child: StaffOtpPage(phone: rawPhone, name: _nameController.text.trim(), password: _passwordController.text.trim(), permissions: _selectedPermissions.toList()),
                ),
              ),
            );
          }
          if (state.lastAction == StaffActionType.sendOtp && state.statusAction == Status.error) {
            Toast.showErrorToast(message: state.errorMessage ?? 'OTP yuborishda xatolik');
          }
        },
        builder: (context, state) {
          final isLoading = state.statusAction == Status.loading && state.lastAction == StaffActionType.sendOtp;
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              _handleBackRequest();
            },
            child: Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    title: const Text('Yangi xodim qo\'shish'),
                    backgroundColor: Colors.white,
                    leading: BackArrowButton(onTap: _handleBackRequest),
                  ),
                bottomNavigationBar: Container(
                  color: Colors.white,

                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, MediaQuery.of(context).padding.bottom + 12.h),
                  child: SizedBox(
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onSendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                            'Saqlash',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                          ),
                    ),
                  ),
                ),
                body: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Personal Info section ───────────────────────
                        _SectionCard(
                          title: 'Shaxsiy ma\'lumotlar',
                          icon: Icons.person_outline_rounded,
                          child: Column(
                            children: [
                              _buildInput(controller: _nameController, hint: 'Ism', icon: Icons.badge_outlined, validator: (v) => (v == null || v.trim().isEmpty) ? 'Ism kiritilmagan' : null),
                              SizedBox(height: 12.h),
                              _buildPhoneInput(),
                              SizedBox(height: 12.h),
                              _buildPasswordInput(),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // ─── Permissions section ─────────────────────────
                        StaffPermissionsSection(
                          groups: state.status == Status.success ? state.permissions : [],
                          isLoading: state.status == Status.loading,
                          selectedPermissions: _selectedPermissions,
                          onToggle: (key) {
                            setState(() {
                              if (_selectedPermissions.contains(key)) {
                                _selectedPermissions.remove(key);
                                // Deselection logic
                                if (key == 'partners.view') {
                                  _selectedPermissions.removeAll(['partners.create', 'partners.edit', 'partners.delete']);
                                } else if (key == 'projects.view') {
                                  _selectedPermissions.removeAll(['projects.create', 'projects.edit', 'projects.delete']);
                                } else if (key == 'wallets_credit.create') {
                                  _selectedPermissions.remove('wallets_credit.cancel');
                                } else if (key == 'wallets_debt.create') {
                                  _selectedPermissions.remove('wallets_debt.cancel');
                                }
                              } else {
                                _selectedPermissions.add(key);
                                // Selection logic
                                if (key == 'partners.create' || key == 'partners.edit' || key == 'partners.delete') {
                                  _selectedPermissions.add('partners.view');
                                } else if (key == 'projects.create' || key == 'projects.edit' || key == 'projects.delete') {
                                  _selectedPermissions.add('projects.view');
                                } else if (key == 'wallets_credit.cancel') {
                                  _selectedPermissions.add('wallets_credit.create');
                                } else if (key == 'wallets_debt.cancel') {
                                  _selectedPermissions.add('wallets_debt.create');
                                }
                              }
                            });
                          },
                          onGroupToggle: (group) {
                            setState(() {
                              final keys = group.permissions.map((p) => p.name).toSet();
                              final allSelected = keys.every(_selectedPermissions.contains);
                              if (allSelected) {
                                _selectedPermissions.removeAll(keys);
                              } else {
                                _selectedPermissions.addAll(keys);
                              }
                            });
                          },
                        ),

                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading) const Loading(),
            ],
          ),
        );
      },
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      maxLength: 30,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        counter: SizedBox(),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return TextFormField(
      initialValue: '+998',
      keyboardType: TextInputType.phone,
      inputFormatters: [_phoneMask],
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
      validator: (_) {
        final digits = _phoneMask.getUnmaskedText();
        return digits.length != 9 ? 'Telefon raqam to\'liq emas' : null;
      },
      decoration: InputDecoration(

        hintText: '+998 (__)  ___-__-__',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400, fontSize: 16),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 20, right: 16),
          child: Icon(Icons.phone_android_outlined, size: 22, color: Color(0xFF94A3B8)),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Parol kiritilmagan';
        if (v.trim().length < 8) return 'Parol kamida 8 ta belgidan iborat bo\'lishi kerak';
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Parol',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400, fontSize: 16),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 20, right: 16),
          child: Icon(Icons.lock_outline_rounded, size: 22, color: Color(0xFF94A3B8)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 58),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8), size: 22),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable Section Card
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0.w, 14.h, 0.w, 0),
          child: Row(
            children: [
              Icon(icon, size: 18.sp, color: AppTheme.colors.primary),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B), letterSpacing: 0.2),
              ),
            ],
          ),
        ),
        Gap(10),
        child,
      ],
    );
  }
}
