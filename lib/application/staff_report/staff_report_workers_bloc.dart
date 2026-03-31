import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'staff_report_workers_event.dart';
import 'staff_report_workers_state.dart';

class StaffReportWorkersBloc extends Bloc<StaffReportWorkersEvent, StaffReportWorkersState> {
  final PartnerReportRepository repository;

  StaffReportWorkersBloc({required this.repository}) : super(const StaffReportWorkersState()) {
    on<LoadStaffReportWorkersEvent>(_onLoadStaffReportWorkers);
  }

  Future<void> _onLoadStaffReportWorkers(
    LoadStaffReportWorkersEvent event,
    Emitter<StaffReportWorkersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isError: false, isInitial: false));

    try {
      final response = await repository.getWorkersList(
        currencyTypeId: event.currencyTypeId,
        date: event.date,
      );

      if (response.status) {
        emit(state.copyWith(
          isLoading: false,
          workers: response.result,
        ));
      } else {
        emit(state.copyWith(isLoading: false, isError: true, errorMessage: 'Failed to load workers list'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, isError: true, errorMessage: e.toString()));
    }
  }
}
