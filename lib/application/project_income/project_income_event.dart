import 'package:equatable/equatable.dart';

abstract class ProjectIncomeEvent extends Equatable {
  const ProjectIncomeEvent();

  @override
  List<Object?> get props => [];
}

class GetProjectIncomesEvent extends ProjectIncomeEvent {
  final int projectId;

  const GetProjectIncomesEvent({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class CreateProjectIncomeEvent extends ProjectIncomeEvent {
  final int currencyTypeId;
  final double summa;
  final String? description;
  final List<int>? fileId;
  final int projectId;

  const CreateProjectIncomeEvent({
    required this.currencyTypeId,
    required this.summa,
    this.description,
    this.fileId,
    required this.projectId,
  });

  @override
  List<Object?> get props => [currencyTypeId, summa, description, fileId, projectId];
}

class UpdateProjectIncomeEvent extends ProjectIncomeEvent {
  final int projectIncomeId;
  final int currencyTypeId;
  final double summa;
  final String? description;
  final List<int>? fileId;
  final int projectId;

  const UpdateProjectIncomeEvent({
    required this.projectIncomeId,
    required this.currencyTypeId,
    required this.summa,
    this.description,
    this.fileId,
    required this.projectId,
  });

  @override
  List<Object?> get props => [projectIncomeId, currencyTypeId, summa, description, fileId, projectId];
}

class DeleteProjectIncomeEvent extends ProjectIncomeEvent {
  final int projectIncomeId;
  final int projectId;

  const DeleteProjectIncomeEvent({
    required this.projectIncomeId,
    required this.projectId,
  });

  @override
  List<Object?> get props => [projectIncomeId, projectId];
}

class RestoreProjectIncomeEvent extends ProjectIncomeEvent {
  final int projectIncomeId;
  final int projectId;

  const RestoreProjectIncomeEvent({
    required this.projectIncomeId,
    required this.projectId,
  });

  @override
  List<Object?> get props => [projectIncomeId, projectId];
}

class ForceDeleteProjectIncomeEvent extends ProjectIncomeEvent {
  final int projectIncomeId;
  final int projectId;

  const ForceDeleteProjectIncomeEvent({
    required this.projectIncomeId,
    required this.projectId,
  });

  @override
  List<Object?> get props => [projectIncomeId, projectId];
}