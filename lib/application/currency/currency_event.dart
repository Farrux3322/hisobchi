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

class GetExchangeRatesByDate extends CurrencyEvent {
  final String date; // Format: yyyy-MM-dd (e.g., 2025-12-22)

  const GetExchangeRatesByDate({required this.date});

  @override
  List<Object?> get props => [date];
}

