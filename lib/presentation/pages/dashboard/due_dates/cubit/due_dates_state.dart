part of 'due_dates_cubit.dart';

enum DueDatesStatus { initial, loading, success, failure }

// ─── Qarz state ──────────────────────────────────────────────────────────────

class QarzDueDatesState {
  final DueDatesStatus status;
  final List<QarzDueItem> items;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String? error;

  const QarzDueDatesState({
    this.status = DueDatesStatus.initial,
    this.items = const [],
    this.currentPage = 1,
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.error,
  });

  QarzDueDatesState copyWith({
    DueDatesStatus? status,
    List<QarzDueItem>? items,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoadingMore,
    String? error,
  }) {
    return QarzDueDatesState(
      status: status ?? this.status,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

// ─── Installment state ───────────────────────────────────────────────────────

class InstallmentDueDatesState {
  final DueDatesStatus status;
  final List<InstallmentDueItem> items;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String? error;

  const InstallmentDueDatesState({
    this.status = DueDatesStatus.initial,
    this.items = const [],
    this.currentPage = 1,
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.error,
  });

  InstallmentDueDatesState copyWith({
    DueDatesStatus? status,
    List<InstallmentDueItem>? items,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoadingMore,
    String? error,
  }) {
    return InstallmentDueDatesState(
      status: status ?? this.status,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}
