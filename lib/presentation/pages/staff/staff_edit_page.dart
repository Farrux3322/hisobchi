import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/staff/staff_bloc.dart';
import 'package:hisobchi/application/staff/staff_event.dart';
import 'package:hisobchi/application/staff/staff_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/permission_model.dart';
import 'package:hisobchi/infrastructure/models/staff_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';

import '../../components/back_button.dart';

// ─── Phone formatter ─────────────────────────────────────────
/// Input: 9 digits like "937373322"
/// Output: "+998 (93) 737 33 22"
String formatStaffPhone(String raw) {
  final d = raw.replaceAll(RegExp(r'\D'), '');
  if (d.length < 9) return '+998 $raw';
  final digits = d.length >= 12 ? d.substring(3) : d; // strip 998 if present
  if (digits.length < 9) return '+998 $raw';
  return '+998 (${digits.substring(0, 2)}) ${digits.substring(2, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)}';
}

class StaffEditPage extends StatefulWidget {
  final StaffModel staff;

  const StaffEditPage({super.key, required this.staff});

  @override
  State<StaffEditPage> createState() => _StaffEditPageState();
}

class _StaffEditPageState extends State<StaffEditPage> {
  late bool _isActive;
  late Set<String> _selectedPermissions;

  @override
  void initState() {
    super.initState();
    _isActive = widget.staff.isActive;
    _selectedPermissions = Set.from(widget.staff.permissions);
    context.read<StaffBloc>().add(StaffPermissionsFetch());
  }

  bool get _hasChanges {
    final permissionsChanged = !_setEquals(_selectedPermissions, Set.from(widget.staff.permissions));
    return _isActive != widget.staff.isActive || permissionsChanged;
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }

