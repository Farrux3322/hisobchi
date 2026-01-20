abstract class PartnerOperationsEvent {
  const PartnerOperationsEvent();
}

/// Load initial operations
class LoadOperationsEvent extends PartnerOperationsEvent {
  final String type;
  final int currencyTypeId;

  const LoadOperationsEvent({
    required this.type,
    required this.currencyTypeId,
  });
}

/// Refresh operations (pull-to-refresh)
class RefreshOperationsEvent extends PartnerOperationsEvent {
  final String type;
  final int currencyTypeId;

  const RefreshOperationsEvent({
    required this.type,
    required this.currencyTypeId,
  });
}

/// Load more operations (pagination)
class LoadMoreOperationsEvent extends PartnerOperationsEvent {
  final String type;
  final int currencyTypeId;
  final int page;

  const LoadMoreOperationsEvent({
    required this.type,
    required this.currencyTypeId,
    required this.page,
  });
}