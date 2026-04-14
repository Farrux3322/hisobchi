abstract class PartnerInstallmentReportEvent {
  const PartnerInstallmentReportEvent();
}

/// Birinchi yuklash — faqat UZS (1-chi tab)
class LoadPartnerReportEvent extends PartnerInstallmentReportEvent {
  final int partnerId;
  const LoadPartnerReportEvent(this.partnerId);
}

/// Valyuta tabini almashtirish
/// — agar maqsad valyuta hali yuklanmagan bo'lsa, API dan yuklaydi
class SelectCurrencyTypeEvent extends PartnerInstallmentReportEvent {
  final int currencyTypeId; // 1 = UZS, 2 = USD
  const SelectCurrencyTypeEvent(this.currencyTypeId);
}

/// Pull-to-refresh — hozirgi active tabni qayta yuklash
class RefreshPartnerReportEvent extends PartnerInstallmentReportEvent {
  const RefreshPartnerReportEvent();
}

/// Items bo'limini status bo'yicha filtrlash (active tab)
/// [status] null = barchasi, 'overdue' | 'pending' | 'partial' | 'paid'
class FilterItemsByStatusEvent extends PartnerInstallmentReportEvent {
  final String? status;
  const FilterItemsByStatusEvent(this.status);
}

/// Oylik dinamika uchun yilni o'zgartirish (active tab)
class ChangePartnerReportYearEvent extends PartnerInstallmentReportEvent {
  final int year;
  const ChangePartnerReportYearEvent(this.year);
}
