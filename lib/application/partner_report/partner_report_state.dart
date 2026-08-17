import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/partner_report_model.dart';

class PartnerReportState {
  final Status status;
  final PartnerReportResult? reportData;
  final String? errorMessage;

  const PartnerReportState({
    this.status = Status.initial,
    this.reportData,
    this.errorMessage,
  });

  PartnerReportState copyWith({
    Status? status,
    PartnerReportResult? reportData,
    String? errorMessage,
  }) {
    return PartnerReportState(
      status: status ?? this.status,
      reportData: reportData ?? this.reportData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper getters
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
  bool get hasData => reportData != null;

  // Get specific currency data
  CurrencyReport? get uzsReport => reportData?.uzs;
  CurrencyReport? get usdReport => reportData?.usd;
}