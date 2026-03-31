import 'package:equatable/equatable.dart';
import 'package:hisobchi/infrastructure/models/time_report_summary_model.dart';

class WorkerDetailsSummaryState extends Equatable {
  final bool isInitial;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final TimeCurrencySummary? uzs;
  final TimeCurrencySummary? usd;

  const WorkerDetailsSummaryState({
    this.isInitial = true,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.uzs,
    this.usd,
  });

  WorkerDetailsSummaryState copyWith({
    bool? isInitial,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    TimeCurrencySummary? uzs,
    TimeCurrencySummary? usd,
  }) {
    return WorkerDetailsSummaryState(
      isInitial: isInitial ?? this.isInitial,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      uzs: uzs ?? this.uzs,
      usd: usd ?? this.usd,
    );
  }

  @override
  List<Object?> get props => [isInitial, isLoading, isError, errorMessage, uzs, usd];
}
