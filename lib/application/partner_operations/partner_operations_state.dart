import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/partner_operations_detail_model.dart';

class PartnerOperationsState {
  final Status status;
  final List<PartnerOperation> operations;
  final String? errorMessage;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoadingMore;

  const PartnerOperationsState({
    this.status = Status.initial,
    this.operations = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasNextPage = false,
    this.isLoadingMore = false,
  });

  PartnerOperationsState copyWith({
    Status? status,
    List<PartnerOperation>? operations,
    String? errorMessage,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoadingMore,
  }) {
    return PartnerOperationsState(
      status: status ?? this.status,
      operations: operations ?? this.operations,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  // Helper getters
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
  bool get hasData => operations.isNotEmpty;
  bool get canLoadMore => hasNextPage && !isLoadingMore;
}