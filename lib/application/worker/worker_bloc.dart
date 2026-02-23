import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/worker/worker_event.dart';
import 'package:hisobchi/application/worker/worker_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/repository/worker/worker_repository.dart';

class WorkerBloc extends Bloc<WorkerEvent, WorkerState> {
  final WorkerRepository repository;

  WorkerBloc({required this.repository}) : super(const WorkerState()) {
    on<GetProjectWorkersEvent>(_onGetProjectWorkers);
    on<GetAllWorkersEvent>(_onGetAllWorkers);
    on<CreateWorkerEvent>(_onCreateWorker);
    on<UpdateWorkerEvent>(_onUpdateWorker);
    on<DeleteWorkerEvent>(_onDeleteWorker);
    on<RestoreWorkerEvent>(_onRestoreWorker);
    on<ForceDeleteWorkerEvent>(_onForceDeleteWorker);
    on<GetWorkerPositionsEvent>(_onGetWorkerPositions);
    on<CreateWorkerPositionEvent>(_onCreateWorkerPosition);
    on<UpdateWorkerPositionEvent>(_onUpdateWorkerPosition);
    on<DeleteWorkerPositionEvent>(_onDeleteWorkerPosition);
    on<RestoreWorkerPositionEvent>(_onRestoreWorkerPosition);
    on<ForceDeleteWorkerPositionEvent>(_onForceDeleteWorkerPosition);
    on<AddWorkerToProjectEvent>(_onAddWorkerToProject);
    on<AddWorkersToProjectEvent>(_onAddWorkersToProject);
    on<RemoveWorkerFromProjectEvent>(_onRemoveWorkerFromProject);
  }

