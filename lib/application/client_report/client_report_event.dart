import 'package:equatable/equatable.dart';

abstract class ClientReportEvent extends Equatable {
  const ClientReportEvent();

  @override
  List<Object?> get props => [];
}

class GetSectionOneReportEvent extends ClientReportEvent {
  const GetSectionOneReportEvent();
}

class RefreshSectionOneReportEvent extends ClientReportEvent {
  const RefreshSectionOneReportEvent();
}

class GetSectionTwoReportEvent extends ClientReportEvent {
  final int partnerId;
  final DateTime startDate;
  final DateTime endDate;

  const GetSectionTwoReportEvent({
    required this.partnerId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [partnerId, startDate, endDate];
}

class UpdateDateRangeEvent extends ClientReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  const UpdateDateRangeEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class GetSectionThreeReportEvent extends ClientReportEvent {
  final int partnerId;
  final DateTime startDate;
  final DateTime endDate;
  final String type; // 'debt' or 'credit'

  const GetSectionThreeReportEvent({
    required this.partnerId,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  @override
  List<Object?> get props => [partnerId, startDate, endDate, type];
}