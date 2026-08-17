import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/partner_operations_detail_model.dart';

class TimeReportOperationsState {
  final Status status;
  final Status statusMore;
  final List<PartnerOperation> operations;
  final int currentPage;
  final bool hasReachedMax;
  final String? errorMessage;
  
  final List<String>? currentDate;
  final int currentCurrencyTypeId;
  final String? currentType;

  const TimeReportOperationsState({
    this.status = Status.initial,
    this.statusMore = Status.initial,
    this.operations = const [],
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.errorMessage,
    this.currentDate,
    this.currentCurrencyTypeId = 1,
    this.currentType,
  });

  TimeReportOperationsState copyWith({
    Status? status,
    Status? statusMore,
    List<PartnerOperation>? operations,
    int? currentPage,
    bool? hasReachedMax,
    String? errorMessage,
    List<String>? currentDate,
    int? currentCurrencyTypeId,
    String? currentType,
  }) {
    return TimeReportOperationsState(
      status: status ?? this.status,
      statusMore: statusMore ?? this.statusMore,
      operations: operations ?? this.operations,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      currentDate: currentDate ?? this.currentDate,
      currentCurrencyTypeId: currentCurrencyTypeId ?? this.currentCurrencyTypeId,
      currentType: currentType, // we want to be able to set type to null if omitted?
      // Wait, we need a way to clear currentType. For now we will update this to handle nulls by using a wrapper, or simply pass the new value explicitly if changed.
    );
  }
  
  // Workaround to allow nullification
  TimeReportOperationsState copyWithNullable({
    Status? status,
    Status? statusMore,
    List<PartnerOperation>? operations,
    int? currentPage,
    bool? hasReachedMax,
    String? errorMessage,
    List<String>? currentDate,
    int? currentCurrencyTypeId,
    String? currentType,
    bool clearType = false,
    bool clearDate = false,
  }) {
    return TimeReportOperationsState(
      status: status ?? this.status,
      statusMore: statusMore ?? this.statusMore,
      operations: operations ?? this.operations,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      currentDate: clearDate ? null : (currentDate ?? this.currentDate),
      currentCurrencyTypeId: currentCurrencyTypeId ?? this.currentCurrencyTypeId,
      currentType: clearType ? null : (currentType ?? this.currentType),
    );
  }

  bool get isInitial => status == Status.initial;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
}
