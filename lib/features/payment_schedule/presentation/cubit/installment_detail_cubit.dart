import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/installment_plan_model.dart';
import '../../data/repositories/installment_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

enum InstallmentDetailStatus { initial, loading, success, failure, paying, cancelling }

class InstallmentDetailState extends Equatable {
  final InstallmentDetailStatus status;
  final InstallmentPlanModel? plan;
  final String? errorMessage;
  final String? actionError; // To'lov yoki bekor qilish xatosi

  const InstallmentDetailState({
    this.status = InstallmentDetailStatus.initial,
    this.plan,
    this.errorMessage,
    this.actionError,
  });

  InstallmentDetailState copyWith({
    InstallmentDetailStatus? status,
    InstallmentPlanModel? plan,
    String? errorMessage,
    String? actionError,
    bool clearActionError = false,
    bool clearError = false,
  }) {
    return InstallmentDetailState(
      status: status ?? this.status,
      plan: plan ?? this.plan,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [status, plan, errorMessage, actionError];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class InstallmentDetailCubit extends Cubit<InstallmentDetailState> {
  final InstallmentRepository _repository;

  InstallmentDetailCubit({InstallmentRepository? repository})
      : _repository = repository ?? InstallmentRepository(),
        super(const InstallmentDetailState());

  /// Reja tafsilotini yuklash
  Future<void> loadDetail(int installmentId) async {
    emit(state.copyWith(status: InstallmentDetailStatus.loading, clearError: true));

    try {
      final plan = await _repository.getInstallmentDetail(installmentId);
      emit(state.copyWith(status: InstallmentDetailStatus.success, plan: plan));
    } catch (e) {
      emit(state.copyWith(
        status: InstallmentDetailStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// To'lov qabul qilish (FIFO)
  Future<bool> acceptPayment({required double amount, String? note, DateTime? paidAt}) async {
    if (state.plan == null) return false;
    if (amount <= 0) return false;

    emit(state.copyWith(status: InstallmentDetailStatus.paying, clearActionError: true));

    try {
      final updated = await _repository.acceptPayment(
        installmentId: state.plan!.id,
        amount: amount,
        note: note,
        paidAt: paidAt ?? DateTime.now(),
      );
      emit(state.copyWith(status: InstallmentDetailStatus.success, plan: updated));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: InstallmentDetailStatus.success, // plan o'zgarmasdan qoladi
        actionError: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  /// Rejani bekor qilish
  Future<bool> cancelPlan() async {
    if (state.plan == null) return false;

    emit(state.copyWith(status: InstallmentDetailStatus.cancelling, clearActionError: true));

    try {
      final updated = await _repository.cancelInstallment(state.plan!.id);
      emit(state.copyWith(status: InstallmentDetailStatus.success, plan: updated));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: InstallmentDetailStatus.success,
        actionError: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  /// Izohni yangilash
  Future<bool> updateNote(String note) async {
    if (state.plan == null) return false;

    try {
      final updated = await _repository.updateNote(state.plan!.id, note);
      emit(state.copyWith(status: InstallmentDetailStatus.success, plan: updated));
      return true;
    } catch (e) {
      emit(state.copyWith(
        actionError: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  void clearActionError() {
    emit(state.copyWith(clearActionError: true));
  }
}
