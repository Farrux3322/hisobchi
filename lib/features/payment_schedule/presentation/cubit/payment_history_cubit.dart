import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/payment_history_model.dart';
import '../../data/repositories/installment_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

enum PaymentHistoryStatus { initial, loading, success, failure }

class PaymentHistoryState extends Equatable {
  final PaymentHistoryStatus status;
  final List<PaymentHistoryModel> items;
  final String? errorMessage;
  final Set<int> cancellingIds; // bekor qilinayotgan to'lovlar ID si

  const PaymentHistoryState({
    this.status = PaymentHistoryStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.cancellingIds = const {},
  });

  PaymentHistoryState copyWith({
    PaymentHistoryStatus? status,
    List<PaymentHistoryModel>? items,
    String? errorMessage,
    Set<int>? cancellingIds,
    bool clearError = false,
  }) {
    return PaymentHistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cancellingIds: cancellingIds ?? this.cancellingIds,
    );
  }

  bool isCancelling(int paymentId) => cancellingIds.contains(paymentId);

  @override
  List<Object?> get props => [status, items, errorMessage, cancellingIds];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class PaymentHistoryCubit extends Cubit<PaymentHistoryState> {
  final InstallmentRepository _repository;
  final int installmentId;

  PaymentHistoryCubit({
    required this.installmentId,
    InstallmentRepository? repository,
  })  : _repository = repository ?? InstallmentRepository(),
        super(const PaymentHistoryState());

  Future<void> loadHistory() async {
    emit(state.copyWith(status: PaymentHistoryStatus.loading, clearError: true));
    try {
      final items = await _repository.getPaymentHistory(installmentId);
      emit(state.copyWith(status: PaymentHistoryStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentHistoryStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// To'lovni bekor qilish. Muvaffaqiyatli bo'lsa, ro'yxatdagi elementni
  /// yangilangan model bilan almashtiradi (isCancelled: true).
  Future<bool> cancelPayment(int paymentId) async {
    // Allaqachon bekor qilinayotgan yoki qilingan bo'lsa — o'tkazib yubor
    if (state.isCancelling(paymentId)) return false;

    final updatedCancelling = {...state.cancellingIds, paymentId};
    emit(state.copyWith(cancellingIds: updatedCancelling));

    try {
      final updated = await _repository.cancelPayment(
        installmentId: installmentId,
        paymentId: paymentId,
      );

      // Ro'yxatdagi eski elementni yangilangan bilan almashtir
      final newItems = state.items.map((e) => e.id == paymentId ? updated : e).toList();
      final newCancelling = {...state.cancellingIds}..remove(paymentId);

      emit(state.copyWith(items: newItems, cancellingIds: newCancelling));
      return true;
    } catch (e) {
      final newCancelling = {...state.cancellingIds}..remove(paymentId);
      emit(state.copyWith(
        cancellingIds: newCancelling,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  void clearError() => emit(state.copyWith(clearError: true));
}
