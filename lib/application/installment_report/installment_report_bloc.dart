import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/installment_report/installment_report_repository.dart';

import 'installment_report_event.dart';
import 'installment_report_state.dart';

class InstallmentReportBloc
    extends Bloc<InstallmentReportEvent, InstallmentReportState> {
  final InstallmentReportRepository _repo;

  InstallmentReportBloc({required InstallmentReportRepository repo})
      : _repo = repo,
        super(InstallmentReportState(selectedYear: DateTime.now().year)) {
    on<LoadInstallmentReportEvent>(_onLoad);
    on<RefreshInstallmentReportEvent>(_onRefresh);
    on<ChangeForecastPeriodEvent>(_onChangeForecastPeriod);
    on<ChangeMonthlyYearEvent>(_onChangeMonthlyYear);
    on<ChangePartnersSortEvent>(_onChangePartnersSort);
    on<LoadMoreInstallmentPartnersEvent>(_onLoadMorePartners);
    on<LoadInstallmentSummaryOnlyEvent>(_onLoadSummaryOnly);
  }

  Future<void> _onLoadSummaryOnly(
    LoadInstallmentSummaryOnlyEvent event,
    Emitter<InstallmentReportState> emit,
  ) async {
    emit(state.copyWith(summaryStatus: Status.loading, clearError: true));
    await _loadSummary(emit);
  }

  // ─── Load all sections ────────────────────────────────────────────────────

  Future<void> _onLoad(
    LoadInstallmentReportEvent event,
    Emitter<InstallmentReportState> emit,
  ) async {
    emit(state.copyWith(
      summaryStatus: Status.loading,
      recoveryStatus: Status.loading,
      forecastStatus: Status.loading,
      partnersStatus: Status.loading,
      riskyStatus: Status.loading,
      monthlyStatus: Status.loading,
      clearError: true,
    ));

    await Future.wait([
      _loadSummary(emit),
      _loadRecovery(emit),
      _loadForecast(emit, period: state.forecastPeriod),
      _loadPartners(emit, page: 1, sort: state.partnersSort),
      _loadRisky(emit),
      _loadMonthly(emit, year: state.selectedYear),
    ]);
  }

  // ─── Refresh ──────────────────────────────────────────────────────────────

  Future<void> _onRefresh(
    RefreshInstallmentReportEvent event,
    Emitter<InstallmentReportState> emit,
  ) async {
    await Future.wait([
      _loadSummary(emit),
      _loadRecovery(emit),
      _loadForecast(emit, period: state.forecastPeriod),
      _loadPartners(emit, page: 1, sort: state.partnersSort),
      _loadRisky(emit),
      _loadMonthly(emit, year: state.selectedYear),
    ]);
  }

  // ─── Change forecast period ───────────────────────────────────────────────

  Future<void> _onChangeForecastPeriod(
    ChangeForecastPeriodEvent event,
    Emitter<InstallmentReportState> emit,
  ) async {
    emit(state.copyWith(
      forecastPeriod: event.period,
      forecastStatus: Status.loading,
      clearForecastUzs: true,
      clearForecastUsd: true,
    ));
    await _loadForecast(emit, period: event.period);
  }

  // ─── Change monthly year ──────────────────────────────────────────────────

  Future<void> _onChangeMonthlyYear(
    ChangeMonthlyYearEvent event,
    Emitter<InstallmentReportState> emit,
  ) async {
    emit(state.copyWith(
      selectedYear: event.year,
      monthlyStatus: Status.loading,
      clearMonthlyUzs: true,
      clearMonthlyUsd: true,
    ));
    await _loadMonthly(emit, year: event.year);
  }

  // ─── Change partners sort ─────────────────────────────────────────────────

  Future<void> _onChangePartnersSort(
    ChangePartnersSortEvent event,
    Emitter<InstallmentReportState> emit,
  ) async {
    emit(state.copyWith(
      partnersSort: event.sort,
      partnersStatus: Status.loading,
      partnersUzs: [],
      partnersUsd: [],
      currentPageUzs: 1,
      currentPageUsd: 1,
    ));
    await _loadPartners(emit, page: 1, sort: event.sort);
  }

  // ─── Load more partners ───────────────────────────────────────────────────

  Future<void> _onLoadMorePartners(
    LoadMoreInstallmentPartnersEvent event,
    Emitter<InstallmentReportState> emit,
  ) async {
    final isUzs = event.currencyTypeId == 1;
    if (state.isLoadingMorePartners) return;
    if (!state.hasMorePartnersFor(event.currencyTypeId)) return;

    emit(state.copyWith(isLoadingMorePartners: true));

    try {
      final nextPage = state.currentPageFor(event.currencyTypeId) + 1;
      final resp = await _repo.getPartners(
        currencyTypeId: event.currencyTypeId,
        sort: state.partnersSort,
        page: nextPage,
      );

      if (isUzs) {
        emit(state.copyWith(
          isLoadingMorePartners: false,
          partnersUzs: [...state.partnersUzs, ...resp.data],
          hasMorePartnersUzs: resp.hasNextPage,
          currentPageUzs: nextPage,
        ));
      } else {
        emit(state.copyWith(
          isLoadingMorePartners: false,
          partnersUsd: [...state.partnersUsd, ...resp.data],
          hasMorePartnersUsd: resp.hasNextPage,
          currentPageUsd: nextPage,
        ));
      }
    } catch (_) {
      emit(state.copyWith(isLoadingMorePartners: false));
    }
  }

  // ─── Private fetch helpers ────────────────────────────────────────────────

  Future<void> _loadSummary(Emitter<InstallmentReportState> emit) async {
    try {
      final data = await _repo.getSummary();
      emit(state.copyWith(summaryStatus: Status.success, summaries: data));
    } catch (e) {
      emit(state.copyWith(
        summaryStatus: Status.error,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _loadRecovery(Emitter<InstallmentReportState> emit) async {
    try {
      final data = await _repo.getRecovery();
      emit(state.copyWith(recoveryStatus: Status.success, recoveries: data));
    } catch (e) {
      emit(state.copyWith(recoveryStatus: Status.error));
    }
  }

  Future<void> _loadForecast(
    Emitter<InstallmentReportState> emit, {
    required int period,
  }) async {
    try {
      final now = DateTime.now();
      final dateFrom = _fmt(now);
      final dateTo = _fmt(now.add(Duration(days: period)));
      final data = await _repo.getForecast(dateFrom: dateFrom, dateTo: dateTo);
      final uzs = data.where((f) => f.currencyTypeId == 1).firstOrNull;
      final usd = data.where((f) => f.currencyTypeId == 2).firstOrNull;
      emit(state.copyWith(
        forecastStatus: Status.success,
        forecastUzs: uzs,
        forecastUsd: usd,
      ));
    } catch (e) {
      emit(state.copyWith(forecastStatus: Status.error));
    }
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _loadRisky(Emitter<InstallmentReportState> emit) async {
    try {
      final all = await _repo.getRiskyPartners();
      // Server returns all; filter client-side if needed
      // If API doesn't filter, we take all and display per currency tab
      emit(state.copyWith(
        riskyStatus: Status.success,
        riskyUzs: all, // Server may return filtered by currency separately
        riskyUsd: all,
      ));
    } catch (e) {
      emit(state.copyWith(riskyStatus: Status.error));
    }
  }

  Future<void> _loadMonthly(
    Emitter<InstallmentReportState> emit, {
    required int year,
  }) async {
    try {
      final data = await _repo.getMonthly(year: year);
      final uzs = data.where((m) => m.currencyTypeId == 1).firstOrNull;
      final usd = data.where((m) => m.currencyTypeId == 2).firstOrNull;
      emit(state.copyWith(
        monthlyStatus: Status.success,
        monthlyUzs: uzs,
        monthlyUsd: usd,
      ));
    } catch (e) {
      emit(state.copyWith(monthlyStatus: Status.error));
    }
  }

  Future<void> _loadPartners(
    Emitter<InstallmentReportState> emit, {
    required int page,
    required String sort,
  }) async {
    try {
      final uzsFuture = _repo.getPartners(currencyTypeId: 1, sort: sort, page: page);
      final usdFuture = _repo.getPartners(currencyTypeId: 2, sort: sort, page: page);

      final results = await Future.wait([uzsFuture, usdFuture]);
      final uzs = results[0];
      final usd = results[1];

      emit(state.copyWith(
        partnersStatus: Status.success,
        partnersUzs: uzs.data,
        partnersUsd: usd.data,
        hasMorePartnersUzs: uzs.hasNextPage,
        hasMorePartnersUsd: usd.hasNextPage,
        currentPageUzs: uzs.currentPage,
        currentPageUsd: usd.currentPage,
      ));
    } catch (e) {
      emit(state.copyWith(partnersStatus: Status.error));
    }
  }
}
