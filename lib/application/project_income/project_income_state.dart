import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/project_income_model.dart';

class ProjectIncomeState {
  final Status status;
  final Status statusAction;
  final List<ProjectIncomeModel> incomes;
  final String? errorMessage;
  final int currentPage;
  final int lastPage;
  final bool hasReachedMax;

  const ProjectIncomeState({
    this.status = Status.initial,
    this.statusAction = Status.initial,
    this.incomes = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasReachedMax = false,
  });

  ProjectIncomeState copyWith({
    Status? status,
    Status? statusAction,
    List<ProjectIncomeModel>? incomes,
    String? errorMessage,
    int? currentPage,
    int? lastPage,
    bool? hasReachedMax,
  }) {
    return ProjectIncomeState(
      status: status ?? this.status,
      statusAction: statusAction ?? this.statusAction,
      incomes: incomes ?? this.incomes,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}