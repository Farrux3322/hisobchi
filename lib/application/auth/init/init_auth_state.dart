part of 'init_auth_bloc.dart';

@immutable
abstract class InitAuthState {}

class InitAuthInitial extends InitAuthState {}

class LoadingState extends InitAuthState {}


class InitScannerState extends InitAuthState {
}

class LoadingScannerState extends InitAuthState {
}

class ErrorScannerState extends InitAuthState {
final String message;

  ErrorScannerState({required this.message});
}


class SuccessScannerState extends InitAuthState {
  final String branchGuid;

  SuccessScannerState({required this.branchGuid});
}

class LocationBlockState extends InitAuthState {}

class InitSuccess extends InitAuthState {
  InitSuccess({required this.pageStatus, required this.phone});

  final String pageStatus;
  final String phone;
}

class ErrorState extends InitAuthState {
  final String error;

  ErrorState(this.error);
}

abstract class OtpState extends InitAuthState {}

class OtpLoading extends OtpState {}

class OtpSuccess extends OtpState {}

class OtpFailed extends OtpState {
  final String? error;
  OtpFailed({this.error});
}

abstract class RegisterState extends InitAuthState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final UserMeModel meData;
  RegisterSuccess(this.meData);
}

class RegisterFailed extends RegisterState {
  final String? error;
  RegisterFailed({this.error});
}

abstract class SignInState extends InitAuthState {}

class SignInLoading extends SignInState {}

class SignInError extends SignInState {
  final String error;

  SignInError(this.error);
}

class SignInSuccess extends SignInState {
  final UserMeModel meData;
  SignInSuccess(this.meData);
}

class ActivateOwnerAccountLoading extends InitAuthState {}

class ActivateOwnerAccountSuccess extends InitAuthState {}

class ActivateOwnerAccountFailed extends InitAuthState {
  final String error;
  ActivateOwnerAccountFailed({required this.error});
}

