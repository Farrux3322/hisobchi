import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/dto/models/installment_report/installment_report_models.dart';

class InstallmentReportState {
  // ─── Statuses ──────────────────────────────────────────────────────────────
  final Status summaryStatus;
  final Status recoveryStatus;
  final Status forecastStatus;
  final Status partnersStatus;
  final Status riskyStatus;
  final Status monthlyStatus;

  // ─── Data (both currencies loaded at once) ─────────────────────────────────
  final List<InstallmentSummaryModel> summaries;
  final List<InstallmentRecoveryModel> recoveries;

  // Forecast per currency (key = currencyTypeId)
  final InstallmentForecastModel? forecastUzs;
  final InstallmentForecastModel? forecastUsd;

  // Partners per currency (paginated)
  final List<InstallmentPartnerReportModel> partnersUzs;
  final List<InstallmentPartnerReportModel> partnersUsd;
  final bool hasMorePartnersUzs;
  final bool hasMorePartnersUsd;
  final int currentPageUzs;
  final int currentPageUsd;
  final bool isLoadingMorePartners;

  // Risky partners per currency
  final List<InstallmentRiskyPartnerModel> riskyUzs;
  final List<InstallmentRiskyPartnerModel> riskyUsd;

  // Monthly per currency
  final InstallmentMonthlyModel? monthlyUzs;
  final InstallmentMonthlyModel? monthlyUsd;

  // ─── Filters ───────────────────────────────────────────────────────────────
  final int forecastPeriod; // 30 | 60 | 90
  final int selectedYear;
  final String partnersSort; // 'remaining' | 'total_given'

  // ─── Error ─────────────────────────────────────────────────────────────────
  final String? error;

  const InstallmentReportState({
    this.summaryStatus = Status.pure,
    this.recoveryStatus = Status.pure,
    this.forecastStatus = Status.pure,
    this.partnersStatus = Status.pure,
    this.riskyStatus = Status.pure,
    this.monthlyStatus = Status.pure,
    this.summaries = const [],
    this.recoveries = const [],
    this.forecastUzs,
    this.forecastUsd,
    this.partnersUzs = const [],
    this.partnersUsd = const [],
    this.hasMorePartnersUzs = false,
    this.hasMorePartnersUsd = false,
    this.currentPageUzs = 1,
    this.currentPageUsd = 1,
    this.isLoadingMorePartners = false,
    this.riskyUzs = const [],
    this.riskyUsd = const [],
    this.monthlyUzs,
    this.monthlyUsd,
    this.forecastPeriod = 30,
    this.selectedYear = 0,
    this.partnersSort = 'remaining',
    this.error,
  });

  // ─── Convenience getters ───────────────────────────────────────────────────

  bool get isInitialLoading =>
      summaryStatus == Status.loading && summaries.isEmpty;

  InstallmentSummaryModel? get summaryUzs =>
      summaries.where((s) => s.currencyTypeId == 1).firstOrNull;

  InstallmentSummaryModel? get summaryUsd =>
      summaries.where((s) => s.currencyTypeId == 2).firstOrNull;

  InstallmentRecoveryModel? get recoveryUzs =>
      recoveries.where((r) => r.currencyTypeId == 1).firstOrNull;

  InstallmentRecoveryModel? get recoveryUsd =>
      recoveries.where((r) => r.currencyTypeId == 2).firstOrNull;

  InstallmentSummaryModel? summaryFor(int currencyTypeId) =>
      currencyTypeId == 1 ? summaryUzs : summaryUsd;

  InstallmentRecoveryModel? recoveryFor(int currencyTypeId) =>
      currencyTypeId == 1 ? recoveryUzs : recoveryUsd;

  InstallmentForecastModel? forecastFor(int currencyTypeId) =>
      currencyTypeId == 1 ? forecastUzs : forecastUsd;

  List<InstallmentPartnerReportModel> partnersFor(int currencyTypeId) =>
      currencyTypeId == 1 ? partnersUzs : partnersUsd;

