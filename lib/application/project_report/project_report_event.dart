part of 'project_report_bloc.dart';

abstract class ProjectReportEvent extends Equatable {
  const ProjectReportEvent();

  @override
  List<Object?> get props => [];
}

class GetProjectReportEvent extends ProjectReportEvent {
  final int projectId;

  const GetProjectReportEvent({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}
