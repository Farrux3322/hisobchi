import 'package:equatable/equatable.dart';
import 'package:hisobchi/infrastructure/models/warranty_periods_model.dart';
import 'package:hisobchi/domain/common/constants.dart';

class WarrantyPeriodsState extends Equatable {
  final Status status;
  final WarrantyPeriodsResponse? response;
  final String? errorMessage;

  const WarrantyPeriodsState({
    this.status = Status.initial,
    this.response,
    this.errorMessage,
  });

  WarrantyPeriodsState copyWith({
    Status? status,
    WarrantyPeriodsResponse? response,
    String? errorMessage,
  }) {
    return WarrantyPeriodsState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, response, errorMessage];
}
