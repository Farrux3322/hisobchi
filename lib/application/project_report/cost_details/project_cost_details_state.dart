part of 'project_cost_details_bloc.dart';

enum CostDetailsStatus { initial, loading, success, error }

class ProjectCostDetailsState extends Equatable {
  final CostDetailsStatus status;
  final List<ProjectCostDetailItemModel> costs;
  final String? errorMessage;
  final int? costTypeId;

  const ProjectCostDetailsState({
    this.status = CostDetailsStatus.initial,
    this.costs = const [],
    this.errorMessage,
    this.costTypeId,
  });

  ProjectCostDetailsState copyWith({
    CostDetailsStatus? status,
    List<ProjectCostDetailItemModel>? costs,
    String? errorMessage,
    int? costTypeId,
  }) {
    return ProjectCostDetailsState(
      status: status ?? this.status,
      costs: costs ?? this.costs,
      errorMessage: errorMessage ?? this.errorMessage,
      costTypeId: costTypeId ?? this.costTypeId,
    );
  }

  @override
  List<Object?> get props => [status, costs, errorMessage, costTypeId];
}
