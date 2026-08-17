import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/client_report/client_report_event.dart';
import 'package:ehisob/application/client_report/client_report_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/repository/client_report/client_report_repository.dart';

class ClientReportBloc extends Bloc<ClientReportEvent, ClientReportState> {
  final ClientReportRepository repository;

  ClientReportBloc({required this.repository}) : super(const ClientReportState()) {
    on<GetSectionOneReportEvent>(_onGetSectionOneReport);
    on<RefreshSectionOneReportEvent>(_onRefreshSectionOneReport);
    on<GetSectionTwoReportEvent>(_onGetSectionTwoReport);
    on<UpdateDateRangeEvent>(_onUpdateDateRange);
    on<GetSectionThreeReportEvent>(_onGetSectionThreeReport);
  }

  Future<void> _onGetSectionOneReport(
    GetSectionOneReportEvent event,
    Emitter<ClientReportState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final response = await repository.getSectionOneReport();
      emit(state.copyWith(
        status: Status.success,
        partners: response.result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshSectionOneReport(
    RefreshSectionOneReportEvent event,
    Emitter<ClientReportState> emit,
  ) async {
    // Don't show loading for refresh, just update data
    try {
      final response = await repository.getSectionOneReport();
      emit(state.copyWith(
        status: Status.success,
        partners: response.result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGetSectionTwoReport(
    GetSectionTwoReportEvent event,
    Emitter<ClientReportState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final response = await repository.getSectionTwoReport(
        partnerId: event.partnerId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(state.copyWith(
        status: Status.success,
        sectionTwoReport: response.result,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateDateRange(
    UpdateDateRangeEvent event,
    Emitter<ClientReportState> emit,
  ) async {
    emit(state.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
    ));
  }

  Future<void> _onGetSectionThreeReport(
    GetSectionThreeReportEvent event,
    Emitter<ClientReportState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final response = await repository.getSectionThreeReport(
        partnerId: event.partnerId,
        startDate: event.startDate,
        endDate: event.endDate,
        type: event.type,
      );
      emit(state.copyWith(
        status: Status.success,
        transactions: response.result,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}