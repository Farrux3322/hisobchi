import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/cost_type_model.dart';

class CostTypeState {
  final Status status;
  final Status statusAction;
  final List<CostTypeModel> costTypes;
  final String? errorMessage;

  const CostTypeState({
    this.status = Status.initial,
    this.statusAction = Status.initial,
    this.costTypes = const [],
    this.errorMessage,
  });

  CostTypeState copyWith({
    Status? status,
    Status? statusAction,
    List<CostTypeModel>? costTypes,
    String? errorMessage,
  }) {
    return CostTypeState(
      status: status ?? this.status,
      statusAction: statusAction ?? this.statusAction,
      costTypes: costTypes ?? this.costTypes,
      errorMessage: errorMessage,
    );
  }
}