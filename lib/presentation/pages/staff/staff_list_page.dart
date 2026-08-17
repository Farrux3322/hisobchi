import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/staff/staff_bloc.dart';
import 'package:ehisob/application/staff/staff_event.dart';
import 'package:ehisob/application/staff/staff_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/staff_model.dart';
import 'package:ehisob/infrastructure/repository/staff/staff_repository.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/toast/toast.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../components/back_button.dart';
import 'staff_add_page.dart';
import 'staff_edit_page.dart'; // formatStaffPhone

class StaffListPage extends StatelessWidget {
  const StaffListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffBloc(repository: StaffRepository())..add(StaffListFetch()),
      child: const _StaffListView(),
    );
  }
}

class _StaffListView extends StatelessWidget {
  const _StaffListView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state.lastAction == StaffActionType.updateStaff && state.statusAction == Status.success) {
          Toast.showSuccessToast(message: 'Xodim muvaffaqiyatli yangilandi');
        }
        if (state.lastAction == StaffActionType.deleteStaff && state.statusAction == Status.success) {
          Toast.showSuccessToast(message: 'Xodim muvaffaqiyatli o\'chirildi');
        }
        if (state.statusAction == Status.error) {
          Toast.showErrorToast(message: state.errorMessage ?? 'Xatolik yuz berdi');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Xodimlar'),
            backgroundColor: Colors.white,
            leading: BackArrowButton(),

          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: FloatingActionButton(
              heroTag: 'staff_fab',
              onPressed: () {
                pushScreen(
                  context,
                  screen: BlocProvider(
                    create: (_) => StaffBloc(repository: StaffRepository()),
                    child: const StaffAddPage(),
                  ),
                  withNavBar: false,
                ).then((_) {
                  if (context.mounted) {
                    context.read<StaffBloc>().add(StaffListFetch());
                  }
                });
              },
              backgroundColor: AppTheme.colors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
              child: Icon(Icons.add, color: Colors.white, size: 32.sp),
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, StaffState state) {
    if (state.status == Status.loading) {
      return _buildShimmer();
    }

    if (state.status == Status.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'Xatolik yuz berdi',
              style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<StaffBloc>().add(StaffListFetch()),
              icon: const Icon(Icons.refresh),
              label: const Text('Qayta urinish'),
            ),
          ],
        ),
      );
    }

    if (state.staffList.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      color: AppTheme.colors.primary,
      onRefresh: () async => context.read<StaffBloc>().add(StaffListFetch()),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
        itemCount: state.staffList.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          return _StaffCard(staff: state.staffList[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline_rounded, size: 48.sp, color: AppTheme.colors.primary.withValues(alpha: 0.5)),
            ),
            SizedBox(height: 24.h),
            Text(
              'Hali xodim yo\'q',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
            ),
            SizedBox(height: 8.h),
            Text(
              '+  tugmasini bosib birinchi xodimingizni qo\'shing',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, __) => Container(
        height: 78.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Staff Card — status badge, tap → edit, long press → delete
// ─────────────────────────────────────────────────────────────
class _StaffCard extends StatelessWidget {
  final StaffModel staff;

  const _StaffCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    final initials = staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => StaffBloc(repository: StaffRepository()),
                  child: StaffEditPage(staff: staff),
                ),
              ),
            ).then((_) {
              if (context.mounted) {
                context.read<StaffBloc>().add(StaffListFetch());
              }
            });
          },
          onLongPress: () => _showDeleteDialog(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(
              children: [
                // Premium Squircle Avatar
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.12), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: AppTheme.colors.primary,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Name + phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        formatStaffPhone(staff.phone),
                        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: staff.isActive
                        ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                        : const Color(0xFF94A3B8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: staff.isActive ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        staff.isActive ? 'Faol' : 'Faol emas',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: staff.isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(Icons.chevron_right_rounded, color: const Color(0xFFCBD5E1), size: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
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
              '${staff.name} ni o\'chirasizmi?',
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Bekor'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<StaffBloc>().add(StaffDelete(id: staff.id));
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
}
