abstract class ProjectCostEvent {}

class GetProjectCostsEvent extends ProjectCostEvent {
  final int projectId;
  final int? costTypeId;

  GetProjectCostsEvent({required this.projectId, this.costTypeId});
}

class CreateProjectCostEvent extends ProjectCostEvent {
  final int costTypeId;
  final int? workerId;
  final int currencyTypeId;
  final double summa;
  final String? description;
  final List<int>? fileId;
  final int projectId;

  CreateProjectCostEvent({
    required this.costTypeId,
     this.workerId,
    required this.currencyTypeId,
    required this.summa,
    this.description,
    this.fileId,
    required this.projectId,
  });
}

class UpdateProjectCostEvent extends ProjectCostEvent {
  final int projectCostId;
  final int costTypeId;
  final int? workerId;
  final int currencyTypeId;
  final double summa;
  final String? description;
  final List<int>? fileId;
  final int projectId;

  UpdateProjectCostEvent({
    required this.projectCostId,
    required this.costTypeId,
     this.workerId,
    required this.currencyTypeId,
    required this.summa,
    this.description,
    this.fileId,
    required this.projectId,
  });
}

class DeleteProjectCostEvent extends ProjectCostEvent {
  final int projectCostId;

  DeleteProjectCostEvent({required this.projectCostId});
}

class RestoreProjectCostEvent extends ProjectCostEvent {
  final int projectCostId;

  RestoreProjectCostEvent({required this.projectCostId});
}

class ForceDeleteProjectCostEvent extends ProjectCostEvent {
  final int projectCostId;

  ForceDeleteProjectCostEvent({required this.projectCostId});
}