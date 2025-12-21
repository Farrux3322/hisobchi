part of 'contract_bloc.dart';

sealed class ContractEvent extends Equatable {
  const ContractEvent();

  @override
  List<Object?> get props => [];
}

class GetContractsEvent extends ContractEvent {
  final int projectId;
  final String search;

  const GetContractsEvent({required this.projectId, this.search = ''});

  @override
  List<Object?> get props => [projectId, search];
}

class CreateContractEvent extends ContractEvent {
  final Object data;

  const CreateContractEvent({required this.data});

  @override
  List<Object?> get props => [data];
}

class UpdateContractEvent extends ContractEvent {
  final Object data;
  final int id;

  const UpdateContractEvent({required this.data, required this.id});

  @override
  List<Object?> get props => [data, id];
}

class DeleteContractEvent extends ContractEvent {
  final int id;

  const DeleteContractEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class RestoreContractEvent extends ContractEvent {
  final int id;

  const RestoreContractEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ForceDeleteContractEvent extends ContractEvent {
  final int id;

  const ForceDeleteContractEvent({required this.id});

  @override
  List<Object?> get props => [id];
}