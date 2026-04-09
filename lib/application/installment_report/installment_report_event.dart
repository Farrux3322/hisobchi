abstract class InstallmentReportEvent {
  const InstallmentReportEvent();
}

class LoadInstallmentReportEvent extends InstallmentReportEvent {
  const LoadInstallmentReportEvent();
}

class RefreshInstallmentReportEvent extends InstallmentReportEvent {
  const RefreshInstallmentReportEvent();
}

class ChangeForecastPeriodEvent extends InstallmentReportEvent {
  final int period; // 30 | 60 | 90
  const ChangeForecastPeriodEvent(this.period);
}

class ChangeMonthlyYearEvent extends InstallmentReportEvent {
  final int year;
  const ChangeMonthlyYearEvent(this.year);
}

class ChangePartnersSortEvent extends InstallmentReportEvent {
  final String sort; // 'remaining' | 'total_given'
  const ChangePartnersSortEvent(this.sort);
}

class LoadMoreInstallmentPartnersEvent extends InstallmentReportEvent {
  final int currencyTypeId;
  const LoadMoreInstallmentPartnersEvent(this.currencyTypeId);
}

class LoadInstallmentSummaryOnlyEvent extends InstallmentReportEvent {
  const LoadInstallmentSummaryOnlyEvent();
}
