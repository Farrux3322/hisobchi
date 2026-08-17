import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'warranty_periods_event.dart';
import 'warranty_periods_state.dart';

class WarrantyPeriodsBloc extends Bloc<WarrantyPeriodsEvent, WarrantyPeriodsState> {
  final PartnerReportRepository repository;

  WarrantyPeriodsBloc({required this.repository}) : super(const WarrantyPeriodsState()) {
    on<LoadWarrantyPeriodsEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadWarrantyPeriodsEvent event, Emitter<WarrantyPeriodsState> emit) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final response = await repository.getWarrantyPeriods();
      emit(state.copyWith(status: Status.success, response: response));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }
}
