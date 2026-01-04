import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/income_history_model.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/income_statement_model.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/infrastructure/repository/partner/partner_repository.dart';

part 'partner_event.dart';
part 'partner_state.dart';

class PartnerBloc extends Bloc<PartnerEvent, PartnerState> {
  final _repo = PartnerRepository();

  PartnerBloc() : super(PartnerState()) {
    on<GetAllEvent>(getAll);
    on<CreateEvent>(create);
    on<UpdateEvent>(update);
    on<DeleteEvent>(delete);
    on<RestoreEvent>(restore);
    on<ForceDeleteEvent>(forceDelete);
    on<IncomeStatementEvent>(getIncomeStatement);
    on<IncomeHistoryEvent>(getIncomeHistory);
    on<CreateKirim>(createKirim);
    on<UpdateKirim>(updateKirim);
    on<CancelIncome>(cancelIncome);
    on<DeleteIncome>(deleteIncome);
    on<ForceDeleteIncomeEvent>(forceDeleteIncome);
    on<RestoreIncomeEvent>(restoreIncome);
  }

  Future<void> getAll(GetAllEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(status: Status.loading, statusAdd: Status.pure));
    try {
      final data = await _repo.get(
        startDate: event.startDate,
        endDate: event.endDate,
        search: event.search,
        sort: event.sort,
        statusFilter: event.statusFilter,
      );

      if (data["status"] == true) {
        List<PartnerModel> model = [];
        model = data["result"].map<PartnerModel>((element) => PartnerModel.fromJson(element)).toList();
        emit(state.copyWith(status: Status.success, models: model));
      } else {
        emit(state.copyWith(status: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> getIncomeStatement(IncomeStatementEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusIncomeStatement: Status.loading,statusKirim: Status.pure));
    try {
      final data = await _repo.incomeStatement(id: event.id);

      if (data["status"] == true) {
        final model = IncomeStatementModel.fromJson(data);
        emit(state.copyWith(statusIncomeStatement: Status.success, incomeStatementModel: model));
      } else {
        emit(state.copyWith(statusIncomeStatement: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusIncomeStatement: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusIncomeStatement: Status.error, errorMessage: e.toString()));
    }
  }
  Future<void> getIncomeHistory(IncomeHistoryEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusIncomeHistory: Status.loading,statusKirimAdd: Status.pure));
    try {
      final data = await _repo.incomeHistory(
        id: event.id,
        search: event.search,
        startDate: event.startDate,
        endDate: event.endDate,
        type: event.type,
      );

      if (data["status"] == true) {
        final model = IncomeHistoryModel.fromJson(data);
        emit(state.copyWith(statusIncomeHistory: Status.success, incomeHistoryModel: model));
      } else {
        emit(state.copyWith(statusIncomeHistory: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusIncomeStatement: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusIncomeStatement: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> create(CreateEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.create(data: event.data);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data['error']?["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> update(UpdateEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.update(data: event.data,id: event.id);

      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> delete(DeleteEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.delete(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }
  Future<void> forceDelete(ForceDeleteEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.forceDelete(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }
  Future<void> restore(RestoreEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.restore(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: e.toString()));
    }
  }
  Future<void> createKirim(CreateKirim event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirim: Status.loading));
    try {
      final data = await _repo.createKirim(data: event.data);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirim: Status.success));
      } else {
        emit(state.copyWith(statusKirim: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusKirim: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusKirim: Status.error, errorMessage: e.toString()));
    }
  }
  Future<void> updateKirim(UpdateKirim event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirimAdd: Status.loading));
    try {
      final data = await _repo.updateKirim(data: event.data,id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirimAdd: Status.success));
      } else {
        emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: e.toString()));
    }
  }
  Future<void> deleteIncome(DeleteIncome event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirimAdd: Status.loading));
    try {
      final data = await _repo.deleteIncome(walletId: event.walletId);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirimAdd: Status.success));
      } else {
        emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: e.toString()));
    }
  }
  Future<void> forceDeleteIncome(ForceDeleteIncomeEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirimAdd: Status.loading));
    try {
      final data = await _repo.forceDeleteIncome(walletId: event.walletId);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirimAdd: Status.success));
      } else {
        emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: e.toString()));
    }
  }
  Future<void> restoreIncome(RestoreIncomeEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirimAdd: Status.loading));
    try {
      final data = await _repo.restoreIncome(walletId: event.walletId);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirimAdd: Status.success));
      } else {
        emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: e.toString()));
    }
  }
  Future<void> cancelIncome(CancelIncome event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirimAdd: Status.loading));
    try {
      final data = await _repo.cancelIncome(walletId: event.walletId,description: event.description);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirimAdd: Status.success));
      } else {
        emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: e.toString()));
    }
  }

}
