import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/repository/partner_installment_report/partner_installment_report_repository.dart';

import 'partner_installment_report_event.dart';
import 'partner_installment_report_state.dart';

class PartnerInstallmentReportBloc
    extends Bloc<PartnerInstallmentReportEvent, PartnerInstallmentReportState> {
  final PartnerInstallmentReportRepository _repo;

  PartnerInstallmentReportBloc({
    required PartnerInstallmentReportRepository repo,
  })  : _repo = repo,
        super(PartnerInstallmentReportState.initial()) {
    on<LoadPartnerReportEvent>(_onLoad);
    on<SelectCurrencyTypeEvent>(_onSelectCurrency);
    on<RefreshPartnerReportEvent>(_onRefresh);
    on<FilterItemsByStatusEvent>(_onFilterItems);
    on<ChangePartnerReportYearEvent>(_onChangeYear);
  }

  // ─── Birinchi yuklash (faqat UZS) ────────────────────────────────────────────

  Future<void> _onLoad(
    LoadPartnerReportEvent event,
    Emitter<PartnerInstallmentReportState> emit,
  ) async {
    emit(state.copyWith(
      partnerId: event.partnerId,
      uzs: state.uzs.copyWith(mainStatus: Status.loading, clearError: true),
    ));

    await _fetchForCurrency(
      emit,
      currencyTypeId: 1,
      partnerId: event.partnerId,
      mainStatusTarget: true,
    );
  }

  // ─── Valyuta tabini almashtirish (lazy load) ──────────────────────────────────

  Future<void> _onSelectCurrency(
    SelectCurrencyTypeEvent event,
    Emitter<PartnerInstallmentReportState> emit,
  ) async {
    if (state.selectedCurrencyTypeId == event.currencyTypeId) return;

    // Active tabni almashtirish
    emit(state.copyWith(selectedCurrencyTypeId: event.currencyTypeId));

    // Agar bu valyuta hali yuklanmagan bo'lsa — yuklaymiz
    if (state.snapshotFor(event.currencyTypeId).isUnloaded) {
      emit(state.updateSnapshot(
        event.currencyTypeId,
        (s) => s.copyWith(mainStatus: Status.loading, clearError: true),
      ));

      await _fetchForCurrency(
        emit,
        currencyTypeId: event.currencyTypeId,
        partnerId: state.partnerId,
        mainStatusTarget: true,
      );
    }
  }

  // ─── Refresh (active tab) ─────────────────────────────────────────────────────

  Future<void> _onRefresh(
    RefreshPartnerReportEvent event,
    Emitter<PartnerInstallmentReportState> emit,
  ) async {
    final cid = state.selectedCurrencyTypeId;
    final snap = state.snapshotFor(cid);

    emit(state.updateSnapshot(
      cid,
      (s) => s.copyWith(mainStatus: Status.loading, clearError: true),
    ));

    await _fetchForCurrency(
      emit,
      currencyTypeId: cid,
      partnerId: state.partnerId,
      itemsStatus: snap.itemsStatusFilter,
      year: snap.selectedYear,
      mainStatusTarget: true,
    );
  }

  // ─── Items filter (active tab) ────────────────────────────────────────────────

  Future<void> _onFilterItems(
    FilterItemsByStatusEvent event,
    Emitter<PartnerInstallmentReportState> emit,
  ) async {
    final cid = state.selectedCurrencyTypeId;
    final snap = state.snapshotFor(cid);

    if (snap.itemsStatusFilter == event.status) return;

    emit(state.updateSnapshot(
      cid,
      (s) => s.copyWith(
        itemsStatus: Status.loading,
        itemsStatusFilter: event.status,
        clearItemsFilter: event.status == null,
      ),
    ));

    await _fetchForCurrency(
      emit,
      currencyTypeId: cid,
      partnerId: state.partnerId,
      itemsStatus: event.status,
      year: snap.selectedYear,
      itemsStatusTarget: true,
    );
  }

  // ─── Yil o'zgartirish (active tab) ────────────────────────────────────────────

  Future<void> _onChangeYear(
    ChangePartnerReportYearEvent event,
    Emitter<PartnerInstallmentReportState> emit,
  ) async {
    final cid = state.selectedCurrencyTypeId;
    final snap = state.snapshotFor(cid);

    if (snap.selectedYear == event.year) return;

    emit(state.updateSnapshot(
      cid,
      (s) => s.copyWith(
        monthlyStatus: Status.loading,
        selectedYear: event.year,
      ),
    ));

    await _fetchForCurrency(
      emit,
      currencyTypeId: cid,
      partnerId: state.partnerId,
      itemsStatus: snap.itemsStatusFilter,
      year: event.year,
      monthlyStatusTarget: true,
    );
  }

  // ─── Private: API chaqiruv ─────────────────────────────────────────────────────
  //
  // mainStatusTarget   → barcha bo'limlar yangilanadi
  // itemsStatusTarget  → faqat items yangilanadi
  // monthlyStatusTarget → faqat oylik dinamika yangilanadi

  Future<void> _fetchForCurrency(
    Emitter<PartnerInstallmentReportState> emit, {
    required int currencyTypeId,
    required int partnerId,
    String? itemsStatus,
    int? year,
    bool mainStatusTarget = false,
    bool itemsStatusTarget = false,
    bool monthlyStatusTarget = false,
  }) async {
    final snap = state.snapshotFor(currencyTypeId);

    try {
      final data = await _repo.getReport(
        partnerId: partnerId,
        itemsStatus: itemsStatus,
        year: year ?? snap.selectedYear,
        currencyTypeId: currencyTypeId,
      );

      // Partner ma'lumotlarini umumiy state ga yozamiz
      // (UZS yoki USD — farqi yo'q, ikkalasi ham bir xil partner)
      emit(
        state
            .copyWith(
              partnerName: data.partnerName,
              partnerPhone: data.partnerPhone,
            )
            .updateSnapshot(
              currencyTypeId,
              (s) => s.copyWith(
                mainStatus: mainStatusTarget ? Status.success : null,
                itemsStatus:
                    (itemsStatusTarget || mainStatusTarget) ? Status.success : null,
                monthlyStatus:
                    (monthlyStatusTarget || mainStatusTarget) ? Status.success : null,
                stat: data.stats.isNotEmpty ? data.stats.first : null,
                clearStat: data.stats.isEmpty,
                plans: data.plans,
                payments: data.payments,
                items: data.items,
                monthlyDynamics: data.monthlyDynamics,
                clearError: true,
              ),
            ),
      );
    } catch (e) {
      final errMsg = e.toString().replaceFirst('Exception: ', '');
      emit(state.updateSnapshot(
        currencyTypeId,
        (s) => s.copyWith(
          mainStatus: mainStatusTarget ? Status.error : null,
          itemsStatus: itemsStatusTarget ? Status.error : null,
          monthlyStatus: monthlyStatusTarget ? Status.error : null,
          error: errMsg,
        ),
      ));
    }
  }
}
