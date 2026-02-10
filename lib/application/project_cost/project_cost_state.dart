import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/project_cost_model.dart';

class ProjectCostState {
  final Status status;
  final Status statusAction;
  final List<ProjectCostModel> projectCosts;
  final String? errorMessage;
  final int currentPage;
  final int lastPage;
  final bool hasReachedMax;

  const ProjectCostState({
    this.status = Status.initial,
    this.statusAction = Status.initial,
    this.projectCosts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasReachedMax = false,
  });

  ProjectCostState copyWith({
    Status? status,
    Status? statusAction,
    List<ProjectCostModel>? projectCosts,
    String? errorMessage,
    int? currentPage,
    int? lastPage,
    bool? hasReachedMax,
  }) {
    return ProjectCostState(
      status: status ?? this.status,
      statusAction: statusAction ?? this.statusAction,
      projectCosts: projectCosts ?? this.projectCosts,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}