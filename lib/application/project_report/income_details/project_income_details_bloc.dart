import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:hisobchi/infrastructure/dto/models/project_report/project_income_detail_model.dart';
import 'package:hisobchi/infrastructure/repository/project_report/project_income_details_repository.dart';

part 'project_income_details_event.dart';
part 'project_income_details_state.dart';

class ProjectIncomeDetailsBloc extends Bloc<ProjectIncomeDetailsEvent, ProjectIncomeDetailsState> {
  final _repo = ProjectIncomeDetailsRepository();

  ProjectIncomeDetailsBloc() : super(const ProjectIncomeDetailsState()) {
    on<GetIncomeDetailsEvent>(_onGetIncomeDetails);
  }

  Future<void> _onGetIncomeDetails(
    GetIncomeDetailsEvent event,
    Emitter<ProjectIncomeDetailsState> emit,
  ) async {
    emit(state.copyWith(status: IncomeDetailsStatus.loading));
    try {
      final data = await _repo.getIncomeDetails(projectId: event.projectId);

      if (data["status"] == true) {
        List<ProjectIncomeDetailModel> list = [];
        if (data["result"] != null) {
          list = (data["result"] as List)
              .map((e) => ProjectIncomeDetailModel.fromJson(e))
              .toList();
        }
        emit(state.copyWith(status: IncomeDetailsStatus.success, incomes: list));
      } else {
        emit(state.copyWith(
            status: IncomeDetailsStatus.error,
            errorMessage: data["error"]?.toString() ?? 'Xatolik yuz berdi'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: IncomeDetailsStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: IncomeDetailsStatus.error, errorMessage: e.toString()));
    }
  }
}
