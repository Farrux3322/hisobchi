import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/dto/models/partner_installment_report/partner_installment_report_models.dart';

// ─── Per-currency snapshot ────────────────────────────────────────────────────
//
// UZS va USD uchun alohida holat saqlanadi. Har bir tab o'zining
// filtrlari, yili va loading statusiga ega bo'ladi.

class PartnerCurrencySnapshot {
  final PartnerInstallmentStatModel? stat;
  final List<PartnerInstallmentPlanModel> plans;
  final List<PartnerInstallmentPaymentModel> payments;
  final List<PartnerInstallmentItemModel> items;
  final List<PartnerMonthlyDynamicModel> monthlyDynamics;

  /// Bo'lim darajasidagi yuklanish statuses
  final Status mainStatus;
  final Status itemsStatus;
  final Status monthlyStatus;

  /// Tab mustaqil filtrlari
  final String? itemsStatusFilter;
  final int selectedYear;

  final String? error;

  const PartnerCurrencySnapshot({
    this.stat,
    this.plans = const [],
    this.payments = const [],
    this.items = const [],
    this.monthlyDynamics = const [],
    this.mainStatus = Status.pure,
    this.itemsStatus = Status.pure,
    this.monthlyStatus = Status.pure,
    this.itemsStatusFilter,
    required this.selectedYear,
    this.error,
  });

  /// Birinchi marta yuklanayotgan (hali ma'lumot yo'q + loading)
  bool get isInitialLoading => mainStatus == Status.loading && stat == null;

  /// Hali umuman yuklanmagan
  bool get isUnloaded => mainStatus == Status.pure;

  PartnerCurrencySnapshot copyWith({
    PartnerInstallmentStatModel? stat,
    List<PartnerInstallmentPlanModel>? plans,
    List<PartnerInstallmentPaymentModel>? payments,
    List<PartnerInstallmentItemModel>? items,
    List<PartnerMonthlyDynamicModel>? monthlyDynamics,
    Status? mainStatus,
    Status? itemsStatus,
    Status? monthlyStatus,
    String? itemsStatusFilter,
    int? selectedYear,
    String? error,
    bool clearItemsFilter = false,
    bool clearError = false,
    bool clearStat = false,
  }) {
    return PartnerCurrencySnapshot(
      stat: clearStat ? null : (stat ?? this.stat),
      plans: plans ?? this.plans,
      payments: payments ?? this.payments,
      items: items ?? this.items,
      monthlyDynamics: monthlyDynamics ?? this.monthlyDynamics,
      mainStatus: mainStatus ?? this.mainStatus,
      itemsStatus: itemsStatus ?? this.itemsStatus,
      monthlyStatus: monthlyStatus ?? this.monthlyStatus,
      itemsStatusFilter:
          clearItemsFilter ? null : (itemsStatusFilter ?? this.itemsStatusFilter),
      selectedYear: selectedYear ?? this.selectedYear,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─── Main state ───────────────────────────────────────────────────────────────

class PartnerInstallmentReportState {
  final int partnerId;
  final String partnerName;
  final String partnerPhone;

  /// Hozirda ko'rsatilayotgan valyuta tab (1 = UZS, 2 = USD)
  final int selectedCurrencyTypeId;

  /// Har bir valyuta uchun mustaqil snapshot (lazy loaded)
  final PartnerCurrencySnapshot uzs;
  final PartnerCurrencySnapshot usd;

  const PartnerInstallmentReportState({
    this.partnerId = 0,
    this.partnerName = '',
    this.partnerPhone = '',
    this.selectedCurrencyTypeId = 1,
    required this.uzs,
    required this.usd,
  });

  factory PartnerInstallmentReportState.initial() {
    final year = DateTime.now().year;
    return PartnerInstallmentReportState(
      uzs: PartnerCurrencySnapshot(selectedYear: year),
      usd: PartnerCurrencySnapshot(selectedYear: year),
    );
  }

  /// Berilgan valyuta uchun snapshot
  PartnerCurrencySnapshot snapshotFor(int currencyTypeId) =>
      currencyTypeId == 1 ? uzs : usd;

  /// Active tab uchun snapshot
  PartnerCurrencySnapshot get current => snapshotFor(selectedCurrencyTypeId);

  /// Active tab birinchi yuklanishda
  bool get isInitialLoading => current.isInitialLoading;

  /// Muayyan valyuta snapshotini o'zgartirish uchun qulay helper
  PartnerInstallmentReportState updateSnapshot(
    int currencyTypeId,
    PartnerCurrencySnapshot Function(PartnerCurrencySnapshot s) updater,
  ) {
    return copyWith(
      uzs: currencyTypeId == 1 ? updater(uzs) : null,
      usd: currencyTypeId == 2 ? updater(usd) : null,
    );
  }

  PartnerInstallmentReportState copyWith({
    int? partnerId,
    String? partnerName,
    String? partnerPhone,
    int? selectedCurrencyTypeId,
    PartnerCurrencySnapshot? uzs,
    PartnerCurrencySnapshot? usd,
  }) {
    return PartnerInstallmentReportState(
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      partnerPhone: partnerPhone ?? this.partnerPhone,
      selectedCurrencyTypeId:
          selectedCurrencyTypeId ?? this.selectedCurrencyTypeId,
      uzs: uzs ?? this.uzs,
      usd: usd ?? this.usd,
    );
  }
}
