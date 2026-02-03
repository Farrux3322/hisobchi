import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hisobchi/domain/enums/bloc_status.dart';
import 'package:hisobchi/infrastructure/dto/models/notification/notification_model.dart';
import 'package:hisobchi/infrastructure/repository/notification/notifaction.dart';

part 'notification_bloc.freezed.dart';
part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final repo = NotificationRepository();

  NotificationBloc() : super(const NotificationState()) {
    on<GetNotifications>(_getNotifications);
    on<ReadNotification>(_readNotification);
    on<ReadAllNotifications>(_readAllNotifications);
    on<ResetNotificationState>((event, emit) => emit(const NotificationState()));
  }

  Future<void> _getNotifications(GetNotifications event, Emitter<NotificationState> emit) async {
    if (state.hasReachedMax && event.isLoadMore) return;

    if (!event.isLoadMore) {
      emit(state.copyWith(status: BlocStatus.loading, notifications: [], currentPage: 1, hasReachedMax: false));
    }

    try {
      final pageToLoad = event.isLoadMore ? state.currentPage + 1 : 1;
      final response = await repo.getNotifications(page: pageToLoad);
      final model = NotificationResponseModel.fromJson(response);

      if (model.status == true && model.result != null) {
        final List<NotificationItemModel> newItems = model.result!.data ?? [];
        final bool reachedMax = model.result!.currentPage == model.result!.lastPage;

        emit(state.copyWith(
          status: BlocStatus.success,
          notifications: event.isLoadMore ? [...state.notifications, ...newItems] : newItems,
          currentPage: model.result!.currentPage ?? pageToLoad,
          hasReachedMax: reachedMax,
        ));
      } else {
        emit(state.copyWith(status: BlocStatus.error, errorMessage: "Failed to load notifications"));
      }
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _readNotification(ReadNotification event, Emitter<NotificationState> emit) async {
    // Optimistic UI update
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == event.id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: updatedNotifications));

    try {
      await repo.readNotification(event.id);
    } catch (e) {
      // If server call fails, we might want to revert or just log
      print("Error marking notification as read: $e");
    }
  }

  Future<void> _readAllNotifications(ReadAllNotifications event, Emitter<NotificationState> emit) async {
    // Optimistic UI update
    final updatedNotifications = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(notifications: updatedNotifications));

    try {
      await repo.readAllNotifications();
    } catch (e) {
      print("Error marking all notifications as read: $e");
    }
  }
}
