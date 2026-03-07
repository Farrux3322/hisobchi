part of 'project_bloc.dart';

class ProjectState extends Equatable {
  final Status status;
  final Status statusAdd;
  final Status statusDetail;
  final Status statusAction; // For delete, restore, forceDelete
  final Status statusLoadMore;
  final String? errorMessage;
  final List<ProjectModel> models;
  final ProjectModel? selectedProject;
  
  // Filter states
  final String? search;
  final String? statusFilter;
  final List<String>? date;
  final int currentPage;
  final int lastPage;
  final bool hasReachedMax;

  const ProjectState({
    this.status = Status.pure,
    this.statusAdd = Status.pure,
    this.statusDetail = Status.pure,
    this.statusAction = Status.pure,
    this.statusLoadMore = Status.pure,
    this.errorMessage,
    this.models = const [],
    this.selectedProject,
    this.search,
    this.statusFilter,
    this.date,
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasReachedMax = false,
  });

  ProjectState copyWith({
    Status? status,
    Status? statusAdd,
    Status? statusDetail,
    Status? statusAction,
    Status? statusLoadMore,
    String? errorMessage,
    List<ProjectModel>? models,
    ProjectModel? selectedProject,
    String? search,
    String? Function()? statusFilter,
    List<String>? Function()? date,
    int? currentPage,
    int? lastPage,
    bool? hasReachedMax,
  }) {
    return ProjectState(
      status: status ?? this.status,
      statusAdd: statusAdd ?? this.statusAdd,
      statusDetail: statusDetail ?? this.statusDetail,
      statusAction: statusAction ?? this.statusAction,
      statusLoadMore: statusLoadMore ?? this.statusLoadMore,
      errorMessage: errorMessage ?? this.errorMessage,
      models: models ?? this.models,
      selectedProject: selectedProject ?? this.selectedProject,
      search: search ?? this.search,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      date: date != null ? date() : this.date,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statusAdd,
        statusDetail,
        statusAction,
        statusLoadMore,
        errorMessage,
        models,
        selectedProject,
        search,
        statusFilter,
        date,
        currentPage,
        lastPage,
        hasReachedMax,
      ];
}