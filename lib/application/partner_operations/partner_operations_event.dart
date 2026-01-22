abstract class PartnerOperationsEvent {
  const PartnerOperationsEvent();
}

/// Load initial operations
class LoadOperationsEvent extends PartnerOperationsEvent {
  final String type;
  final int currencyTypeId;
  final int? partnerId;

  const LoadOperationsEvent({
    required this.type,
    required this.currencyTypeId,
    this.partnerId,
  });
}

/// Refresh operations (pull-to-refresh)
class RefreshOperationsEvent extends PartnerOperationsEvent {
  final String type;
  final int currencyTypeId;
  final int? partnerId;

  const RefreshOperationsEvent({
    required this.type,
    required this.currencyTypeId,
    this.partnerId,
  });
}

/// Load more operations (pagination)
class LoadMoreOperationsEvent extends PartnerOperationsEvent {
  final String type;
  final int currencyTypeId;
  final int page;
  final int? partnerId;

  const LoadMoreOperationsEvent({
    required this.type,
    required this.currencyTypeId,
    required this.page,
    this.partnerId,
  });
}