  Future<void> _onGetProjectWorkers(
    GetProjectWorkersEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(
      status: Status.loading,
      statusAction: Status.initial, // Reset statusAction
    ));
    try {
      final response = await repository.getProjectWorkers(event.projectId);
      emit(state.copyWith(
        status: Status.success,
        projectWorkers: response.result,
        statusAction: Status.initial, // Keep statusAction reset
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
        statusAction: Status.initial, // Keep statusAction reset
      ));
    }
  }

  Future<void> _onGetAllWorkers(
    GetAllWorkersEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusAllWorkers: Status.loading));
    try {
      final response = await repository.getAllWorkers(projectId: event.projectId);
      emit(state.copyWith(
        statusAllWorkers: Status.success,
        allWorkers: response.result,
      ));
    } catch (e) {
      emit(state.copyWith(
        statusAllWorkers: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateWorker(
    CreateWorkerEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.createWorker(
        name: event.name,
        phone: event.phone,
        additionalPhone: event.additionalPhone,
        fileIds: event.fileIds,
        workerPositionId: event.workerPositionId,
        description: event.description,
      );
      emit(state.copyWith(statusAction: Status.success));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateWorker(
    UpdateWorkerEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.updateWorker(
        workerId: event.workerId,
        name: event.name,
        phone: event.phone,
        additionalPhone: event.additionalPhone,
        fileIds: event.fileIds,
        workerPositionId: event.workerPositionId,
        description: event.description,
      );
      emit(state.copyWith(statusAction: Status.success));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: _getErrorMessage(e),
      ));
    }
  }

  Future<void> _onDeleteWorker(
    DeleteWorkerEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.deleteWorker(event.workerId);
      emit(state.copyWith(statusAction: Status.success));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRestoreWorker(
    RestoreWorkerEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.restoreWorker(event.workerId);
      emit(state.copyWith(statusAction: Status.success));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onForceDeleteWorker(
    ForceDeleteWorkerEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.forceDeleteWorker(event.workerId);
      emit(state.copyWith(statusAction: Status.success));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGetWorkerPositions(
    GetWorkerPositionsEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(
      statusPositions: Status.loading,
      statusPositionAction: Status.initial, // Reset statusPositionAction
    ));
    try {
      final response = await repository.getWorkerPositions();
      emit(state.copyWith(
        statusPositions: Status.success,
        positions: response.result,
        statusPositionAction: Status.initial, // Keep statusPositionAction reset
      ));
    } catch (e) {
      emit(state.copyWith(
        statusPositions: Status.error,
        errorMessage: e.toString(),
        statusPositionAction: Status.initial, // Keep statusPositionAction reset
      ));
    }
  }

  Future<void> _onCreateWorkerPosition(
    CreateWorkerPositionEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusPositionAction: Status.loading));
    try {
      await repository.createWorkerPosition(
        name: event.name,
        description: event.description,
      );
      emit(state.copyWith(statusPositionAction: Status.success));
      // Reset statusPositionAction after a short delay to allow UI to react
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusPositionAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusPositionAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateWorkerPosition(
    UpdateWorkerPositionEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusPositionAction: Status.loading));
    try {
      await repository.updateWorkerPosition(
        positionId: event.positionId,
        name: event.name,
        description: event.description,
      );
      emit(state.copyWith(statusPositionAction: Status.success));
      // Reset statusPositionAction after a short delay to allow UI to react
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusPositionAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusPositionAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }


  Future<void> _onDeleteWorkerPosition(
    DeleteWorkerPositionEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusPositionAction: Status.loading));
    try {
      await repository.deleteWorkerPosition(event.positionId);
      emit(state.copyWith(statusPositionAction: Status.success));
      // Reset statusPositionAction after a short delay to allow UI to react
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusPositionAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusPositionAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRestoreWorkerPosition(
    RestoreWorkerPositionEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusPositionAction: Status.loading));
    try {
      await repository.restoreWorkerPosition(event.positionId);
      emit(state.copyWith(statusPositionAction: Status.success));
      // Reset statusPositionAction after a short delay to allow UI to react
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusPositionAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusPositionAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onForceDeleteWorkerPosition(
    ForceDeleteWorkerPositionEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusPositionAction: Status.loading));
    try {
      await repository.forceDeleteWorkerPosition(event.positionId);
      emit(state.copyWith(statusPositionAction: Status.success));
      // Reset statusPositionAction after a short delay to allow UI to react
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusPositionAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusPositionAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddWorkerToProject(
    AddWorkerToProjectEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.addWorkerToProject(
        workerId: event.workerId,
        projectId: event.projectId,
      );
      emit(state.copyWith(statusAction: Status.success));
      // Reset statusAction after a short delay to allow UI to react
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddWorkersToProject(
    AddWorkersToProjectEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.addWorkersToProject(
        workerIds: event.workerIds,
        projectId: event.projectId,
      );
      emit(state.copyWith(statusAction: Status.success));
      // Reset statusAction after a short delay to allow UI to react
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRemoveWorkerFromProject(
    RemoveWorkerFromProjectEvent event,
    Emitter<WorkerState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.removeWorkerFromProject(
        workerId: event.workerId,
        projectId: event.projectId,
      );
      emit(state.copyWith(statusAction: Status.success));
      // Reset statusAction after a short delay to allow UI to react
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Extracts error message from DioException and stringifies validation errors
  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      final response = e.response;
      if (response != null && response.data != null) {
        final dynamic data = response.data;

        // If it's already a JSON string that contains 'errors', return as is
        if (data is String && data.contains('"errors"')) {
          return data;
        }

        // If it's a Map, use the helper to extract/encode
        if (data is Map<String, dynamic>) {
          return _extractMessageFromData(data);
        }

        // Fallback for other status 422 cases if data is somehow a Map but not caught
        if (response.statusCode == 422) {
          try {
            return jsonEncode(data);
          } catch (_) {}
        }

        return _extractMessageFromData(data);
      }
      return e.message ?? e.toString();
    }
    return e.toString();
  }

  /// Helper to extract message from response data Map
  /// Senior level: prioritize 'errors' for UI parsing
  String _extractMessageFromData(dynamic data) {
    if (data is Map<String, dynamic>) {
      // 1. Check for Laravel style "errors" map
      if (data.containsKey('errors') && data['errors'] != null) {
        final errors = data['errors'];
        // Only return JSON if errors actually have content
        if (errors is Map && errors.isNotEmpty) {
          return jsonEncode(data);
        }
      }

      // 2. Check for nested "error" object with "errors"
      if (data.containsKey('error') && data['error'] is Map) {
        final errorObj = data['error'] as Map<String, dynamic>;
        if (errorObj.containsKey('errors') && errorObj['errors'] != null) {
          return jsonEncode(errorObj);
        }
        if (errorObj.containsKey('message')) {
          return errorObj['message'].toString();
        }
      }

      // 3. Fallback to top-level "message"
      if (data.containsKey('message')) {
        return data['message'].toString();
      }

      // 4. Last resort: just encode the whole map
      return jsonEncode(data);
    }

    // If it's a string, try to see if it's JSON
    if (data is String) {
      if (data.startsWith('{') && data.contains('"errors"')) {
        return data;
      }
      return data;
    }

    return data.toString();
  }
}