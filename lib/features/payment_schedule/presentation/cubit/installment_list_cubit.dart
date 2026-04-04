import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/installment_plan_model.dart';
import '../../data/repositories/installment_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

enum InstallmentListStatus { initial, loading, loadingMore, success, failure }

class InstallmentListState extends Equatable {
  final InstallmentListStatus status;
  final List<InstallmentPlanModel> plans;
  final String? nextUrl;
  final bool hasMore;
  final String? errorMessage;
  // Filtrlar
  final String? filterStatus; // 'active' | 'completed' | 'cancelled' | null
  final String? filterScheduleType; // 'equal' | 'custom' | null

  const InstallmentListState({
    this.status = InstallmentListStatus.initial,
    this.plans = const [],
    this.nextUrl,
    this.hasMore = false,
    this.errorMessage,
    this.filterStatus,
    this.filterScheduleType,
  });

  InstallmentListState copyWith({
    InstallmentListStatus? status,
    List<InstallmentPlanModel>? plans,
    String? nextUrl,
    bool? hasMore,
    String? errorMessage,
    String? filterStatus,
    String? filterScheduleType,
    bool clearNextUrl = false,
    bool clearError = false,
    bool clearFilterStatus = false,
    bool clearFilterScheduleType = false,
  }) {
    return InstallmentListState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      nextUrl: clearNextUrl ? null : (nextUrl ?? this.nextUrl),
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      filterStatus: clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
      filterScheduleType: clearFilterScheduleType ? null : (filterScheduleType ?? this.filterScheduleType),
    );
  }

  @override
  List<Object?> get props => [status, plans, nextUrl, hasMore, errorMessage, filterStatus, filterScheduleType];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class InstallmentListCubit extends Cubit<InstallmentListState> {
  final InstallmentRepository _repository;
  final int _partnerId;

  InstallmentListCubit({
    required int partnerId,
    InstallmentRepository? repository,
  })  : _partnerId = partnerId,
        _repository = repository ?? InstallmentRepository(),
        super(const InstallmentListState());

  /// Birinchi yuklash yoki yangilash (pull-to-refresh)
  Future<void> load({bool refresh = false}) async {
    if (!refresh && state.status == InstallmentListStatus.loading) return;

    emit(state.copyWith(status: InstallmentListStatus.loading, clearError: true));

    try {
      final result = await _repository.getPartnerInstallments(_partnerId);

      // Filtrlash client-side (server filter ham ishlatish mumkin,
      // lekin "partner/{id}/installments" — paginationsiz, shu sababdan clientda filter qilamiz)
      final filtered = _applyFilters(result);

      emit(state.copyWith(
        status: InstallmentListStatus.success,
        plans: filtered,
        hasMore: false,
        clearNextUrl: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InstallmentListStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  List<InstallmentPlanModel> _applyFilters(List<InstallmentPlanModel> all) {
    var list = all;
    if (state.filterStatus != null) {
      list = list.where((p) => p.status.value == state.filterStatus).toList();
    }
    if (state.filterScheduleType != null) {
      list = list.where((p) => p.scheduleType.value == state.filterScheduleType).toList();
    }
    return list;
  }

  /// Status filtrni o'zgartirish va qayta yuklash
  Future<void> setStatusFilter(String? status) async {
    if (state.filterStatus == status) return;
    emit(state.copyWith(
      filterStatus: status,
      clearFilterStatus: status == null,
    ));
    await load(refresh: true);
  }

  /// Reja yaratilgandan yoki o'zgarganidan keyin ro'yxatni yangilash
  Future<void> refresh() => load(refresh: true);

  /// Bitta rejani state ichida yangilash (Detail page dan qaytganda)
  void updatePlan(InstallmentPlanModel updated) {
    final newList = state.plans.map((p) => p.id == updated.id ? updated : p).toList();
    emit(state.copyWith(plans: newList));
  }

  /// Bekor qilingan rejani ro'yxatda yangilash
  void cancelPlan(int id) {
    final newList = state.plans.map((p) {
      if (p.id != id) return p;
      return InstallmentPlanModel.fromJson({
        'id': p.id,
        'partner_id': p.partnerId,
        'partner_name': p.partnerName,
        'currency_type_id': p.currencyTypeId,
        'currency_type_name': p.currencyTypeName,
        'total_amount': p.totalAmount.toString(),
        'paid_amount': p.paidAmount.toString(),
        'remaining': p.remaining.toString(),
        'schedule_type': p.scheduleType.value,
        'has_advance': p.hasAdvance,
        'advance_amount': p.advanceAmount?.toString(),
        'start_date': p.startDate,
        'note': p.note,
        'status': 'cancelled',
        'status_label': 'Bekor qilingan',
        'items': [],
        'items_count': p.itemsCount,
        'created_at': p.createdAt,
      });
    }).toList();
    emit(state.copyWith(plans: newList));
  }
}
