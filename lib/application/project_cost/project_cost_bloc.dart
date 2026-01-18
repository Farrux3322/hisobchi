import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/project_cost/project_cost_event.dart';
import 'package:hisobchi/application/project_cost/project_cost_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/project_cost/project_cost_repository.dart';

class ProjectCostBloc extends Bloc<ProjectCostEvent, ProjectCostState> {
  final ProjectCostRepository repository;

  ProjectCostBloc({required this.repository}) : super(const ProjectCostState()) {
    on<GetProjectCostsEvent>(_onGetProjectCosts);
    on<CreateProjectCostEvent>(_onCreateProjectCost);
    on<UpdateProjectCostEvent>(_onUpdateProjectCost);
    on<DeleteProjectCostEvent>(_onDeleteProjectCost);
    on<RestoreProjectCostEvent>(_onRestoreProjectCost);
    on<ForceDeleteProjectCostEvent>(_onForceDeleteProjectCost);
  }

  Future<void> _onGetProjectCosts(
    GetProjectCostsEvent event,
    Emitter<ProjectCostState> emit,
  ) async {
    emit(state.copyWith(
      status: Status.loading,
      statusAction: Status.initial,
    ));
    try {
      final response = await repository.getProjectCosts(event.projectId, costTypeId: event.costTypeId);
      emit(state.copyWith(
        status: Status.success,
        projectCosts: response.result,
        statusAction: Status.initial,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
        statusAction: Status.initial,
      ));
    }
  }

  Future<void> _onCreateProjectCost(
    CreateProjectCostEvent event,
    Emitter<ProjectCostState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.createProjectCost(
        costTypeId: event.costTypeId,
        workerId: event.workerId,
        currencyTypeId: event.currencyTypeId,
        summa: event.summa,
        description: event.description,
        fileId: event.fileId,
        projectId: event.projectId,
      );
      emit(state.copyWith(statusAction: Status.success));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateProjectCost(
    UpdateProjectCostEvent event,
    Emitter<ProjectCostState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.updateProjectCost(
        projectCostId: event.projectCostId,
        costTypeId: event.costTypeId,
        workerId: event.workerId,
        currencyTypeId: event.currencyTypeId,
        summa: event.summa,
        description: event.description,
        fileId: event.fileId,
        projectId: event.projectId,
      );
      emit(state.copyWith(statusAction: Status.success));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteProjectCost(
    DeleteProjectCostEvent event,
    Emitter<ProjectCostState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.deleteProjectCost(event.projectCostId);
      emit(state.copyWith(statusAction: Status.success));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRestoreProjectCost(
    RestoreProjectCostEvent event,
    Emitter<ProjectCostState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.restoreProjectCost(event.projectCostId);
      emit(state.copyWith(statusAction: Status.success));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onForceDeleteProjectCost(
    ForceDeleteProjectCostEvent event,
    Emitter<ProjectCostState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.forceDeleteProjectCost(event.projectCostId);
      emit(state.copyWith(statusAction: Status.success));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}