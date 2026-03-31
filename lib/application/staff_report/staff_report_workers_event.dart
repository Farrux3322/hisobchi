import 'package:equatable/equatable.dart';

abstract class StaffReportWorkersEvent extends Equatable {
  const StaffReportWorkersEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffReportWorkersEvent extends StaffReportWorkersEvent {
  final List<String>? date;
  final int currencyTypeId;

  const LoadStaffReportWorkersEvent({
    this.date,
    required this.currencyTypeId,
  });

  @override
  List<Object?> get props => [date, currencyTypeId];
}
