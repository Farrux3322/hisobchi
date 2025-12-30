part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  final Status status;
  final DashboardModel? dashboardModel;
  final String? errorMessage;

  const DashboardState({
    this.status = Status.pure,
    this.dashboardModel,
    this.errorMessage,
  });

  DashboardState copyWith({
    Status? status,
    DashboardModel? dashboardModel,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      dashboardModel: dashboardModel ?? this.dashboardModel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, dashboardModel, errorMessage];
}