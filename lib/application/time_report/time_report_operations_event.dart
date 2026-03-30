abstract class TimeReportOperationsEvent {
  const TimeReportOperationsEvent();
}

class LoadTimeReportOperationsEvent extends TimeReportOperationsEvent {
  final List<String>? date;
  final int currencyTypeId;
  final String? type; // 'debt', 'credit', or null/'all' for Barchasi
  final bool isRefresh;

  const LoadTimeReportOperationsEvent({
    this.date,
    required this.currencyTypeId,
    this.type,
    this.isRefresh = false,
  });
}

class LoadMoreTimeReportOperationsEvent extends TimeReportOperationsEvent {
  const LoadMoreTimeReportOperationsEvent();
}
