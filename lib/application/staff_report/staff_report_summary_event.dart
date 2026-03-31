import 'package:equatable/equatable.dart';

abstract class StaffReportSummaryEvent extends Equatable {
  const StaffReportSummaryEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffReportSummaryEvent extends StaffReportSummaryEvent {
  final List<String>? date;

  const LoadStaffReportSummaryEvent({this.date});

  @override
  List<Object?> get props => [date];
}
