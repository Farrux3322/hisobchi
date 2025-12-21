part of 'work_type_bloc.dart';

sealed class WorkTypeEvent extends Equatable {
  const WorkTypeEvent();

  @override
  List<Object?> get props => [];
}

class GetAllWorkTypesEvent extends WorkTypeEvent {
  const GetAllWorkTypesEvent();
}

class CreateWorkTypeEvent extends WorkTypeEvent {
  final Object data;

  const CreateWorkTypeEvent({required this.data});
}

class UpdateWorkTypeEvent extends WorkTypeEvent {
  final Object data;
  final int id;

  const UpdateWorkTypeEvent({required this.data, required this.id});
}

class DeleteWorkTypeEvent extends WorkTypeEvent {
  final int id;

  const DeleteWorkTypeEvent({required this.id});
}

class RestoreWorkTypeEvent extends WorkTypeEvent {
  final int id;

  const RestoreWorkTypeEvent({required this.id});
}

class ForceDeleteWorkTypeEvent extends WorkTypeEvent {
  final int id;

  const ForceDeleteWorkTypeEvent({required this.id});
}