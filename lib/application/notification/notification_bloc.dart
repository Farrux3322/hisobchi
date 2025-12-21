import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hisobchi/domain/enums/bloc_status.dart';
import 'package:hisobchi/infrastructure/models/notification_model.dart';
import 'package:hisobchi/infrastructure/repository/notification/notifaction.dart';

part 'notification_bloc.freezed.dart';
part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final repo = NotificationRepository();

  NotificationBloc() : super(const NotificationState()) {
    on<GetNotifications>((event, emit) async {
      emit(state.copyWith(statusGet: BlocStatus.loading));

      try {
        final response = await repo.getNotifications(status: event.status);
        final notifications = response["result"].map<NotificationModel>((e) => NotificationModel.fromJson(e)).toList();

        if (event.status == 1) {
          emit(state.copyWith(
            newsNotifications: notifications,
            statusGet: notifications.isEmpty ? BlocStatus.empty : BlocStatus.success,
          ));
        } else if (event.status == 2) {
          emit(state.copyWith(
            personalNotifications: notifications,
            statusGet: notifications.isEmpty ? BlocStatus.empty : BlocStatus.success,
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          statusGet: BlocStatus.error,
          errorMessage: e.toString(),
        ));
      }
    });

    on<ShowNotification>((event, emit) async {
      emit(state.copyWith(statusShow: BlocStatus.loading));
      try {
        final response = await repo.showNotification(event.notification.id!);
        if (response["status"] == true) {
          emit(state.copyWith(statusShow: BlocStatus.success));
          add(GetNotifications(status: event.status));
        } else {
          emit(state.copyWith(statusShow: BlocStatus.error, errorMessage: response["message"].toString()));
        }
      } catch (e) {
        emit(state.copyWith(statusShow: BlocStatus.error, errorMessage: e.toString()));
      }
    });

    on<ReadAllNotifications>((event, emit) async {
      emit(state.copyWith(statusReadAll: BlocStatus.loading));
      try {
        final response = await repo.readAllNotifications();
        if (response["status"] == true) {
          emit(state.copyWith(statusReadAll: BlocStatus.success));
          add(GetNotifications(status: event.status));
        } else {
          emit(state.copyWith(statusReadAll: BlocStatus.error, errorMessage: response["message"].toString()));
        }
      } catch (e) {
        emit(state.copyWith(statusReadAll: BlocStatus.error, errorMessage: e.toString()));
      }
    });

    on<ResetNotificationState>((event, emit) {
      emit(const NotificationState());
    });

    on<ReadNotification>((event, emit) async {
      final List<NotificationModel> updatedNews = List.from(state.newsNotifications);
      final List<NotificationModel> updatedPersonal = List.from(state.personalNotifications);

      final newsIndex = updatedNews.indexWhere((n) => n.id == event.id);
      if (newsIndex != -1) {
        final notificationToUpdate = updatedNews[newsIndex];
        updatedNews[newsIndex] = notificationToUpdate.copyWith(viewed: true);
      }

      final personalIndex = updatedPersonal.indexWhere((n) => n.id == event.id);
      if (personalIndex != -1) {
        final notificationToUpdate = updatedPersonal[personalIndex];
        updatedPersonal[personalIndex] = notificationToUpdate.copyWith(viewed: true);
      }

      emit(state.copyWith(
        newsNotifications: updatedNews,
        personalNotifications: updatedPersonal,
        statusGet: BlocStatus.success,
      ));

      try {
        await repo.showNotification(event.id);
      } catch (e) {
        emit(state.copyWith(statusShow: BlocStatus.error, errorMessage: e.toString()));
      }
    });
  }
}
