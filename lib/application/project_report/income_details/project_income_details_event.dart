part of 'project_income_details_bloc.dart';

abstract class ProjectIncomeDetailsEvent extends Equatable {
  const ProjectIncomeDetailsEvent();

  @override
  List<Object?> get props => [];
}

class GetIncomeDetailsEvent extends ProjectIncomeDetailsEvent {
  final int projectId;

  const GetIncomeDetailsEvent({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}
