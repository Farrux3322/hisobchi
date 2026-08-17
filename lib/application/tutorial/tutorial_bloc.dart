import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:ehisob/application/tutorial/tutorial_event.dart';
import 'package:ehisob/application/tutorial/tutorial_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/tutorial_model.dart';
import 'package:ehisob/infrastructure/repository/tutorial/tutorial_repository.dart';

class TutorialBloc extends Bloc<TutorialEvent, TutorialState> {
  final TutorialRepository repository;

  TutorialBloc({required this.repository}) : super(const TutorialState()) {
    on<GetTutorialsEvent>(_getTutorials);
  }

  Future<void> _getTutorials(GetTutorialsEvent event, Emitter<TutorialState> emit) async {
    emit(state.copyWith(status: Status.loading, isNotFound: false));
    try {
      final data = await repository.getTutorials();
      if (data["status"] == true) {
        final List<dynamic> resultList = data["result"] ?? [];
        final List<TutorialModel> tutorials = resultList.map((element) => TutorialModel.fromJson(element)).toList();
        emit(state.copyWith(status: Status.success, tutorials: tutorials));
      } else {
        emit(state.copyWith(status: Status.error, errorMessage: data["message"]?.toString() ?? 'Noma\'lum xatolik yuz berdi'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        emit(state.copyWith(status: Status.error, isNotFound: true, errorMessage: e.message ?? e.toString()));
      } else {
        emit(state.copyWith(status: Status.error, errorMessage: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }
}
