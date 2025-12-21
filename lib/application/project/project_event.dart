part of 'project_bloc.dart';

sealed class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class GetAllProjectEvent extends ProjectEvent {
  const GetAllProjectEvent();
}

class GetProjectByIdEvent extends ProjectEvent {
  final int id;

  const GetProjectByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class CreateProjectEvent extends ProjectEvent {
  final Object data;

  const CreateProjectEvent({required this.data});
}

class UpdateProjectEvent extends ProjectEvent {
  final Object data;
  final int id;

  const UpdateProjectEvent({required this.data, required this.id});
}

class DeleteProjectEvent extends ProjectEvent {
  final int id;

  const DeleteProjectEvent({required this.id});
}

class RestoreProjectEvent extends ProjectEvent {
  final int id;

  const RestoreProjectEvent({required this.id});
}

class ForceDeleteProjectEvent extends ProjectEvent {
  final int id;

  const ForceDeleteProjectEvent({required this.id});
}