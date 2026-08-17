import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/contract_model.dart';
import 'package:ehisob/infrastructure/repository/contract/contract_repository.dart';

part 'contract_event.dart';
part 'contract_state.dart';

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  final _repo = ContractRepository();

  ContractBloc() : super(const ContractState()) {
    on<GetContractsEvent>(getContracts);
    on<CreateContractEvent>(createContract);
    on<UpdateContractEvent>(updateContract);
    on<DeleteContractEvent>(deleteContract);
    on<RestoreContractEvent>(restoreContract);
    on<ForceDeleteContractEvent>(forceDeleteContract);
  }

  Future<void> getContracts(GetContractsEvent event, Emitter<ContractState> emit) async {
    emit(state.copyWith(status: Status.loading, statusAction: Status.pure));
    try {
      final data = await _repo.getContracts(
        projectId: event.projectId,
        search: event.search,
      );

      if (data["status"] == true) {
        List<ContractModel> contracts = [];
        contracts = data["result"]
            .map<ContractModel>((element) => ContractModel.fromJson(element))
            .toList();
        emit(state.copyWith(status: Status.success, contracts: contracts));
      } else {
        emit(state.copyWith(
          status: Status.error,
          errorMessage: data["message"].toString(),
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> createContract(CreateContractEvent event, Emitter<ContractState> emit) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      final data = await _repo.createContract(data: event.data);
      if (data["status"] == true) {
        emit(state.copyWith(statusAction: Status.success));
      } else {
        emit(state.copyWith(
          statusAction: Status.error,
          errorMessage: data['error']?["message"].toString(),
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> updateContract(UpdateContractEvent event, Emitter<ContractState> emit) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      final data = await _repo.updateContract(data: event.data, id: event.id);

      if (data["status"] == true) {
        emit(state.copyWith(statusAction: Status.success));
      } else {
        emit(state.copyWith(
          statusAction: Status.error,
          errorMessage: data["message"].toString(),
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> deleteContract(DeleteContractEvent event, Emitter<ContractState> emit) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      final data = await _repo.deleteContract(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAction: Status.success));
      } else {
        emit(state.copyWith(
          statusAction: Status.error,
          errorMessage: data["message"].toString(),
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> forceDeleteContract(
      ForceDeleteContractEvent event, Emitter<ContractState> emit) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      final data = await _repo.forceDeleteContract(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAction: Status.success));
      } else {
        emit(state.copyWith(
          statusAction: Status.error,
          errorMessage: data["message"].toString(),
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> restoreContract(RestoreContractEvent event, Emitter<ContractState> emit) async {
    emit(state.copyWith(statusAction: Status.loading));
    try {
      final data = await _repo.restoreContract(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAction: Status.success));
      } else {
        emit(state.copyWith(
          statusAction: Status.error,
          errorMessage: data["message"].toString(),
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAction: Status.error, errorMessage: e.toString()));
    }
  }
}