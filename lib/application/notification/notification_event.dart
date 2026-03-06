part of 'notification_bloc.dart';

@freezed
class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.getNotifications({
    @Default(false) bool isLoadMore,
  }) = GetNotifications;
  
  const factory NotificationEvent.readNotification({required int id}) = ReadNotification;
  const factory NotificationEvent.readAllNotifications() = ReadAllNotifications;
  const factory NotificationEvent.getUnreadCount() = GetUnreadCount;
  const factory NotificationEvent.reset() = ResetNotificationState;
}
