import 'package:equatable/equatable.dart';

abstract class WorkerEvent extends Equatable {
  const WorkerEvent();

  @override
  List<Object?> get props => [];
}

// Project workers events
class GetProjectWorkersEvent extends WorkerEvent {
  final int projectId;

  const GetProjectWorkersEvent({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

// All workers events
class GetAllWorkersEvent extends WorkerEvent {
  const GetAllWorkersEvent();
}

// Create worker event
class CreateWorkerEvent extends WorkerEvent {
  final String name;
  final String phone;
  final String? additionalPhone;
  final List<String>? fileIds;
  final int workerPositionId;
  final String? description;

  const CreateWorkerEvent({
    required this.name,
    required this.phone,
    this.additionalPhone,
    this.fileIds,
    required this.workerPositionId,
    this.description,
  });

  @override
  List<Object?> get props => [name, phone, additionalPhone, fileIds, workerPositionId, description];
}

// Update worker event
class UpdateWorkerEvent extends WorkerEvent {
  final int workerId;
  final String name;
  final String phone;
  final String? additionalPhone;
  final List<String>? fileIds;
  final int workerPositionId;
  final String? description;

  const UpdateWorkerEvent({
    required this.workerId,
    required this.name,
    required this.phone,
    this.additionalPhone,
    this.fileIds,
    required this.workerPositionId,
    this.description,
  });

  @override
  List<Object?> get props => [workerId, name, phone, additionalPhone, fileIds, workerPositionId, description];
}

// Delete worker event
class DeleteWorkerEvent extends WorkerEvent {
  final int workerId;

  const DeleteWorkerEvent({required this.workerId});

  @override
  List<Object?> get props => [workerId];
}

// Restore worker event
class RestoreWorkerEvent extends WorkerEvent {
  final int workerId;

  const RestoreWorkerEvent({required this.workerId});

  @override
  List<Object?> get props => [workerId];
}

// Force delete worker event
class ForceDeleteWorkerEvent extends WorkerEvent {
  final int workerId;

  const ForceDeleteWorkerEvent({required this.workerId});

  @override
  List<Object?> get props => [workerId];
}

// Worker positions events
class GetWorkerPositionsEvent extends WorkerEvent {
  const GetWorkerPositionsEvent();
}

// Create worker position event
class CreateWorkerPositionEvent extends WorkerEvent {
  final String name;
  final String? description;

  const CreateWorkerPositionEvent({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

// Delete worker position event
class DeleteWorkerPositionEvent extends WorkerEvent {
  final int positionId;

  const DeleteWorkerPositionEvent({required this.positionId});

  @override
  List<Object?> get props => [positionId];
}

// Restore worker position event
class RestoreWorkerPositionEvent extends WorkerEvent {
  final int positionId;

  const RestoreWorkerPositionEvent({required this.positionId});

  @override
  List<Object?> get props => [positionId];
}

// Force delete worker position event
class ForceDeleteWorkerPositionEvent extends WorkerEvent {
  final int positionId;

  const ForceDeleteWorkerPositionEvent({required this.positionId});

  @override
  List<Object?> get props => [positionId];
}

// Add worker to project event
class AddWorkerToProjectEvent extends WorkerEvent {
  final int workerId;
  final int projectId;

  const AddWorkerToProjectEvent({
    required this.workerId,
    required this.projectId,
  });

  @override
  List<Object?> get props => [workerId, projectId];
}

// Remove worker from project event
class RemoveWorkerFromProjectEvent extends WorkerEvent {
  final int workerId;
  final int projectId;

  const RemoveWorkerFromProjectEvent({
    required this.workerId,
    required this.projectId,
  });

  @override
  List<Object?> get props => [workerId, projectId];
}