  void _onSave() {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }
    context.read<StaffBloc>().add(StaffUpdate(
          id: widget.staff.id,
          isActive: _isActive,
          permissions: _selectedPermissions.toList(),
        ));
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.staff.name} ni o\'chirasizmi?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu amalni qaytarib bo\'lmaydi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Bekor', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<StaffBloc>().add(StaffDelete(id: widget.staff.id));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("O'chirish"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state.lastAction == StaffActionType.updateStaff && state.statusAction == Status.success) {
          Toast.showSuccessToast(message: 'Xodim muvaffaqiyatli yangilandi');
          Navigator.pop(context);
        }
        if (state.lastAction == StaffActionType.deleteStaff && state.statusAction == Status.success) {
          Toast.showSuccessToast(message: 'Xodim muvaffaqiyatli o\'chirildi');
          Navigator.pop(context);
        }
        if ((state.lastAction == StaffActionType.updateStaff || state.lastAction == StaffActionType.deleteStaff) &&
            state.statusAction == Status.error) {
          Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
        }
      },
      builder: (context, state) {
        final isSaving = state.statusAction == Status.loading &&
            (state.lastAction == StaffActionType.updateStaff || state.lastAction == StaffActionType.deleteStaff);
        final isLoadingPerms = state.status == Status.loading;
        final initials = widget.staff.name.isNotEmpty ? widget.staff.name[0].toUpperCase() : '?';

        return Scaffold(
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: const Color(0xFFF1F5F9), width: 1.5)),
            ),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, MediaQuery.of(context).padding.bottom + 12.h),
            child: SizedBox(
              height: 54.h,
              child: ElevatedButton(
                onPressed: isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasChanges ? AppTheme.colors.primary : const Color(0xFFE2E8F0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: isSaving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Saqlash',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: _hasChanges ? Colors.white : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          appBar: AppBar(
            title: const Text('Xodimni tahrirlash'),
            backgroundColor: Colors.white,
            leading: BackArrowButton(),

            actions: [
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: IconButton(onPressed: isSaving ? null : _showDeleteDialog,icon: SvgPicture.asset(AppIcons.delete),)
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: [
                // ─── Staff info header ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.colors.primary, AppTheme.colors.primary.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(initials, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.staff.name,
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              formatStaffPhone(widget.staff.phone),
                              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // ─── Active toggle ─────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: (_isActive ? const Color(0xFF22C55E) : const Color(0xFF94A3B8)).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            _isActive ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                            color: _isActive ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Holat', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                              Text(
                                _isActive ? 'Faol' : 'Faol emas',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: _isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isActive,
                          activeTrackColor: const Color(0xFF22C55E).withValues(alpha: 0.5),
                          activeThumbColor: const Color(0xFF22C55E),
                          onChanged: (v) => setState(() => _isActive = v),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // ─── Permissions ───────────────────────────────
                StaffPermissionsSection(
                  groups: state.permissions,
                  isLoading: isLoadingPerms,
                  selectedPermissions: _selectedPermissions,
                  onToggle: (key) => setState(() {
                    if (_selectedPermissions.contains(key)) {
                      _selectedPermissions.remove(key);
                    } else {
                      _selectedPermissions.add(key);
                    }
                  }),
                  onGroupToggle: (group) => setState(() {
                    final keys = group.permissions.map((p) => p.name).toSet();
                    final allSelected = keys.every(_selectedPermissions.contains);
                    if (allSelected) {
                      _selectedPermissions.removeAll(keys);
                    } else {
                      _selectedPermissions.addAll(keys);
                    }
                  }),
                ),

                SizedBox(height: 12.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Permissions Widget — ExpansionTile, default open
// ─────────────────────────────────────────────────────────────
class StaffPermissionsSection extends StatelessWidget {
  final List<PermissionGroupModel> groups;
  final bool isLoading;
  final Set<String> selectedPermissions;
  final void Function(String) onToggle;
  final void Function(PermissionGroupModel) onGroupToggle;

  const StaffPermissionsSection({
    super.key,
    required this.groups,
    required this.isLoading,
    required this.selectedPermissions,
    required this.onToggle,
    required this.onGroupToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Section label ───────────────────────────────────
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 16.sp, color: AppTheme.colors.primary),
              SizedBox(width: 6.w),
              Text('Ruxsatlar', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
              const Spacer(),
              if (!isLoading)
                Text(
                  '${selectedPermissions.length} ta tanlangan',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.primary, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),

        if (isLoading)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            padding: EdgeInsets.all(20.w),
            child: Center(child: CircularProgressIndicator(color: AppTheme.colors.primary)),
          )
        else
          ...groups.asMap().entries.map((entry) {
            return _PermissionGroupItem(
              group: entry.value,
              selectedPermissions: selectedPermissions,
              onToggle: onToggle,
              onGroupToggle: onGroupToggle,
            );
          }),
      ],
    );
  }
}

class _PermissionGroupItem extends StatefulWidget {
  final PermissionGroupModel group;
  final Set<String> selectedPermissions;
  final void Function(String) onToggle;
  final void Function(PermissionGroupModel) onGroupToggle;

  const _PermissionGroupItem({
    required this.group,
    required this.selectedPermissions,
    required this.onToggle,
    required this.onGroupToggle,
  });

  @override
  State<_PermissionGroupItem> createState() => _PermissionGroupItemState();
}

class _PermissionGroupItemState extends State<_PermissionGroupItem> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final allGroupSelected = widget.group.permissions.every((p) => widget.selectedPermissions.contains(p.name));
    final selectedCount = widget.group.permissions.where((p) => widget.selectedPermissions.contains(p.name)).length;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            maintainState: true,
            onExpansionChanged: (val) => setState(() => _isExpanded = val),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.only(bottom: 8.h),
            trailing: const SizedBox.shrink(),
            // ─── Category header ─────────────────────────
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  CupertinoCheckbox(
                    value: allGroupSelected,
                    activeColor: AppTheme.colors.primary,
                    onChanged: (_) => widget.onGroupToggle(widget.group),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.group.label,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    ),
                  ),
                  if (selectedCount > 0) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$selectedCount/${widget.group.permissions.length}',
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.primary),
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  // Animated Arrow on the right
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0 : -0.25, // Rotates 90 degrees
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF64748B),
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ─── Permissions list ─────────────────────────
            children: widget.group.permissions.asMap().entries.map((pEntry) {
              final pIndex = pEntry.key;
              final perm = pEntry.value;
              final selected = widget.selectedPermissions.contains(perm.name);
              final isLast = pIndex == widget.group.permissions.length - 1;

              return Column(
                children: [
                  InkWell(
                    onTap: () => widget.onToggle(perm.name),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      child: Row(
                        children: [
                          SizedBox(width: 4.w),
                          Container(
                            width: 7.w,
                            height: 7.w,
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.colors.primary : const Color(0xFFCBD5E1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              perm.displayName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: selected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                          CupertinoCheckbox(
                            value: selected,
                            activeColor: AppTheme.colors.primary,
                            onChanged: (_) => widget.onToggle(perm.name),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast) Divider(height: 1, color: const Color(0xFFF1F5F9), indent: 16.w, endIndent: 16.w),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
