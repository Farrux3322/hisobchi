part of 'update_checker_bloc.dart';

class UpdateCheckerState extends Equatable {
  final bool hasUpdate;
  final String updateStatus;
  final String? errorMessage;

  const UpdateCheckerState({
    required this.hasUpdate,
    required this.updateStatus,
    this.errorMessage,
  });

  UpdateCheckerState copyWith({
    bool? hasUpdate,
    String? updateStatus,
    String? errorMessage,
  }) {
    return UpdateCheckerState(
      hasUpdate: hasUpdate ?? this.hasUpdate,
      updateStatus: updateStatus ?? this.updateStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [hasUpdate, updateStatus, errorMessage];
}