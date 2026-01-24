part of 'project_bloc.dart';

class ProjectState extends Equatable {
  final Status status;
  final Status statusAdd;
  final Status statusDetail;
  final Status statusAction; // For delete, restore, forceDelete
  final String? errorMessage;
  final List<ProjectModel> models;
  final ProjectModel? selectedProject;
  
  // Filter states
  final String? search;
  final String? statusFilter;
  final List<String>? date;

  const ProjectState({
    this.status = Status.pure,
    this.statusAdd = Status.pure,
    this.statusDetail = Status.pure,
    this.statusAction = Status.pure,
    this.errorMessage,
    this.models = const [],
    this.selectedProject,
    this.search,
    this.statusFilter,
    this.date,
  });

  ProjectState copyWith({
    Status? status,
    Status? statusAdd,
    Status? statusDetail,
    Status? statusAction,
    String? errorMessage,
    List<ProjectModel>? models,
    ProjectModel? selectedProject,
    String? search,
    String? Function()? statusFilter,
    List<String>? Function()? date,
  }) {
    return ProjectState(
      status: status ?? this.status,
      statusAdd: statusAdd ?? this.statusAdd,
      statusDetail: statusDetail ?? this.statusDetail,
      statusAction: statusAction ?? this.statusAction,
      errorMessage: errorMessage ?? this.errorMessage,
      models: models ?? this.models,
      selectedProject: selectedProject ?? this.selectedProject,
      search: search ?? this.search,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      date: date != null ? date() : this.date,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statusAdd,
        statusDetail,
        statusAction,
        errorMessage,
        models,
        selectedProject,
        search,
        statusFilter,
        date,
      ];
}