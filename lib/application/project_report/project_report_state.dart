part of 'project_report_bloc.dart';

enum ReportStatus { initial, loading, success, error }

class ProjectReportState extends Equatable {
  final ReportStatus status;
  final ProjectReportModel? report;
  final String? errorMessage;

  const ProjectReportState({
    this.status = ReportStatus.initial,
    this.report,
    this.errorMessage,
  });

  ProjectReportState copyWith({
    ReportStatus? status,
    ProjectReportModel? report,
    String? errorMessage,
  }) {
    return ProjectReportState(
      status: status ?? this.status,
      report: report ?? this.report,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, report, errorMessage];
}
