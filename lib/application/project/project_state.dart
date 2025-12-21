part of 'project_bloc.dart';

class ProjectState extends Equatable {
  final Status status;
  final Status statusAdd;
  final Status statusDetail;
  final String? errorMessage;
  final List<ProjectModel> models;
  final ProjectModel? selectedProject;

  const ProjectState({
    this.status = Status.pure,
    this.statusAdd = Status.pure,
    this.statusDetail = Status.pure,
    this.errorMessage,
    this.models = const [],
    this.selectedProject,
  });

  ProjectState copyWith({
    Status? status,
    Status? statusAdd,
    Status? statusDetail,
    String? errorMessage,
    List<ProjectModel>? models,
    ProjectModel? selectedProject,
  }) {
    return ProjectState(
      status: status ?? this.status,
      statusAdd: statusAdd ?? this.statusAdd,
      statusDetail: statusDetail ?? this.statusDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      models: models ?? this.models,
      selectedProject: selectedProject ?? this.selectedProject,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statusAdd,
        statusDetail,
        errorMessage,
        models,
        selectedProject,
      ];
}