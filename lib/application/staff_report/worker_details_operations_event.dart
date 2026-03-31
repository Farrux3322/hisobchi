import 'package:equatable/equatable.dart';

abstract class WorkerDetailsOperationsEvent extends Equatable {
  const WorkerDetailsOperationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkerDetailsOperationsEvent extends WorkerDetailsOperationsEvent {
  final int workerId;
  final List<String>? date;
  final int currencyTypeId;
  final String? type;

  const LoadWorkerDetailsOperationsEvent({
    required this.workerId,
    this.date,
    required this.currencyTypeId,
    this.type,
  });

  @override
  List<Object?> get props => [workerId, date, currencyTypeId, type];
}

class LoadMoreWorkerDetailsOperationsEvent extends WorkerDetailsOperationsEvent {}
