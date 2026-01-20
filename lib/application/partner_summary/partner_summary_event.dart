abstract class PartnerSummaryEvent {
  const PartnerSummaryEvent();
}

class LoadPartnerSummaryEvent extends PartnerSummaryEvent {
  final String type;
  final int currencyTypeId;

  const LoadPartnerSummaryEvent({
    required this.type,
    required this.currencyTypeId,
  });
}

class LoadMorePartnerSummaryEvent extends PartnerSummaryEvent {}

class RefreshPartnerSummaryEvent extends PartnerSummaryEvent {}
