import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/project_cost/project_cost_event.dart';
import 'package:hisobchi/application/project_cost/project_cost_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/project_cost/project_cost_repository.dart';

class ProjectCostBloc extends Bloc<ProjectCostEvent, ProjectCostState> {
  final ProjectCostRepository repository;

  ProjectCostBloc({required this.repository}) : super(const ProjectCostState()) {
    on<GetProjectCostsEvent>(_onGetProjectCosts);
    on<LoadMoreProjectCostsEvent>(_onLoadMoreProjectCosts);
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
      currentPage: 1,
      hasReachedMax: false,
      projectCosts: [],
    ));
    try {
      final response = await repository.getProjectCosts(
        event.projectId,
        costTypeId: event.costTypeId,
        page: 1,
        search: event.search,
      );

      final int lastPage = response.meta?.lastPage ?? 1;
      final int currentPage = response.meta?.currentPage ?? 1;

      emit(state.copyWith(
        status: Status.success,
        projectCosts: response.costs,
        currentPage: currentPage,
        lastPage: lastPage,
        hasReachedMax: currentPage >= lastPage,
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

  Future<void> _onLoadMoreProjectCosts(
    LoadMoreProjectCostsEvent event,
    Emitter<ProjectCostState> emit,
  ) async {
    if (state.hasReachedMax || state.status == Status.loading) return;

    try {
      final int nextPage = state.currentPage + 1;
      final response = await repository.getProjectCosts(
        event.projectId,
        costTypeId: event.costTypeId,
        page: nextPage,
        search: event.search,
      );

      final int lastPage = response.meta?.lastPage ?? 1;
      final int currentPage = response.meta?.currentPage ?? nextPage;

      emit(state.copyWith(
        status: Status.success,
        projectCosts: List.of(state.projectCosts)..addAll(response.costs),
        currentPage: currentPage,
        lastPage: lastPage,
        hasReachedMax: currentPage >= lastPage,
      ));
    } catch (_) {
      // For load more, we might want to just stop trying or show a silent error
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