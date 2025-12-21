import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/currency/currency_model.dart';
import 'package:hisobchi/infrastructure/dto/models/currency/exchange_rate_model.dart';
import 'package:hisobchi/infrastructure/repository/currency/currency_repository.dart';

part 'currency_event.dart';

part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final _repo = CurrencyRepository();

  CurrencyBloc() : super(CurrencyState()) {
    on<GetCurrency>(getCurrency);
    on<GetExchangeRates>(getExchangeRates);
    on<RefreshExchangeRates>(refreshExchangeRates);
    on<GetExchangeRatesByDate>(getExchangeRatesByDate);
  }

  Future<void> getCurrency(GetCurrency event, Emitter<CurrencyState> emit) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final data = await _repo.getCurrency();

      if (data["status"] == true) {
        final model = CurrencyModel.fromJson(data);
        emit(state.copyWith(status: Status.success, currencyModel: model));
      } else {
        emit(state.copyWith(status: Status.error, errorMessage: data["message"].toString()));
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  /// Get exchange rates with professional error handling
  Future<void> getExchangeRates(GetExchangeRates event, Emitter<CurrencyState> emit) async {
    emit(state.copyWith(exchangeRatesStatus: Status.loading));
    try {
      final data = await _repo.getExchangeRates();

      if (data["status"] == true) {
        final model = ExchangeRateModel.fromJson(data);
        emit(state.copyWith(
          exchangeRatesStatus: Status.success,
          exchangeRateModel: model,
          lastUpdated: DateTime.now(),
        ));
      } else {
        emit(state.copyWith(
          exchangeRatesStatus: Status.error,
          errorMessage: data["message"]?.toString() ?? 'Xatolik yuz berdi',
        ));
      }
    } on DioException catch (e) {
      String errorMessage = 'Internet bilan bog\'lanishda xatolik';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Serverga ulanish vaqti tugadi';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Ma\'lumot olish vaqti tugadi';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Ma\'lumot topilmadi';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server xatosi';
      }
      emit(state.copyWith(
        exchangeRatesStatus: Status.error,
        errorMessage: errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        exchangeRatesStatus: Status.error,
        errorMessage: 'Kutilmagan xatolik: ${e.toString()}',
      ));
    }
  }

  /// Refresh exchange rates (for pull-to-refresh)
  Future<void> refreshExchangeRates(RefreshExchangeRates event, Emitter<CurrencyState> emit) async {
    try {
      final data = await _repo.getExchangeRates();

      if (data["status"] == true) {
        final model = ExchangeRateModel.fromJson(data);
        emit(state.copyWith(
          exchangeRatesStatus: Status.success,
          exchangeRateModel: model,
          lastUpdated: DateTime.now(),
        ));
      } else {
        emit(state.copyWith(
          exchangeRatesStatus: Status.error,
          errorMessage: data["message"]?.toString() ?? 'Xatolik yuz berdi',
        ));
      }
    } catch (e) {
      // Don't change status on refresh error, keep previous data
      emit(state.copyWith(
        errorMessage: 'Yangilashda xatolik',
      ));
    }
  }

  /// Get exchange rates by date
  Future<void> getExchangeRatesByDate(GetExchangeRatesByDate event, Emitter<CurrencyState> emit) async {
    emit(state.copyWith(exchangeRatesStatus: Status.loading));
    try {
      final data = await _repo.getExchangeRatesByDate(event.date);

      if (data["status"] == true) {
        final model = ExchangeRateModel.fromJson(data);
        emit(state.copyWith(
          exchangeRatesStatus: Status.success,
          exchangeRateModel: model,
          lastUpdated: DateTime.now(),
        ));
      } else {
        emit(state.copyWith(
          exchangeRatesStatus: Status.error,
          errorMessage: data["message"]?.toString() ?? 'Xatolik yuz berdi',
        ));
      }
    } on DioException catch (e) {
      String errorMessage = 'Internet bilan bog\'lanishda xatolik';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Serverga ulanish vaqti tugadi';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Ma\'lumot olish vaqti tugadi';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Tanlangan sana uchun ma\'lumot topilmadi';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server xatosi';
      }
      emit(state.copyWith(
        exchangeRatesStatus: Status.error,
        errorMessage: errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        exchangeRatesStatus: Status.error,
        errorMessage: 'Kutilmagan xatolik: ${e.toString()}',
      ));
    }
  }
}
