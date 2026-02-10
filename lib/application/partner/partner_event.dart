part of 'partner_bloc.dart';

sealed class PartnerEvent extends Equatable {
  const PartnerEvent();

  @override
  List<Object?> get props => [];
}

class GetAllEvent extends PartnerEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;
  final String? sort;
  final String? statusFilter;

  const GetAllEvent({
    this.startDate,
    this.endDate,
    this.search,
    this.sort,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [startDate, endDate, search, sort, statusFilter];
}

class LoadMorePartnersEvent extends PartnerEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;
  final String? sort;
  final String? statusFilter;

  const LoadMorePartnersEvent({
    this.startDate,
    this.endDate,
    this.search,
    this.sort,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [startDate, endDate, search, sort, statusFilter];
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
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? type;
  final bool? isCancelled;
  final int? currencyId;

  const IncomeHistoryEvent({
    required this.id,
    this.search,
    this.startDate,
    this.endDate,
    this.type,
    this.isCancelled,
    this.currencyId,
  });

  @override
  List<Object?> get props => [id, search, startDate, endDate, type, isCancelled, currencyId];
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

class GetSmsSettingsEvent extends PartnerEvent {
  final int id;

  const GetSmsSettingsEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateSmsSettingsEvent extends PartnerEvent {
  final int id;
  final Object data;

  const UpdateSmsSettingsEvent({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class UpdateSmsSettingsLocalEvent extends PartnerEvent {
  final Map<String, dynamic> data;

  const UpdateSmsSettingsLocalEvent({required this.data});

  @override
  List<Object?> get props => [data];
}
