import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/partner_operations/partner_operations_event.dart';
import 'package:hisobchi/application/partner_operations/partner_operations_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/partner_operations/partner_operations_repository.dart';

class PartnerOperationsBloc
    extends Bloc<PartnerOperationsEvent, PartnerOperationsState> {
  final PartnerOperationsRepository _repository;

  PartnerOperationsBloc(this._repository)
      : super(const PartnerOperationsState()) {
    on<LoadOperationsEvent>(_onLoadOperations);
    on<RefreshOperationsEvent>(_onRefreshOperations);
    on<LoadMoreOperationsEvent>(_onLoadMoreOperations);
  }

  /// Handle initial load of operations
  Future<void> _onLoadOperations(
    LoadOperationsEvent event,
    Emitter<PartnerOperationsState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final response = event.partnerId != null
          ? await _repository.getPartnerDetailsSectionOne(
              partnerId: event.partnerId!,
              type: event.type,
              currencyTypeId: event.currencyTypeId,
              page: 1,
            )
          : await _repository.getOperationsDetail(
              type: event.type,
              currencyTypeId: event.currencyTypeId,
              page: 1,
            );

      emit(state.copyWith(
        status: Status.success,
        operations: response.result.data,
        currentPage: response.result.currentPage,
        hasNextPage: response.result.hasNextPage,
        isLoadingMore: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        operations: [],
      ));
    }
  }

  /// Handle pull-to-refresh
  Future<void> _onRefreshOperations(
    RefreshOperationsEvent event,
    Emitter<PartnerOperationsState> emit,
  ) async {
    try {
      final response = event.partnerId != null
          ? await _repository.getPartnerDetailsSectionOne(
              partnerId: event.partnerId!,
              type: event.type,
              currencyTypeId: event.currencyTypeId,
              page: 1,
            )
          : await _repository.refreshOperationsDetail(
              type: event.type,
              currencyTypeId: event.currencyTypeId,
            );

      emit(state.copyWith(
        status: Status.success,
        operations: response.result.data,
        currentPage: response.result.currentPage,
        hasNextPage: response.result.hasNextPage,
        isLoadingMore: false,
        errorMessage: null,
      ));
    } catch (e) {
      // Keep existing data on refresh error, just show error message
      emit(state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Handle load more (pagination)
  Future<void> _onLoadMoreOperations(
    LoadMoreOperationsEvent event,
    Emitter<PartnerOperationsState> emit,
  ) async {
    // Don't load more if already loading or no next page
    if (state.isLoadingMore || !state.hasNextPage) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final response = await _repository.loadMoreOperations(
        type: event.type,
        currencyTypeId: event.currencyTypeId,
        page: event.page,
        partnerId: event.partnerId,
      );

      // Append new data to existing operations
      final updatedOperations = List.of(state.operations)
        ..addAll(response.result.data);

      emit(state.copyWith(
        status: Status.success,
        operations: updatedOperations,
        currentPage: response.result.currentPage,
        hasNextPage: response.result.hasNextPage,
        isLoadingMore: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}