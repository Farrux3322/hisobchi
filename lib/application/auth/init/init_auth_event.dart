part of 'init_auth_bloc.dart';

@immutable
abstract class InitAuthEvent {}

class VerifyNumber extends InitAuthEvent {
  final String phone;

  VerifyNumber({required this.phone});
}

class SignInEvent extends InitAuthEvent {
  final String phone;
  final String password;

  SignInEvent({required this.phone, required this.password});
}

class SendOtpEvent extends InitAuthEvent {
  final String password;
  final String name;

  SendOtpEvent({required this.password,required this.name});
}

class ResetSendOtpEvent extends InitAuthEvent {
  final String password;
  final String otp;

  ResetSendOtpEvent({required this.password, required this.otp});
}

class RegisterEvent extends InitAuthEvent {
  final String otp;


  RegisterEvent({required this.otp});
}

class VerifyOtpEvent extends InitAuthEvent {
  final String otp;

  VerifyOtpEvent({required this.otp});
}

class ScannerLoginEvent extends InitAuthEvent {
  final String qrCode;

  ScannerLoginEvent({required this.qrCode});
}


class ResetAuthEvent extends InitAuthEvent {}

class SelectWorkspaceEvent extends InitAuthEvent {
  final UserMeModel meData;
  final WorksFor? workspace;

  SelectWorkspaceEvent({required this.meData, this.workspace});
}

class ActivateOwnerAccountEvent extends InitAuthEvent {
  final UserMeModel meData;

  ActivateOwnerAccountEvent({required this.meData});
}

