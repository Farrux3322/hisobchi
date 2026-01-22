part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class GetDashboardEvent extends DashboardEvent {
  const GetDashboardEvent();
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}