import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/dashboard/dashboard_model.dart';
import 'package:hisobchi/infrastructure/repository/dashboard/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final _repo = DashboardRepository();

  DashboardBloc() : super(const DashboardState()) {
    on<GetDashboardEvent>(getDashboard);
  }

  Future<void> getDashboard(GetDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final data = await _repo.getDashboard();

      if (data["status"] == true) {
        final model = DashboardModel.fromJson(data);
        emit(state.copyWith(status: Status.success, dashboardModel: model));
      } else {
        emit(state.copyWith(
          status: Status.error,
          errorMessage: data["message"]?.toString() ?? 'Xatolik yuz berdi',
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.response?.data?['message']?.toString() ?? e.message ?? 'Xatolik yuz berdi',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}