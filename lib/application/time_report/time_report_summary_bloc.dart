import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/time_report/time_report_summary_event.dart';
import 'package:ehisob/application/time_report/time_report_summary_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/repository/partner_report/partner_report_repository.dart';

class TimeReportSummaryBloc
    extends Bloc<TimeReportSummaryEvent, TimeReportSummaryState> {
  final PartnerReportRepository repository;

  TimeReportSummaryBloc({required this.repository})
      : super(const TimeReportSummaryState()) {
    on<LoadTimeReportSummaryEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadTimeReportSummaryEvent event,
    Emitter<TimeReportSummaryState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final response = await repository.getTimeReportSummary(date: event.date);

      emit(state.copyWith(
        status: Status.success,
        data: response.result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
