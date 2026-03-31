import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'warranty_period_details_event.dart';
import 'warranty_period_details_state.dart';

class WarrantyPeriodDetailsBloc extends Bloc<WarrantyPeriodDetailsEvent, WarrantyPeriodDetailsState> {
  final PartnerReportRepository repository;

  WarrantyPeriodDetailsBloc({required this.repository}) : super(const WarrantyPeriodDetailsState()) {
    on<LoadWarrantyPeriodDetailsEvent>(_onLoad);
    on<LoadMoreWarrantyPeriodDetailsEvent>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadWarrantyPeriodDetailsEvent event,
    Emitter<WarrantyPeriodDetailsState> emit,
  ) async {
    emit(state.copyWithNullable(
      status: Status.loading,
      currentType: event.type,
      currentCurrencyTypeId: event.currencyTypeId,
    ));

    try {
      final response = await repository.getWarrantyPeriodDetails(
        type: event.type,
        currencyTypeId: event.currencyTypeId,
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
    LoadMoreWarrantyPeriodDetailsEvent event,
    Emitter<WarrantyPeriodDetailsState> emit,
  ) async {
    if (state.hasReachedMax || state.statusMore == Status.loading || state.currentType == null) return;

    emit(state.copyWithNullable(statusMore: Status.loading));

    try {
      final nextPage = state.currentPage + 1;
      final response = await repository.getWarrantyPeriodDetails(
        type: state.currentType!,
        currencyTypeId: state.currentCurrencyTypeId,
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
