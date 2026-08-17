import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/sent_sms/sent_sms_event.dart';
import 'package:ehisob/application/sent_sms/sent_sms_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/repository/partner_report/partner_report_repository.dart';

class SentSmsBloc extends Bloc<SentSmsEvent, SentSmsState> {
  final PartnerReportRepository repository;

  SentSmsBloc({required this.repository}) : super(const SentSmsState()) {
    on<FetchSentSmsEvent>(_onFetchSentSms);
  }

  Future<void> _onFetchSentSms(
    FetchSentSmsEvent event,
    Emitter<SentSmsState> emit,
  ) async {
    if (event.isRefresh) {
      emit(state.copyWith(
        status: Status.loading,
        smsList: [],
        currentPage: 1,
        hasMore: true,
      ));
    } else {
      if (!state.hasMore || state.status == Status.loading) return;
      emit(state.copyWith(status: Status.loading));
    }

    try {
      final response = await repository.getSentSms(
        partnerId: event.partnerId,
        page: state.currentPage,
      );

      final newList = event.isRefresh
          ? response.result.data
          : [...state.smsList, ...response.result.data];

      emit(state.copyWith(
        status: Status.success,
        smsList: newList,
        currentPage: state.currentPage + 1,
        hasMore: response.result.links.next != null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
