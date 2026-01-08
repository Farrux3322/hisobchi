part of 'project_cost_details_bloc.dart';

abstract class ProjectCostDetailsEvent extends Equatable {
  const ProjectCostDetailsEvent();

  @override
  List<Object?> get props => [];
}

class GetCostDetailsEvent extends ProjectCostDetailsEvent {
  final int projectId;
  final int costTypeId;

  const GetCostDetailsEvent({required this.projectId, required this.costTypeId});

  @override
  List<Object?> get props => [projectId, costTypeId];
}
