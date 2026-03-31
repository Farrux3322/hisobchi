import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'worker_details_summary_event.dart';
import 'worker_details_summary_state.dart';

class WorkerDetailsSummaryBloc extends Bloc<WorkerDetailsSummaryEvent, WorkerDetailsSummaryState> {
  final PartnerReportRepository repository;

  WorkerDetailsSummaryBloc({required this.repository}) : super(const WorkerDetailsSummaryState()) {
    on<LoadWorkerDetailsSummaryEvent>(_onLoadWorkerDetailsSummary);
  }

  Future<void> _onLoadWorkerDetailsSummary(
    LoadWorkerDetailsSummaryEvent event,
    Emitter<WorkerDetailsSummaryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isError: false, isInitial: false));

    try {
      final response = await repository.getWorkerDetailsSummary(
        workerId: event.workerId,
        date: event.date,
      );

      if (response.status) {
        emit(state.copyWith(
          isLoading: false,
          uzs: response.result.uzs,
          usd: response.result.usd,
        ));
      } else {
        emit(state.copyWith(isLoading: false, isError: true, errorMessage: 'Failed to load summary'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, isError: true, errorMessage: e.toString()));
    }
  }
}
