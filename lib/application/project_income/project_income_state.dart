import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/project_income_model.dart';

class ProjectIncomeState {
  final Status status;
  final Status statusAction;
  final List<ProjectIncomeModel> incomes;
  final String? errorMessage;

  const ProjectIncomeState({
    this.status = Status.initial,
    this.statusAction = Status.initial,
    this.incomes = const [],
    this.errorMessage,
  });

  ProjectIncomeState copyWith({
    Status? status,
    Status? statusAction,
    List<ProjectIncomeModel>? incomes,
    String? errorMessage,
  }) {
    return ProjectIncomeState(
      status: status ?? this.status,
      statusAction: statusAction ?? this.statusAction,
      incomes: incomes ?? this.incomes,
      errorMessage: errorMessage,
    );
  }
}