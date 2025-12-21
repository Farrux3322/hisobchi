part of 'app_manager_cubit.dart';

@immutable
abstract class AppManagerState {}

class AppManagerInitial extends AppManagerState {}

class AppManagerLoading extends AppManagerState {}

class AppManagerError extends AppManagerState {
  AppManagerError(this.error);

  final String error;
}
