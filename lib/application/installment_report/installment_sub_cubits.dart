import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/dto/models/installment_report/installment_report_models.dart';
import 'package:ehisob/infrastructure/repository/installment_report/installment_report_repository.dart';

// ─── Recovery Cubit ───────────────────────────────────────────────────────────

class RecoveryState {
  final Status status;
  final List<InstallmentRecoveryModel> data;
  final String? error;
  const RecoveryState({this.status = Status.pure, this.data = const [], this.error});
  RecoveryState copyWith({Status? status, List<InstallmentRecoveryModel>? data, String? error}) =>
      RecoveryState(status: status ?? this.status, data: data ?? this.data, error: error ?? this.error);
  InstallmentRecoveryModel? forCurrency(int id) => data.where((r) => r.currencyTypeId == id).firstOrNull;
}

class InstallmentRecoveryCubit extends Cubit<RecoveryState> {
  final InstallmentReportRepository _repo;
  InstallmentRecoveryCubit(this._repo) : super(const RecoveryState());

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading));
    try {
      final data = await _repo.getRecovery();
      emit(state.copyWith(status: Status.success, data: data));
    } catch (e) {
      emit(state.copyWith(status: Status.error, error: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

// ─── Forecast Cubit ───────────────────────────────────────────────────────────

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

class ForecastState {
  final Status status;
  final List<InstallmentForecastModel> data;
  final int? presetDays; // 30 | 60 | 90 | null = custom
  final String dateFrom;
  final String dateTo;
  final String? error;

  ForecastState({
    this.status = Status.pure,
    this.data = const [],
    this.presetDays = 30,
    String? dateFrom,
    String? dateTo,
    this.error,
  })  : dateFrom = dateFrom ?? _fmtDate(DateTime.now()),
        dateTo = dateTo ?? _fmtDate(DateTime.now().add(const Duration(days: 30)));

  ForecastState copyWith({
    Status? status,
    List<InstallmentForecastModel>? data,
    int? presetDays,
    bool clearPreset = false,
    String? dateFrom,
    String? dateTo,
    String? error,
  }) =>
      ForecastState(
        status: status ?? this.status,
        data: data ?? this.data,
        presetDays: clearPreset ? null : (presetDays ?? this.presetDays),
        dateFrom: dateFrom ?? this.dateFrom,
        dateTo: dateTo ?? this.dateTo,
        error: error ?? this.error,
      );

  InstallmentForecastModel? forCurrency(int id) =>
      data.where((f) => f.currencyTypeId == id).firstOrNull;
}

class InstallmentForecastCubit extends Cubit<ForecastState> {
  final InstallmentReportRepository _repo;
  InstallmentForecastCubit(this._repo) : super(ForecastState());

  Future<void> load() => _fetch();

  Future<void> changePreset(int days) async {
    final from = DateTime.now();
    final to = from.add(Duration(days: days));
    emit(state.copyWith(
      presetDays: days,
      dateFrom: _fmtDate(from),
      dateTo: _fmtDate(to),
    ));
    await _fetch();
  }

  Future<void> changeCustomRange(String dateFrom, String dateTo) async {
    emit(state.copyWith(clearPreset: true, dateFrom: dateFrom, dateTo: dateTo));
    await _fetch();
  }

  Future<void> _fetch() async {
    emit(state.copyWith(status: Status.loading));
    try {
      final results = await Future.wait([
        _repo.getForecast(dateFrom: state.dateFrom, dateTo: state.dateTo, currencyTypeId: 1),
        _repo.getForecast(dateFrom: state.dateFrom, dateTo: state.dateTo, currencyTypeId: 2),
      ]);
      emit(state.copyWith(status: Status.success, data: [...results[0], ...results[1]]));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}

// ─── Risky Cubit ──────────────────────────────────────────────────────────────

class RiskyState {
  final Status status;
  final List<InstallmentRiskyPartnerModel> data;
  final String? error;
  const RiskyState({this.status = Status.pure, this.data = const [], this.error});
  RiskyState copyWith({Status? status, List<InstallmentRiskyPartnerModel>? data, String? error}) =>
      RiskyState(status: status ?? this.status, data: data ?? this.data, error: error ?? this.error);
}

class InstallmentRiskyCubit extends Cubit<RiskyState> {
  final InstallmentReportRepository _repo;
  InstallmentRiskyCubit(this._repo) : super(const RiskyState());

  Future<void> load({int? currencyTypeId}) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final data = await _repo.getRiskyPartners(currencyTypeId: currencyTypeId);
      emit(state.copyWith(status: Status.success, data: data));
    } catch (e) {
      emit(state.copyWith(status: Status.error, error: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

// ─── Monthly Cubit ────────────────────────────────────────────────────────────

class MonthlyState {
  final Status status;
  final List<InstallmentMonthlyModel> data;
  final int selectedYear;
  final String? error;
  MonthlyState({this.status = Status.pure, this.data = const [], int? selectedYear, this.error})
      : selectedYear = selectedYear ?? DateTime.now().year;
  MonthlyState copyWith({Status? status, List<InstallmentMonthlyModel>? data, int? selectedYear, String? error}) =>
      MonthlyState(status: status ?? this.status, data: data ?? this.data, selectedYear: selectedYear ?? this.selectedYear, error: error ?? this.error);
  InstallmentMonthlyModel? forCurrency(int id) => data.where((m) => m.currencyTypeId == id).firstOrNull;
}

class InstallmentMonthlyCubit extends Cubit<MonthlyState> {
  final InstallmentReportRepository _repo;
  InstallmentMonthlyCubit(this._repo) : super(MonthlyState());

  Future<void> load({int? year}) async {
    final y = year ?? state.selectedYear;
    emit(state.copyWith(status: Status.loading, selectedYear: y));
    try {
      final data = await _repo.getMonthly(year: y);
      emit(state.copyWith(status: Status.success, data: data));
    } catch (e) {
      emit(state.copyWith(status: Status.error, error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> changeYear(int year) => load(year: year);
}

// ─── Items Cubit ──────────────────────────────────────────────────────────────

class ItemsState {
  final Status status;
  final List<InstallmentItemModel> items;
  final bool hasMore;
  final int page;
  final bool isLoadingMore;
  final String itemStatus;
  final int currencyTypeId;
  final String? error;

  const ItemsState({
    this.status = Status.pure,
    this.items = const [],
    this.hasMore = false,
    this.page = 1,
    this.isLoadingMore = false,
    this.itemStatus = 'pending',
    this.currencyTypeId = 1,
    this.error,
  });

  ItemsState copyWith({
    Status? status,
    List<InstallmentItemModel>? items,
    bool? hasMore,
    int? page,
    bool? isLoadingMore,
    String? itemStatus,
    int? currencyTypeId,
    String? error,
  }) =>
      ItemsState(
        status: status ?? this.status,
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        itemStatus: itemStatus ?? this.itemStatus,
        currencyTypeId: currencyTypeId ?? this.currencyTypeId,
        error: error ?? this.error,
      );
}

class InstallmentItemsCubit extends Cubit<ItemsState> {
  final InstallmentReportRepository _repo;
  InstallmentItemsCubit(this._repo) : super(const ItemsState());

  Future<void> load({required String status, required int currencyTypeId}) async {
    emit(state.copyWith(
      status: Status.loading,
      items: [],
      page: 1,
      hasMore: false,
      itemStatus: status,
      currencyTypeId: currencyTypeId,
    ));
    try {
      final resp = await _repo.getItems(status: status, currencyTypeId: currencyTypeId, page: 1);
      emit(state.copyWith(
        status: Status.success,
        items: resp.data,
        hasMore: resp.hasNextPage,
        page: 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: Status.error, error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.page + 1;
      final resp = await _repo.getItems(
        status: state.itemStatus,
        currencyTypeId: state.currencyTypeId,
        page: nextPage,
      );
      emit(state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...resp.data],
        hasMore: resp.hasNextPage,
        page: nextPage,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}

// ─── Partners Cubit ───────────────────────────────────────────────────────────

class PartnersState {
  final Status status;
  final List<InstallmentPartnerReportModel> uzs;
  final List<InstallmentPartnerReportModel> usd;
  final bool hasMoreUzs;
  final bool hasMoreUsd;
  final int pageUzs;
  final int pageUsd;
  final bool isLoadingMore;
  final String sort;
  final String? error;

  const PartnersState({
    this.status = Status.pure,
    this.uzs = const [],
    this.usd = const [],
    this.hasMoreUzs = false,
    this.hasMoreUsd = false,
    this.pageUzs = 1,
    this.pageUsd = 1,
    this.isLoadingMore = false,
    this.sort = 'remaining',
    this.error,
  });

  List<InstallmentPartnerReportModel> forCurrency(int id) => id == 1 ? uzs : usd;
  bool hasMoreFor(int id) => id == 1 ? hasMoreUzs : hasMoreUsd;
  int pageFor(int id) => id == 1 ? pageUzs : pageUsd;

  PartnersState copyWith({
    Status? status,
    List<InstallmentPartnerReportModel>? uzs,
    List<InstallmentPartnerReportModel>? usd,
    bool? hasMoreUzs,
    bool? hasMoreUsd,
    int? pageUzs,
    int? pageUsd,
    bool? isLoadingMore,
    String? sort,
    String? error,
  }) =>
      PartnersState(
        status: status ?? this.status,
        uzs: uzs ?? this.uzs,
        usd: usd ?? this.usd,
        hasMoreUzs: hasMoreUzs ?? this.hasMoreUzs,
        hasMoreUsd: hasMoreUsd ?? this.hasMoreUsd,
        pageUzs: pageUzs ?? this.pageUzs,
        pageUsd: pageUsd ?? this.pageUsd,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        sort: sort ?? this.sort,
        error: error ?? this.error,
      );
}

class InstallmentPartnersCubit extends Cubit<PartnersState> {
  final InstallmentReportRepository _repo;
  InstallmentPartnersCubit(this._repo) : super(const PartnersState());

  Future<void> load({String sort = 'remaining'}) async {
    emit(state.copyWith(status: Status.loading, sort: sort, uzs: [], usd: [], pageUzs: 1, pageUsd: 1));
    try {
      final results = await Future.wait([
        _repo.getPartners(currencyTypeId: 1, sort: sort, page: 1),
        _repo.getPartners(currencyTypeId: 2, sort: sort, page: 1),
      ]);
      emit(state.copyWith(
        status: Status.success,
        uzs: results[0].data,
        usd: results[1].data,
        hasMoreUzs: results[0].hasNextPage,
        hasMoreUsd: results[1].hasNextPage,
        pageUzs: 1,
        pageUsd: 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: Status.error, error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> changeSort(String sort) => load(sort: sort);

  Future<void> loadMore(int currencyTypeId) async {
    if (state.isLoadingMore || !state.hasMoreFor(currencyTypeId)) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.pageFor(currencyTypeId) + 1;
      final resp = await _repo.getPartners(currencyTypeId: currencyTypeId, sort: state.sort, page: nextPage);
      if (currencyTypeId == 1) {
        emit(state.copyWith(isLoadingMore: false, uzs: [...state.uzs, ...resp.data], hasMoreUzs: resp.hasNextPage, pageUzs: nextPage));
      } else {
        emit(state.copyWith(isLoadingMore: false, usd: [...state.usd, ...resp.data], hasMoreUsd: resp.hasNextPage, pageUsd: nextPage));
      }
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}
