part of 'currency_bloc.dart';

sealed class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object?> get props => [];
}

class GetCurrency extends CurrencyEvent {
  const GetCurrency();
}

class GetExchangeRates extends CurrencyEvent {
  const GetExchangeRates();
}

class RefreshExchangeRates extends CurrencyEvent {
  const RefreshExchangeRates();
}

