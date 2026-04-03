import 'package:equatable/equatable.dart';
import '../../data/models/enums.dart';
import '../../data/models/installment_item_model.dart';
import '../../data/models/payment_partner_model.dart';

abstract class PaymentScheduleEvent extends Equatable {
  const PaymentScheduleEvent();

  @override
  List<Object?> get props => [];
}

class PaymentScheduleStarted extends PaymentScheduleEvent {
  final PaymentPartnerModel? initialPartner;

  const PaymentScheduleStarted({this.initialPartner});

  @override
  List<Object?> get props => [initialPartner];
}

class PaymentPartnerSelected extends PaymentScheduleEvent {
  final PaymentPartnerModel partner;

  const PaymentPartnerSelected(this.partner);

  @override
  List<Object?> get props => [partner];
}

class PaymentTotalAmountChanged extends PaymentScheduleEvent {
  final double amount;

  const PaymentTotalAmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

class PaymentCurrencyChanged extends PaymentScheduleEvent {
  final PaymentCurrency currency;

  const PaymentCurrencyChanged(this.currency);

  @override
  List<Object?> get props => [currency];
}

class PaymentNoteChanged extends PaymentScheduleEvent {
  final String note;

  const PaymentNoteChanged(this.note);

  @override
  List<Object?> get props => [note];
}

class PaymentScheduleTypeSelected extends PaymentScheduleEvent {
  final PaymentScheduleType type;

  const PaymentScheduleTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

class PaymentStartDateChanged extends PaymentScheduleEvent {
  final DateTime date;

  const PaymentStartDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class PaymentInstallmentCountChanged extends PaymentScheduleEvent {
  final int count;

  const PaymentInstallmentCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}

class PaymentAdvanceToggled extends PaymentScheduleEvent {
  final bool isEnabled;

  const PaymentAdvanceToggled(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class PaymentAdvanceAmountChanged extends PaymentScheduleEvent {
  final double amount;

  const PaymentAdvanceAmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

class PaymentFreeInstallmentAdded extends PaymentScheduleEvent {
  const PaymentFreeInstallmentAdded();
}

class PaymentFreeInstallmentRemoved extends PaymentScheduleEvent {
  final String id;

  const PaymentFreeInstallmentRemoved(this.id);

  @override
  List<Object?> get props => [id];
}

class PaymentFreeInstallmentUpdated extends PaymentScheduleEvent {
  final InstallmentItemModel item;

  const PaymentFreeInstallmentUpdated(this.item);

  @override
  List<Object?> get props => [item];
}

class PaymentScheduleSubmitted extends PaymentScheduleEvent {
  const PaymentScheduleSubmitted();
}

class PaymentStepChanged extends PaymentScheduleEvent {
  final int step;

  const PaymentStepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

class PaymentStepBack extends PaymentScheduleEvent {
  const PaymentStepBack();
}
