part of 'update_checker_bloc.dart';

class UpdateCheckerState extends Equatable {
  final bool hasUpdate;
  final String updateStatus;
  final String version;
  final String? errorMessage;

  const UpdateCheckerState({
    required this.hasUpdate,
    required this.updateStatus,
    this.version = '',
    this.errorMessage,
  });

  UpdateCheckerState copyWith({
    bool? hasUpdate,
    String? updateStatus,
    String? version,
    String? errorMessage,
  }) {
    return UpdateCheckerState(
      hasUpdate: hasUpdate ?? this.hasUpdate,
      updateStatus: updateStatus ?? this.updateStatus,
      version: version ?? this.version,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [hasUpdate, updateStatus, version, errorMessage];
}