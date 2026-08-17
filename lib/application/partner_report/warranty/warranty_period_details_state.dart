import 'package:equatable/equatable.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/partner_operations_detail_model.dart';

class WarrantyPeriodDetailsState extends Equatable {
  final Status status;
  final Status statusMore;
  final List<PartnerOperation> operations;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;

  // Selected filters for pagination
  final String? currentType;
  final int currentCurrencyTypeId;

  const WarrantyPeriodDetailsState({
    this.status = Status.initial,
    this.statusMore = Status.initial,
    this.operations = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.currentType,
    this.currentCurrencyTypeId = 1,
  });

  WarrantyPeriodDetailsState copyWithNullable({
    Status? status,
    Status? statusMore,
    List<PartnerOperation>? operations,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
    String? currentType,
    int? currentCurrencyTypeId,
  }) {
    return WarrantyPeriodDetailsState(
      status: status ?? this.status,
      statusMore: statusMore ?? this.statusMore,
      operations: operations ?? this.operations,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentType: currentType ?? this.currentType,
      currentCurrencyTypeId: currentCurrencyTypeId ?? this.currentCurrencyTypeId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statusMore,
        operations,
        errorMessage,
        currentPage,
        hasReachedMax,
        currentType,
        currentCurrencyTypeId,
      ];
}
