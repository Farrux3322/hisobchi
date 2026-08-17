import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/time_report_summary_model.dart';

class TimeReportSummaryState {
  final Status status;
  final TimeReportSummaryResult? data;
  final String? errorMessage;

  const TimeReportSummaryState({
    this.status = Status.initial,
    this.data,
    this.errorMessage,
  });

  TimeReportSummaryState copyWith({
    Status? status,
    TimeReportSummaryResult? data,
    String? errorMessage,
  }) {
    return TimeReportSummaryState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ─── Convenient helper getters ────────────────────────────────────────────
  bool get isInitial => status == Status.initial;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
  bool get hasData => data != null;

  TimeCurrencySummary? get uzs => data?.uzs;
  TimeCurrencySummary? get usd => data?.usd;
}
