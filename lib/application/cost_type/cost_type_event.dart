abstract class CostTypeEvent {}

class GetCostTypesEvent extends CostTypeEvent {}

class CreateCostTypeEvent extends CostTypeEvent {
  final String name;
  final String? description;

  CreateCostTypeEvent({
    required this.name,
    this.description,
  });
}

class UpdateCostTypeEvent extends CostTypeEvent {
  final int costTypeId;
  final String name;
  final String? description;

  UpdateCostTypeEvent({
    required this.costTypeId,
    required this.name,
    this.description,
  });
}

class DeleteCostTypeEvent extends CostTypeEvent {
  final int costTypeId;

  DeleteCostTypeEvent({required this.costTypeId});
}

class RestoreCostTypeEvent extends CostTypeEvent {
  final int costTypeId;

  RestoreCostTypeEvent({required this.costTypeId});
}

class ForceDeleteCostTypeEvent extends CostTypeEvent {
  final int costTypeId;

  ForceDeleteCostTypeEvent({required this.costTypeId});
}