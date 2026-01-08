part of 'project_income_details_bloc.dart';

enum IncomeDetailsStatus { initial, loading, success, error }

class ProjectIncomeDetailsState extends Equatable {
  final IncomeDetailsStatus status;
  final List<ProjectIncomeDetailModel> incomes;
  final String? errorMessage;

  const ProjectIncomeDetailsState({
    this.status = IncomeDetailsStatus.initial,
    this.incomes = const [],
    this.errorMessage,
  });

  ProjectIncomeDetailsState copyWith({
    IncomeDetailsStatus? status,
    List<ProjectIncomeDetailModel>? incomes,
    String? errorMessage,
  }) {
    return ProjectIncomeDetailsState(
      status: status ?? this.status,
      incomes: incomes ?? this.incomes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, incomes, errorMessage];
}
