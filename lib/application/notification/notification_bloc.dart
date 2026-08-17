import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ehisob/domain/enums/bloc_status.dart';
import 'package:ehisob/infrastructure/dto/models/notification/notification_model.dart';
import 'package:ehisob/infrastructure/repository/notification/notifaction.dart';

part 'notification_bloc.freezed.dart';
part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final repo = NotificationRepository();

  NotificationBloc() : super(const NotificationState()) {
    on<GetNotifications>(_getNotifications);
    on<ReadNotification>(_readNotification);
    on<ReadAllNotifications>(_readAllNotifications);
    on<GetUnreadCount>(_getUnreadCount);
    on<ResetNotificationState>((event, emit) => emit(const NotificationState()));
  }

  Future<void> _getUnreadCount(GetUnreadCount event, Emitter<NotificationState> emit) async {
    try {
      final response = await repo.getUnreadCount();
      final model = NotificationUnreadCountModel.fromJson(response);
      if (model.status == true && model.result != null) {
        emit(state.copyWith(unreadCount: model.result!.unreadCount ?? 0));
      }
    } catch (e) {
      debugPrint("Error fetching unread count: $e");
    }
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

    emit(state.copyWith(
      notifications: updatedNotifications,
      unreadCount: (state.unreadCount - 1).clamp(0, 999),
    ));

    try {
      await repo.readNotification(event.id);
    } catch (e) {
      // If server call fails, we might want to revert or just log
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> _readAllNotifications(ReadAllNotifications event, Emitter<NotificationState> emit) async {
    // Optimistic UI update
    final updatedNotifications = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    ));

    try {
      await repo.readAllNotifications();
    } catch (e) {
      debugPrint("Error marking all notifications as read: $e");
    }
  }
}
