import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/project_income/project_income_event.dart';
import 'package:hisobchi/application/project_income/project_income_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/project_income/project_income_repository.dart';

class ProjectIncomeBloc extends Bloc<ProjectIncomeEvent, ProjectIncomeState> {
  final ProjectIncomeRepository repository;

  ProjectIncomeBloc({required this.repository}) : super(const ProjectIncomeState()) {
    on<GetProjectIncomesEvent>(_onGetProjectIncomes);
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
    emit(state.copyWith(status: Status.loading));

    try {
      final response = await repository.getProjectIncomes(event.projectId);
      emit(state.copyWith(
        status: Status.success,
        incomes: response.result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
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