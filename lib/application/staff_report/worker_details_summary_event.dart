import 'package:equatable/equatable.dart';

abstract class WorkerDetailsSummaryEvent extends Equatable {
  const WorkerDetailsSummaryEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkerDetailsSummaryEvent extends WorkerDetailsSummaryEvent {
  final int workerId;
  final List<String>? date;

  const LoadWorkerDetailsSummaryEvent({
    required this.workerId,
    this.date,
  });

  @override
  List<Object?> get props => [workerId, date];
}
