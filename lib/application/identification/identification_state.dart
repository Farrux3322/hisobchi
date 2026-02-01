part of 'identification_bloc.dart';

enum IdentificationStatus { initial, loading, myIdStarted, verifying, success, error }

class IdentificationState extends Equatable {
  final IdentificationStatus status;
  final String errorMessage;
  final String? code;

  const IdentificationState({
    this.status = IdentificationStatus.initial,
    this.errorMessage = '',
    this.code,
  });

  IdentificationState copyWith({
    IdentificationStatus? status,
    String? errorMessage,
    String? code,
  }) {
    return IdentificationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      code: code ?? this.code,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, code];
}
