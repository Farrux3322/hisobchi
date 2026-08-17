import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/project_income/project_income_event.dart';
import 'package:ehisob/application/project_income/project_income_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/repository/project_income/project_income_repository.dart';

class ProjectIncomeBloc extends Bloc<ProjectIncomeEvent, ProjectIncomeState> {
  final ProjectIncomeRepository repository;

  ProjectIncomeBloc({required this.repository}) : super(const ProjectIncomeState()) {
    on<GetProjectIncomesEvent>(_onGetProjectIncomes);
    on<LoadMoreProjectIncomesEvent>(_onLoadMoreProjectIncomes);
    on<CreateProjectIncomeEvent>(_onCreateProjectIncome);
    on<UpdateProjectIncomeEvent>(_onUpdateProjectIncome);
    on<DeleteProjectIncomeEvent>(_onDeleteProjectIncome);
    on<RestoreProjectIncomeEvent>(_onRestoreProjectIncome);
    on<ForceDeleteProjectIncomeEvent>(_onForceDeleteProjectIncome);
  }

  Future<void> _onGetProjectIncomes(
    GetProjectIncomesEvent event,
    Emitter<ProjectIncomeState> emit,
  ) async {
    emit(state.copyWith(
      status: Status.loading,
      currentPage: 1,
      hasReachedMax: false,
      incomes: [],
    ));

    try {
      final response = await repository.getProjectIncomes(
        event.projectId,
        page: 1,
        search: event.search,
      );

      final int lastPage = response.meta?.lastPage ?? 1;
      final int currentPage = response.meta?.currentPage ?? 1;

      emit(state.copyWith(
        status: Status.success,
        incomes: response.incomes,
        currentPage: currentPage,
        lastPage: lastPage,
        hasReachedMax: currentPage >= lastPage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreProjectIncomes(
    LoadMoreProjectIncomesEvent event,
    Emitter<ProjectIncomeState> emit,
  ) async {
    if (state.hasReachedMax || state.status == Status.loading) return;

    try {
      final int nextPage = state.currentPage + 1;
      final response = await repository.getProjectIncomes(
        event.projectId,
        page: nextPage,
        search: event.search,
      );

      final int lastPage = response.meta?.lastPage ?? 1;
      final int currentPage = response.meta?.currentPage ?? nextPage;

      emit(state.copyWith(
        status: Status.success,
        incomes: List.of(state.incomes)..addAll(response.incomes),
        currentPage: currentPage,
        lastPage: lastPage,
        hasReachedMax: currentPage >= lastPage,
      ));
    } catch (_) {
      // For load more, we might want to just stop trying or show a silent error
    }
  }

  Future<void> _onCreateProjectIncome(
    CreateProjectIncomeEvent event,
    Emitter<ProjectIncomeState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));

    try {
      await repository.createProjectIncome(
        currencyTypeId: event.currencyTypeId,
        summa: event.summa,
        description: event.description,
        fileId: event.fileId,
        projectId: event.projectId,
      );
      emit(state.copyWith(statusAction: Status.success));
      // statusAction ni initial ga qaytarish
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusAction: Status.initial));
      add(GetProjectIncomesEvent(projectId: event.projectId));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateProjectIncome(
    UpdateProjectIncomeEvent event,
    Emitter<ProjectIncomeState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));

    try {
      await repository.updateProjectIncome(
        projectIncomeId: event.projectIncomeId,
        currencyTypeId: event.currencyTypeId,
        summa: event.summa,
        description: event.description,
        fileId: event.fileId,
        projectId: event.projectId,
      );
      emit(state.copyWith(statusAction: Status.success));
      // statusAction ni initial ga qaytarish
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusAction: Status.initial));
      add(GetProjectIncomesEvent(projectId: event.projectId));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteProjectIncome(
    DeleteProjectIncomeEvent event,
    Emitter<ProjectIncomeState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));

    try {
      await repository.deleteProjectIncome(event.projectIncomeId);
      emit(state.copyWith(statusAction: Status.success));
      add(GetProjectIncomesEvent(projectId: event.projectId));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRestoreProjectIncome(
    RestoreProjectIncomeEvent event,
    Emitter<ProjectIncomeState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));

    try {
      await repository.restoreProjectIncome(event.projectIncomeId);
      emit(state.copyWith(statusAction: Status.success));
      add(GetProjectIncomesEvent(projectId: event.projectId));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onForceDeleteProjectIncome(
    ForceDeleteProjectIncomeEvent event,
    Emitter<ProjectIncomeState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));

    try {
      await repository.forceDeleteProjectIncome(event.projectIncomeId);
      emit(state.copyWith(statusAction: Status.success));
      add(GetProjectIncomesEvent(projectId: event.projectId));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}