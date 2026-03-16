import 'package:equatable/equatable.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

class StaffPermissionsFetch extends StaffEvent {}

class StaffSendOtp extends StaffEvent {
  final String phone;
  const StaffSendOtp({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class StaffVerifyOtp extends StaffEvent {
  final String phone;
  final String otpCode;
  const StaffVerifyOtp({required this.phone, required this.otpCode});

  @override
  List<Object?> get props => [phone, otpCode];
}

class StaffCreate extends StaffEvent {
  final String phone;
  final String verifyToken;
  final String name;
  final String password;
  final List<String> permissions;

  const StaffCreate({
    required this.phone,
    required this.verifyToken,
    required this.name,
    required this.password,
    required this.permissions,
  });

  @override
  List<Object?> get props => [phone, verifyToken, name, password, permissions];
}

class StaffUpdate extends StaffEvent {
  final int id;
  final bool isActive;
  final List<String> permissions;

  const StaffUpdate({
    required this.id,
    required this.isActive,
    required this.permissions,
  });

  @override
  List<Object?> get props => [id, isActive, permissions];
}

class StaffDelete extends StaffEvent {
  final int id;
  const StaffDelete({required this.id});

  @override
  List<Object?> get props => [id];
}

class StaffListFetch extends StaffEvent {}