  bool hasMorePartnersFor(int currencyTypeId) =>
      currencyTypeId == 1 ? hasMorePartnersUzs : hasMorePartnersUsd;

  int currentPageFor(int currencyTypeId) =>
      currencyTypeId == 1 ? currentPageUzs : currentPageUsd;

  List<InstallmentRiskyPartnerModel> riskyFor(int currencyTypeId) =>
      currencyTypeId == 1 ? riskyUzs : riskyUsd;

  InstallmentMonthlyModel? monthlyFor(int currencyTypeId) =>
      currencyTypeId == 1 ? monthlyUzs : monthlyUsd;

  // ─── copyWith ──────────────────────────────────────────────────────────────

  InstallmentReportState copyWith({
    Status? summaryStatus,
    Status? recoveryStatus,
    Status? forecastStatus,
    Status? partnersStatus,
    Status? riskyStatus,
    Status? monthlyStatus,
    List<InstallmentSummaryModel>? summaries,
    List<InstallmentRecoveryModel>? recoveries,
    InstallmentForecastModel? forecastUzs,
    InstallmentForecastModel? forecastUsd,
    List<InstallmentPartnerReportModel>? partnersUzs,
    List<InstallmentPartnerReportModel>? partnersUsd,
    bool? hasMorePartnersUzs,
    bool? hasMorePartnersUsd,
    int? currentPageUzs,
    int? currentPageUsd,
    bool? isLoadingMorePartners,
    List<InstallmentRiskyPartnerModel>? riskyUzs,
    List<InstallmentRiskyPartnerModel>? riskyUsd,
    InstallmentMonthlyModel? monthlyUzs,
    InstallmentMonthlyModel? monthlyUsd,
    int? forecastPeriod,
    int? selectedYear,
    String? partnersSort,
    String? error,
    bool clearForecastUzs = false,
    bool clearForecastUsd = false,
    bool clearMonthlyUzs = false,
    bool clearMonthlyUsd = false,
    bool clearError = false,
  }) {
    return InstallmentReportState(
      summaryStatus: summaryStatus ?? this.summaryStatus,
      recoveryStatus: recoveryStatus ?? this.recoveryStatus,
      forecastStatus: forecastStatus ?? this.forecastStatus,
      partnersStatus: partnersStatus ?? this.partnersStatus,
      riskyStatus: riskyStatus ?? this.riskyStatus,
      monthlyStatus: monthlyStatus ?? this.monthlyStatus,
      summaries: summaries ?? this.summaries,
      recoveries: recoveries ?? this.recoveries,
      forecastUzs: clearForecastUzs ? null : (forecastUzs ?? this.forecastUzs),
      forecastUsd: clearForecastUsd ? null : (forecastUsd ?? this.forecastUsd),
      partnersUzs: partnersUzs ?? this.partnersUzs,
      partnersUsd: partnersUsd ?? this.partnersUsd,
      hasMorePartnersUzs: hasMorePartnersUzs ?? this.hasMorePartnersUzs,
      hasMorePartnersUsd: hasMorePartnersUsd ?? this.hasMorePartnersUsd,
      currentPageUzs: currentPageUzs ?? this.currentPageUzs,
      currentPageUsd: currentPageUsd ?? this.currentPageUsd,
      isLoadingMorePartners: isLoadingMorePartners ?? this.isLoadingMorePartners,
      riskyUzs: riskyUzs ?? this.riskyUzs,
      riskyUsd: riskyUsd ?? this.riskyUsd,
      monthlyUzs: clearMonthlyUzs ? null : (monthlyUzs ?? this.monthlyUzs),
      monthlyUsd: clearMonthlyUsd ? null : (monthlyUsd ?? this.monthlyUsd),
      forecastPeriod: forecastPeriod ?? this.forecastPeriod,
      selectedYear: selectedYear ?? this.selectedYear,
      partnersSort: partnersSort ?? this.partnersSort,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
