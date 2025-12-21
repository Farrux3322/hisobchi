part of 'work_type_bloc.dart';

class WorkTypeState extends Equatable {
  final Status status;
  final Status statusAdd;
  final String? errorMessage;
  final List<WorkTypeModel> models;

  const WorkTypeState({
    this.status = Status.pure,
    this.statusAdd = Status.pure,
    this.errorMessage,
    this.models = const [],
  });

  WorkTypeState copyWith({
    Status? status,
    Status? statusAdd,
    String? errorMessage,
    List<WorkTypeModel>? models,
  }) {
    return WorkTypeState(
      status: status ?? this.status,
      statusAdd: statusAdd ?? this.statusAdd,
      errorMessage: errorMessage ?? this.errorMessage,
      models: models ?? this.models,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statusAdd,
        errorMessage,
        models,
      ];
}