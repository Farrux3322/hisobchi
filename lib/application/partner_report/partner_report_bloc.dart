import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/partner_report/partner_report_event.dart';
import 'package:hisobchi/application/partner_report/partner_report_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';

class PartnerReportBloc extends Bloc<PartnerReportEvent, PartnerReportState> {
  final PartnerReportRepository repository;

  PartnerReportBloc({required this.repository}) : super(const PartnerReportState()) {
    on<LoadPartnerReportEvent>(_onLoadPartnerReport);
    on<RefreshPartnerReportEvent>(_onRefreshPartnerReport);
  }

  /// Load partner main report
  Future<void> _onLoadPartnerReport(
    LoadPartnerReportEvent event,
    Emitter<PartnerReportState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final response = await repository.getPartnerMainReport();

      emit(state.copyWith(
        status: Status.success,
        reportData: response.result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Refresh partner main report (for pull-to-refresh)
  Future<void> _onRefreshPartnerReport(
    RefreshPartnerReportEvent event,
    Emitter<PartnerReportState> emit,
  ) async {
    // Don't show loading state for refresh, just update data silently
    try {
      final response = await repository.refreshPartnerMainReport();

      emit(state.copyWith(
        status: Status.success,
        reportData: response.result,
      ));
    } catch (e) {
      // On refresh error, keep existing data and show error message
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}