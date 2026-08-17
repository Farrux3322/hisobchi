import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/work_type_model.dart';
import 'package:ehisob/infrastructure/repository/work_type/work_type_repository.dart';

part 'work_type_event.dart';
part 'work_type_state.dart';

class WorkTypeBloc extends Bloc<WorkTypeEvent, WorkTypeState> {
  final _repo = WorkTypeRepository();

  WorkTypeBloc() : super(WorkTypeState()) {
    on<GetAllWorkTypesEvent>(getAll);
    on<CreateWorkTypeEvent>(create);
    on<UpdateWorkTypeEvent>(update);
    on<DeleteWorkTypeEvent>(delete);
    on<RestoreWorkTypeEvent>(restore);
    on<ForceDeleteWorkTypeEvent>(forceDelete);
  }

  Future<void> getAll(GetAllWorkTypesEvent event, Emitter<WorkTypeState> emit) async {
    emit(state.copyWith(status: Status.loading, statusAdd: Status.pure));
    try {
      final data = await _repo.getAll();

      if (data["status"] == true) {
        List<WorkTypeModel> models = [];
        models = data["result"].map<WorkTypeModel>((element) => WorkTypeModel.fromJson(element)).toList();
        emit(state.copyWith(status: Status.success, models: models));
      } else {
        emit(state.copyWith(status: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> create(CreateWorkTypeEvent event, Emitter<WorkTypeState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.create(data: event.data);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data['error']?["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> update(UpdateWorkTypeEvent event, Emitter<WorkTypeState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.update(data: event.data, id: event.id);

      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> delete(DeleteWorkTypeEvent event, Emitter<WorkTypeState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.delete(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> forceDelete(ForceDeleteWorkTypeEvent event, Emitter<WorkTypeState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.forceDelete(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> restore(RestoreWorkTypeEvent event, Emitter<WorkTypeState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.restore(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }
}