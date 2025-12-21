part of 'currency_bloc.dart';

class CurrencyState extends Equatable {
  final Status status;
  final Status exchangeRatesStatus;
  final String? errorMessage;
  final CurrencyModel? currencyModel;
  final ExchangeRateModel? exchangeRateModel;
  final DateTime? lastUpdated;

  const CurrencyState({
    this.status = Status.pure,
    this.exchangeRatesStatus = Status.pure,
    this.errorMessage,
    this.currencyModel,
    this.exchangeRateModel,
    this.lastUpdated,
  });

  CurrencyState copyWith({
    Status? status,
    Status? exchangeRatesStatus,
    String? errorMessage,
    CurrencyModel? currencyModel,
    ExchangeRateModel? exchangeRateModel,
    DateTime? lastUpdated,
  }) {
    return CurrencyState(
      status: status ?? this.status,
      exchangeRatesStatus: exchangeRatesStatus ?? this.exchangeRatesStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      currencyModel: currencyModel ?? this.currencyModel,
      exchangeRateModel: exchangeRateModel ?? this.exchangeRateModel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exchangeRatesStatus,
        currencyModel,
        exchangeRateModel,
        errorMessage,
        lastUpdated,
      ];
}
