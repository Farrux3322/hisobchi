part of 'identification_bloc.dart';

abstract class IdentificationEvent extends Equatable {
  const IdentificationEvent();

  @override
  List<Object?> get props => [];
}

class StartMyIdEvent extends IdentificationEvent {}

class IdentityVerifiedEvent extends IdentificationEvent {
  final String code;
  const IdentityVerifiedEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class IdentityErrorEvent extends IdentificationEvent {
  final String message;
  const IdentityErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetIdentificationEvent extends IdentificationEvent {}
