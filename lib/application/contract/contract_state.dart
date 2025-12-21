part of 'contract_bloc.dart';

class ContractState extends Equatable {
  final Status status;
  final Status statusAction;
  final String? errorMessage;
  final List<ContractModel> contracts;

  const ContractState({
    this.status = Status.pure,
    this.statusAction = Status.pure,
    this.errorMessage,
    this.contracts = const [],
  });

  ContractState copyWith({
    Status? status,
    Status? statusAction,
    String? errorMessage,
    List<ContractModel>? contracts,
  }) {
    return ContractState(
      status: status ?? this.status,
      statusAction: statusAction ?? this.statusAction,
      errorMessage: errorMessage ?? this.errorMessage,
      contracts: contracts ?? this.contracts,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statusAction,
        errorMessage,
        contracts,
      ];
}