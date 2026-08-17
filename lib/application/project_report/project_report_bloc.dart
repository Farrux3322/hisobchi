import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:ehisob/infrastructure/dto/models/project_report/project_report_model.dart';
import 'package:ehisob/infrastructure/repository/project_report/project_report_repository.dart';

part 'project_report_event.dart';
part 'project_report_state.dart';

class ProjectReportBloc extends Bloc<ProjectReportEvent, ProjectReportState> {
  final _repo = ProjectReportRepository();

  ProjectReportBloc() : super(const ProjectReportState()) {
    on<GetProjectReportEvent>(_onGetProjectReport);
  }

  Future<void> _onGetProjectReport(
    GetProjectReportEvent event,
    Emitter<ProjectReportState> emit,
  ) async {
    emit(state.copyWith(status: ReportStatus.loading));
    try {
      final data = await _repo.getProjectReport(projectId: event.projectId);

      if (data["status"] == true) {
        final report = ProjectReportModel.fromJson(data["result"]);
        emit(state.copyWith(status: ReportStatus.success, report: report));
      } else {
        emit(state.copyWith(
          status: ReportStatus.error,
          errorMessage: data["error"]?.toString() ?? 'Xatolik yuz berdi',
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: ReportStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: ReportStatus.error, errorMessage: e.toString()));
    }
  }
}
