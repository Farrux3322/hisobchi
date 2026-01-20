import 'package:hisobchi/infrastructure/models/partner_summary_model.dart';
import 'package:hisobchi/domain/common/constants.dart';

class PartnerSummaryState {
  final Status status;
  final List<PartnerSummaryData> partners;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final String type;
  final int currencyTypeId;

  PartnerSummaryState({
    this.status = Status.initial,
    this.partners = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.type = '',
    this.currencyTypeId = 1,
  });

  PartnerSummaryState copyWith({
    Status? status,
    List<PartnerSummaryData>? partners,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    String? type,
    int? currencyTypeId,
  }) {
    return PartnerSummaryState(
      status: status ?? this.status,
      partners: partners ?? this.partners,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      type: type ?? this.type,
      currencyTypeId: currencyTypeId ?? this.currencyTypeId,
    );
  }
}
