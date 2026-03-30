import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/time_report/time_report_operations_event.dart';
import 'package:hisobchi/application/time_report/time_report_operations_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';

class TimeReportOperationsBloc extends Bloc<TimeReportOperationsEvent, TimeReportOperationsState> {
  final PartnerReportRepository repository;

  TimeReportOperationsBloc({required this.repository}) : super(const TimeReportOperationsState()) {
    on<LoadTimeReportOperationsEvent>(_onLoad);
    on<LoadMoreTimeReportOperationsEvent>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadTimeReportOperationsEvent event,
    Emitter<TimeReportOperationsState> emit,
  ) async {
    emit(state.copyWithNullable(
      status: Status.loading,
      currentDate: event.date,
      currentCurrencyTypeId: event.currencyTypeId,
      currentType: event.type,
      clearType: event.type == null,
      clearDate: event.date == null,
    ));

    try {
      final response = await repository.getPeriodsOperations(
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
    LoadMoreTimeReportOperationsEvent event,
    Emitter<TimeReportOperationsState> emit,
  ) async {
    if (state.hasReachedMax || state.statusMore == Status.loading) return;

    emit(state.copyWithNullable(statusMore: Status.loading));

    try {
      final nextPage = state.currentPage + 1;
      final response = await repository.getPeriodsOperations(
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
