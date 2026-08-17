import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/cost_type/cost_type_event.dart';
import 'package:ehisob/application/cost_type/cost_type_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/repository/cost_type/cost_type_repository.dart';

class CostTypeBloc extends Bloc<CostTypeEvent, CostTypeState> {
  final CostTypeRepository repository;

  CostTypeBloc({required this.repository}) : super(const CostTypeState()) {
    on<GetCostTypesEvent>(_onGetCostTypes);
    on<CreateCostTypeEvent>(_onCreateCostType);
    on<UpdateCostTypeEvent>(_onUpdateCostType);
    on<DeleteCostTypeEvent>(_onDeleteCostType);
    on<RestoreCostTypeEvent>(_onRestoreCostType);
    on<ForceDeleteCostTypeEvent>(_onForceDeleteCostType);
  }

  Future<void> _onGetCostTypes(
    GetCostTypesEvent event,
    Emitter<CostTypeState> emit,
  ) async {
    emit(state.copyWith(
      status: Status.loading,
      statusAction: Status.initial,
    ));
    try {
      final response = await repository.getCostTypes();
      emit(state.copyWith(
        status: Status.success,
        costTypes: response.result,
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

  Future<void> _onCreateCostType(
    CreateCostTypeEvent event,
    Emitter<CostTypeState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.createCostType(
        name: event.name,
        description: event.description,
      );
      emit(state.copyWith(statusAction: Status.success));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateCostType(
    UpdateCostTypeEvent event,
    Emitter<CostTypeState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.updateCostType(
        costTypeId: event.costTypeId,
        name: event.name,
        description: event.description,
      );
      emit(state.copyWith(statusAction: Status.success));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteCostType(
    DeleteCostTypeEvent event,
    Emitter<CostTypeState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.deleteCostType(event.costTypeId);
      emit(state.copyWith(statusAction: Status.success));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRestoreCostType(
    RestoreCostTypeEvent event,
    Emitter<CostTypeState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.restoreCostType(event.costTypeId);
      emit(state.copyWith(statusAction: Status.success));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onForceDeleteCostType(
    ForceDeleteCostTypeEvent event,
    Emitter<CostTypeState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      await repository.forceDeleteCostType(event.costTypeId);
      emit(state.copyWith(statusAction: Status.success));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(statusAction: Status.initial));
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}