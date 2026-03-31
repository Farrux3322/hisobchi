import 'package:equatable/equatable.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/partner_operations_detail_model.dart';

class WorkerDetailsOperationsState extends Equatable {
  final Status status;
  final Status statusMore;
  final List<PartnerOperation> operations;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;

  // Selected filters for pagination
  final int? currentWorkerId;
  final List<String>? currentDate;
  final int currentCurrencyTypeId;
  final String? currentType;

  const WorkerDetailsOperationsState({
    this.status = Status.initial,
    this.statusMore = Status.initial,
    this.operations = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.currentWorkerId,
    this.currentDate,
    this.currentCurrencyTypeId = 1,
    this.currentType,
  });

  WorkerDetailsOperationsState copyWithNullable({
    Status? status,
    Status? statusMore,
    List<PartnerOperation>? operations,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
    int? currentWorkerId,
    List<String>? currentDate,
    bool clearDate = false,
    int? currentCurrencyTypeId,
    String? currentType,
    bool clearType = false,
  }) {
    return WorkerDetailsOperationsState(
      status: status ?? this.status,
      statusMore: statusMore ?? this.statusMore,
      operations: operations ?? this.operations,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentWorkerId: currentWorkerId ?? this.currentWorkerId,
      currentDate: clearDate ? null : (currentDate ?? this.currentDate),
      currentCurrencyTypeId: currentCurrencyTypeId ?? this.currentCurrencyTypeId,
      currentType: clearType ? null : (currentType ?? this.currentType),
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
        currentWorkerId,
        currentDate,
        currentCurrencyTypeId,
        currentType,
      ];
}
