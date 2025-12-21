part of 'partner_bloc.dart';

sealed class PartnerEvent extends Equatable {
  const PartnerEvent();

  @override
  List<Object?> get props => [];
}

class GetAllEvent extends PartnerEvent {
  const GetAllEvent();
}

class ShowEvent extends PartnerEvent {
  final String guid;

  const ShowEvent({required this.guid});
}

class CreateEvent extends PartnerEvent {
  final Object data;

  const CreateEvent({required this.data});
}

class UpdateEvent extends PartnerEvent {
  final Object data;
  final int id;

  const UpdateEvent({required this.data, required this.id});
}

class DeleteEvent extends PartnerEvent {
  final int id;

  const DeleteEvent({required this.id});
}

class RestoreEvent extends PartnerEvent {
  final int id;

  const RestoreEvent({required this.id});
}

class ForceDeleteEvent extends PartnerEvent {
  final int id;

  const ForceDeleteEvent({required this.id});
}

class IncomeStatementEvent extends PartnerEvent {
  final int id;

  const IncomeStatementEvent({required this.id});
}

class IncomeHistoryEvent extends PartnerEvent {
  final int id;

  const IncomeHistoryEvent({required this.id});
}

class CreateKirim extends PartnerEvent {
  final Object data;

  const CreateKirim({required this.data});
}

class UpdateKirim extends PartnerEvent {
  final Object data;
  final int id;

  const UpdateKirim({required this.data, required this.id});
}

class CancelIncome extends PartnerEvent {
  final String description;
  final int walletId;

  const CancelIncome({required this.walletId, required this.description});
}

class DeleteIncome extends PartnerEvent {
  final int walletId;
  const DeleteIncome({required this.walletId});
}

class ForceDeleteIncomeEvent extends PartnerEvent {
  final int walletId;

  const ForceDeleteIncomeEvent({required this.walletId});
}
class RestoreIncomeEvent extends PartnerEvent {
  final int walletId;

  const RestoreIncomeEvent({required this.walletId});
}
