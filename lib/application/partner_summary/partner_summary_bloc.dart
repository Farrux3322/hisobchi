import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/partner_summary/partner_summary_event.dart';
import 'package:hisobchi/application/partner_summary/partner_summary_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';

class PartnerSummaryBloc extends Bloc<PartnerSummaryEvent, PartnerSummaryState> {
  final PartnerReportRepository repository;

  PartnerSummaryBloc({required this.repository}) : super(PartnerSummaryState()) {
    on<LoadPartnerSummaryEvent>(_onLoadPartnerSummary);
    on<LoadMorePartnerSummaryEvent>(_onLoadMorePartnerSummary);
    on<RefreshPartnerSummaryEvent>(_onRefreshPartnerSummary);
  }

  Future<void> _onLoadPartnerSummary(
    LoadPartnerSummaryEvent event,
    Emitter<PartnerSummaryState> emit,
  ) async {
    emit(state.copyWith(
      status: Status.loading,
      type: event.type,
      currencyTypeId: event.currencyTypeId,
      partners: [],
      currentPage: 1,
      hasReachedMax: false,
    ));

    try {
      final response = await repository.getPartnerSummaryList(
        type: event.type,
        currencyTypeId: event.currencyTypeId,
        page: 1,
      );

      emit(state.copyWith(
        status: Status.success,
        partners: response.result.data,
        currentPage: response.result.currentPage,
        hasReachedMax: response.result.nextPageUrl == null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMorePartnerSummary(
    LoadMorePartnerSummaryEvent event,
    Emitter<PartnerSummaryState> emit,
  ) async {
    if (state.hasReachedMax || state.status == Status.loading) return;

    try {
      final nextPage = state.currentPage + 1;
      final response = await repository.getPartnerSummaryList(
        type: state.type,
        currencyTypeId: state.currencyTypeId,
        page: nextPage,
      );

      emit(state.copyWith(
        partners: List.of(state.partners)..addAll(response.result.data),
        currentPage: response.result.currentPage,
        hasReachedMax: response.result.nextPageUrl == null,
      ));
    } catch (e) {
      // Don't change status to error to keep the current list
    }
  }

  Future<void> _onRefreshPartnerSummary(
    RefreshPartnerSummaryEvent event,
    Emitter<PartnerSummaryState> emit,
  ) async {
    try {
      final response = await repository.getPartnerSummaryList(
        type: state.type,
        currencyTypeId: state.currencyTypeId,
        page: 1,
      );

      emit(state.copyWith(
        status: Status.success,
        partners: response.result.data,
        currentPage: response.result.currentPage,
        hasReachedMax: response.result.nextPageUrl == null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
