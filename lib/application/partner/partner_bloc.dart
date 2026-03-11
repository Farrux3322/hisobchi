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
    on<LoadMorePartnersEvent>(loadMore);
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
    on<GetSmsSettingsEvent>(getSmsSettings);
    on<UpdateSmsSettingsEvent>(updateSmsSettings);
    on<UpdateSmsSettingsLocalEvent>(updateSmsSettingsLocal);
  }

  Future<void> getAll(GetAllEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(
      status: Status.loading,
      statusAdd: Status.pure,
      statusLoadMore: Status.pure,
      currentPage: 1,
      hasReachedMax: false,
      models: [],
    ));
    try {
      final data = await _repo.get(
        startDate: event.startDate,
        endDate: event.endDate,
        search: event.search,
        sort: event.sort,
        statusFilter: event.statusFilter,
        page: 1,
      );

      if (data["status"] == true) {
        final result = data["result"];
        final List<dynamic> dataList = result["data"] ?? [];
        final List<PartnerModel> models = dataList.map((element) => PartnerModel.fromJson(element)).toList();
        
        final meta = result["meta"];
        final links = result["links"];
        final int lastPage = meta?["last_page"] ?? 1;
        final int currentPage = meta?["current_page"] ?? 1;

        bool hasReachedMax = false;
        if (links != null && links.containsKey('next')) {
          hasReachedMax = links['next'] == null;
        } else if (meta != null && meta.containsKey('last_page')) {
          hasReachedMax = currentPage >= lastPage;
        } else {
          // If no links and no meta[last_page], we can't be sure, 
          // but let's assume if we got less than per_page items we're at the end.
          // However, user said specifically to follow 'next' link.
          hasReachedMax = false; 
        }

        emit(state.copyWith(
          status: Status.success,
          models: models,
          currentPage: currentPage,
          lastPage: lastPage,
          hasReachedMax: hasReachedMax,
        ));
      } else {
        emit(state.copyWith(status: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> loadMore(LoadMorePartnersEvent event, Emitter<PartnerState> emit) async {
    if (state.hasReachedMax || state.statusLoadMore == Status.loading) return;

    emit(state.copyWith(statusLoadMore: Status.loading));

    try {
      final int nextPage = state.currentPage + 1;
      final data = await _repo.get(
        startDate: event.startDate,
        endDate: event.endDate,
        search: event.search,
        sort: event.sort,
        statusFilter: event.statusFilter,
        page: nextPage,
      );

      if (data["status"] == true) {
        final result = data["result"];
        final List<dynamic> dataList = result["data"] ?? [];
        final List<PartnerModel> newModels = dataList.map((element) => PartnerModel.fromJson(element)).toList();
        
        final meta = result["meta"];
        final links = result["links"];
        final int lastPage = meta?["last_page"] ?? 1;
        final int currentPage = meta?["current_page"] ?? nextPage;

        bool hasReachedMax = false;
        if (links != null && links.containsKey('next')) {
          hasReachedMax = links['next'] == null;
        } else if (meta != null && meta.containsKey('last_page')) {
          hasReachedMax = currentPage >= lastPage;
        }

        emit(state.copyWith(
          status: Status.success,
          statusLoadMore: Status.success,
          models: List.of(state.models)..addAll(newModels),
          currentPage: currentPage,
          lastPage: lastPage,
          hasReachedMax: hasReachedMax,
        ));
      } else {
        emit(state.copyWith(statusLoadMore: Status.error));
      }
    } catch (_) {
      emit(state.copyWith(statusLoadMore: Status.error));
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
      final data = await _repo.incomeHistory(
        id: event.id,
        search: event.search,
        startDate: event.startDate,
        endDate: event.endDate,
        type: event.type,
        isCancelled: event.isCancelled,
        currencyId: event.currencyId,
      );

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
        final model = PartnerModel.fromJson(data["result"]);
        emit(state.copyWith(statusAdd: Status.success, lastCreatedPartner: model));
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

  Future<void> getSmsSettings(GetSmsSettingsEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusGetSmsSettings: Status.loading, statusUpdateSmsSettings: Status.pure, smsSettingsMap: {})); // Use empty map as sentinel or I should fix copyWith
    try {
      final data = await _repo.getSmsSettings(id: event.id);
      if (data["status"] == true) {
        emit(state.copyWith(statusGetSmsSettings: Status.success, smsSettingsMap: data["result"]));
      } else {
        emit(state.copyWith(statusGetSmsSettings: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusGetSmsSettings: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> updateSmsSettings(UpdateSmsSettingsEvent event, Emitter<PartnerState> emit) async {
    emit(state.copyWith(statusUpdateSmsSettings: Status.loading));
    try {
      final data = await _repo.updateSmsSettings(id: event.id, data: event.data);
      if (data["status"] == true) {
        emit(state.copyWith(statusUpdateSmsSettings: Status.success, smsSettingsMap: null)); // Explicitly set map to null to trigger navigation
      } else {
        emit(state.copyWith(statusUpdateSmsSettings: Status.error, errorMessage: _extractMessageFromData(data)));
      }
    } catch (e) {
      emit(state.copyWith(statusUpdateSmsSettings: Status.error, errorMessage: _getErrorMessage(e)));
    }
  }

  Future<void> updateSmsSettingsLocal(UpdateSmsSettingsLocalEvent event, Emitter<PartnerState> emit) async {
    final currentMap = Map<String, dynamic>.from(state.smsSettingsMap ?? {});
    final currentBody = Map<String, dynamic>.from(currentMap['body'] ?? {});
    currentBody.addAll(event.data);
    currentMap['body'] = currentBody;
    emit(state.copyWith(smsSettingsMap: currentMap));
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
