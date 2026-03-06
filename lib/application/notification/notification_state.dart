part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final BlocStatus status;
  final List<NotificationItemModel> notifications;
  final int currentPage;
  final bool hasReachedMax;
  final int unreadCount;
  final String? errorMessage;

  const NotificationState({
    this.status = BlocStatus.initial,
    this.notifications = const [],
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.unreadCount = 0,
    this.errorMessage,
  });

  NotificationState copyWith({
    BlocStatus? status,
    List<NotificationItemModel>? notifications,
    int? currentPage,
    bool? hasReachedMax,
    int? unreadCount,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        currentPage,
        hasReachedMax,
        unreadCount,
        errorMessage,
      ];
}
  
