import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/infrastructure/dto/models/due_dates/due_dates_model.dart';
import 'package:hisobchi/infrastructure/repository/due_dates/due_dates_repository.dart';

part 'due_dates_state.dart';

class QarzDueDatesCubit extends Cubit<QarzDueDatesState> {
  final DueDatesRepository _repo;
  final String type;

  QarzDueDatesCubit({required DueDatesRepository repo, required this.type})
      : _repo = repo,
        super(const QarzDueDatesState());

  Future<void> load() async {
    if (state.status == DueDatesStatus.loading) return;
    emit(state.copyWith(status: DueDatesStatus.loading, items: [], currentPage: 1, hasNextPage: false));
    try {
      final res = await _repo.getQarzDueDates(type: type, page: 1);
      emit(state.copyWith(
        status: DueDatesStatus.success,
        items: res.result.data,
        currentPage: res.result.currentPage,
        hasNextPage: res.result.hasNextPage,
      ));
    } catch (e) {
      emit(state.copyWith(status: DueDatesStatus.failure, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(status: DueDatesStatus.loading, items: [], currentPage: 1, hasNextPage: false));
    try {
      final res = await _repo.getQarzDueDates(type: type, page: 1);
      emit(state.copyWith(
        status: DueDatesStatus.success,
        items: res.result.data,
        currentPage: res.result.currentPage,
        hasNextPage: res.result.hasNextPage,
      ));
    } catch (e) {
      emit(state.copyWith(status: DueDatesStatus.failure, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasNextPage || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.currentPage + 1;
      final res = await _repo.getQarzDueDates(type: type, page: nextPage);
      emit(state.copyWith(
        status: DueDatesStatus.success,
        items: [...state.items, ...res.result.data],
        currentPage: res.result.currentPage,
        hasNextPage: res.result.hasNextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}

class InstallmentDueDatesCubit extends Cubit<InstallmentDueDatesState> {
  final DueDatesRepository _repo;
  final String type;

  InstallmentDueDatesCubit({required DueDatesRepository repo, required this.type})
      : _repo = repo,
        super(const InstallmentDueDatesState());

  Future<void> load() async {
    if (state.status == DueDatesStatus.loading) return;
    emit(state.copyWith(status: DueDatesStatus.loading, items: [], currentPage: 1, hasNextPage: false));
    try {
      final res = await _repo.getInstallmentDueDates(type: type, page: 1);
      emit(state.copyWith(
        status: DueDatesStatus.success,
        items: res.result.data,
        currentPage: res.result.currentPage,
        hasNextPage: res.result.hasNextPage,
      ));
    } catch (e) {
      emit(state.copyWith(status: DueDatesStatus.failure, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(status: DueDatesStatus.loading, items: [], currentPage: 1, hasNextPage: false));
    try {
      final res = await _repo.getInstallmentDueDates(type: type, page: 1);
      emit(state.copyWith(
        status: DueDatesStatus.success,
        items: res.result.data,
        currentPage: res.result.currentPage,
        hasNextPage: res.result.hasNextPage,
      ));
    } catch (e) {
      emit(state.copyWith(status: DueDatesStatus.failure, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasNextPage || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.currentPage + 1;
      final res = await _repo.getInstallmentDueDates(type: type, page: nextPage);
      emit(state.copyWith(
        status: DueDatesStatus.success,
        items: [...state.items, ...res.result.data],
        currentPage: res.result.currentPage,
        hasNextPage: res.result.hasNextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
