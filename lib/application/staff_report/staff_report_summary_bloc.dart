import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'staff_report_summary_event.dart';
import 'staff_report_summary_state.dart';

class StaffReportSummaryBloc extends Bloc<StaffReportSummaryEvent, StaffReportSummaryState> {
  final PartnerReportRepository repository;

  StaffReportSummaryBloc({required this.repository}) : super(const StaffReportSummaryState()) {
    on<LoadStaffReportSummaryEvent>(_onLoadStaffReportSummary);
  }

  Future<void> _onLoadStaffReportSummary(
    LoadStaffReportSummaryEvent event,
    Emitter<StaffReportSummaryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isError: false, isInitial: false));

    try {
      final response = await repository.getWorkersSummary(date: event.date);

      if (response.status) {
        emit(state.copyWith(
          isLoading: false,
          uzs: response.result.uzs,
          usd: response.result.usd,
        ));
      } else {
        emit(state.copyWith(isLoading: false, isError: true, errorMessage: 'Failed to load staff summary'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, isError: true, errorMessage: e.toString()));
    }
  }
}
