abstract class TimeReportSummaryEvent {
  const TimeReportSummaryEvent();
}

/// Load time report summary.
/// [date] is null for "Barchasi", or ['DD.MM.YYYY', 'DD.MM.YYYY'] for a range.
class LoadTimeReportSummaryEvent extends TimeReportSummaryEvent {
  final List<String>? date;

  const LoadTimeReportSummaryEvent({this.date});
}
