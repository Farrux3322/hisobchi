import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/project/project_model.dart';
import 'package:hisobchi/infrastructure/repository/project/project_repository.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final _repo = ProjectRepository();

  ProjectBloc() : super(ProjectState()) {
    on<GetAllProjectEvent>(getAll);
    on<GetProjectByIdEvent>(getById);
    on<CreateProjectEvent>(create);
    on<UpdateProjectEvent>(update);
    on<DeleteProjectEvent>(delete);
    on<RestoreProjectEvent>(restore);
    on<ForceDeleteProjectEvent>(forceDelete);
    on<UpdateProjectStatusEvent>(updateStatus);
  }

  Future<void> getAll(GetAllProjectEvent event, Emitter<ProjectState> emit) async {
    final search = event.updateSearch ? event.search : state.search;
    final statusFilter = event.updateFilters ? event.status : state.statusFilter;
    final date = event.updateFilters ? event.date : state.date;

    emit(state.copyWith(
      status: Status.loading,
      statusAdd: Status.pure,
      search: search,
      statusFilter: event.updateFilters ? () => event.status : null,
      date: event.updateFilters ? () => event.date : null,
    ));

    try {
      final Map<String, dynamic> params = {};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (statusFilter != null && statusFilter.isNotEmpty) params['status'] = statusFilter;
      if (date != null && date.isNotEmpty) params['date[]'] = date;

      final data = await _repo.get(params: params);

      if (data["status"] == true) {
        List<ProjectModel> model = [];
        model = data["result"].map<ProjectModel>((element) => ProjectModel.fromJson(element)).toList();
        emit(state.copyWith(status: Status.success, models: model));
      } else {
        emit(state.copyWith(status: Status.error, errorMessage: data["error"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> getById(GetProjectByIdEvent event, Emitter<ProjectState> emit) async {
    // Reset statusAction when navigating back from edit page
    emit(state.copyWith(statusDetail: Status.loading, statusAction: Status.pure,statusAdd: Status.pure));
    try {
      final data = await _repo.getById(id: event.id);

      if (data["status"] == true) {
        final project = ProjectModel.fromJson(data["result"]);
        emit(state.copyWith(statusDetail: Status.success, selectedProject: project));
      } else {
        emit(state.copyWith(statusDetail: Status.error, errorMessage: data["error"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusDetail: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusDetail: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> create(CreateProjectEvent event, Emitter<ProjectState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.create(data: event.data);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data["error"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> update(UpdateProjectEvent event, Emitter<ProjectState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.update(data: event.data, id: event.id);

      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
        add(const GetAllProjectEvent());
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data["error"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> delete(DeleteProjectEvent event, Emitter<ProjectState> emit) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      final data = await _repo.delete(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAction: Status.success));
      } else {
        emit(state.copyWith(statusAction: Status.error, errorMessage: data["error"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> forceDelete(ForceDeleteProjectEvent event, Emitter<ProjectState> emit) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      final data = await _repo.forceDelete(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAction: Status.success));
      } else {
        emit(state.copyWith(statusAction: Status.error, errorMessage: data["error"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> restore(RestoreProjectEvent event, Emitter<ProjectState> emit) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      final data = await _repo.restore(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAction: Status.success));
      } else {
        emit(state.copyWith(statusAction: Status.error, errorMessage: data["error"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> updateStatus(UpdateProjectStatusEvent event, Emitter<ProjectState> emit) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      final data = await _repo.updateStatus(id: event.id, status: event.status);
      if (data["status"] == true) {
        emit(state.copyWith(statusAction: Status.success));
        add(GetProjectByIdEvent(id: event.id));
        add(const GetAllProjectEvent());
      } else {
        emit(state.copyWith(statusAction: Status.error, errorMessage: data["error"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    }
  }
}