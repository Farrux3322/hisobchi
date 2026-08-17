import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:ehisob/infrastructure/dto/models/project_report/project_cost_detail_item_model.dart';
import 'package:ehisob/infrastructure/repository/project_report/project_cost_details_repository.dart';

part 'project_cost_details_event.dart';
part 'project_cost_details_state.dart';

class ProjectCostDetailsBloc extends Bloc<ProjectCostDetailsEvent, ProjectCostDetailsState> {
  final _repo = ProjectCostDetailsRepository();

  ProjectCostDetailsBloc() : super(const ProjectCostDetailsState()) {
    on<GetCostDetailsEvent>(_onGetCostDetails);
  }

  Future<void> _onGetCostDetails(
    GetCostDetailsEvent event,
    Emitter<ProjectCostDetailsState> emit,
  ) async {
    emit(state.copyWith(status: CostDetailsStatus.loading, costTypeId: event.costTypeId));
    try {
      final data = await _repo.getCostDetails(projectId: event.projectId, costTypeId: event.costTypeId);

      if (data["status"] == true) {
        List<ProjectCostDetailItemModel> list = [];
        if (data["result"] != null) {
          list = (data["result"] as List)
              .map((e) => ProjectCostDetailItemModel.fromJson(e))
              .toList();
        }
        emit(state.copyWith(status: CostDetailsStatus.success, costs: list));
      } else {
        emit(state.copyWith(
            status: CostDetailsStatus.error,
            errorMessage: data["error"]?.toString() ?? 'Xatolik yuz berdi'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: CostDetailsStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: CostDetailsStatus.error, errorMessage: e.toString()));
    }
  }
}
