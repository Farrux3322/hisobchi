import 'package:equatable/equatable.dart';

abstract class WarrantyPeriodDetailsEvent extends Equatable {
  const WarrantyPeriodDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadWarrantyPeriodDetailsEvent extends WarrantyPeriodDetailsEvent {
  final String type;
  final int currencyTypeId;

  const LoadWarrantyPeriodDetailsEvent({
    required this.type,
    required this.currencyTypeId,
  });

  @override
  List<Object?> get props => [type, currencyTypeId];
}

class LoadMoreWarrantyPeriodDetailsEvent extends WarrantyPeriodDetailsEvent {}
