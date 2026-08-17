import 'package:equatable/equatable.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/worker_model.dart';

class WorkerState extends Equatable {
  final Status status;
  final Status statusAction;
  final Status statusAllWorkers;
  final Status statusPositions;
  final Status statusPositionAction;
  final List<WorkerModel> projectWorkers;
  final List<WorkerModel> allWorkers;
  final List<WorkerPositionModel> positions;
  final String? errorMessage;

  const WorkerState({
    this.status = Status.initial,
    this.statusAction = Status.initial,
    this.statusAllWorkers = Status.initial,
    this.statusPositions = Status.initial,
    this.statusPositionAction = Status.initial,
    this.projectWorkers = const [],
    this.allWorkers = const [],
    this.positions = const [],
    this.errorMessage,
  });

  WorkerState copyWith({
    Status? status,
    Status? statusAction,
    Status? statusAllWorkers,
    Status? statusPositions,
    Status? statusPositionAction,
    List<WorkerModel>? projectWorkers,
    List<WorkerModel>? allWorkers,
    List<WorkerPositionModel>? positions,
    String? errorMessage,
  }) {
    return WorkerState(
      status: status ?? this.status,
      statusAction: statusAction ?? this.statusAction,
      statusAllWorkers: statusAllWorkers ?? this.statusAllWorkers,
      statusPositions: statusPositions ?? this.statusPositions,
      statusPositionAction: statusPositionAction ?? this.statusPositionAction,
      projectWorkers: projectWorkers ?? this.projectWorkers,
      allWorkers: allWorkers ?? this.allWorkers,
      positions: positions ?? this.positions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statusAction,
        statusAllWorkers,
        statusPositions,
        statusPositionAction,
        projectWorkers,
        allWorkers,
        positions,
        errorMessage,
      ];
}