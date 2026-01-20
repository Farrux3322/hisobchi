abstract class PartnerReportEvent {
  const PartnerReportEvent();
}

/// Load partner main report
class LoadPartnerReportEvent extends PartnerReportEvent {
  const LoadPartnerReportEvent();
}

/// Refresh partner main report (for pull-to-refresh)
class RefreshPartnerReportEvent extends PartnerReportEvent {
  const RefreshPartnerReportEvent();
}