import 'dart:convert';
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
      final data = await _repo.get(startDate: event.startDate, endDate: event.endDate, search: event.search, sort: event.sort, statusFilter: event.statusFilter);

      if (data["status"] == true) {
        List<PartnerModel> model = [];
        model = data["result"].map<PartnerModel>((element) => PartnerModel.fromJson(element)).toList();
        emit(state.copyWith(status: Status.success, models: model));
      } else {
        emit(state.copyWith(status: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> getIncomeStatement(IncomeStatementEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusIncomeStatement: Status.loading, statusKirim: Status.pure, statusAdd: Status.initial));
    try {
      final data = await _repo.incomeStatement(id: event.id);

      if (data["status"] == true) {
        final model = IncomeStatementModel.fromJson(data);
        emit(state.copyWith(statusIncomeStatement: Status.success, incomeStatementModel: model));
      } else {
        emit(state.copyWith(statusIncomeStatement: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusIncomeStatement: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> getIncomeHistory(IncomeHistoryEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusIncomeHistory: Status.loading, statusKirimAdd: Status.pure));
    try {
      final data = await _repo.incomeHistory(id: event.id, search: event.search, startDate: event.startDate, endDate: event.endDate, type: event.type);

      if (data["status"] == true) {
        final model = IncomeHistoryModel.fromJson(data);
        emit(state.copyWith(statusIncomeHistory: Status.success, incomeHistoryModel: model));
      } else {
        emit(state.copyWith(statusIncomeHistory: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusIncomeHistory: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> create(CreateEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.create(data: event.data);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> update(UpdateEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.update(data: event.data, id: event.id);

      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> delete(DeleteEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.delete(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> forceDelete(ForceDeleteEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.forceDelete(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> restore(RestoreEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusAdd: Status.loading));
    try {
      final data = await _repo.restore(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusAdd: Status.success));
      } else {
        emit(state.copyWith(statusAdd: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusAdd: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> createKirim(CreateKirim event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirim: Status.loading));
    try {
      final data = await _repo.createKirim(data: event.data);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirim: Status.success));
      } else {
        emit(state.copyWith(statusKirim: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusKirim: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> updateKirim(UpdateKirim event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirimAdd: Status.loading));
    try {
      final data = await _repo.updateKirim(data: event.data, id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirimAdd: Status.success));
      } else {
        emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> deleteIncome(DeleteIncome event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirimAdd: Status.loading));
    try {
      final data = await _repo.deleteIncome(walletId: event.walletId);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirimAdd: Status.success));
      } else {
        emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> forceDeleteIncome(ForceDeleteIncomeEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirimAdd: Status.loading));
    try {
      final data = await _repo.forceDeleteIncome(walletId: event.walletId);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirimAdd: Status.success));
      } else {
        emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> restoreIncome(RestoreIncomeEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirimAdd: Status.loading));
    try {
      final data = await _repo.restoreIncome(walletId: event.walletId);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirimAdd: Status.success));
      } else {
        emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> cancelIncome(CancelIncome event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusKirimAdd: Status.loading));
    try {
      final data = await _repo.cancelIncome(walletId: event.walletId, description: event.description);
      if (data["status"] == true) {
        emit(state.copyWith(statusKirimAdd: Status.success));
      } else {
        emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusKirimAdd: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  /// Extracts error message from DioException and stringifies validation errors
  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      final response = e.response;
      if (response != null && response.data != null) {
        final dynamic data = response.data;

        // If it's already a JSON string that contains 'errors', return as is
        if (data is String && data.contains('"errors"')) {
          return data;
        }

        // If it's a Map, use the helper to extract/encode
        if (data is Map<String, dynamic>) {
          return _extractMessageFromData(data);
        }

        // Fallback for other status 422 cases if data is somehow a Map but not caught
        if (response.statusCode == 422) {
          try {
            return jsonEncode(data);
          } catch (_) {}
        }

        return _extractMessageFromData(data);
      }
      return e.message ?? e.toString();
    }
    return e.toString();
  }

  /// Helper to extract message from response data Map
  /// Senior level: prioritize 'errors' for UI parsing
  String _extractMessageFromData(dynamic data) {
    if (data is Map<String, dynamic>) {
      // 1. Check for Laravel style "errors" map
      if (data.containsKey('errors') && data['errors'] != null) {
        final errors = data['errors'];
        // Only return JSON if errors actually have content
        if (errors is Map && errors.isNotEmpty) {
          return jsonEncode(data);
        }
      }

      // 2. Check for nested "error" object with "errors"
      if (data.containsKey('error') && data['error'] is Map) {
        final errorObj = data['error'] as Map<String, dynamic>;
        if (errorObj.containsKey('errors') && errorObj['errors'] != null) {
          return jsonEncode(errorObj);
        }
        if (errorObj.containsKey('message')) {
          return errorObj['message'].toString();
        }
      }

      // 3. Fallback to top-level "message"
      if (data.containsKey('message')) {
        return data['message'].toString();
      }

      // 4. Last resort: just encode the whole map
      return jsonEncode(data);
    }

    // If it's a string, try to see if it's JSON
    if (data is String) {
      if (data.startsWith('{') && data.contains('"errors"')) {
        return data;
      }
      return data;
    }

    return data.toString();
  }
}
