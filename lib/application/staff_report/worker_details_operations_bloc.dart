import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'worker_details_operations_event.dart';
import 'worker_details_operations_state.dart';

class WorkerDetailsOperationsBloc extends Bloc<WorkerDetailsOperationsEvent, WorkerDetailsOperationsState> {
  final PartnerReportRepository repository;

  WorkerDetailsOperationsBloc({required this.repository}) : super(const WorkerDetailsOperationsState()) {
    on<LoadWorkerDetailsOperationsEvent>(_onLoad);
    on<LoadMoreWorkerDetailsOperationsEvent>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadWorkerDetailsOperationsEvent event,
    Emitter<WorkerDetailsOperationsState> emit,
  ) async {
    emit(state.copyWithNullable(
      status: Status.loading,
      currentWorkerId: event.workerId,
      currentDate: event.date,
      currentCurrencyTypeId: event.currencyTypeId,
      currentType: event.type,
      clearType: event.type == null,
      clearDate: event.date == null,
    ));

    try {
      final response = await repository.getWorkerDetailsOperations(
        workerId: event.workerId,
        date: event.date,
        currencyTypeId: event.currencyTypeId,
        type: event.type,
        page: 1,
      );

      emit(state.copyWithNullable(
        status: Status.success,
        operations: response.result.data,
        currentPage: 1,
        hasReachedMax: !response.result.hasNextPage,
      ));
    } catch (e) {
      emit(state.copyWithNullable(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreWorkerDetailsOperationsEvent event,
    Emitter<WorkerDetailsOperationsState> emit,
  ) async {
    if (state.hasReachedMax || state.statusMore == Status.loading || state.currentWorkerId == null) return;

    emit(state.copyWithNullable(statusMore: Status.loading));

    try {
      final nextPage = state.currentPage + 1;
      final response = await repository.getWorkerDetailsOperations(
        workerId: state.currentWorkerId!,
        date: state.currentDate,
        currencyTypeId: state.currentCurrencyTypeId,
        type: state.currentType,
        page: nextPage,
      );

      if (response.result.data.isEmpty) {
        emit(state.copyWithNullable(
          statusMore: Status.success,
          hasReachedMax: true,
        ));
      } else {
        emit(state.copyWithNullable(
          statusMore: Status.success,
          operations: List.from(state.operations)..addAll(response.result.data),
          currentPage: nextPage,
          hasReachedMax: !response.result.hasNextPage,
        ));
      }
    } catch (e) {
      emit(state.copyWithNullable(
        statusMore: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
