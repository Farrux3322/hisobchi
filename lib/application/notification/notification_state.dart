part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final BlocStatus statusGet;
  final BlocStatus statusShow;
  final BlocStatus statusReadAll;
  final List<NotificationModel> newsNotifications;
  final List<NotificationModel> personalNotifications;
  final String? errorMessage;

  const NotificationState({
    this.statusGet = BlocStatus.initial,
    this.statusShow = BlocStatus.initial,
    this.statusReadAll = BlocStatus.initial,
    this.newsNotifications = const [],
    this.personalNotifications = const [],
    this.errorMessage,
  });

  NotificationState copyWith({
    BlocStatus? statusGet,
    BlocStatus? statusShow,
    BlocStatus? statusReadAll,
    List<NotificationModel>? newsNotifications,
    List<NotificationModel>? personalNotifications,
    String? errorMessage,
  }) {
    return NotificationState(
      statusGet: statusGet ?? this.statusGet,
      statusShow: statusShow ?? this.statusShow,
      statusReadAll: statusReadAll ?? this.statusReadAll,
      newsNotifications: newsNotifications ?? this.newsNotifications,
      personalNotifications: personalNotifications ?? this.personalNotifications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        statusGet,
        statusShow,
        statusReadAll,
        newsNotifications,
        personalNotifications,
        errorMessage,
      ];
}
