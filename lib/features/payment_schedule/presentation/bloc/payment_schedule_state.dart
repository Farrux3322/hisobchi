import 'package:equatable/equatable.dart';
import '../../data/models/enums.dart';
import '../../data/models/installment_item_model.dart';
import '../../data/models/installment_plan_model.dart';
import '../../data/models/payment_partner_model.dart';

enum PaymentScheduleStatus { initial, loading, success, failure }

class PaymentScheduleState extends Equatable {
  final PaymentScheduleStatus status;
  final int currentStep;
  final PaymentPartnerModel? selectedPartner;
  final double totalAmount;
  final PaymentCurrency currency;
  final String note;
  final PaymentScheduleType? scheduleType;
  final DateTime startDate;
  final int installmentCount;
  final bool isAdvanceEnabled;
  final double advanceAmount;
  // Free/custom jadval uchun — preview items (id = itemNumber int, sana = String 'yyyy-MM-dd')
  final List<InstallmentItemModel> freeInstallments;
  // Equal jadval uchun — preview items
  final List<InstallmentItemModel> calculatedInstallments;
  final String? errorMessage;
  final Map<String, String> validationErrors;
  final bool isPartnerLocked;
  // Muvaffaqiyatli yaratilgan reja (list page refresh uchun)
  final InstallmentPlanModel? createdPlan;

  PaymentScheduleState({
    this.status = PaymentScheduleStatus.initial,
    this.currentStep = 0,
    this.selectedPartner,
    this.totalAmount = 0.0,
    this.currency = PaymentCurrency.uzs,
    this.note = '',
    this.scheduleType,
    DateTime? startDate,
    this.installmentCount = 4,
    this.isAdvanceEnabled = false,
    this.advanceAmount = 0.0,
    this.freeInstallments = const [],
    this.calculatedInstallments = const [],
    this.errorMessage,
    this.validationErrors = const {},
    this.isPartnerLocked = false,
    this.createdPlan,
  }) : startDate = startDate ?? DateTime.now().add(const Duration(days: 1));

  PaymentScheduleState copyWith({
    PaymentScheduleStatus? status,
    int? currentStep,
    PaymentPartnerModel? selectedPartner,
    double? totalAmount,
    PaymentCurrency? currency,
    String? note,
    PaymentScheduleType? scheduleType,
    DateTime? startDate,
    int? installmentCount,
    bool? isAdvanceEnabled,
    double? advanceAmount,
    List<InstallmentItemModel>? freeInstallments,
    List<InstallmentItemModel>? calculatedInstallments,
    String? errorMessage,
    Map<String, String>? validationErrors,
    bool? isPartnerLocked,
    InstallmentPlanModel? createdPlan,
  }) {
    return PaymentScheduleState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      selectedPartner: selectedPartner ?? this.selectedPartner,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      scheduleType: scheduleType ?? this.scheduleType,
      startDate: startDate ?? this.startDate,
      installmentCount: installmentCount ?? this.installmentCount,
      isAdvanceEnabled: isAdvanceEnabled ?? this.isAdvanceEnabled,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      freeInstallments: freeInstallments ?? this.freeInstallments,
      calculatedInstallments: calculatedInstallments ?? this.calculatedInstallments,
      errorMessage: errorMessage,
      validationErrors: validationErrors ?? this.validationErrors,
      isPartnerLocked: isPartnerLocked ?? this.isPartnerLocked,
      createdPlan: createdPlan ?? this.createdPlan,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentStep,
        selectedPartner,
        totalAmount,
        currency,
        note,
        scheduleType,
        startDate,
        installmentCount,
        isAdvanceEnabled,
        advanceAmount,
        freeInstallments,
        calculatedInstallments,
        errorMessage,
        validationErrors,
        isPartnerLocked,
        createdPlan,
      ];
}
