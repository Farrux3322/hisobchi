import 'package:equatable/equatable.dart';
import 'package:hisobchi/infrastructure/models/staff_worker_model.dart';

class StaffReportWorkersState extends Equatable {
  final bool isInitial;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final List<StaffWorkerModel> workers;

  const StaffReportWorkersState({
    this.isInitial = true,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.workers = const [],
  });

  StaffReportWorkersState copyWith({
    bool? isInitial,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    List<StaffWorkerModel>? workers,
  }) {
    return StaffReportWorkersState(
      isInitial: isInitial ?? this.isInitial,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      workers: workers ?? this.workers,
    );
  }

  @override
  List<Object?> get props => [isInitial, isLoading, isError, errorMessage, workers];
}
