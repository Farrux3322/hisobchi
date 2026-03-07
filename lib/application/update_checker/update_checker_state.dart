part of 'update_checker_bloc.dart';

class UpdateCheckerState extends Equatable {
  final bool hasUpdate;
  final String updateStatus;
  final String version;
  final String? errorMessage;
  final bool isDismissed;

  const UpdateCheckerState({
    required this.hasUpdate,
    required this.updateStatus,
    this.version = '',
    this.errorMessage,
    this.isDismissed = false,
  });

  UpdateCheckerState copyWith({
    bool? hasUpdate,
    String? updateStatus,
    String? version,
    String? errorMessage,
    bool? isDismissed,
  }) {
    return UpdateCheckerState(
      hasUpdate: hasUpdate ?? this.hasUpdate,
      updateStatus: updateStatus ?? this.updateStatus,
      version: version ?? this.version,
      errorMessage: errorMessage ?? this.errorMessage,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  @override
  List<Object?> get props => [hasUpdate, updateStatus, version, errorMessage, isDismissed];
}