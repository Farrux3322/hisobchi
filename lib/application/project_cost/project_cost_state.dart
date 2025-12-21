import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/project_cost_model.dart';

class ProjectCostState {
  final Status status;
  final Status statusAction;
  final List<ProjectCostModel> projectCosts;
  final String? errorMessage;

  const ProjectCostState({
    this.status = Status.initial,
    this.statusAction = Status.initial,
    this.projectCosts = const [],
    this.errorMessage,
  });

  ProjectCostState copyWith({
    Status? status,
    Status? statusAction,
    List<ProjectCostModel>? projectCosts,
    String? errorMessage,
  }) {
    return ProjectCostState(
      status: status ?? this.status,
      statusAction: statusAction ?? this.statusAction,
      projectCosts: projectCosts ?? this.projectCosts,
      errorMessage: errorMessage,
    );
  }
}